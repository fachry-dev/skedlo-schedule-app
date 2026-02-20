import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final scheduleProvider = Provider.of<ScheduleProvider>(context);

    // Menghitung Progres
    final totalTasks = scheduleProvider.schedules.length;
    final completedTasks = scheduleProvider.schedules
        .where((s) => s.isCompleted)
        .length;
    final double progress = totalTasks == 0 ? 0 : completedTasks / totalTasks;

    return Scaffold(
      backgroundColor: const Color(0xFFCAD7CD),
      body: Column(
        children: [
          // Header Profile
          Container(
            height: 350,
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFF2D503C),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage(
                    'assets/images/profile_picture.png',
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  authProvider.user?.displayName ?? 'Fachry Wardana',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Software Engineer',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Text(
                  "Remid Task",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),
                _buildProgressItem(
                  "Develop Web & App",
                  "stack: Laravel, Postgres, Flutter",
                  progress,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(
    String title,
    String subtitle,
    double progressValue,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.laptop_chromebook,
            size: 40,
            color: Color(0xFF2D503C),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progressValue,
                  backgroundColor: Colors.grey[300],
                  color: const Color(0xFF2D503C),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            "${(progressValue * 100).toInt()}%",
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }
}
