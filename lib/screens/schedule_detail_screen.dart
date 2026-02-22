import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/schedule_model.dart';
import '../providers/schedule_provider.dart';

class ScheduleDetailScreen extends StatefulWidget {
  final Schedule schedule;
  const ScheduleDetailScreen({super.key, required this.schedule});

  @override
  State<ScheduleDetailScreen> createState() => _ScheduleDetailScreenState();
}

class _ScheduleDetailScreenState extends State<ScheduleDetailScreen> {
  final Map<int, bool> _activityStatus = {};

  void _deleteSchedule(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Schedule'),
        content: const Text('Are you sure you want to delete this schedule?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<ScheduleProvider>(
                context,
                listen: false,
              ).deleteSchedule(widget.schedule.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    final isDone = widget.schedule.isCompleted;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Task Details",
          style: TextStyle(
            color: Color(0xFF2D503C),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D503C)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _deleteSchedule(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDone
                        ? Colors.green.withOpacity(0.1)
                        : const Color(0xFFE9F0E4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isDone ? "Success" : "Ongoing",
                    style: TextStyle(
                      color: isDone ? Colors.green : const Color(0xFF2D503C),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  DateFormat('MMM dd, yyyy').format(widget.schedule.startTime),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Text(
              widget.schedule.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D503C),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  DateFormat('HH:mm').format(widget.schedule.startTime),
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),

            const SizedBox(height: 32),
            const Text(
              "Description",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.schedule.description ?? "No description provided.",
              style: const TextStyle(color: Colors.black54, height: 1.5),
            ),

            const SizedBox(height: 32),
            const Text(
              "Generated Activities",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            if (widget.schedule.activities.isEmpty)
              const Text(
                "No activities generated.",
                style: TextStyle(color: Colors.grey),
              )
            else
              ...List.generate(widget.schedule.activities.length, (index) {
                final activityMap = widget.schedule.activities[index];
                final activityText = activityMap['content'] ?? '';
                bool isCheck = _activityStatus[index] ?? false;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: CheckboxListTile(
                    value: isCheck,
                    activeColor: const Color(0xFF2D503C),
                    checkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    title: Text(
                      activityText,
                      style: TextStyle(
                        decoration: isCheck ? TextDecoration.lineThrough : null,
                        color: isCheck ? Colors.grey : Colors.black87,
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _activityStatus[index] = val!;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                );
              }),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDone
                      ? Colors.grey
                      : const Color(0xFF2D503C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                onPressed: isDone
                    ? null
                    : () async {
                        await scheduleProvider.toggleCompletion(
                          widget.schedule.id,
                          true,
                        );
                        if (mounted) Navigator.pop(context);
                      },
                child: Text(
                  isDone ? "Task Completed" : "Mark as Finished",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
