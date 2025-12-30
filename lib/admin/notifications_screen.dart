import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _recipientType = 'All';
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Notifications'),
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recipient Type',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ['All', 'Workers', 'Customers', 'Specific']
                  .map(
                    (type) => ChoiceChip(
                      label: Text(type),
                      selected: _recipientType == type,
                      onSelected: (selected) {
                        setState(() => _recipientType = type);
                      },
                      selectedColor: const Color(0xFF005DFF),
                      labelStyle: TextStyle(
                        color: _recipientType == type ? Colors.white : null,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Notification Title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.message),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _sendNotification,
                icon: const Icon(Icons.send),
                label: const Text('Send Notification'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005DFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Recent Notifications',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _buildRecentNotificationsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentNotificationsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        // Client-side filtering for 'admin' or 'All'
        final adminNotifications = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final targets = List<String>.from(data['targetUserIds'] ?? []);
          return targets.contains('admin') || targets.contains('All');
        }).toList();

        if (adminNotifications.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No notifications found'),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: adminNotifications.length,
          itemBuilder: (context, index) {
            final data =
                adminNotifications[index].data() as Map<String, dynamic>;
            // Format timestamp if needed, using simple string for now or intl package if available
            // For simplicity, showing a generic date or trying to parse if it exists
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(
                  Icons.notifications,
                  color: Color(0xFF005DFF),
                ),
                title: Text(data['title'] ?? 'No Title'),
                subtitle: Text(data['message'] ?? 'No Body'),
                trailing: data['isRead'] == true
                    ? const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16,
                      )
                    : const Icon(Icons.circle, color: Colors.red, size: 12),
              ),
            );
          },
        );
      },
    );
  }

  void _sendNotification() async {
    if (_titleController.text.isEmpty || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Send notification (Write to Firestore which Worker app listens to)
    await NotificationService().createNotificationInFirestore(
      title: _titleController.text,
      body: _messageController.text,
      type: 'system', // Default type for admin messages
      targetUserIds: _recipientType == 'All'
          ? ['All']
          : [], // Simple logic for now
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification sent successfully'),
        backgroundColor: Colors.green,
      ),
    );
    _titleController.clear();
    _messageController.clear();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
