class Task {
  final String id;
  final String title;
  final String? description;
  final String assignedTo;
  final String status;
  final DateTime? dueDate;
  final String createdBy;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.assignedTo,
    required this.status,
    this.dueDate,
    required this.createdBy,
    required this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      assignedTo: json['assigned_to'],
      status: json['status'],
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}