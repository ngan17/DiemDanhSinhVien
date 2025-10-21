import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/activity.dart';
import '../../utils/mock_data.dart';
import 'activity_detail_screen.dart';

class ActivityRegistrationScreen extends StatefulWidget {
  const ActivityRegistrationScreen({super.key});

  @override
  State<ActivityRegistrationScreen> createState() =>
      _ActivityRegistrationScreenState();
}

class _ActivityRegistrationScreenState extends State<ActivityRegistrationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'Tất cả';
  List<Activity> _filteredActivities = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadActivities();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadActivities() {
    setState(() {
      if (_selectedCategory == 'Tất cả') {
        _filteredActivities = _getActivitiesByTab();
      } else {
        _filteredActivities =
            MockData.getActivitiesByCategory(_selectedCategory).where((
              activity,
            ) {
              if (_tabController.index == 0)
                return activity.status == 'upcoming';
              if (_tabController.index == 1)
                return activity.status == 'ongoing';
              return activity.status == 'completed';
            }).toList();
      }
    });
  }

  List<Activity> _getActivitiesByTab() {
    if (_tabController.index == 0) {
      return MockData.getActivitiesByStatus('upcoming');
    } else if (_tabController.index == 1) {
      return MockData.getActivitiesByStatus('ongoing');
    } else {
      return MockData.getActivitiesByStatus('completed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E90FF),
        elevation: 0,
        title: const Text(
          'Đăng ký hoạt động',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          onTap: (index) {
            _loadActivities();
          },
          tabs: const [
            Tab(text: 'Sắp diễn ra'),
            Tab(text: 'Đang diễn ra'),
            Tab(text: 'Đã kết thúc'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Category filter
          Container(
            height: 60,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: MockData.getCategories().length,
              itemBuilder: (context, index) {
                final category = MockData.getCategories()[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                        _loadActivities();
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: const Color(0xFF1E90FF),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    checkmarkColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                );
              },
            ),
          ),

          // Activities list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildActivityList(),
                _buildActivityList(),
                _buildActivityList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList() {
    if (_filteredActivities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Chưa có hoạt động nào',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadActivities();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredActivities.length,
        itemBuilder: (context, index) {
          final activity = _filteredActivities[index];
          return _buildActivityCard(activity);
        },
      ),
    );
  }

  Widget _buildActivityCard(Activity activity) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ActivityDetailScreen(activity: activity),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with category and score
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getCategoryColor(activity.category),
                    _getCategoryColor(activity.category).withOpacity(0.7),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      activity.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: Color(0xFFFF9800),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+${activity.trainingScore.toStringAsFixed(0)} điểm',
                          style: const TextStyle(
                            color: Color(0xFFFF9800),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Activity details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.calendar_today,
                    '${dateFormat.format(activity.startDate)} - ${dateFormat.format(activity.endDate)}',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.access_time,
                    '${timeFormat.format(activity.startDate)} - ${timeFormat.format(activity.endDate)}',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.location_on, activity.location),
                  const SizedBox(height: 12),

                  // Registration deadline
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.alarm, size: 18, color: Colors.orange[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Hạn đăng ký: ${dateFormat.format(activity.registrationDeadline)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.orange[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Participants progress
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Số lượng đăng ký',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Text(
                                  '${activity.currentParticipants}/${activity.maxParticipants}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            LinearProgressIndicator(
                              value:
                                  activity.currentParticipants /
                                  activity.maxParticipants,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getCategoryColor(activity.category),
                              ),
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Action button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: activity.canRegister
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ActivityDetailScreen(activity: activity),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: activity.isRegistered
                            ? Colors.green
                            : const Color(0xFF1E90FF),
                        disabledBackgroundColor: Colors.grey[300],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        activity.isRegistered
                            ? 'Đã đăng ký'
                            : activity.canRegister
                            ? 'Đăng ký ngay'
                            : 'Hết hạn đăng ký',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: activity.canRegister || activity.isRegistered
                              ? Colors.white
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Học tập':
        return const Color(0xFF2196F3);
      case 'Tình nguyện':
        return const Color(0xFF4CAF50);
      case 'Thể thao':
        return const Color(0xFFFF5722);
      case 'Kỹ năng mềm':
        return const Color(0xFF9C27B0);
      case 'Văn hóa - Xã hội':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF607D8B);
    }
  }
}
