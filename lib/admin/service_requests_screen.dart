import 'package:flutter/material.dart';

class ServiceRequestsScreen extends StatefulWidget {
  const ServiceRequestsScreen({super.key});

  @override
  State<ServiceRequestsScreen> createState() => _ServiceRequestsScreenState();
}

class _ServiceRequestsScreenState extends State<ServiceRequestsScreen> {
  String _selectedStatus = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Requests'),
        backgroundColor: const Color(0xFF6B5B9A),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 10,
              itemBuilder: (context, index) => _buildRequestCard(index),
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
        children: ['All', 'Requested', 'Assigned', 'Completed', 'Postponed']
            .map((status) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: FilterChip(
            label: Text(status),
            selected: _selectedStatus == status,
            onSelected: (selected) {
              setState(() => _selectedStatus = status);
            },
            selectedColor: const Color(0xFF6B5B9A),
            labelStyle: TextStyle(
              color: _selectedStatus == status ? Colors.white : null,
            ),
          ),
        ))
            .toList(),
      ),
    );
  }

  Widget _buildRequestCard(int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF6B5B9A),
          child: Text('#${index + 1}'),
        ),
        title: Text('Service Request #SRV00${index + 1}'),
        subtitle: Text('Customer Name • AC Repair • SAR 450'),
        trailing: Chip(
          label: const Text('Pending', style: TextStyle(fontSize: 11)),
          backgroundColor: Colors.orange.withOpacity(0.2),
        ),
        onTap: () {},
      ),
    );
  }
}