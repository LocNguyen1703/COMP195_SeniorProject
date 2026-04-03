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
  // dynamic appointment; 
  // CalendarResource? resource;
  // DateTime? draggingTime;
  // Offset? draggingOffset;
  // CalendarResource? sourceResource;
  // CalendarResource? targetResource;
  bool isDragging = false; // track whether an event is currently being dragged
  late EventDataSource dataSource; 
  
  Future<void> loadEvents() async {
    // load events from the database and set the state
    if (isDragging) return; // if an event is currently being dragged, do not load events to prevent conflicts between dragging and loading events from the database
    
    List<CalendarEvent> loadedEvents = await CalendarDatabase.getAllEvents();
    setState(() {
      events = loadedEvents;
      final filteredEvents = events
        .where((e) => widget.activeCalendarIds.contains(e.calendarId))
        .toList();
      dataSource = EventDataSource(filteredEvents);
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

  Future<void> onEventDragEnd(AppointmentDragEndDetails details) async {
    // final droppedTime = details.droppingTime; // new Start time
    // if (droppedTime == null) return; 

    // if (details.appointment is! CalendarEvent) return; // make sure the dragged appointment is a CalendarEvent, if not do nothing

    // final appointment = details.appointment as Appointment; // new 
    // final duration = appointment.endTime.difference(appointment.startTime); // calculate the duration of the event

    // final event = events.firstWhere(
    //   (e) => e.id == appointment.id, 
    //   orElse: () => throw Exception("Event not found"), 
    // );

    // final updatedEvent = CalendarEvent(
    //   id: event.id,
    //   calendarId: event.calendarId,
    //   title: event.title,
    //   description: event.description,
    //   start: droppedTime, // update the start time to the new dropped time
    //   end: droppedTime.add(duration), // update the end time based on the original duration
    //   color: event.color,
    //   recurrenceRule: event.recurrenceRule,  
    // );

    // await CalendarDatabase.updateEvent(updatedEvent); // update the event in the database and reload events

    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   if(!mounted) return; 
    //   await loadEvents(); // reload events after the current frame to reflect the changes from dragging and dropping the event
    //   isDragging = false; 
    // });
    final droppedTime = details.droppingTime;
    if (droppedTime == null) return;

    if (details.appointment is! CalendarEvent) return;

    final event = details.appointment as CalendarEvent;

    final duration = event.end.difference(event.start);

    final updatedEvent = CalendarEvent(
      id: event.id,
      calendarId: event.calendarId,
      title: event.title,
      description: event.description,
      start: droppedTime,
      end: droppedTime.add(duration),
      color: event.color,
      recurrenceRule: event.recurrenceRule,
    );

    await CalendarDatabase.updateEvent(updatedEvent);

    if (!mounted) return;

    setState(() {
      final index = events.indexWhere((e) => e.id == updatedEvent.id);
      if (index != -1) {
        events[index] = updatedEvent;
      }

      dataSource = EventDataSource(
        events.where((e) => widget.activeCalendarIds.contains(e.calendarId)).toList(),
      );

      isDragging = false;
    });

  }

  @override
  void initState() {
    super.initState();
    dataSource = EventDataSource([]); // initialize with an empty data source until events are loaded from the database
    loadEvents(); // load events when the widget is first created
  }

  @override
  void didUpdateWidget(covariant CalendarPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeCalendarIds != widget.activeCalendarIds) {
      final filtered = events
      .where((e) => widget.activeCalendarIds.contains(e.calendarId))
      .toList();

      setState(() {
        dataSource = EventDataSource(filtered);
      }); //filteredEvents get updated automatically since it's a getter that depends on widget.activeCalendarIds, so just call setState to trigger a rebuild
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
      allowDragAndDrop: true,
      dragAndDropSettings: DragAndDropSettings(
        allowNavigation: true, // allow navigating to different dates while dragging an event
        allowScroll: true, // allow scrolling while dragging an event
        showTimeIndicator: true, // show a time indicator while dragging an event to indicate the potential new start time of the event
        indicatorTimeFormat: 'h:mm a', // format the time indicator as hours and minutes with AM/PM
        autoNavigateDelay: Duration(seconds: 1),
      ),

      // initialDisplayDate: DateTime(2021, 03, 01, 08, 30),
      dataSource: dataSource, // use the filtered list of events based on activeCalendarIds
      onTap: (CalendarTapDetails details) {
        if (details.targetElement == CalendarElement.calendarCell) { // tapping on an empty cell opens the create event form with the start time pre-filled
          showEventFormDialog(initialStart: details.date!);
        } else if (details.targetElement == CalendarElement.appointment) { // tapping on an existing event opens the edit form
          final event = details.appointments!.first as CalendarEvent;
          showEventFormDialog(event: event); 
        }
      },
      // onLongPress: (CalendarLongPressDetails details) {
      //   if (isDragging) return; // if an event is currently being dragged, ignore long press to prevent conflicts between dragging and long press actions
      //   if(details.targetElement == CalendarElement.appointment) {
      //     final event = details.appointments!.first as CalendarEvent;
      //     showDeleteConfirmation(event); // long pressing on an event opens the delete confirmation dialog
      //   }
      // },
      onDragStart: (AppointmentDragStartDetails details) {
        isDragging = true; // set dragging state to true when drag starts
      },
      onDragEnd: (AppointmentDragEndDetails details) {
        onEventDragEnd(details); // handle event drag and drop to update the event's start and end time in the database
      },
    );
  }
}