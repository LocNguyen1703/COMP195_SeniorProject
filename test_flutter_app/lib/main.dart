import 'package:flutter/material.dart';
import 'package:test_flutter_app/ai_chat_handler/ai_chat_page.dart';
import 'package:test_flutter_app/ai_chat_handler/conversation.dart';
import 'package:test_flutter_app/new_app.dart';
import 'package:test_flutter_app/calendar_page_handler/calendar_page.dart';
import 'package:test_flutter_app/calendar_page_handler/calendar_form_widget.dart';
import 'package:test_flutter_app/calendar_page_handler/calendar_database.dart';
import 'package:test_flutter_app/calendar_page_handler/calendar.dart';
import 'package:test_flutter_app/testing_database/contact_page.dart';
import 'package:test_flutter_app/ai_chat_handler/message_database.dart';  
import 'package:test_flutter_app/to_do_list_handler/todo_list_page.dart';
import 'package:test_flutter_app/to_do_list_handler/todo_database.dart';
import 'package:test_flutter_app/to_do_list_handler/todo_list.dart';

/*handy VSCode shortcuts for refactoring: 
Alt + Click: Place cursors at arbitrary, non-consecutive locations in the file.
Ctrl + Alt + Down / Up: Insert a cursor directly below or above the current line, useful for consecutive lines.
Ctrl + D: Select the word under the cursor, or add a cursor to the next occurrence of the current selection (one by one).
Ctrl + Shift + L: Select all occurrences of the currently highlighted text in the document and add a cursor to each, which is great for mass changes.
Shift + Alt + Down / Up: Copies the current line down or up and places a cursor on the new line.
Shift + Alt + I: After making a multi-line selection (e.g., using Shift and arrow keys), this shortcut places a cursor at the end of each selected
*/

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData( 
        colorScheme: .fromSeed(seedColor: Colors.yellowAccent), // This is the color theme of your application.
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentPage = 0; 
  int? currentConversationId; 
  List<Conversation> conversations = []; 

  List<Calendar> calendars = [];
  Set<int> activeCalendarIds = {}; // set of calendar IDs to show events from, if empty show all events

  final GlobalKey<HomePageState> homeKey = GlobalKey<HomePageState>();
  final GlobalKey<ContactPageState> contactKey = GlobalKey<ContactPageState>();
  
  final ScrollController scrollController = ScrollController();
  
  List<Widget> pages = [];

  int todoCreateTrigger = 0;
  int todoReloadTrigger = 0; 
  int calendarReloadTrigger = 0;

  Map<String, List<TodoList>> groupedTodoLists = {};

  Future<void> loadConversations() async {
    // if the widget is no longer mounted to the UI tree (i.e. no longer alive because it's destroyed) - exit function immediately
    if (!context.mounted) return; 

    final conversations = await MessageDatabase.getConversations();
    setState(() {
      this.conversations = conversations;
    }); 
  }

  Future<void> deleteConversation(int conversationId) async {
    if (conversationId == -1) {
      return; // do nothing if no conversation is selected
    }
    await MessageDatabase.deleteConversation(conversationId);
    await loadConversations(); // reload conversations to update the sidebar after deletion
    if (currentConversationId == conversationId) {
      setState(() {
        currentConversationId = null; // clear the current conversation if it was deleted
      });
    }
  }
  
  Future<void> loadCalendars() async {
    if (!context.mounted) return;
    final loaded = await CalendarDatabase.getAllCalendars();
    setState(() {
      this.calendars = loaded;
      
      final newIds = loaded
        .where((c) => c.calendarId != null)
        .map((c) => c.calendarId!)
        .toSet();
      
      // activeCalendarIds = newIds.intersection(activeCalendarIds)..addAll(newIds.difference(activeCalendarIds)); // add any new calendar IDs to the active set and remove any deleted calendar IDs from the active set
      activeCalendarIds = newIds;
    });
  }

  void toggleCalendar(int calendarId) {
    setState(() {
      final newSet = Set<int>.from(activeCalendarIds);
      if (newSet.contains(calendarId)) {
        newSet.remove(calendarId);
      } else {
        newSet.add(calendarId);
      }
      activeCalendarIds = newSet;
    });
  }

  void toggleAllCalendars(bool selectAll) { 
    setState(() {
      if (selectAll) { 
        activeCalendarIds = calendars
          .where((c) => c.calendarId != null)
          .map((c) => c.calendarId!)
          .toSet();
      } else {
        activeCalendarIds = {};
      }
    });
  }

  Future<void> loadGroupedTodoLists() async {
  final lists = await TodoDatabase.getAllTodoLists();

  final Map<String, List<TodoList>> grouped = {};

  for (final list in lists) {
    final category = (list.category.isEmpty) ? 'Uncategorized' : list.category;

    grouped.putIfAbsent(category, () => []).add(list);
  }

  // Sort lists inside each category
  for (final entry in grouped.entries) {
    entry.value.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
  }

  setState(() {
  groupedTodoLists = grouped; // store the grouped lists in the state variable to be used for rendering the to-do lists in the drawer
    
  });
}

  bool? get allCalendarCheckboxValues {
    if (calendars.isEmpty) return false;
    if (activeCalendarIds.isEmpty) return false;
    if (activeCalendarIds.length == calendars.length) return true;
    return null; 
  }

  Widget? _buildFAB() {
    switch (currentPage) {
    case 1: 
      return FloatingActionButton(
        onPressed: () {
          // calendarKey.currentState?.addEvent();
          // handling different calendar management operations 
        },
        shape: CircleBorder(
          side: BorderSide(
            color: Theme.of(context).colorScheme.onPrimary, // use the onPrimary color from the theme for the border
            width: 2, // set the width of the border
          ),
        ),
        child: const Icon(Icons.add),
      );
    case 2: 
      return FloatingActionButton(
        onPressed: () async {
          setState(() {
            todoCreateTrigger++; // increment the trigger to signal the TodoListPage to show the create dialog
          });
        },
        child: const Icon(Icons.add),
      ); 
    default:
      return null;
    }
  }

  Widget? _buildDrawer() {
    switch(currentPage) {
      case 0:
        return Drawer(
          child: Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,

                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Text('Drawer Header'),
                ), 
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  // itemCount: aiChatKey.currentState?.conversations.length ?? 0,
                  itemCount: conversations.length + 1,
                  itemBuilder: (context, index) {
                    // final title = aiChatKey.currentState?.conversations[index].title ?? 'Conversation $index';
                    if (index == 0) {
                      return ListTile(
                        title: const Text('New Conversation'),
                        leading: const Icon(Icons.add),
                        onTap: () {
                          // Handle new conversation creation
                          setState(() {
                            currentConversationId = null; // clear the current conversation when creating a new one
                          });
                        },
                      );
                    }
                    final title = conversations[index-1].title; 
                    return ListTile(
                      title: Text(title),
                      onTap: () {
                        // Handle conversation tap (e.g., load the conversation in the main area)
                        setState(() {
                          currentConversationId = conversations[index-1].id;
                        });
                      },
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          // Handle conversation deletion
                          await deleteConversation(conversations[index-1].id??-1); // delete the conversation from the database
                        },
                      ),
                    );
                  },
                ),
              ),
            ], 
          ),
        );

      case 1: 
        return Drawer(
          child: Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: const SizedBox(
                  width: double.infinity,
                  child: Text('Calendars', style: TextStyle(fontSize: 23),),
                ),
              ),

              ListTile(
                leading: Checkbox(
                  tristate: true,
                  value: allCalendarCheckboxValues, 
                  onChanged: (v) => toggleAllCalendars(v ?? false),
                ),
                title: Text('Select All'),
              ),

              const Divider(height: 1),

              Expanded(
                child: ListView.builder(
                  itemCount: calendars.length,
                  itemBuilder: (context, index) {
                    final displayCal = calendars[index];
                    final isActive = activeCalendarIds.contains(displayCal.calendarId);
                    return ListTile(
                      leading: Checkbox(
                        value: isActive,
                        activeColor: displayCal.color,
                        onChanged: (_) => toggleCalendar(displayCal.calendarId!),
                      ),
                      title: Text(displayCal.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(backgroundColor: displayCal.color, radius: 8,),
                          const SizedBox(width: 4), 
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18),
                            onPressed: () async {
                              final result = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Edit Calendar'),
                                  content: CalendarFormWidget(calendar: displayCal),
                                )
                              );
                              if (result == true) await loadCalendars(); // refresh the calendar list after editing a calendar to reflect any changes made (e.g., name or color changes)
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const Divider(height: 1),

              // Add_calendar button at the bottom of the drawer
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () async { 
                    final result = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Create Calendar'),
                        content: const CalendarFormWidget(),
                      ),
                    );
                    if (result == true) await loadCalendars();
                  },
                  icon: const Icon(Icons.add), 
                  label: const Text('Add Calendar'),  
                ),
              )
            ]
          )
        );

      case 2: 
        final categories = groupedTodoLists.keys.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
        return Drawer(
          child: Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: const SizedBox(
                  width: double.infinity,
                  child: Text('To-Do Lists', style: TextStyle(fontSize: 23),),
                ),
              ),

              // List of to-do lists would go here, similar to the calendar drawer implementation but for to-do lists instead of calendars

              Expanded(
                child: groupedTodoLists.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final lists = groupedTodoLists[category]!;

                        return ExpansionTile(
                          title: Text(category),
                          children: lists.map((list) {
                            return ListTile(
                              title: Text(list.title),
                              onTap: () {
                                // Handle to-do list tap (e.g., load the to-do list in the main area)
                              },  
                            );
                          }).toList(),
                        );
                      },
                    ),
              ),

              const Divider(height: 1),

              // Add To-Do List button at the bottom of the drawer
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () async { 
                    setState(() {
                      todoCreateTrigger++; // increment the trigger to signal the TodoListPage to show the create dialog
                    });
                  },
                  icon: const Icon(Icons.add), 
                  label: const Text('Add To-Do List'),  
                ),
              )
            ]
          )
        ); 

      default:
        return null;
    }
  }

  @override
  void initState() {
    super.initState();
    loadConversations();
    loadCalendars();
    loadGroupedTodoLists();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My App'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: IndexedStack(
        index: currentPage,
        children: [
          AIChatPage(
            conversationId: currentConversationId,
            onConversationCreated: (int newId) async {
              await loadConversations();
              setState(() {
                currentConversationId = newId;
              });
            },
            onConversationDeleted: deleteConversation,
            onTodoAction: () async {
              await loadGroupedTodoLists(); // reload the grouped to-do lists to get the latest data after a to-do action is executed in the AIChatPage (e.g., a to-do list is created, updated, or deleted through an AI action)
              setState(() {
                todoReloadTrigger++; // increment the trigger to signal the TodoListPage to show the create dialog
              });
            },
            onCalendarAction: () async {
              await loadCalendars(); // reload calendars to get the latest calendar data after a calendar action is executed
              setState(() {
                calendarReloadTrigger++; // increment the trigger to signal the CalendarPage to reload events from the database
              });
            },
          ),
          CalendarPage(
            activeCalendarIds: activeCalendarIds,
            calendars: calendars,
            reloadTrigger: calendarReloadTrigger,
          ),
          TodoListPage(
            createTrigger: todoCreateTrigger,
            reloadTrigger: todoReloadTrigger,
            onListChanged: () async {
              await loadGroupedTodoLists(); // reload the gdrarouped to-do lists to get the latest data after a to-do list is created, updated, or deleted in the TodoListPage
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPage,
        fixedColor: Colors.blue[100],
        unselectedItemColor: Colors.black,
        onTap: (value) {
          setState(() {
            currentPage = value;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
              icon: const Icon(Icons.calendar_month_sharp),
              label: 'Calendar',
            ),
          BottomNavigationBarItem(
              icon: const Icon(Icons.checklist),
              label: 'To-Do List',
            ),
        ],
      ),

      floatingActionButton: _buildFAB(),
      drawer: _buildDrawer(),
    );
  }
}


