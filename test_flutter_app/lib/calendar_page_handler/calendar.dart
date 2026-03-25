import 'package:flutter/material.dart';

class Calendar {
  int? calendarId; 
  String name;
  Color color; 

  Calendar({
    this.calendarId,
    required this.name, 
    required this.color, 
  });

  Map<String, dynamic> toMap() => {
    if (calendarId != null) 'calendarId': calendarId,
    'name': name,
    'color': color.toARGB32(),
  };

  factory Calendar.fromMap(Map<String, dynamic> map) => Calendar(
    calendarId: map['calendarId'],
    name: map['name'],
    color: Color.fromARGB(
      (map['color'] as int) >> 24 & 0xFF, 
      (map['color'] as int) >> 16 & 0xFF, 
      (map['color'] as int) >> 8 & 0xFF, 
      (map['color'] as int) & 0xFF,
    ),
  );
}