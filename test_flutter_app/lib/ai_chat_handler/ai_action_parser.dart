import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:test_flutter_app/to_do_list_handler/todo_database.dart';
import 'package:test_flutter_app/to_do_list_handler/todo_item.dart';
import 'package:test_flutter_app/to_do_list_handler/todo_list.dart';
import 'package:test_flutter_app/calendar_page_handler/calendar_database.dart';
import 'package:test_flutter_app/calendar_page_handler/calendar_event.dart';

class AIActionParser {
    static String fixJson(String input) {
      final withoutLineComments = input.replaceAll(RegExp(r'//[^\n]*'), '');
      String result =  withoutLineComments
          .replaceAll(RegExp(r',\s*}'), '}')
          .replaceAll(RegExp(r',\s*]'), ']')
          .replaceAllMapped(RegExp(r'(?<!")(\b\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\b)(?!")'), 
            (m) => '"${m[0]}"')
        // replace Colors.blue → "blue"
          .replaceAllMapped(RegExp(r'Colors\s*\.\s*(\w+)'), (m) => '"${m[1]}"')
        // convert {item1, item2} → [item1, item2]
          .replaceAllMapped(RegExp(r'items"\s*:\s*{([^}]*)}'), (m) {
          return '"items": [${m[1]}]';
        });  
      return balanceBrackets(result);
  }

    static String balanceBrackets(String input) {
      int braces = 0;
      int brackets = 0;
      bool inString = false;
      
      for (int i = 0; i < input.length; i++) {
        final c = input[i];
        if (c == '"' && (i == 0 || input[i - 1] != '\\')) inString = !inString;
        if (inString) continue;
        if (c == '{') braces++;
        if (c == '}') braces--;
        if (c == '[') brackets++;
        if (c == ']') brackets--;
      }

      // append however many closing characters are missing
      final buffer = StringBuffer(input.trimRight());
      for (int i = 0; i < brackets; i++) {buffer.write(']');}
      for (int i = 0; i < braces; i++) {buffer.write('}');}
      
      return buffer.toString();
  }

  static ({String cleanText, Map<String, dynamic>? action}) parse(String response) {
    final regex = RegExp(
      r'<\s*[A-Z_]+\s*>\s*(\{.*?\})\s*</\s*[A-Z_]+\s*>', 
      dotAll: true,
      caseSensitive: false,);
    var match = regex.firstMatch(response);

    // fallback check catches case where model starts a JSON tag but never closes it
    match ??= RegExp(r'<[A-Z_]+>\s*(\{.*?)$', dotAll: true).firstMatch(response); 

    if (match == null) return (cleanText: response, action: null); 
  
    final jsonStr = match.group(1)!.trim(); 
    final cleanText = (response.substring(0, match.start) + 
      (match.end < response.length ? response.substring(match.end) : ''))
      .trim();

    debugPrint("RAW JSON:\n$jsonStr");

    final fixed = fixJson(jsonStr);

    debugPrint("FIXED JSON:\n$fixed");

    try {
      final fixed = fixJson(jsonStr);
      final action = jsonDecode(fixed) as Map<String, dynamic>;
      return (cleanText: cleanText, action: action);
    } catch (e) {
      debugPrint('FAILED JSON:\n$fixed');
      debugPrint('Error parsing action JSON: $e');
      return (cleanText: response, action: null);
    }
  }

  static Future<String?> execute(Map<String, dynamic> action) async {
    final type = action['action'] as String?; 
    final payload = action['payload'] as Map<String, dynamic>? ?? {};

    switch(type) {
      case 'create_todo_list': 
        final listTitle = payload['title'] as String?; 
        if (listTitle == null || listTitle.isEmpty) {
          debugPrint('Missing or empty title for create_todo_list action: $payload');
          return null; 
        }

        final list = TodoList(
          title: listTitle as String? ?? 'Untitled List',
          category: payload['category'] as String? ?? 'General',
          description: payload['description'] as String? ?? '',
          createdAt: DateTime.now(),
          color: Colors.blue,
        );

        final listId = await TodoDatabase.addTodoList(list);

        final items = (payload['items'] as List<dynamic>?) ?? [];
        for (final item in items) {
          await TodoDatabase.addTodoItem(TodoItem(
            listId: listId,
            description: item.toString(),
            createdAt: DateTime.now(),
            priority: (payload['priority'] as int?) ?? 2,
            isDone: false,
          ));
        }
        return 'todo_list added';

      case 'create_todo_item':
        final lists = await TodoDatabase.getAllTodoLists();
        final match = lists.where((l) =>
          l.title.toLowerCase() == (payload['listTitle'] ?? '').toLowerCase()).firstOrNull;

        if (match == null) return null;

        // Resolve items from whichever field the model used:
        // "descriptions" (correct), "items" (model drift), or "description" (singular fallback)
        final List<String> descriptions;
        final raw = payload['descriptions'] ?? payload['items'];
        if (raw is List) {
          descriptions = raw.map((e) => e.toString()).toList();
        } else {
          final single = (payload['description'] as String? ?? '').trim();
          descriptions = single.isNotEmpty ? [single] : [];
        }

        if (descriptions.isEmpty) return null;

        for (final desc in descriptions) {
          await TodoDatabase.addTodoItem(TodoItem(
            listId: match.id!,
            description: desc,
            createdAt: DateTime.now(),
            priority: (payload['priority'] as int?) ?? 2,
            isDone: false,
          ));
        }
        return 'todo_list item added';

      case 'create_calendar_event':
        final title = payload['title'] as String?;
        final startStr = payload['start'] as String?;
        final endStr = payload['end'] as String?;

        if (title == null || title.isEmpty || startStr == null || endStr == null) {
          debugPrint('Missing required fields in payload: $payload');
          return null;
        }
      
        DateTime start, end;
        try {
          start = DateTime.parse(startStr);
          end = DateTime.parse(endStr);
        } catch (e) {
          debugPrint('Invalid date format in payload: $e');
          return null;
        }

        // sanity check: reject events more than 2 years in the past
        if (start.year < DateTime.now().year - 1) {
          debugPrint('Suspiciously old date rejected: $startStr');
          return null;
        }

        final allCalendars = await CalendarDatabase.getAllCalendars();
        if (allCalendars.isEmpty) {
          debugPrint('No calendars found, cannot create event');
          return null; 
        }
        // match by name, fall back to first calendar
        final calendarName = (payload['calendarName'] as String? ?? '').toLowerCase();
        final targetCalendar = allCalendars.firstWhere(
          (c) => c.name.toLowerCase() == calendarName,
          orElse: () => allCalendars.first,
        );
        final targetCalendarId = targetCalendar.calendarId!;

        final event = CalendarEvent(
          calendarId: targetCalendarId, //default calendarId to add events to for now...
          title: title,
          description: payload['description'] as String? ?? 'No description',
          start: start,
          end: end,  
          color: targetCalendar.color,
        ); 
        await CalendarDatabase.addEvent(event);
        return 'calendar event added'; 

      default: 
        debugPrint('Unknown action type: $type');
        return null;
    }
  }
}