import 'package:flutter/material.dart';
import 'package:test_flutter_app/calendar_page_handler/calendar.dart';
import 'package:test_flutter_app/calendar_page_handler/calendar_database.dart';
import 'package:test_flutter_app/calendar_page_handler/calendar_event.dart';

class EventFormWidget extends StatefulWidget {
  final CalendarEvent? event; 
  final DateTime? initialStart;

  const EventFormWidget({
    super.key,
    this.event,
    this.initialStart,
  });

  @override
  State<EventFormWidget> createState() => EventFormWidgetState();
}

class EventFormWidgetState extends State<EventFormWidget> {
  final _formKey = GlobalKey<FormState>();
  String? endDateError; 
  String? endTimeError; 

  // initial values for form fields
  String title = ''; 
  String description = '';
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(hours: 1));
  Color selectedColor = Colors.blue;
  String? recurrenceRule;
  int calendarId = 1;  

  // dropdown list of available calendars
  List<Calendar> availableCalendars = [];

  final Map<String, String?> recurrenceOptions = {
    'None': null,
    'Daily': 'FREQ=DAILY',
    'Weekly': 'FREQ=WEEKLY',
    'Monthly': 'FREQ=MONTHLY',
    'Yearly': 'FREQ=YEARLY',
    'weekdays only': 'FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR',
    'weekends only': 'FREQ=WEEKLY;BYDAY=SA,SU',
    'custom...': 'custom', // special value to trigger custom recurrence rule input
  };

  final List<Color> colorOptions = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
    Colors.cyan,
    Colors.brown,
  ];

  Future<void> _loadCalendars() async {
    final calendars = await CalendarDatabase.getAllCalendars();
    setState(() {
      availableCalendars = calendars;
    });
  }

  Future<void> pickDate(bool isStart) async { 
    final initial = isStart ? startDate : endDate;
    final picked = await showDatePicker(
      context: context, 
      initialDate: initial,
      firstDate: DateTime(2000), // first pickable date 
      lastDate: DateTime(2100)  // last pickable date
    );
    if (picked == null) return; 

    setState(() {
      if (isStart) {
        startDate = DateTime(picked.year, picked.month, picked.day, startDate.hour, startDate.minute);  
      } if (!endDate.isAfter(startDate)) {
        endDate = startDate.add(const Duration(hours: 1));
      } else {
        final proposedEnd = DateTime(picked.year, picked.month, picked.day, endDate.hour, endDate.minute);
        if (!proposedEnd.isAfter(startDate)) {
          endDateError = "End date must be after start date";
          return;
        } else {
          endDate = proposedEnd;
          endDateError = null;
        }
      }
    });
  }

  Future<void> pickTime(bool isStart) async {
    final initial = TimeOfDay.fromDateTime(isStart? startDate : endDate);
    final picked = await showTimePicker(
      context: context, 
      initialTime: initial,
    );
    if (picked == null) return;

    setState(() {
      if (isStart) {
        startDate = DateTime(startDate.year, startDate.month, startDate.day, picked.hour, picked.minute);
        if (endDate.isAtSameMomentAs(startDate) || endDate.isBefore(startDate)) {
        endDate = startDate.add(const Duration(hours: 1));
        }
      } else {
        final proposedEnd = DateTime(endDate.year, endDate.month, endDate.day, picked.hour, picked.minute);
        if(!proposedEnd.isAfter(startDate)) {
          endTimeError = "End time must be after start time";
          return; 
        }
        endDate = proposedEnd; 
        endTimeError = null;
      }
    });
  }

  //helper method
  String formatDateTime(DateTime date) {
    return '${date.month}/${date.day}/${date.year} ${TimeOfDay.fromDateTime(date).format(context)}';
  }

  Future<void> save() async { 
    if(!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (!endDate.isAfter(startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time'))
      );
      return;
    }

    final event = CalendarEvent(
      id: widget.event?.id,
      calendarId: calendarId, 
      title: title,
      description: description,
      start: startDate,
      end: endDate,
      color: selectedColor,
      recurrenceRule: recurrenceRule,
    );

    if (widget.event != null) {
      await CalendarDatabase.updateEvent(event);
    } else {
      await CalendarDatabase.addEvent(event);
    }

    Navigator.of(context).pop(true);
  }

  @override
  void initState() {
    super.initState();
    title = widget.event?.title ?? '';  
    description = widget.event?.description ?? '';
    startDate = widget.event?.start ?? widget.initialStart ?? DateTime.now();
    endDate = widget.event?.end ?? (widget.initialStart?.add(const Duration(hours: 1)) ?? DateTime.now().add(const Duration(hours: 1)));
    selectedColor = widget.event?.color ?? Colors.blue;
    recurrenceRule = widget.event?.recurrenceRule;
    calendarId = widget.event?.calendarId ?? 1; 

    _loadCalendars();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(height: 12.0),
            //--title
            TextFormField(
              initialValue: title,
              decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a title' : null,
              onSaved: (v) => title = v?.trim() ?? '',
            ),
            
            const SizedBox(height: 12.0),
            //--description
            TextFormField(
              initialValue: description,
              decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
              maxLines: 3,
              onSaved:(newValue) => description = newValue?.trim() ?? '',
            ),

            const SizedBox(height: 12.0),
            //--start date/time 
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Start'),
              subtitle: Text(formatDateTime(startDate)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(onPressed: () => pickDate(true), icon: Icon(Icons.calendar_today)),
                  IconButton(onPressed: () => pickTime(true), icon: Icon(Icons.access_time))
                ],
              )
            ),

            const SizedBox(height: 12.0),
            //--end date/time
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('End'), 
              subtitle: Text(formatDateTime(endDate)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(onPressed: () => pickDate(false), icon: Icon(Icons.calendar_today)),
                  IconButton(onPressed: () => pickTime(false), icon: Icon(Icons.access_time))
                ],
              )
            ),
            if(endDateError != null) Padding(
              padding: const EdgeInsets.only(left: 4, top: 2), 
              child: Text(
                endDateError!,
                style: const TextStyle(color: Colors.red, fontSize: 12,),
              )
            ),
            if (endTimeError != null) Padding(
              padding: const EdgeInsets.only(left: 4, top: 2), 
              child: Text(
                endTimeError!,
                style: const TextStyle(color: Colors.red, fontSize: 12,),
              )
            ),

            const SizedBox(height: 12.0),
            //--calendar selector
            if (availableCalendars.isNotEmpty) 
              DropdownButtonFormField<int>(
                initialValue: calendarId,
                decoration: const InputDecoration(
                  labelText: 'Calendar',
                  border: OutlineInputBorder(),
                ),
                items: availableCalendars.map((cal) {
                  return DropdownMenuItem<int>(
                    value: cal.calendarId,
                    child: Row(
                      children: [
                        CircleAvatar(backgroundColor: cal.color, radius: 8),
                        const SizedBox(width: 8),
                        Text(cal.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => calendarId = val ?? 1),
              ),
            
            const SizedBox(height: 12.0),
            //-recurrence selector 
            DropdownButtonFormField<String?>(
              initialValue: recurrenceRule,
              decoration: const InputDecoration(
                labelText: 'Repeat',
                border: OutlineInputBorder(),
              ),
              items: recurrenceOptions.entries.map((entry) {
                return DropdownMenuItem<String?>(
                  value: entry.value,
                  child: Text(entry.key),
                );
              }).toList(),
              onChanged: (val) => setState(() => recurrenceRule = val),
            ),

            const SizedBox(height: 12.0),
            //-color selector
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Color', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ),
            const SizedBox(height: 8.0),
            Wrap(
              runSpacing: 8.0,
              children: colorOptions.map((color) {
                return GestureDetector(
                  onTap: () => setState(() => selectedColor = color),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8.0),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: selectedColor == color ? Border.all(width: 3, color: Colors.black) : null,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20.0),
            //--Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: save,
                  child: Text(widget.event != null ? 'Update' : 'Save'),
                ),
                if (widget.event != null) TextButton(
                  onPressed: () async {
                    await CalendarDatabase.deleteEvent(widget.event!.id!);
                    Navigator.of(context).pop(true);
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Delete', style: TextStyle(color: Colors.red))
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}