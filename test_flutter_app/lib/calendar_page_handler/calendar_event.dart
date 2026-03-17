import 'package:flutter/material.dart';

class CalendarEvent {
  int? id;
  String title;
  String description;
  DateTime start;
  DateTime end;
  Color color;
  int calendarId;
  String? recurrenceRule; // Optional field for recurring events

  CalendarEvent({
    this.recurrenceRule, 
    this.id,
    required this.title, 
    required this.description,
    required this.start,
    required this.end,
    required this.color,
    required this.calendarId,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,      // omit id on insert so AUTOINCREMENT works
    'calendarId': calendarId,
    'title': title,
    'description': description,
    'start': start.millisecondsSinceEpoch,
    'end': end.millisecondsSinceEpoch,
    'color': color,
    'recurrenceRule': recurrenceRule,
  };

  factory CalendarEvent.fromMap(Map<String, dynamic> map) => CalendarEvent(
    id: map['id'],
    calendarId: map['calendarId'],
    title: map['title'],
    description: map['description'] ?? '',
    start: DateTime.fromMillisecondsSinceEpoch(map['start']),
    end: DateTime.fromMillisecondsSinceEpoch(map['end']),
    color: Color(map['color']),
    recurrenceRule: map['recurrenceRule'],
  );

}