import 'package:flutter/material.dart';
import 'package:test_flutter_app/ai_chat_handler/conversation.dart';
import 'package:test_flutter_app/ai_chat_handler/message.dart';
import 'package:test_flutter_app/ai_chat_handler/message_database.dart';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => AIChatPageState();
}

class AIChatPageState extends State<AIChatPage> {
  List<Message> messages = []; // this will hold the chat messages
  List<Conversation> conversations = []; // this will hold the list of conversations (for the sidebar)

  Future<void> loadMessages() async {
    final messages = await MessageDatabase.getAllMessages();
    setState(() {
      this.messages = messages; 
    });
  }

  Future<void> loadConversations() async {
    final conversations = await MessageDatabase.getConversations();
    setState(() {
      this.conversations = conversations; 
    });
  }

  @override
  void initState() {
    super.initState();
    loadMessages(); 
    loadConversations();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              return Align(
                alignment: messages[index].isUser ? Alignment.topRight : Alignment.topLeft, // Aligns messages to the left
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(messages[index].text),
                ),
              );
            },
          )
        ),
        
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Ask [app_name] anything...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  
                },
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      
      
      ],
    );

    // return Stack(
    //   children: [
        
    //   ],
    // );
  }
}