import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:test_flutter_app/calendar_page_handler/calendar_data_source.dart';
import 'package:test_flutter_app/calendar_page_handler/calendar_event.dart';

class CalendarPage extends StatefulWidget {  
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => CalendarPageState();
}

class CalendarPageState extends State<CalendarPage> {
  List<CalendarEvent> events = [];
  
  
  @override
  Widget build(BuildContext context) {
    return SfCalendar(
      view: CalendarView.week,
      // monthViewSettings: const MonthViewSettings(
      //   appointmentDisplayMode: MonthAppointmentDisplayMode.appointment
      // ),
      allowedViews: [
        CalendarView.day,
        CalendarView.week,
        CalendarView.workWeek,
        CalendarView.month,
      ],
      // initialDisplayDate: DateTime(2021, 03, 01, 08, 30),
      dataSource: EventDataSource(events),
    );
  }
}