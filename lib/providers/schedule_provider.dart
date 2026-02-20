import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/schedule_model.dart';
import '../services/firebase_service.dart';
import '../services/cohere_service.dart';

class ScheduleProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final CohereService _cohereService = CohereService();

  List<Schedule> _schedules = [];
  bool _isLoading = false;
  StreamSubscription<List<Schedule>>? _schedulesSubscription;

  List<Schedule> get schedules => _schedules;
  bool get isLoading => _isLoading;

  void fetchSchedules(String userId) {
    _isLoading = true;
    notifyListeners();

    _schedulesSubscription?.cancel();
    _schedulesSubscription = _firebaseService
        .getSchedules(userId)
        .listen(
          (schedules) {
            _schedules = schedules;
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            debugPrint('Error fetching schedules: $error');
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  Future<void> addSchedule(
    String title,
    DateTime date,
    TimeOfDay time,
    String description,
    String userId,
    List<String> activities,
  ) async {
    final startTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    final endTime = startTime.add(const Duration(hours: 1));
    final activityMaps = activities
        .map((a) => {'content': a, 'isCompleted': false})
        .toList();

    final newSchedule = Schedule(
      title: title,
      date: date,
      startTime: startTime,
      endTime: endTime,
      description: description,
      userId: userId,
      activities: activityMaps,
      isGenerated: activities.isNotEmpty,
    );

    await _firebaseService.addSchedule(newSchedule);
  }

  Future<void> updateSchedule(Schedule schedule) async {
    await _firebaseService.updateSchedule(schedule);
  }

  Future<void> generateAndSaveActivities(Schedule schedule) async {
    if (schedule.isGenerated && schedule.activities.isNotEmpty) return;

    try {
      final rawActivities = await _cohereService.generateActivities(
        schedule.title,
        schedule.date,
        schedule.startTime,
        schedule.endTime,
      );

      final activities = rawActivities
          .map((content) => {'content': content, 'isCompleted': false})
          .toList();

      final updatedSchedule = schedule.copyWith(
        activities: activities,
        isGenerated: true,
      );

      await _firebaseService.updateSchedule(updatedSchedule);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> toggleActivityStatus(
    Schedule schedule,
    int index,
    bool isCompleted,
  ) async {
    final updatedActivities = List<Map<String, dynamic>>.from(
      schedule.activities,
    );
    updatedActivities[index] = {
      ...updatedActivities[index],
      'isCompleted': isCompleted,
    };

    final updatedSchedule = schedule.copyWith(activities: updatedActivities);
    await _firebaseService.updateSchedule(updatedSchedule);
  }

  Future<void> toggleCompletion(String scheduleId, bool isCompleted) async {
    // efficient lookup
    try {
      final schedule = _schedules.firstWhere((s) => s.id == scheduleId);
      final updatedSchedule = schedule.copyWith(isCompleted: isCompleted);
      // Optimistic update
      final index = _schedules.indexWhere((s) => s.id == scheduleId);
      if (index != -1) {
        _schedules[index] = updatedSchedule;
        notifyListeners();
      }
      await _firebaseService.updateSchedule(updatedSchedule);
    } catch (e) {
      debugPrint("Error toggling completion: $e");
    }
  }

  Future<void> deleteSchedule(String id) async {
    await _firebaseService.deleteSchedule(id);
  }

  @override
  void dispose() {
    _schedulesSubscription?.cancel();
    super.dispose();
  }
}
