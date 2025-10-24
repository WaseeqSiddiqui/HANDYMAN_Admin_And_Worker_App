import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WorkerManagementScreen extends StatefulWidget {
  const WorkerManagementScreen({super.key});

  @override
  State<WorkerManagementScreen> createState() => _WorkerManagementScreenState();
}

class _WorkerManagementScreenState extends State<WorkerManagementScreen> {
  final List<Map<String, dynamic>> _workers = [
    {
      'id': 'w001',
      'name': 'Ahmed Hassan',
      'phone': '+966501234567',
      'email': 'ahmed@example.com',
      'stcPayId': 'STC123456',
      'skills': ['AC Repair', 'Refrigerator'],
      'walletBalance': 2500.0,
      'creditBalance': 350.0,
      'isActive': true,
      'isBlocked': false,
      'completedServices': 45,
      'joinedDate': '2024-01-15',
    },
    {
      'id': 'w002',
      'name': 'Mohammed Ali',
      'phone': '+966507654321',
      'email': 'mohammed@example.com',
      'stcPayId': 'STC789012',
      'skills': ['Plumbing', 'Electrical'],
      'walletBalance': 3200.0,
      'creditBalance': 500.0,
      'isActive': true,
      'isBlocked': false,
      'completedServices': 67,
      'joinedDate': '2023-11-20',
    },
    {
      'id': 'w003',
      'name': 'Khalid Ibrahim',
      'phone': '+966509876543',
      'email': 'khalid@example.com',
      'stcPayId': 'STC345678',
      'skills': ['Washing Machine', 'Microwave'],
      'walletBalance': 1800.0,
      'creditBalance': 200.0,
      'isActive': false,
      'isBlocked': true,
      'completedServices': 23,
      'joinedDate': '2024-03-10',
    },
  ];

  String _searchQuery = '';
  String _filterStatus = 'All';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FA);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    final filteredWorkers = _workers.where((worker) {
      final matchesSearch = worker['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          worker['phone'].contains(_searchQuery);
      final matchesFilter = _filterStatus == 'All' ||
          (_filterStatus == 'Active' && worker['isActive']) ||
          (_filterStatus == 'Blocked' && worker['isBlocked']) ||
          (_filterStatus == 'Inactive' && !worker['isActive']);
      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Worker Management'),
        backgroundColor: const Color(0xFF6B5B9A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: cardColor,
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search workers...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: isDark ? const Color(0xFF0F172A) : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Workers list
          Expanded(
            child: filteredWorkers.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No workers found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredWorkers.length,
              itemBuilder: (context, index) {
                final worker = filteredWorkers[index];
                return _buildWorkerCard(worker, cardColor, textColor);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddWorkerDialog,
        backgroundColor: const Color(0xFF6B5B9A),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Add Worker', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildWorkerCard(Map<String, dynamic> worker, Color cardColor, Color textColor) {
    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: const Color(0xFF6B5B9A),
          child: Text(
            worker['name'].substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                worker['name'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
            ),
            if (worker['isBlocked'])
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'BLOCKED',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else if (!worker['isActive'])
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'INACTIVE',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(worker['phone'], style: TextStyle(color: textColor.withOpacity(0.6))),
            Text(
              '${worker['completedServices']} services completed',
              style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.6)),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Email', worker['email'], textColor),
                _buildInfoRow('STC Pay ID', worker['stcPayId'], textColor),
                _buildInfoRow('Joined Date', worker['joinedDate'], textColor),
                const SizedBox(height: 12),
                Text(
                  'Skills:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (worker['skills'] as List<String>).map((skill) {
                    return Chip(
                      label: Text(skill, style: const TextStyle(fontSize: 12)),
                      backgroundColor: const Color(0xFF6B5B9A).withOpacity(0.1),
                      labelStyle: const TextStyle(color: Color(0xFF6B5B9A)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildBalanceCard(
                        'Wallet',
                        worker['walletBalance'],
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildBalanceCard(
                        'Credit',
                        worker['creditBalance'],
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showWorkerDetails(worker),
                        icon: const Icon(Icons.visibility, size: 18),
                        label: const Text('View'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6B5B9A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showEditWorkerDialog(worker),
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _toggleBlockWorker(worker),
                        icon: Icon(
                          worker['isBlocked'] ? Icons.check_circle : Icons.block,
                          size: 18,
                        ),
                        label: Text(worker['isBlocked'] ? 'Unblock' : 'Block'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: worker['isBlocked'] ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: textColor.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(String label, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'SAR ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Workers'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('All'),
              value: 'All',
              groupValue: _filterStatus,
              onChanged: (value) {
                setState(() => _filterStatus = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Active'),
              value: 'Active',
              groupValue: _filterStatus,
              onChanged: (value) {
                setState(() => _filterStatus = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Blocked'),
              value: 'Blocked',
              groupValue: _filterStatus,
              onChanged: (value) {
                setState(() => _filterStatus = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Inactive'),
              value: 'Inactive',
              groupValue: _filterStatus,
              onChanged: (value) {
                setState(() => _filterStatus = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddWorkerDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final stcPayController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Worker'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixText: '+966',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: stcPayController,
                decoration: const InputDecoration(
                  labelText: 'STC Pay ID',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Add worker logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Worker added successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B5B9A),
              foregroundColor: Colors.white,
            ),
            child: const Text('Add Worker'),
          ),
        ],
      ),
    );
  }

  void _showEditWorkerDialog(Map<String, dynamic> worker) {
    // Similar to add dialog but with pre-filled data
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit worker dialog')),
    );
  }

  void _showWorkerDetails(Map<String, dynamic> worker) {
    // Navigate to detailed worker view
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('View details for ${worker['name']}')),
    );
  }

  void _toggleBlockWorker(Map<String, dynamic> worker) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${worker['isBlocked'] ? 'Unblock' : 'Block'} Worker'),
        content: Text(
          'Are you sure you want to ${worker['isBlocked'] ? 'unblock' : 'block'} ${worker['name']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                worker['isBlocked'] = !worker['isBlocked'];
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Worker ${worker['isBlocked'] ? 'blocked' : 'unblocked'} successfully',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: worker['isBlocked'] ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(worker['isBlocked'] ? 'Unblock' : 'Block'),
          ),
        ],
      ),
    );
  }
}