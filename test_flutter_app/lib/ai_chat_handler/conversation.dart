class Conversation {
  //define attributes of the Conversation class
  int? id; // id is not required (marked by the "?") - it's nullable because it will be auto-incremented by the database
  String title; // all these attributes are required (no "?") - cannot be null
  DateTime timestamp; 

  //constructor for the Conversation class 
  Conversation({
    this.id,
    required this.title,
    required this.timestamp,
  });

  //function to convert a Conversation object to a Map (for database storage) 
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'timestamp': timestamp,
    };
  }

  //function to convert a Map to a Conversation object (for retrieving from the database)
  static Conversation fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'],
      title: map['title'],
      timestamp: DateTime.parse(map['created_at']),
    );
  }

  

}