import 'package:flutter/material.dart';
import 'package:test_flutter_app/to_do_list_handler/todo_database.dart';
import 'package:test_flutter_app/to_do_list_handler/todo_item.dart';
import 'package:test_flutter_app/to_do_list_handler/todo_list.dart';

class TodoListPage extends StatefulWidget {
  // final VoidCallback? onFabPressed; // callback for when the FAB is pressed, if needed
  final VoidCallback? onListChanged;
  final int createTrigger; 
  final int reloadTrigger;
  
  const TodoListPage({
    super.key,
    // this.onFabPressed,
    this.createTrigger = 0, // pass the create trigger from the parent widget
    this.reloadTrigger = 0, // pass the reload trigger from the parent widget
    this.onListChanged,
  });

  @override
  State<TodoListPage> createState() => TodoListPageState();
}

class TodoListPageState extends State<TodoListPage> {
  List<TodoList> todoLists = [];
  List<TodoItem> todoItems = [];

  Map<int, List<TodoItem>> itemsByList = {};

  int? selectedListId; // track the currently selected list ID, if any

  Set<int> expandedListIds = {}; // track which lists are expanded

  Future<void> loadTodoLists() async {
    // load todo lists from the database and set the state
    final loadedList = await TodoDatabase.getAllTodoLists();
    
    final Map<int, List<TodoItem>> loadedItems = {};

    await Future.wait(
      loadedList.map((list) async {
        final items = await TodoDatabase.getTodoItems(list.id!);
        loadedItems[list.id!] = items;
      }),
    );
    setState(() {
      this.todoLists = loadedList;
      itemsByList = loadedItems;
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
      itemsByList[listId] = loadedItems;
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

  Future<void> deleteTodoList(int listId) async {
    await TodoDatabase.deleteTodoList(listId);
    await loadTodoLists();
  }

  Future<void> deleteTodoItem(int itemId) async {
    await TodoDatabase.deleteTodoItem(itemId);
    await loadTodoLists();
  }

  Future<void> showCreateDialog() async {
    final formKey = GlobalKey<FormState>();

    final titleController = TextEditingController(); 
    final descriptionController = TextEditingController();
    final customCategoryController = TextEditingController();

    String selectedCategory = 'General'; 
    final categories = ['General', 'Work', 'School', 'Personal', 'Shopping', 'Others']; // example categories
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('New list'),
            // content: TextField(
            //   controller: controller,
            //   decoration: const InputDecoration(
            //     hintText: 'List title'
            //   ),
            // ),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'List Title',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Title cannot be empty';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: categories.map((c) {
                        return DropdownMenuItem(
                          value: c,
                          child: Text(c),
                        );
                      }).toList(), 
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!; 
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    if (selectedCategory == 'Others') 
                      TextFormField(
                        controller: customCategoryController,
                        decoration: const InputDecoration(
                          labelText: 'Custom Category',
                        ),
                        validator: (v) {
                          if (selectedCategory == 'Others' && (v == null || v.trim().isEmpty)) {
                            return 'Please enter a custom category';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional',
                      ),
                      maxLines: 3,
                      validator: (v) {
                        if (v != null && v.length > 200) {
                          return 'Description cannot be longer than 200 characters';
                        }
                        return null;
                      },
                    )
                  ],
                ),
              ),
            ),

            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (!(formKey.currentState?.validate() ?? false)) {
                    return; // if form is not valid, do not proceed
                  }

                  String finalCategory = selectedCategory;

                  if (finalCategory == 'Others') {
                    finalCategory = customCategoryController.text.trim();
                    
                    if (!categories.contains(finalCategory)) {
                      categories.insert(categories.length - 1, finalCategory); // add new category before 'Others'
                    }
                  }

                  await TodoDatabase.addTodoList(
                    TodoList(
                      title: titleController.text.trim(), 
                      category: finalCategory,
                      description: descriptionController.text.trim(),
                      createdAt: DateTime.now(),
                      color: Colors.blue,
                    )
                  );
                  Navigator.pop(context, true);
                }, 
                child: const Text('Create'))
            ],
          );
        });
      } 
    );

    if (result == true) {
      await loadTodoLists();
      widget.onListChanged?.call(); // notify parent widget that a new list has been created
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

    if (widget.reloadTrigger != oldWidget.reloadTrigger) {
      loadTodoLists();
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
            onExpansionChanged: (expanded) {
              setState(() {
                if (expanded) {
                  expandedListIds.add(list.id!);
                } else {
                  expandedListIds.remove(list.id!);
                }
              });
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedRotation(
                  turns: expandedListIds.contains(list.id) ? -0.25 : 0.0, 
                  duration: const Duration(milliseconds: 200), //duration of the turning animation
                  child: const Icon(Icons.arrow_back_ios_new, size: 16,),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context, 
                      builder: (_) => AlertDialog(
                        title: const Text('Delete List'),
                        content: const Text('Are you sure you want to delete this list and all its items?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      deleteTodoList(list.id!);
                      widget.onListChanged?.call(); // notify parent widget that a list has been deleted
                    }
                  }
                ),
              ],
            ),
            children: [
              ...items.map((item) => CheckboxListTile(
                value: item.isDone,
                title: Text(item.description, style: TextStyle(
                  decoration: item.isDone ? TextDecoration.lineThrough : null,
                  decorationColor: Colors.grey,
                  color: item.isDone ? Colors.grey : null,
                ),), 
                onChanged: (_) => toggleItem(item),
                controlAffinity: ListTileControlAffinity.leading,
                secondary: IconButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context, 
                      builder: (_) => AlertDialog(
                        title: const Text('Delete Task'),
                        content: const Text('Are you sure you want to delete this task?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      deleteTodoItem(item.id!);
                    }
                  },
                  icon: Icon(Icons.delete, color: Colors.red),),
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