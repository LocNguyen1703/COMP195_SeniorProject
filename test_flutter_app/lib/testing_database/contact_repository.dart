import 'package:test_flutter_app/testing_database/contact.dart';
import 'package:sqflite/sqflite.dart';

class ContactRepository {

  static Future<Database> _getDatabase() async {
    final database = await openDatabase(
      'contact_manager.db',
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS contacts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL,
            phone TEXT NOT NULL,
            address TEXT NOT NULL
          )
        ''');

      await db.insert('contacts',
        {'name': "John Smith", 'email': "john@gmail.com", 'phone': "1234567890", 'address': "123 Main St"});

      await db.insert('contacts',
        {'name': "Bob Smith", 'email': "bob@gmail.com", 'phone': "0987654321", 'address': "456 Main St"});
      },
    );

    return database;
  }

  static Future<List<Contact>> getContacts() async {
    final db = await _getDatabase(); 
    final result = await db.query('contacts'); 
    return result.map((json) => Contact.fromMap(json)).toList();
  }

  static Future<int> addContact(Contact contact) async {
    final db = await _getDatabase();
    return await db.insert('contacts', contact.toMap());
  }

  static Future<int> updateContact(Contact contact) async {
    final db = await _getDatabase();
    return await db.update(
      'contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  static Future<int> deleteContact(int id) async {
    final db = await _getDatabase(); 
    return await db.delete('contacts', where: 'id = ?', whereArgs: [id]);
  }

}