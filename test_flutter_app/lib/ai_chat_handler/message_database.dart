import 'package:test_flutter_app/ai_chat_handler/conversation.dart';
import 'package:test_flutter_app/ai_chat_handler/message.dart';
import 'package:sqflite/sqflite.dart';

class MessageDatabase {

  //  int? id; // id is not required (marked by the "?") - it's nullable because it will be auto-incremented by the database
  // String title; 
  // String text; // all these attributes are required (no "?") - cannot be null
  // String timestamp; 
  // bool isUser; 

  static Future<Database> _getDatabase() async {
    final messages = await openDatabase(
      'messageHistory.db',
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          DROP TABLE IF EXISTS conversations; 
        ''');
        
        await db.execute('''
          DROP TABLE IF EXISTS messages;
        ''');

        await db.execute('''
          CREATE TABLE conversations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            timestamp TEXT NOT NULL
          );
        ''');

        await db.execute('''
          CREATE TABLE messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            conversationId INTEGER,
            text TEXT NOT NULL,
            title TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            isUser INTEGER NOT NULL,
              FOREIGN KEY (conversationId) REFERENCES conversations(id)
          );
        ''');
      },
    );

    return messages;
  }

  static Future<List<Message>> getAllMessages() async {
    final db = await _getDatabase(); 
    final result = await db.query('messages'); 
    return result.map((json) => Message.fromMap(json)).toList();
  } 

  static Future<List<Message>> getMessage(int conversationId) async {
    if (conversationId == -1) {
      return []; // return an empty list if no conversation is selected
    }
    final db = await _getDatabase(); 
    final result = await db.query(
      'messages',
      where: 'conversationId = ?',
      whereArgs: [conversationId],
      ); 
    return result.map((json) => Message.fromMap(json)).toList();
  } 

  static Future<List<Conversation>> getConversations() async {
    final db = await _getDatabase(); 
    final result = await db.query('conversations'); 
    return result.map((json) => Conversation.fromMap(json)).toList();
  }

  static Future<int> addMessage(Message message) async {
    final db = await _getDatabase();
    return await db.insert('messages', message.toMap());
  }

  static Future<int> addConversation(Conversation conversation) async {
    final db = await _getDatabase();
    return await db.insert('conversations', conversation.toMap());
  }

  //not sure if we need this function - not sure if we need to update past messages in chat history
  static Future<int> updateMessage(Message message) async {
    final db = await _getDatabase();
    return await db.update(
      'messages',
      message.toMap(),
      where: 'id = ?',
      whereArgs: [message.id],
    );
  }

  static Future<int> deleteMessage(int id) async {
    final db = await _getDatabase(); 
    return await db.delete('messages', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> deleteConversation(int conversationId) async {
    final db = await _getDatabase(); 
    // First delete all messages associated with the conversation
    await db.delete('messages', where: 'conversationId = ?', whereArgs: [conversationId]);
    // Then delete the conversation itself
    return await db.delete('conversations', where: 'id = ?', whereArgs: [conversationId]);
  }
}