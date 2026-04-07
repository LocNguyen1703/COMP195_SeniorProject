  import 'package:flutter/material.dart';

  class TodoList {
    int? id;
    String title;
    String category; 
    String description;
    DateTime createdAt; 
    Color color;
    bool isCompleted;

    TodoList({
      this.id,
      required this.title,
      required this.category,
      required this.description,
      required this.createdAt,
      required this.color,     
      this.isCompleted = false,
    });

    TodoList copyWith({
      int? id,
      String? title,
      String? category,
      String? description,
      DateTime? createdAt,
      Color? color,
      bool? isCompleted,
    }) {
      return TodoList(
        id: id ?? this.id,
        title: title ?? this.title,
        category: category ?? this.category,
        description: description ?? this.description,
        createdAt: createdAt ?? this.createdAt,
        color: color ?? this.color,
        isCompleted: isCompleted ?? this.isCompleted,
      );
    }

    Map<String, dynamic> toMap() => {
      if (id != null) 'id': id,
      'title': title,
      'category': category,
      'description': description,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'color': color.toARGB32(),
      'isCompleted': isCompleted ? 1 : 0, // Store as integer for SQLite
    };

    factory TodoList.fromMap(Map<String, dynamic> map) => TodoList(
      id: map['id'],
      title: map['title'],
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      color: Color.fromARGB(
        (map['color'] as int) >> 24 & 0xFF, 
        (map['color'] as int) >> 16 & 0xFF, 
        (map['color'] as int) >> 8 & 0xFF, 
        (map['color'] as int) & 0xFF,
      ),
      isCompleted: (map['isCompleted'] as int) == 1, // Convert back to boolean
    );

  }