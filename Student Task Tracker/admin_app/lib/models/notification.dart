class Notification {
  final String id;
  final String userId;
  final String message;
  final String type;
  final DateTime createdAt;
  final bool isRead;

  Notification({
    required this.id,
    required this.userId,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.isRead,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      message: json['message'].toString(),
      type: json['type'].toString(),
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'] as bool,
    );
  }
}