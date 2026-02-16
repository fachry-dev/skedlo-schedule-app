import 'package:cloud_firestore/cloud_firestore.dart';

class Schedule {
  final String id;
  final String title;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final String description;
  final List<Map<String, dynamic>> activities;
  final bool isGenerated;
  final bool isCompleted;
  final String userId;

  Schedule({
    this.id = '',
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.description,
    this.activities = const [],
    this.isGenerated = false,
    this.isCompleted = false,
    required this.userId,
  });

  String get time =>
      "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}";

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': Timestamp.fromDate(date),
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'description': description,
      'activities': activities,
      'isGenerated': isGenerated,
      'isCompleted': isCompleted,
      'userId': userId,
    };
  }

  factory Schedule.fromMap(Map<String, dynamic> map, String id) {
    // Handle migration from List<String> to List<Map<String, dynamic>>
    var activitiesData = map['activities'] ?? [];
    List<Map<String, dynamic>> parsedActivities = [];

    if (activitiesData is List) {
      for (var item in activitiesData) {
        if (item is String) {
          parsedActivities.add({'content': item, 'isCompleted': false});
        } else if (item is Map) {
          parsedActivities.add(Map<String, dynamic>.from(item));
        }
      }
    }

    return Schedule(
      id: id,
      title: map['title'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp).toDate(),
      description: map['description'] ?? '',
      activities: parsedActivities,
      isGenerated: map['isGenerated'] ?? false,
      isCompleted: map['isCompleted'] ?? false,
      userId: map['userId'] ?? '',
    );
  }

  Schedule copyWith({
    String? id,
    String? title,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    String? description,
    List<Map<String, dynamic>>? activities,
    bool? isGenerated,
    bool? isCompleted,
    String? userId,
  }) {
    return Schedule(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      description: description ?? this.description,
      activities: activities ?? this.activities,
      isGenerated: isGenerated ?? this.isGenerated,
      isCompleted: isCompleted ?? this.isCompleted,
      userId: userId ?? this.userId,
    );
  }
}
