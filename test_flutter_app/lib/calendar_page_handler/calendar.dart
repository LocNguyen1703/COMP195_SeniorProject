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
    'color': color,
  };

  factory Calendar.fromMap(Map<String, dynamic> map) => Calendar(
    calendarId: map['calendarId'],
    name: map['name'],
    color: Color(map['color']),
  );
}