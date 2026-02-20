import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:intl/intl.dart';
import '../providers/schedule_provider.dart';
import '../providers/auth_provider.dart';
import '../models/schedule_model.dart';
import 'add_schedule_screen.dart';
import 'schedule_detail_screen.dart';

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
            _buildCategoryGrid(),
            
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
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
                        return _buildScheduleCard(schedule, isSelected);
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
            _buildNavItem(Icons.home, 'Home', true),
            _buildNavItem(Icons.calendar_month, 'Agenda', false),
            const SizedBox(width: 40),
            _buildNavItem(Icons.assignment, 'Task', false),
            _buildNavItem(Icons.person, 'Profile', false),
          ],
        ),
      ),
    );
  }

  // Masukkan ke dalam body Column di HomeScreen
  Widget _buildCategoryGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildCategoryCard('Project', Icons.computer, true), // Dark Card
          _buildCategoryCard(
            'Exercise',
            Icons.fitness_center,
            false,
          ), // Light Card
          _buildCategoryCard('Learning', Icons.menu_book, false),
          _buildCategoryCard('Rest', Icons.bedtime, false),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D503C) : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 50,
            color: isDark ? Colors.white : const Color(0xFF2D503C),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF2D503C),
              fontWeight: FontWeight.bold,
              fontSize: 16,
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

  Widget _buildScheduleCard(Schedule schedule, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (_isSelectionMode) {
          _toggleSelectionMode(schedule.id);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScheduleDetailScreen(schedule: schedule),
            ),
          );
        }
      },
      onLongPress: () => _toggleSelectionMode(schedule.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? darkGreen.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: isSelected ? Border.all(color: darkGreen, width: 2) : null,
        ),
        child: Row(
          children: [
            if (_isSelectionMode)
              Checkbox(
                value: isSelected,
                onChanged: (_) => _toggleSelectionMode(schedule.id),
                activeColor: darkGreen,
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    schedule.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: darkGreen,
                    ),
                  ),
                  Text(
                    DateFormat('HH:mm').format(schedule.startTime),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                schedule.isCompleted
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: schedule.isCompleted ? Colors.green : Colors.grey,
              ),
              onPressed: () {
                Provider.of<ScheduleProvider>(
                  context,
                  listen: false,
                ).toggleCompletion(schedule.id, !schedule.isCompleted);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool active) {
    return Column(
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
