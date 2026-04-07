class TodoItem {
  int? id; 
  int listId; 
  String description;
  DateTime createdAt;
  DateTime? dueDate;
  DateTime? reminderTime;
  int priority; // 1 = High, 2 = Medium, 3 = Low
  bool isDone;

  TodoItem({
    this.id,
    required this.listId,
    required this.description, 
    required this.createdAt,
    this.dueDate,
    this.reminderTime,
    required this.priority,
    this.isDone = false
  });

  TodoItem copyWith({
    int? id,
    int? listId,
    String? description,
    DateTime? createdAt,
    DateTime? dueDate,
    DateTime? reminderTime,
    int? priority,
    bool? isDone,
  }) {
    return TodoItem(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      reminderTime: reminderTime ?? this.reminderTime,
      priority: priority ?? this.priority,
      isDone: isDone ?? this.isDone,
    );
  }

  String get priorityLabel {
    switch (priority) {
      case 1:
        return 'High';
      case 2:
        return 'Medium';
      case 3:
        return 'Low';
      default:
        return 'Unknown';
    }
  }

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'listId': listId,
    'description': description,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'dueDate': dueDate?.millisecondsSinceEpoch,
    'reminderTime': reminderTime?.millisecondsSinceEpoch,
    'priority': priority,
    'isDone': isDone ? 1 : 0, // Store as integer for SQLite
  };

  factory TodoItem.fromMap(Map<String, dynamic> map) => TodoItem(
    id: map['id'] as int?,
    listId: map['listId'] as int,
    description: map['description'],
    createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    dueDate: map['dueDate'] != null ? DateTime.fromMillisecondsSinceEpoch(map['dueDate']) : null,
    reminderTime: map['reminderTime'] != null ? DateTime.fromMillisecondsSinceEpoch(map['reminderTime']) : null,
    priority: (map['priority'] as int?) ?? 2, // Default to Medium if not set
    isDone: (map['isDone'] as int) == 1, // Convert back to boolean
  );
}
