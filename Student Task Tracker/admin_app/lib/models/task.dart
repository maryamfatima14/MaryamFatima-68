class Task {
  final String id;
  final String title;
  final String description;
  final String assignedTo;
  final DateTime dueDate;
  final String createdBy;
  final String status;
  final DateTime createdAt;
  final String? feedbackCategory; // Replace feedbackPoints with feedbackCategory
  final String? feedbackComments;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.dueDate,
    required this.createdBy,
    required this.status,
    required this.createdAt,
    this.feedbackCategory,
    this.feedbackComments,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'].toString(),
      title: json['title'].toString(),
      description: json['description'].toString(),
      assignedTo: json['assigned_to'].toString(),
      dueDate: DateTime.parse(json['due_date']),
      createdBy: json['created_by'].toString(),
      status: json['status'].toString(),
      createdAt: DateTime.parse(json['created_at']),
      feedbackCategory: json['feedback_category']?.toString(), // Map to feedback_category
      feedbackComments: json['feedback_comments']?.toString(),
    );
  }
}