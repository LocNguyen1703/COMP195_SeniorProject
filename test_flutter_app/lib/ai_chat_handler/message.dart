class Message {
  //define attributes of the Message class
  int? id; // id is not required (marked by the "?") - it's nullable because it will be auto-incremented by the database
  String text;
  String title; // all these attributes are required (no "?") - cannot be null
  DateTime timestamp; 
  bool isUser; // to differentiate between user messages and AI messages (true for user messages, false for AI messages)
  int conversationId;

  //constructor for the Message class 
  Message({
    this.id,
    required this.title,
    required this.text,
    required this.timestamp,
    required this.isUser,
    required this.conversationId,
  });

  //function to convert a Message object to a Map (for database storage) 
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'title': title,
      'timestamp': timestamp,
      'isUser': isUser ? 1 : 0, // store as 1 for true and 0 for false in the database  
      'conversation_id': conversationId,
    };
  }

  //function to convert a Map to a Message object (for retrieving from the database)
  static Message fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      text: map['text'],
      title: map['title'],
      timestamp: DateTime.parse(map['created_at']),
      isUser: map['isUser'] == 1, // convert back to bool (true if 1, false if 0)
      conversationId: map['conversation_id'],
    );
  }

  

}