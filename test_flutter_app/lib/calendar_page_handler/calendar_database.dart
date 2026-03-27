import 'package:sqflite/sqflite.dart';
import 'package:test_flutter_app/calendar_page_handler/calendar_event.dart';
import 'package:test_flutter_app/calendar_page_handler/calendar.dart';
import 'package:flutter/material.dart';

class CalendarDatabase {

  static Future<Database> _getDatabase() async {
    final database = await openDatabase(
      'calendarEvents.db',
      version: 1, // bump this number up for database upgrades for future deployments
      onCreate: (Database db, int version) async {
        await db.execute('''
          DROP TABLE IF EXISTS calendars;
        ''');
        
        await db.execute('''
          DROP TABLE IF EXISTS events;
        ''');

        await db.execute('''
          CREATE TABLE calendars (
            calendarId INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            color INTEGER NOT NULL
          );
        ''');

        await db.execute('''
          CREATE TABLE events (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            start INTEGER NOT NULL,
            end INTEGER NOT NULL,
            color INTEGER NOT NULL,
            calendarId INTEGER NOT NULL,
            recurrenceRule TEXT,
              FOREIGN KEY (calendarId) REFERENCES calendars(calendarId) ON DELETE CASCADE
          );
        ''');

        await db.insert('calendars', {
          'name': 'Personal',
          'color': Colors.blue.toARGB32(),
        });

        await db.insert('calendars', {
          'name': 'Holidays',
          'color': Colors.green.toARGB32(),
        });
      },

      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < newVersion) {
          await db.execute('DROP TABLE IF EXISTS calendars;');
          await db.execute('DROP TABLE IF EXISTS events;');
          await _getDatabase(); // recreate the database with the new schema
          
          final existingCalendars = await db.query('calendars');
          if (existingCalendars.isEmpty) {
            await db.insert('calendars', {
              'name': 'Personal',
              'color': Colors.blue.toARGB32(),
            });

            await db.insert('calendars', {
              'name': 'Holidays',
              'color': Colors.green.toARGB32(),
            });
          }
        }
      },
    );

    return database;
  }

//--calendar CRUD
  static Future<List<Calendar>> getAllCalendars() async {
    final db = await _getDatabase(); 
    final result = await db.query('calendars'); 
    return result.map((json) => Calendar.fromMap(json)).toList();
  }

  static Future<List<Calendar>> getCalendar(int calendarId) async {
    final db = await _getDatabase(); 
    final result = await db.query(
      'calendars', 
      where: 'calendarId = ?', 
      whereArgs: [calendarId],
    ); 
    return result.map((json) => Calendar.fromMap(json)).toList();
  }

  static Future<int> addCalendar(Calendar calendar) async {
    final db = await _getDatabase(); 
    return await db.insert('calendars', calendar.toMap()); 
  }

  static Future<void> updateCalendar(Calendar calendar) async {
    final db = await _getDatabase();
    await db.update(
      'calendars', 
      calendar.toMap(), 
      where: 'calendarId = ?', 
      whereArgs: [calendar.calendarId],
    );
  }

  static Future<void> deleteCalendar(int calendarId) async {
    final db = await _getDatabase(); 
    await db.delete(
      'calendars', 
      where: 'calendarId = ?', 
      whereArgs: [calendarId],
    ); 
  }

//--event CRUD
  
  static Future<List<CalendarEvent>> getAllEvents() async {
    final db = await _getDatabase();
    final result = await db.query('events'); 
    return result.map((json) => CalendarEvent.fromMap(json)).toList();
  } 

  static Future<List<CalendarEvent>> getAllEventsForCalendar(int calendarId) async {
    final db = await _getDatabase(); 
    final result = await db.query(
      'events', 
      where: 'calendarId = ?', 
      whereArgs: [calendarId],
    ); 
    return result.map((json) => CalendarEvent.fromMap(json)).toList();
  }

  static Future<int> addEvent(CalendarEvent event) async {
    final db = await _getDatabase(); 
    return await db.insert('events', event.toMap()); 
  }

  static Future<void> updateEvent(CalendarEvent event) async {
    final db = await _getDatabase();
    await db.update(
      'events', 
      event.toMap(), 
      where: 'id = ?', 
      whereArgs: [event.id],
    );
  }

  static Future<void> deleteEvent(int eventId) async {
    final db = await _getDatabase(); 
    await db.delete(
      'events', 
      where: 'id = ?', 
      whereArgs: [eventId],
    ); 
  }
}