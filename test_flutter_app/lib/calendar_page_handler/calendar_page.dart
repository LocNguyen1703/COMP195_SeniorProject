import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:test_flutter_app/calendar_page_handler/calendar.dart';
import 'package:test_flutter_app/calendar_page_handler/calendar_data_source.dart';
import 'package:test_flutter_app/calendar_page_handler/calendar_event.dart';
import 'package:test_flutter_app/calendar_page_handler/calendar_database.dart';
import 'package:test_flutter_app/calendar_page_handler/event_form_widget.dart';

class CalendarPage extends StatefulWidget {  
  final Set<int> activeCalendarIds; // set of calendar IDs to show events from, if empty show all events
  final List<Calendar> calendars;
  
  const CalendarPage({
    super.key,
    required this.activeCalendarIds,
    required this.calendars,
  });

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

  List<CalendarEvent> get filteredEvents => events
  .where((e) => widget.activeCalendarIds.contains(e.calendarId))
  .toList();

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

  Future<void> showDeleteConfirmation(CalendarEvent event) async {
    final confirmed = await showDialog<bool>(
      context: context, 
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), 
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed:() => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await CalendarDatabase.deleteEvent(event.id!); // delete the event from the database
      await loadEvents();
    }
  }

  @override
  void initState() {
    super.initState();
    loadEvents(); // load events when the widget is first created
  }

  @override
  void didUpdateWidget(covariant CalendarPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeCalendarIds != widget.activeCalendarIds) {
      setState(() {}); //filteredEvents get updated automatically since it's a getter that depends on widget.activeCalendarIds, so just call setState to trigger a rebuild
    }
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
      dataSource: EventDataSource(filteredEvents), // use the filtered list of events based on activeCalendarIds
      onTap: (CalendarTapDetails details) {
        if (details.targetElement == CalendarElement.calendarCell) { // tapping on an empty cell opens the create event form with the start time pre-filled
          showEventFormDialog(initialStart: details.date!);
        } else if (details.targetElement == CalendarElement.appointment) { // tapping on an existing event opens the edit form
          final event = details.appointments!.first as CalendarEvent;
          showEventFormDialog(event: event); 
        }
      },
      onLongPress: (CalendarLongPressDetails details) {
        if(details.targetElement == CalendarElement.appointment) {
          final event = details.appointments!.first as CalendarEvent;
          showDeleteConfirmation(event); // long pressing on an event opens the delete confirmation dialog
        }
      },
    );
  }
}