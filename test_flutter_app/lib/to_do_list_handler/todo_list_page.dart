import 'package:flutter/material.dart';
import 'package:test_flutter_app/to_do_list_handler/todo_database.dart';
import 'package:test_flutter_app/to_do_list_handler/todo_item.dart';
import 'package:test_flutter_app/to_do_list_handler/todo_list.dart';

class TodoListPage extends StatefulWidget {
  // final VoidCallback? onFabPressed; // callback for when the FAB is pressed, if needed
  final int createTrigger; 
  
  const TodoListPage({
    super.key,
    // this.onFabPressed,
    this.createTrigger = 0, // pass the create trigger from the parent widget
  });

  @override
  State<TodoListPage> createState() => TodoListPageState();
}

class TodoListPageState extends State<TodoListPage> {
  List<TodoList> todoLists = [];
  List<TodoItem> todoItems = [];

  Map<int, List<TodoItem>> itemsByList = {};

  int? selectedListId; // track the currently selected list ID, if any

  Future<void> loadTodoLists() async {
    // load todo lists from the database and set the state
    final loadedList = await TodoDatabase.getAllTodoLists();

    setState(() {
      this.todoLists = loadedList;
      if (todoLists.isNotEmpty) {
        selectedListId = todoLists.first.id; // select the first list by default if there are any lists
      }
    });

    if (selectedListId != null) {
      await loadTodoItemsForList(selectedListId!); // load items for the selected list
    }
  }

  Future<void> loadTodoItemsForList(int listId) async {
    // load todo items for a specific list from the database and set the state
    final loadedItems = await TodoDatabase.getTodoItems(listId);
    setState(() {
      this.todoItems = loadedItems;
    });
  }

  void selectList(int listId) async {
    // set the selected list ID and load items for that list
    setState(() {
      selectedListId = listId;
    });
    await loadTodoItemsForList(listId);
  } 

  Future<void> addItem(int listId) async {
    final controller = TextEditingController(); 

    final result = await showDialog<bool>(
      context: context, 
      builder: (_) => AlertDialog(
        title: const Text('Add Task'),
        content: TextField(
          controller: controller,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await TodoDatabase.addTodoItem(
                TodoItem( 
                  listId: listId, 
                  description: controller.text,
                  createdAt: DateTime.now(),
                  priority: 2, 
                  isDone: false
                ),
              );
              Navigator.pop(context, true);
            }, 
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result == true) {
      await loadTodoLists();
    }
  }

  Future<void> showCreateDialog() async {
    final controller = TextEditingController(); 
    
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New list'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'List title'
          ),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await TodoDatabase.addTodoList(
                TodoList(
                  title: controller.text, 
                  category: '',
                  description: '',
                  createdAt: DateTime.now(),
                  color: Colors.blue,
                )
              );
              Navigator.pop(context, true);
            }, 
            child: const Text('Create'))
        ],
      ),
    );

    if (result == true) {
      await loadTodoLists();
    }
  }

  Future<void> toggleItem(TodoItem item) async {
    await TodoDatabase.updateTodoItem(
      item.copyWith(isDone: !item.isDone)
    );
    await loadTodoLists();
  }  

  @override
  void initState() {
    super.initState();
    loadTodoLists();
  }

  @override
  void didUpdateWidget(covariant TodoListPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.createTrigger != oldWidget.createTrigger) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showCreateDialog();
      }); 
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: todoLists.length,
      itemBuilder: (context, index) {
        final list = todoLists[index];
        final items = itemsByList[list.id] ?? [];

        return Card(
          child: ExpansionTile(
            title: Text(list.title),
            children: [
              ...items.map((item) => CheckboxListTile(
                value: item.isDone,
                title: Text(item.description), 
                onChanged: (_) => toggleItem(item),
              )),

              TextButton.icon(
                onPressed: () => addItem(list.id!),
                label: const Text('Add Item'),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        );
      },
    );
  }
}