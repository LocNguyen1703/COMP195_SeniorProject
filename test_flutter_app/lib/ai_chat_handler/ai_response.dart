import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AIqueryHandler {
  String? response;

  AIqueryHandler();

  Future<void> streamAIResponse({
    required List<Map<String, String>> messageHistory,
    required void Function(String token) onToken, 
    required void Function() onDone
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

    try {
      final request = http.Request(
        'POST',
        Uri.parse('http://10.0.2.2:11434/api/chat'));

        request.headers['Content-Type'] = 'application/json'; // set the content type to JSON

        request.body = jsonEncode({
          'model': 'llama3', // specify the model you want to use
          'messages': messageHistory, // this should be a list of messages, including the message history and the new query
          'stream': true, // set to true to receive the response in a streaming manner
        }); // encode the data as JSON

      final streamedResponse = await request.send(); // send the HTTP POST request to the Ollama API and get the streamed response

      streamedResponse.stream
        .transform(utf8.decoder) // decode the streamed response from UTF-8
        .transform(const LineSplitter()) // split the response into lines
        .listen((line){
          if (line.isEmpty) return; // skip empty lines

          final decoded = jsonDecode(line);

          if (decoded['done'] == true) {
            onDone(); 
            return;
          }

          final content = decoded['message']?['content']; // extract the content of the message from the decoded response
          if (content != null) {
            onToken(content); // call the onToken callback with the content of the message
          }
        });

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