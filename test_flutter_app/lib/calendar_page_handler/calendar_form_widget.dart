import 'package:flutter/material.dart';
import 'package:test_flutter_app/calendar_page_handler/calendar.dart';
import 'package:test_flutter_app/calendar_page_handler/calendar_database.dart';

class CalendarFormWidget extends StatefulWidget{
  final Calendar? calendar; 

  const CalendarFormWidget({super.key, this.calendar});

  @override
  State<CalendarFormWidget> createState() => CalendarFormWidgetState();
}

class CalendarFormWidgetState extends State<CalendarFormWidget> {
  final _formKey = GlobalKey<FormState>();
  String name = ''; 
  Color selectedColor = Colors.blue;

  final List<Color> colorOptions = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
  ];

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final calendar = Calendar(
      calendarId: widget.calendar?.calendarId, 
      name: name,
      color: selectedColor,
    );

    if (widget.calendar == null) {
      await CalendarDatabase.addCalendar(calendar);
    } else {
      await CalendarDatabase.updateCalendar(calendar);
    }

    Navigator.of(context).pop(true);
  }

  @override
  void initState() {
    super.initState();
    name = widget.calendar?.name ?? '';
    selectedColor = widget.calendar?.color ?? Colors.blue; 
  }  

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12), 
            TextFormField(
              initialValue: name,
              decoration: InputDecoration(
                labelText: 'Calendar Name',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Please enter a name' : null,
              onSaved: (v) => name = v?.trim() ?? '', 
            ),

            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Color', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: colorOptions.map((color) {
                return GestureDetector(
                  onTap: () => setState(() => selectedColor = color),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: selectedColor == color? Border.all(width: 3, color: Colors.black) : null,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20), 
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.calendar != null) TextButton(
                  onPressed: () async {
                    await CalendarDatabase.deleteCalendar(widget.calendar!.calendarId!);
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Delete'),
                ),

                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: save,
                  child: Text(widget.calendar != null ? "Update" : "Save"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}