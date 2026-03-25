import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:test_flutter_app/calendar_page_handler/calendar_data_source.dart';
import 'package:test_flutter_app/calendar_page_handler/calendar_event.dart';
import 'package:test_flutter_app/calendar_page_handler/calendar_database.dart';
import 'package:test_flutter_app/calendar_page_handler/event_form_widget.dart';

class CalendarPage extends StatefulWidget {  
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => CalendarPageState();
}

class CalendarPageState extends State<CalendarPage> {
  List<CalendarEvent> events = [];
  
  Future<void> loadEvents() async {
    // load events from the database and set the state
    List<CalendarEvent> loadedEvents = await CalendarDatabase.getAllEvents();
    setState(() {
      events = loadedEvents;
    });
  }

  Future<void> createEvent(int calendarId, String title, 
                          String description, DateTime startTime, 
                          DateTime endTime, Color color) async {
    // create a new event and add it to the list of events
    CalendarEvent newEvent = CalendarEvent(
      calendarId: calendarId,
      title: title,
      description: description,
      start: startTime,
      end: endTime,
      color: color,
    );
    await CalendarDatabase.addEvent(newEvent); // insert the new event into the database
    await loadEvents(); // reload events from the database to reflect the new event
  }

  Future<void> updateEvent(CalendarEvent event) async {
    await CalendarDatabase.updateEvent(event); // update the event in the database
    await loadEvents(); // reload events from the database to reflect the update
  }

  //show event form dialog for creating or editing an event
  Future<void> showEventFormDialog({CalendarEvent? event, DateTime? initialStart}) async {
    final result = await showDialog<bool>(
      context: context, 
      builder: (context) => AlertDialog(
        title: Text(event == null ? 'Create Event' : 'Edit Event'),
        content: EventFormWidget(event: event, initialStart: initialStart),
      ),
    );
    if (result == true) await loadEvents(); // reload events if an event was created or updated
  }

  @override
  void initState() {
    super.initState();
    loadEvents(); // load events when the widget is first created
  }

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
      onTap: (CalendarTapDetails details) {
        if (details.targetElement == CalendarElement.calendarCell) { // tapping on an empty cell opens the create event form with the start time pre-filled
          showEventFormDialog(initialStart: details.date!);
        } else if (details.targetElement == CalendarElement.appointment) { // tapping on an existing event opens the edit form
          final event = details.appointments!.first as CalendarEvent;
          showEventFormDialog(event: event); 
        }
      }
    );
  }
}