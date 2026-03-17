import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:test_flutter_app/calendar_page_handler/calendar_event.dart';
import 'package:flutter/material.dart';

class EventDataSource extends CalendarDataSource {
  EventDataSource(List<CalendarEvent> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].start;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].end;
  }

  @override
  String getSubject(int index) {
    return appointments![index].title;
  }

  //can I do this?
  String getDescription(int index) {
    return appointments![index].description;
  }

  @override
  Color getColor(int index) {
    return appointments![index].color;
  }

  @override
  String? getRecurrenceRule(int index) {
    return appointments![index].recurrenceRule;
  }
}