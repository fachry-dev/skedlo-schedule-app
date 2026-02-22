import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:intl/intl.dart';
import '../providers/schedule_provider.dart';
import '../providers/auth_provider.dart';
import '../models/schedule_model.dart';
import 'add_schedule_screen.dart';
import 'schedule_detail_screen.dart';
import 'profile_screen.dart';
import 'agenda_screen.dart';
import 'task_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSelectionMode = false;
  final Set<String> _selectedScheduleIds = {};

  final Color darkGreen = const Color(0xFF2D503C);
  final Color sageGreen = const Color(0xFFCAD7CD);
  final Color lightBg = const Color(0xFFE0E9E1);

  @override
  void initState() {
    super.initState();
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
          if (_selectedScheduleIds.isEmpty) _isSelectionMode = false;
        } else {
          _selectedScheduleIds.add(scheduleId);
        }
      } else {
        _isSelectionMode = true;
        _selectedScheduleIds.add(scheduleId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final scheduleProvider = Provider.of<ScheduleProvider>(context);

    final userName = authProvider.user?.displayName ?? 'User';
    final allSchedules = scheduleProvider.schedules;

    return Scaffold(
      backgroundColor: sageGreen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _isSelectionMode
            ? Text(
                '${_selectedScheduleIds.length} terpilih',
                style: TextStyle(color: darkGreen),
              )
            : Text(
                'Hi, $userName!',
                style: TextStyle(
                  color: darkGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
        actions: [
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.red),
              onPressed: _confirmDelete,
            )
          else
            IconButton(
              icon: Icon(Icons.logout, color: darkGreen),
              onPressed: () => authProvider.signOut(),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: _buildWelcomeBanner(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Text(
                'Recent Schedule',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D503C),
                ),
              ),
            ),
            Expanded(
              child: scheduleProvider.isLoading
                  ? Center(child: CircularProgressIndicator(color: darkGreen))
                  : allSchedules.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: allSchedules.length,
                      itemBuilder: (context, index) {
                        final schedule = allSchedules[index];
                        final isSelected = _selectedScheduleIds.contains(
                          schedule.id,
                        );

                        bool isLast = index == allSchedules.length - 1;

                        return _buildTimelineScheduleCard(
                          schedule,
                          isSelected,
                          isLast,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddScheduleScreen()),
        ),
        backgroundColor: darkGreen,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: lightBg,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 'Home', true, () {}),
            _buildNavItem(Icons.calendar_month, 'Agenda', false, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AgendaScreen()));
            }),
            const SizedBox(width: 40),
            _buildNavItem(Icons.assignment, 'Task', false, () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const TaskScreen()));
      }),
            _buildNavItem(Icons.person, 'Profile', false, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            }),
          ],
        ),
      ),
    );
  }


Widget _buildCategoryCard(String title, IconData icon, bool isDark) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF2D503C) : Colors.white.withOpacity(0.7),
      borderRadius: BorderRadius.circular(24), // Sudut lebih bulat
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {}, 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFF2D503C).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: isDark ? Colors.white : const Color(0xFF2D503C)),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF2D503C),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildTimelineScheduleCard(
    Schedule schedule,
    bool isSelected,
    bool isLast,
  ) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: schedule.isCompleted ? darkGreen : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: darkGreen, width: 2),
                ),
                child: schedule.isCompleted
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: darkGreen.withOpacity(0.3)),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
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
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? darkGreen.withOpacity(0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: isSelected
                      ? Border.all(color: darkGreen, width: 2)
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('HH:mm').format(schedule.startTime),
                          style: TextStyle(
                            color: darkGreen.withOpacity(0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: schedule.isCompleted
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            schedule.isCompleted ? "Done" : "Upcoming",
                            style: TextStyle(
                              color: schedule.isCompleted
                                  ? Colors.green
                                  : Colors.orange,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      schedule.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: darkGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      schedule.description ?? "No description",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: lightBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: darkGreen, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: darkGreen,
                  ),
                ),
                Text(
                  'Lets manage your time',
                  style: TextStyle(color: darkGreen),
                ),
              ],
            ),
          ),
          Icon(Icons.laptop_chromebook, size: 50, color: darkGreen),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool active,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? darkGreen : Colors.grey),
          Text(
            label,
            style: TextStyle(
              color: active ? darkGreen : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: darkGreen.withOpacity(0.3)),
          const SizedBox(height: 10),
          Text('Belum ada jadwal', style: TextStyle(color: darkGreen)),
        ],
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Jadwal?'),
        content: Text(
          'Anda akan menghapus ${_selectedScheduleIds.length} jadwal.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final provider = Provider.of<ScheduleProvider>(context, listen: false);
      for (var id in _selectedScheduleIds) {
        await provider.deleteSchedule(id);
      }
      setState(() {
        _selectedScheduleIds.clear();
        _isSelectionMode = false;
      });
    }
  }
}
