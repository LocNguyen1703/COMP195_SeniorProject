import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:test_flutter_app/calendar_page_handler/calendar_event.dart';
import 'package:flutter/material.dart';

class EventDataSource extends CalendarDataSource {
  EventDataSource(List<CalendarEvent> source) {
    appointments = source;
  }

  CalendarEvent getCalendarEvent(int index) {
    return appointments![index] as CalendarEvent;
  }

  @override
  DateTime getStartTime(int index) {
    return getCalendarEvent(index).start;
  }

  @override
  DateTime getEndTime(int index) {
    return getCalendarEvent(index).end;
  }

  @override
  String getSubject(int index) {
    return getCalendarEvent(index).title;
  }

  //can I do this?
  @override
  String? getNotes(int index) {
    return getCalendarEvent(index).description;
  }

  @override
  Color getColor(int index) {
    return getCalendarEvent(index).color;
  }

  @override 
  Object? getId(int index) {
    return getCalendarEvent(index).id ?? index;
  }

  @override
  String? getStartTimeZone(int index) { 
    return null; // not using time zones in this implementation
  }

  @override
  String? getEndTimeZone(int index) {
    return null; // not using time zones in this implementation
  }

  @override
  String? getRecurrenceRule(int index) {
    return getCalendarEvent(index).recurrenceRule;
  }
}