import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:intl/intl.dart';
import '../providers/schedule_provider.dart';
import '../providers/auth_provider.dart';
import '../models/schedule_model.dart';
import 'add_schedule_screen.dart';
import 'schedule_detail_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Selection mode state
  bool _isSelectionMode = false;
  final Set<String> _selectedScheduleIds = {};

  @override
  void initState() {
    super.initState();
    // Fetch schedules when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId =
          authProvider.user?.uid ?? FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        Provider.of<ScheduleProvider>(
          context,
          listen: false,
        ).fetchSchedules(userId);
      }
    });
  }

  void _toggleSelectionMode(String scheduleId) {
    setState(() {
      if (_isSelectionMode) {
        if (_selectedScheduleIds.contains(scheduleId)) {
          _selectedScheduleIds.remove(scheduleId);
          if (_selectedScheduleIds.isEmpty) {
            _isSelectionMode = false;
          }
        } else {
          _selectedScheduleIds.add(scheduleId);
        }
      } else {
        _isSelectionMode = true;
        _selectedScheduleIds.add(scheduleId);
      }
    });
  }

  Future<void> _deleteSelected() async {
    final provider = Provider.of<ScheduleProvider>(context, listen: false);

    // Show confirmation dialog (optional, for safety)
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Selected?'),
        content: Text(
          'Are you sure you want to delete ${_selectedScheduleIds.length} items?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      for (final id in _selectedScheduleIds) {
        await provider.deleteSchedule(id);
      }
      setState(() {
        _selectedScheduleIds.clear();
        _isSelectionMode = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Schedules deleted')));
      }
    }
  }

  Future<void> _logout() async {
    await Provider.of<AuthProvider>(context, listen: false).signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user =
        Provider.of<AuthProvider>(context).user ??
        FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'User';

    // Filter logic for dashboard stats
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    final allSchedules = scheduleProvider.schedules;
    final ongoingCount = allSchedules.where((s) => !s.isCompleted).length;
    final completedCount = allSchedules.where((s) => s.isCompleted).length;

    // Placeholder logic for "Pending" and "Cancel" as per design request/visuals
    // In a real app, these might be specific status fields.
    // For now, we'll map: Ongoing -> Not Completed, Completed -> Completed.
    // We can keep Pending/Cancel as 0 or derive from other logic if we add it later.
    final pendingCount = 0;
    final cancelCount = 0;

    return Scaffold(
      backgroundColor: Colors
          .grey[50], // Very light grey background for contrast with white cards
      appBar: AppBar(
        title: _isSelectionMode
            ? Text('${_selectedScheduleIds.length} Selected')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi, $userName',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    DateFormat('EEEE, d MMM y').format(DateTime.now()),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
        actions: [
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: colorScheme.error,
              onPressed: _deleteSelected,
            )
          else
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              color: colorScheme.primary,
              onPressed: _logout,
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dashboard Row (Horizontal Scroll)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  _buildDashboardCard(
                    context,
                    title: 'Ongoing',
                    count: ongoingCount.toString(),
                    icon: Icons.sync,
                    color: colorScheme.primary, // Black
                    textColor: Colors.white,
                    iconColor: colorScheme.secondary, // Yellow icon
                  ),
                  const SizedBox(width: 12),
                  _buildDashboardCard(
                    context,
                    title: 'Pending',
                    count: pendingCount.toString(),
                    icon: Icons.timer_outlined,
                    color: colorScheme.secondary, // Yellow
                    textColor: colorScheme.primary, // Black text
                    iconColor: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  _buildDashboardCard(
                    context,
                    title: 'Completed',
                    count: completedCount.toString(),
                    icon: Icons.check_circle_outline,
                    color: Colors.blue[50]!,
                    textColor: Colors.blue[900]!,
                    iconColor: Colors.blue[900]!,
                  ),
                  const SizedBox(width: 12),
                  _buildDashboardCard(
                    context,
                    title: 'Canceled',
                    count: cancelCount.toString(),
                    icon: Icons.cancel_outlined,
                    color: Colors.red[50]!,
                    textColor: Colors.red[900]!,
                    iconColor: Colors.red[900]!,
                  ),
                ],
              ),
            ),

            // List Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Schedule',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Maybe navigate to a "View All" screen if list is limited
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),

            // Schedule List
            Expanded(
              child: scheduleProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : allSchedules.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_note_outlined,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No schedules yet',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: allSchedules.length,
                      separatorBuilder: (ctx, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final schedule = allSchedules[index];
                        final isSelected = _selectedScheduleIds.contains(
                          schedule.id,
                        );

                        return _buildScheduleCard(
                          context,
                          schedule: schedule,
                          isSelected: isSelected,
                          onTap: () {
                            if (_isSelectionMode) {
                              _toggleSelectionMode(schedule.id);
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ScheduleDetailScreen(schedule: schedule),
                                ),
                              );
                            }
                          },
                          onLongPress: () => _toggleSelectionMode(schedule.id),
                          onToggleComplete: () {
                            scheduleProvider.toggleCompletion(
                              schedule.id,
                              !schedule.isCompleted,
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddScheduleScreen()),
          );
        },
        backgroundColor: colorScheme.primary, // Black button
        child: Icon(Icons.add, color: colorScheme.secondary), // Yellow icon
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    required Color textColor,
    required Color iconColor,
  }) {
    return Container(
      width: 140, // Fixed width for consistent look
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2), // Semi-transparent circle
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: textColor.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: TextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(
    BuildContext context, {
    required Schedule schedule,
    required bool isSelected,
    required VoidCallback onTap,
    required VoidCallback onLongPress,
    required VoidCallback onToggleComplete,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: theme.colorScheme.primary, width: 2)
              : Border.all(
                  color: Colors.transparent,
                  width: 2,
                ), // Invisible border for layout stability
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04), // Very subtle shadow
              offset: const Offset(0, 4),
              blurRadius: 16,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Selection or Status Indicator
              if (_isSelectionMode)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (val) => onTap(),
                    activeColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: schedule.isCompleted
                          ? Colors.green
                          : theme.colorScheme.secondary, // Yellow for active
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        decoration: schedule.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: schedule.isCompleted
                            ? Colors.grey
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          schedule.time,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('d MMM').format(schedule.date),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action (Complete Toggle)
              IconButton(
                icon: Icon(
                  schedule.isCompleted
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                  color: schedule.isCompleted ? Colors.green : Colors.grey[400],
                ),
                onPressed: onToggleComplete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
