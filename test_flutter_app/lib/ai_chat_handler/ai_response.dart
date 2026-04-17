import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AIqueryHandler {
  String? response;

  AIqueryHandler();

  Future<void> streamAIResponse({
    required List<Map<String, String>> messageHistory,
    required void Function(String token) onToken, 
    required Future<void> Function() onDone
  }) async {
    // Simulate a delay for fetching the AI query

    /* 
    problem: the Ollama API expects the messages to be in a specific format
      - a list of maps where each map represents a message with a "role" (either "user" or "system") and "content" (the text of the message).
    on the other hand - each Message object in my app has different attributes from that format (timestamp, isUser, and conversationId.)
    */
    // construct prompt message in JSON format - standard messaging convention for Ollama models
    // final Map<String, String>message = <String, String>{
    //   'role': query.isUser ? 'user' : 'system',
    //   'content': query.text,
    // }; 

    // convert the list of Message objects into the format expected by the Ollama API
    // this will get slower the longer the messageHistory becomes...
    // List<Map<String, String>> messageHistModified = [];
    // for (var message in messageHistory) {
    //   messageHistModified.add(<String, String>{
    //     'role': message.isUser ? 'user' : 'system', // determine the role based on the isUser attribute of the Message object
    //     'content': message.text, // use the text attribute of the Message object as the content of the message
    //   });
    // }


    // final Map<String, Object>data = <String, Object>{
    //   'model': 'llama3', // specify the model you want to use
    //   'messages': messageHistory, // this should be a list of messages, including the message history and the new query
    //   'stream': true, // set to true to receive the response in a streaming manner
    // };

    final now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day); // get today's date without the time component

    String nextWeekDay(DateTime from, int targetWeekday) {
      int daysUntil = (targetWeekday - from.weekday + 7) % 7;
      if (daysUntil == 0) daysUntil = 7; // if the target weekday is the same as the current weekday, we want the next one, which is 7 days away
      final next = from.add(Duration(days: daysUntil));
      return '${next.year}-${next.month.toString().padLeft(2,'0')}-${next.day.toString().padLeft(2,'0')}';
    }
    final nextMon = nextWeekDay(today, DateTime.monday); // calculate the date for "this coming Monday" based on today's date
    final nextTue = nextWeekDay(today, DateTime.tuesday); // calculate the date for "this coming Tuesday" based on today's date
    final nextWed = nextWeekDay(today, DateTime.wednesday); // calculate the date for "this coming Wednesday" based on today's date
    final nextThurs = nextWeekDay(today, DateTime.thursday); // calculate the date for "this coming Thursday" based on today's date
    final nextFri = nextWeekDay(today, DateTime.friday); // calculate the date for "this coming Friday" based on today's date
    final nextSat = nextWeekDay(today, DateTime.saturday); // calculate the date for "this coming Saturday" based on today's date
    final nextSun = nextWeekDay(today, DateTime.sunday); // calculate the date for "this coming Sunday" based on today's date 

    final String todayStr = '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
    final String dayOfWeek = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'][now.weekday - 1];

    final String systemPrompt = '''
    You are a helpful student assistant. When the user asks you to create a to-do list, 
    add a task, or schedule a calendar event, respond conversationally AND embed a 
    JSON action block at THE VERY END of your response, wrapped in <ACTION> tags following 
    this EXACT format (i.e. the EXACT field names, the EXACT number of curly brackets, etc.):

    <ACTION>
    {"action": "create_todo_list", 
    "payload": {
      "title": "...", 
      "category": '...',
      "description": '...',
      "createdAt": 2026-04-15T10:00:00,
      "color": Colors.blue,
      }
    }
    </ACTION>

    or

    <ACTION>
    {"action": "create_todo_item", 
    "payload": {
      "listId": "listId", 
      "description": "...",
      "createdAt": 2026-04-15T10:00:00,
      "priority": 2, 
      "isDone": false
      }
    }
    </ACTION>

    or

    <ACTION>
    {"action": "create_calendar_event",
    "payload": {
      "title": "Meeting",
      "start": "2026-04-15T10:00:00",
      "end": "2026-04-15T11:00:00",
      "description": "Discuss project"
      }
    }
    </ACTION>

    Only include an <ACTION> block when the user explicitly asks to create or schedule something.
    Today is $dayOfWeek, $todayStr.
    Upcoming dates for reference:
    - This coming Monday: $nextMon
    - This coming Tuesday: $nextTue
    - This coming Wednesday: $nextWed
    - This coming Thursday: $nextThurs
    - This coming Friday: $nextFri
    - this coming Saturday: $nextSat
    - this coming Sunday: $nextSun
    use these exact dates for reference. try your best to NOT calculate dates yourself, but if you have to
    use these as reference. 
    Always use the correct year (${ now.year}) in ISO 8601 dates.
    For all dates, use ISO 8601 format. If the user doesn't specify a time, default to 09:00.

    CRITICAL RULES - follow these exactly:
    1. NEVER create an <ACTION> block with guessed or assumed 
    information BEFORE confirming it with the user in natural language. Instead, ALWAYS confirm the 
    details in plain natural language. This is because once an ACTION block is created, the app 
    immediately tries to parse and execute the action specified in the block, and it CANNOT be undone.
    So if the ACTION block is wrong or contains assumptions that the user didn't explicitly confirm, 
    it will lead to unintended consequences in the user's calendar or to-do lists. 
    (e.g. "To confirm, you want to set a reminder for your Cybersecurity class for Monday April 13th from 3–4pm right?").
    2. NEVER include an <ACTION> block until you have ALL required fields confirmed by the user.
    3. For calendar events, you MUST have ALL of: title, exact start date+time, exact end date+time, 
    description. 
    4. For the end date+time, if the user doesn't give an exact value, by default it is the SAME date
    and ONE HOUR AFTER the start time, but you MUST confirm that assumption with the user in natural language 
    first. And NEVER confirm anything by giving the user an <ACTION> block.
    5. If ANY required field is missing or ambiguous (other than the end date+time), ask the user to 
    clarify FIRST. If you have to guess and fill in any missing information, ALWAYS ask the user to
    confirm it FIRST by providing your guesses in natural language. NEVER create an <ACTION> block 
    with guessed or assumed information and use that to confirm with the user. ONLY create the 
    <ACTION> block once you have received confirmation from the user through their natural language 
    response.
    6. Only AFTER the user has confirmed all details with the user response, respond with your confirmation 
    message AND the <ACTION> block.
    7. For dates, always compute from today ($todayStr). Never use a past year.
    
    Required fields per action:
    - create_todo_list: title (required), items (optional)
    - create_todo_item: listTitle (required), description (required)  
    - create_calendar_event: title (required), start (required, ISO 8601), end (required, ISO 8601), description (required)
      (try to discern or guess a logical description from the user's query if they don't provide one, 
      and if you cannot discern any description at all, use "No description provided." as the description value)

    If the user says "this coming Monday", calculate the actual date before proceeding.
    If the user says "later today", use $todayStr.
    ''';

    final List<Map<String, String>> fullHistory = [
      {'role': 'system', 'content': systemPrompt},
      ...messageHistory, // include the message history in the prompt
    ];

    try {
      final request = http.Request(
        'POST',
        Uri.parse('http://10.0.2.2:11434/api/chat'));
        request.headers['Content-Type'] = 'application/json'; // set the content type to JSON
        request.body = jsonEncode({
          'model': 'llama3', // specify the model you want to use
          'messages': fullHistory, // this should be a list of messages, including the system prompt, message history and the new query
          'stream': true, // set to true to receive the response in a streaming manner
        }); // encode the data as JSON

      final streamedResponse = await request.send(); // send the HTTP POST request to the Ollama API and get the streamed response
      final completer = Completer<void>(); // create a Completer to signal when the streaming is done

      streamedResponse.stream
        .transform(utf8.decoder) // decode the streamed response from UTF-8
        .transform(const LineSplitter()) // split the response into lines
        .listen((line) async {
          if (line.isEmpty) return; // skip empty lines

          final decoded = jsonDecode(line);

          if (decoded['done'] == true) {
            await onDone(); 
            if (!completer.isCompleted) completer.complete(); // complete the completer when the streaming is done
            return;
          }

          final content = decoded['message']?['content']; // extract the content of the message from the decoded response
          if (content != null) {
            onToken(content); // call the onToken callback with the content of the message
          }
        },
        onError: (e) {
          debugPrint('stream error: $e');
          if (!completer.isCompleted) completer.completeError(e); // complete the completer with an error if an error occurs during streaming
        },
        onDone: () {
          if (!completer.isCompleted) completer.complete(); // complete the completer when the streaming is done
        },
      );
      await completer.future; // wait for the streaming to be done before proceeding

  //     final response = http.post(
  //       Uri.parse('http://10.0.2.2:11434/api/chat'), // replace with your Ollama API endpoint
  //       headers: <String, String>{
  //         'Content-Type': 'application/json', // set the content type to JSON
  //       },
  //       body: jsonEncode(data), // encode the data as JSON
  //     ); // make the HTTP POST request to the Ollama API with the constructed data

  //     if (response.statusCode == 200) {
  //       final responseData = json.decode(response.body); // decode the response body from JSON
  //       print(responseData); // print the decoded response data for debugging purposes
  //       return responseData['message']['content']; // extract and return the AI's response from the decoded data

  //     }
    } catch (e) {
      // implement correct error-handling logic for HTTP requests here
      debugPrint('Error fetching AI query: $e'); // print any errors that occur during the HTTP request
    }
  //   return 'Error fetching AI query'; // return an error message if the request fails
  }
}