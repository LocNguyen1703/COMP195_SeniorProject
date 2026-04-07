import 'package:sqflite/sqflite.dart';
import 'package:test_flutter_app/to_do_list_handler/todo_item.dart';
import 'package:test_flutter_app/to_do_list_handler/todo_list.dart';
import 'package:flutter/material.dart';

class TodoDatabase {
  
    static Future<Database> _getDatabase() async {
      final database = await openDatabase(
        'todoLists.db',
        version: 1,
        
        onConfigure: (Database db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },

        onCreate: (Database db, int version) async {
          await db.execute('''
            CREATE TABLE todoLists (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              description TEXT NOT NULL,
              createdAt INTEGER NOT NULL,
              color INTEGER NOT NULL,
              category TEXT NOT NULL, 
              isCompleted INTEGER NOT NULL
            );
          ''');
  
          await db.execute('''
            CREATE TABLE todoItems (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              listId INTEGER NOT NULL,
              description TEXT NOT NULL,
              createdAt INTEGER NOT NULL,
              dueDate INTEGER,
              reminderTime INTEGER,
              priority INTEGER NOT NULL DEFAULT 2,
              isDone INTEGER NOT NULL,
                FOREIGN KEY (listId) REFERENCES todoLists(id) ON DELETE CASCADE
            );
          ''');

          await db.execute('''
            CREATE INDEX idx_todoItems_listId ON todoItems(listId);
          ''');

          await db.execute('''
            CREATE INDEX idx_todoItems_dueDate ON todoItems(dueDate);
          ''');
        },

        // onUpgrade: (Database db, int oldVersion, int newVersion) async {
        //   if (oldVersion < newVersion) {
        //     await db.execute('DROP TABLE IF EXISTS todoLists;');
        //     await db.execute('DROP TABLE IF EXISTS todoItems;');
        //   }
        // },
      );
  
      return database;
    }
    // TodoList CRUD operations
    static Future<List<TodoList>> getAllTodoLists() async {
      final db = await _getDatabase();
      final result = await db.query(
        'todoLists',
        orderBy: 'createdAt DESC'
        );
      return result.map((json) => TodoList.fromMap(json)).toList();
    }

    static Future<int> addTodoList(TodoList todoList) async {
      final db = await _getDatabase();
      return await db.insert(
        'todoLists', 
        todoList.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    static Future<void> updateTodoList(TodoList todoList) async {
      final db = await _getDatabase();
      await db.update(
        'todoLists',
        todoList.toMap(),
        where: 'id = ?',
        whereArgs: [todoList.id],
      );
    }

    static Future<void> deleteTodoList(int id) async {
      final db = await _getDatabase();
      await db.delete(
        'todoLists',
        where: 'id = ?',
        whereArgs: [id],
      );
    }

    // TodoItem CRUD operations

    static Future<List<TodoItem>> getAllTodoItems() async {
      final db = await _getDatabase();
      final result = await db.query(
        'todoItems',
        orderBy: 'priority ASC, dueDate ASC, createdAt DESC',
        );
      return result.map((json) => TodoItem.fromMap(json)).toList();
    }

    static Future<List<TodoItem>> getTodoItems(int listId) async {
      final db = await _getDatabase();
      final result = await db.query(
        'todoItems',
        where: 'listId = ?',
        whereArgs: [listId],
        orderBy: 'priority ASC, dueDate ASC, createdAt DESC'
      );
      return result.map((json) => TodoItem.fromMap(json)).toList();
    }

    static Future<int> addTodoItem(TodoItem todoItem) async {
      final db = await _getDatabase();
      return await db.insert(
        'todoItems', 
        todoItem.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore, 
      );
    }

    static Future<void> updateTodoItem(TodoItem todoItem) async {
      final db = await _getDatabase();
      await db.update(
        'todoItems',
        todoItem.toMap(),
        where: 'id = ?',
        whereArgs: [todoItem.id],
      );
    }

    static Future<void> deleteTodoItem(int id) async {
      final db = await _getDatabase();
      await db.delete(
        'todoItems',
        where: 'id = ?',
        whereArgs: [id],
      );
    }
}