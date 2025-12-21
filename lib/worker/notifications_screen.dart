import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WorkerNotificationsScreen extends StatefulWidget {
  const WorkerNotificationsScreen({super.key});

  @override
  State<WorkerNotificationsScreen> createState() =>
      _WorkerNotificationsScreenState();
}

class _WorkerNotificationsScreenState extends State<WorkerNotificationsScreen> {
  String _selectedFilter = 'All';

  // Helper to map type to Icon and Color
  Map<String, dynamic> _getTypeDetails(String type) {
    switch (type.toLowerCase()) {
      case 'service':
        return {'icon': Icons.build_circle, 'color': Colors.blue};
      case 'payment':
        return {'icon': Icons.account_balance_wallet, 'color': Colors.green};
      case 'reminder':
        return {'icon': Icons.notifications_active, 'color': Colors.orange};
      case 'warning':
        return {'icon': Icons.warning, 'color': Colors.red};
      case 'system':
        return {'icon': Icons.system_update, 'color': const Color(0xFF005DFF)};
      case 'review':
        return {'icon': Icons.star, 'color': Colors.amber};
      default:
        return {'icon': Icons.notifications, 'color': Colors.grey};
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FA);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'clear') {
                _clearAllNotifications();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline),
                    SizedBox(width: 8),
                    Text('Clear all'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var docs = snapshot.data!.docs;

                // Filter locally (or update query above)
                if (_selectedFilter != 'All') {
                  if (_selectedFilter == 'Unread') {
                    docs = docs
                        .where(
                          (d) =>
                              (d.data() as Map<String, dynamic>)['isRead'] ==
                              false,
                        )
                        .toList();
                  } else {
                    docs = docs
                        .where(
                          (d) =>
                              (d.data() as Map<String, dynamic>)['type'] ==
                              _selectedFilter.toLowerCase(),
                        )
                        .toList();
                  }
                }

                if (docs.isEmpty) {
                  return _buildEmptyState(textColor);
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;
                    String id = docs[index].id;

                    // Add ID to data for easier handling
                    data['id'] = id;

                    // Add derived icon/color
                    var details = _getTypeDetails(data['type'] ?? 'general');
                    data['icon'] = details['icon'];
                    data['color'] = details['color'];

                    // Handle Timestamp
                    if (data['timestamp'] is Timestamp) {
                      data['timestamp'] = (data['timestamp'] as Timestamp)
                          .toDate();
                    } else {
                      data['timestamp'] = DateTime.now();
                    }

                    return _buildNotificationCard(
                      data,
                      cardColor,
                      textColor,
                      id,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        children:
            [
                  'All',
                  'Unread',
                  'Service',
                  'Payment',
                  'Reminder',
                  'Warning',
                  'System',
                ]
                .map(
                  (filter) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: _selectedFilter == filter,
                      onSelected: (selected) {
                        setState(() => _selectedFilter = filter);
                      },
                      selectedColor: const Color(0xFF005DFF),
                      labelStyle: TextStyle(
                        color: _selectedFilter == filter ? Colors.white : null,
                        fontWeight: _selectedFilter == filter
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildNotificationCard(
    Map<String, dynamic> notification,
    Color cardColor,
    Color textColor,
    String docId,
  ) {
    final bool isUnread =
        !(notification['isRead'] ??
            true); // Default to read if missing, or handle null

    return Dismissible(
      key: Key(docId),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        FirebaseFirestore.instance
            .collection('notifications')
            .doc(docId)
            .delete();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Notification deleted')));
      },
      child: GestureDetector(
        onTap: () => _openNotification(notification, docId),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isUnread
                ? notification['color'].withOpacity(0.05)
                : cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isUnread
                  ? notification['color'].withOpacity(0.3)
                  : Colors.transparent,
              width: isUnread ? 2 : 0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: notification['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    notification['icon'],
                    color: notification['color'],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification['title'] ?? 'No Title',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isUnread
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ),
                          if (isUnread)
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: notification['color'],
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification['message'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTimestamp(notification['timestamp']),
                        style: TextStyle(
                          fontSize: 12,
                          color: textColor.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: textColor.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textColor.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('dd/MM/yyyy').format(timestamp);
    }
  }

  void _openNotification(Map<String, dynamic> notification, String docId) {
    // Mark as read
    FirebaseFirestore.instance.collection('notifications').doc(docId).update({
      'isRead': true,
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(notification['icon'], color: notification['color']),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                notification['title'],
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification['message']),
            const SizedBox(height: 12),
            Text(
              _formatTimestamp(notification['timestamp']),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _clearAllNotifications() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      var snapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All notifications cleared')),
        );
      }
    }
  }
}
