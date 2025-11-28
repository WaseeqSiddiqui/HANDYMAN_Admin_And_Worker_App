import 'package:flutter/material.dart';

class WorkerNotificationsScreen extends StatefulWidget {
  const WorkerNotificationsScreen({super.key});

  @override
  State<WorkerNotificationsScreen> createState() => _WorkerNotificationsScreenState();
}

class _WorkerNotificationsScreenState extends State<WorkerNotificationsScreen> {
  String _selectedFilter = 'All';

  // Mock notifications data
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'New Service Request',
      'message': 'You have been assigned a new AC Repair service at Building 12, Sultan Town',
      'type': 'service',
      'isRead': false,
      'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
      'icon': Icons.build_circle,
      'color': Colors.blue,
    },
    {
      'id': '2',
      'title': 'Payment Received',
      'message': 'SAR 420.00 has been added to your wallet for Service #SRV047',
      'type': 'payment',
      'isRead': false,
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'icon': Icons.account_balance_wallet,
      'color': Colors.green,
    },
    {
      'id': '3',
      'title': 'Service Reminder',
      'message': 'You have a service scheduled today at 2:00 PM - Washing Machine Service',
      'type': 'reminder',
      'isRead': true,
      'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
      'icon': Icons.notifications_active,
      'color': Colors.orange,
    },
    {
      'id': '4',
      'title': 'Credit Low Warning',
      'message': 'Your credit balance is low (SAR 50.00). Please top-up to accept new services.',
      'type': 'warning',
      'isRead': true,
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      'icon': Icons.warning,
      'color': Colors.red,
    },
    {
      'id': '5',
      'title': 'System Update',
      'message': 'New features have been added to the app. Check out the latest updates!',
      'type': 'system',
      'isRead': true,
      'timestamp': DateTime.now().subtract(const Duration(days: 2)),
      'icon': Icons.system_update,
      'color': const Color(0xFF005DFF),
    },
    {
      'id': '6',
      'title': 'Service Completed',
      'message': 'Service #SRV046 has been marked as completed. Invoice sent to customer.',
      'type': 'service',
      'isRead': true,
      'timestamp': DateTime.now().subtract(const Duration(days: 3)),
      'icon': Icons.check_circle,
      'color': Colors.green,
    },
    {
      'id': '7',
      'title': 'Customer Review',
      'message': 'You received a 5-star review from Fatima Khan for Washing Machine Service',
      'type': 'review',
      'isRead': true,
      'timestamp': DateTime.now().subtract(const Duration(days: 5)),
      'icon': Icons.star,
      'color': Colors.amber,
    },
  ];

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_selectedFilter == 'All') {
      return _notifications;
    } else if (_selectedFilter == 'Unread') {
      return _notifications.where((n) => !n['isRead']).toList();
    } else {
      return _notifications.where((n) => n['type'] == _selectedFilter.toLowerCase()).toList();
    }
  }

  int get _unreadCount => _notifications.where((n) => !n['isRead']).length;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FA);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notifications'),
            if (_unreadCount > 0)
              Text(
                '$_unreadCount unread',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
          ],
        ),
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(color: Colors.white),
              ),
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'clear') {
                _clearAllNotifications();
              } else if (value == 'settings') {
                _openNotificationSettings();
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
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined),
                    SizedBox(width: 8),
                    Text('Notification settings'),
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
            child: _filteredNotifications.isEmpty
                ? _buildEmptyState(textColor)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredNotifications.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationCard(
                        _filteredNotifications[index],
                        cardColor,
                        textColor,
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
        children: ['All', 'Unread', 'Service', 'Payment', 'Reminder', 'Warning', 'System']
            .map((filter) => Padding(
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
                      fontWeight: _selectedFilter == filter ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildNotificationCard(
    Map<String, dynamic> notification,
    Color cardColor,
    Color textColor,
  ) {
    final bool isUnread = !notification['isRead'];

    return Dismissible(
      key: Key(notification['id']),
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
        setState(() {
          _notifications.removeWhere((n) => n['id'] == notification['id']);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notification deleted'),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () {
                setState(() {
                  // In a real app, restore from a temporary list
                });
              },
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: () => _openNotification(notification),
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
                              notification['title'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
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
                        notification['message'],
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
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'All'
                ? 'You\'re all caught up!'
                : 'No ${_selectedFilter.toLowerCase()} notifications',
            style: TextStyle(
              fontSize: 14,
              color: textColor.withOpacity(0.4),
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
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _openNotification(Map<String, dynamic> notification) {
    setState(() {
      notification['isRead'] = true;
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
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (notification['type'] == 'service')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to service details
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening service details...')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF005DFF),
              ),
              child: const Text('View Service'),
            ),
        ],
      ),
    );
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _notifications.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications cleared'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _openNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Service Requests'),
              subtitle: const Text('Get notified about new services'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Payment Updates'),
              subtitle: const Text('Wallet and payment notifications'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Service Reminders'),
              subtitle: const Text('Upcoming service reminders'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('System Updates'),
              subtitle: const Text('App updates and announcements'),
              value: false,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings saved'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005DFF),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
