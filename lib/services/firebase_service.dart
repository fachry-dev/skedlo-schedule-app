import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/schedule_model.dart';

class FirebaseService {
  final CollectionReference _schedulesCollection = FirebaseFirestore.instance
      .collection('schedules');

  // Add a new schedule
  // Add a new schedule and return the ID
  Future<String> addSchedule(Schedule schedule) async {
    try {
      final docRef = await _schedulesCollection
          .add(schedule.toMap())
          .timeout(const Duration(seconds: 10));
      return docRef.id;
    } catch (e) {
      print('Error adding schedule: $e');
      rethrow;
    }
  }

  // Get stream of schedules for a specific user
  Stream<List<Schedule>> getSchedules(String userId) {
    return _schedulesCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final schedules = snapshot.docs.map((doc) {
            return Schedule.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

          // Sort client-side to avoid needing a Firestore Composite Index
          schedules.sort((a, b) => a.startTime.compareTo(b.startTime));

          return schedules;
        });
  }

  // Update a schedule (e.g., adding activities)
  Future<void> updateSchedule(Schedule schedule) async {
    try {
      await _schedulesCollection
          .doc(schedule.id)
          .update(schedule.toMap())
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      print('Error updating schedule: $e');
      rethrow;
    }
  }

  // Delete a schedule
  Future<void> deleteSchedule(String id) async {
    try {
      await _schedulesCollection
          .doc(id)
          .delete()
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      print('Error deleting schedule: $e');
      rethrow;
    }
  }
}
