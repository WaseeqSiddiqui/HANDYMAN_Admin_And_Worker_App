import 'package:flutter/material.dart';
import '/services/worker_auth_service.dart';

class WorkerManagementScreen extends StatefulWidget {
  const WorkerManagementScreen({super.key});

  @override
  State<WorkerManagementScreen> createState() => _WorkerManagementScreenState();
}

class _WorkerManagementScreenState extends State<WorkerManagementScreen> {
  String _filterStatus = 'All';
  final TextEditingController _searchController = TextEditingController();
  final _authService = WorkerAuthService();

  final List<Map<String, dynamic>> _workers = [];

  @override
  void initState() {
    super.initState();
    _authService.addListener(_onWorkersUpdated);
    _loadWorkers();
  }

  @override
  void dispose() {
    _authService.removeListener(_onWorkersUpdated);
    _searchController.dispose();
    super.dispose();
  }

  void _onWorkersUpdated() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadWorkers();
        }
      });
    }
  }

  void _loadWorkers() {
    if (!mounted) return;

    setState(() {
      _workers.clear();
      _workers.addAll(_authService.getAllWorkers().map((worker) {
        return {
          'id': worker.id,
          'name': worker.name,
          'nationalId': worker.nationalId,
          'email': worker.email,
          'phone': worker.phone,
          'stcPayId': worker.stcPayId,
          'address': worker.address,
          'status': worker.status,
          'joinDate': worker.joinedDate,
          'totalServices': worker.completedServices,
          'creditBalance': worker.creditBalance,
        };
      }).toList());
    });
  }

  List<Map<String, dynamic>> get _filteredWorkers {
    List<Map<String, dynamic>> filtered = _workers;

    if (_filterStatus != 'All') {
      filtered = filtered.where((w) => w['status'] == _filterStatus).toList();
    }

    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((w) {
        return w['name'].toString().toLowerCase().contains(searchQuery) ||
            w['id'].toString().toLowerCase().contains(searchQuery) ||
            w['phone'].toString().contains(searchQuery);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Worker Management'),
        backgroundColor: const Color(0xFF6B5B9A),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSummaryCards(),
          _buildSearchAndFilter(),
          Expanded(
            child: _filteredWorkers.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredWorkers.length,
              itemBuilder: (context, index) => _buildWorkerCard(_filteredWorkers[index]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddWorkerDialog,
        backgroundColor: const Color(0xFF6B5B9A),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Worker'),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final activeWorkers = _workers.where((w) => w['status'] == 'Active').length;
    final blockedWorkers = _workers.where((w) => w['status'] == 'Blocked').length;
    final totalServices = _workers.fold(0, (sum, w) => sum + (w['totalServices'] as int));

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSmallStatCard('Active Workers', '$activeWorkers', Icons.people, Colors.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSmallStatCard('Blocked', '$blockedWorkers', Icons.block, Colors.red),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSmallStatCard('Services', '$totalServices', Icons.build_circle, Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center, maxLines: 2),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search by name, ID, or phone...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
              )
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Active', 'Blocked'].map((status) {
                final isSelected = _filterStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (selected) => setState(() => _filterStatus = status),
                    selectedColor: const Color(0xFF6B5B9A),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
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
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            _workers.isEmpty ? 'No workers registered' : 'No workers found',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkerCard(Map<String, dynamic> worker) {
    final status = worker['status'] as String;
    final isActive = status == 'Active';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showWorkerDetailsDialog(worker),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFF6B5B9A).withOpacity(0.1),
                    child: Text(
                      worker['name'].toString().substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF6B5B9A)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(worker['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('${worker['id']} • ${worker['phone']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(isActive ? Icons.check_circle : Icons.block, size: 14, color: isActive ? Colors.green : Colors.red),
                        const SizedBox(width: 4),
                        Text(status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isActive ? Colors.green : Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildInfoColumn('Services', '${worker['totalServices']}', Icons.build, Colors.blue)),
                  Expanded(child: _buildInfoColumn('Credit', 'SAR ${worker['creditBalance'].toStringAsFixed(0)}', Icons.credit_card, const Color(0xFF6B5B9A))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey), textAlign: TextAlign.center),
      ],
    );
  }

  // ✅ UPDATED: Add worker dialog with custom initial credit
  void _showAddWorkerDialog() {
    final nameController = TextEditingController();
    final nameArabicController = TextEditingController();
    final nationalIdController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final stcPayController = TextEditingController();
    final addressController = TextEditingController();
    final addressArabicController = TextEditingController();
    final initialCreditController = TextEditingController(text: '100'); // ✅ Default 100 SAR

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => WillPopScope(
        onWillPop: () async => true,
        child: AlertDialog(
          title: const Text('Add New Worker'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name (English) *',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameArabicController,
                  textDirection: TextDirection.rtl,
                  decoration: const InputDecoration(
                    labelText: 'الاسم الكامل (Arabic) *',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nationalIdController,
                  decoration: const InputDecoration(
                    labelText: 'National ID *',
                    prefixIcon: Icon(Icons.credit_card),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number *',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                    hintText: '+966501234567',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: stcPayController,
                  decoration: const InputDecoration(
                    labelText: 'STC Pay ID *',
                    prefixIcon: Icon(Icons.payment),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Address (English) *',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressArabicController,
                  maxLines: 2,
                  textDirection: TextDirection.rtl,
                  decoration: const InputDecoration(
                    labelText: 'العنوان (Arabic) *',
                    prefixIcon: Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                // ✅ NEW: Initial Credit Field
                TextField(
                  controller: initialCreditController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Initial Credit (SAR) *',
                    prefixIcon: const Icon(Icons.account_balance_wallet),
                    border: const OutlineInputBorder(),
                    hintText: 'Default: 100 SAR',
                    helperText: 'Set initial credit balance for worker',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.info_outline, size: 20),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Initial credit is used for service commissions & VAT'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                nameController.dispose();
                nameArabicController.dispose();
                nationalIdController.dispose();
                emailController.dispose();
                phoneController.dispose();
                stcPayController.dispose();
                addressController.dispose();
                addressArabicController.dispose();
                initialCreditController.dispose();
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validate
                if (nameController.text.isEmpty ||
                    nameArabicController.text.isEmpty ||
                    nationalIdController.text.isEmpty ||
                    emailController.text.isEmpty ||
                    phoneController.text.isEmpty ||
                    stcPayController.text.isEmpty ||
                    addressController.text.isEmpty ||
                    addressArabicController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all required fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // ✅ Validate initial credit
                final initialCredit = double.tryParse(initialCreditController.text.trim());
                if (initialCredit == null || initialCredit < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid initial credit amount'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Create worker data
                final newWorkerId = 'W${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
                final newWorker = WorkerData(
                  id: newWorkerId,
                  name: nameController.text.trim(),
                  nameArabic: nameArabicController.text.trim(),
                  nationalId: nationalIdController.text.trim(),
                  email: emailController.text.trim(),
                  phone: phoneController.text.trim(),
                  stcPayId: stcPayController.text.trim(),
                  address: addressController.text.trim(),
                  addressArabic: addressArabicController.text.trim(),
                  status: 'Active',
                  joinedDate: DateTime.now(),
                  completedServices: 0,
                  creditBalance: initialCredit, // ✅ Use custom initial credit
                );

                Navigator.of(dialogContext).pop();

                final workerName = nameController.text.trim();
                final workerPhone = phoneController.text.trim();
                final creditAmount = initialCredit;

                nameController.dispose();
                nameArabicController.dispose();
                nationalIdController.dispose();
                emailController.dispose();
                phoneController.dispose();
                stcPayController.dispose();
                addressController.dispose();
                addressArabicController.dispose();
                initialCreditController.dispose();

                await Future.delayed(const Duration(milliseconds: 300));

                if (!mounted) return;

                final success = _authService.addWorker(newWorker);

                if (!mounted) return;

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ Worker "$workerName" added successfully!\nPhone: $workerPhone\nInitial Credit: SAR ${creditAmount.toStringAsFixed(2)}'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 5),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('❌ Worker with this phone already exists'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B5B9A),
                foregroundColor: Colors.white,
              ),
              child: const Text('Add Worker'),
            ),
          ],
        ),
      ),
    );
  }

  void _showWorkerDetailsDialog(Map<String, dynamic> worker) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: ListView(
              controller: scrollController,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xFF6B5B9A).withOpacity(0.1),
                      child: Text(
                        worker['name'].toString().substring(0, 1).toUpperCase(),
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF6B5B9A)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(worker['name'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          Text(worker['id'], style: const TextStyle(fontSize: 14, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildDetailRow(Icons.credit_card, 'National ID', worker['nationalId']),
                _buildDetailRow(Icons.email, 'Email', worker['email']),
                _buildDetailRow(Icons.phone, 'Phone', worker['phone']),
                _buildDetailRow(Icons.payment, 'STC Pay ID', worker['stcPayId']),
                _buildDetailRow(Icons.location_on, 'Address', worker['address']),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showEditWorkerDialog(worker);
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6B5B9A),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _toggleWorkerStatus(worker);
                        },
                        icon: Icon(worker['status'] == 'Active' ? Icons.block : Icons.check_circle),
                        label: Text(worker['status'] == 'Active' ? 'Block' : 'Unblock'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: worker['status'] == 'Active' ? Colors.red : Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF6B5B9A), size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditWorkerDialog(Map<String, dynamic> worker) {
    // Similar pattern as add but with pre-filled data
  }

  void _toggleWorkerStatus(Map<String, dynamic> worker) {
    final newStatus = worker['status'] == 'Active' ? 'Blocked' : 'Active';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${newStatus == 'Active' ? 'Unblock' : 'Block'} Worker'),
        content: Text('Are you sure you want to ${newStatus == 'Active' ? 'unblock' : 'block'} ${worker['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await Future.delayed(const Duration(milliseconds: 300));

              if (!mounted) return;

              _authService.toggleWorkerStatus(worker['phone']);

              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Worker ${worker['name']} ${newStatus == 'Active' ? 'unblocked' : 'blocked'}'),
                  backgroundColor: newStatus == 'Active' ? Colors.green : Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus == 'Active' ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(newStatus == 'Active' ? 'Unblock' : 'Block'),
          ),
        ],
      ),
    );
  }
}