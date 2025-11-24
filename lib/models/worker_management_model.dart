import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/services/worker_auth_service.dart';
import '/providers/app_state_provider.dart';
import '/utils/admin_translations.dart';
import '/models/worker_data_model.dart';

class WorkerManagementScreen extends StatefulWidget {
  const WorkerManagementScreen({super.key});

  @override
  State<WorkerManagementScreen> createState() => _WorkerManagementScreenState();
}

class _WorkerManagementScreenState extends State<WorkerManagementScreen> {
  String _filterStatus = AdminTranslations.split(AdminTranslations.all)[0];
  final TextEditingController _searchController = TextEditingController();
  final WorkerAuthService _authService = WorkerAuthService();

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

    try {
      setState(() {
        _workers.clear();
        _workers.addAll(_authService.getAllWorkers().map((worker) {
          return {
            'id': worker.id,
            'name': worker.name,
            'nameArabic': worker.nameArabic,
            'nationalId': worker.nationalId,
            'email': worker.email,
            'phone': worker.phone,
            'stcPayId': worker.stcPayId,
            'address': worker.address,
            'addressArabic': worker.addressArabic,
            'status': worker.status,
            'joinDate': worker.joinedDate,
            'totalServices': worker.completedServices,
            'creditBalance': worker.creditBalance,
          };
        }).toList());
      });
    } catch (e) {
      debugPrint('Error loading workers: $e');
    }
  }

  List<Map<String, dynamic>> get _filteredWorkers {
    List<Map<String, dynamic>> filtered = List.from(_workers);

    if (_filterStatus != AdminTranslations.split(AdminTranslations.all)[0]) {
      filtered = filtered.where((w) => w['status'] == _filterStatus).toList();
    }

    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((w) {
        return w['name'].toString().toLowerCase().contains(searchQuery) ||
            w['id'].toString().toLowerCase().contains(searchQuery) ||
            w['phone'].toString().contains(searchQuery) ||
            (w['nameArabic']?.toString().contains(searchQuery) ?? false);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // English text - top with font size 16
            Text(
              AdminTranslations.split(AdminTranslations.workerManagement)[0],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            // Arabic text - bottom with font size 14
            Text(
              AdminTranslations.split(AdminTranslations.workerManagement)[1],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
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
        label: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // English text - top
            Text(
              AdminTranslations.split(AdminTranslations.addWorker)[0],
              style: const TextStyle(fontSize: 14),
            ),
            // Arabic text - bottom
            Text(
              AdminTranslations.split(AdminTranslations.addWorker)[1],
              style: const TextStyle(fontSize: 12),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final activeWorkers = _workers.where((w) => w['status'] == AdminTranslations.split(AdminTranslations.active)[0]).length;
    final blockedWorkers = _workers.where((w) => w['status'] == AdminTranslations.split(AdminTranslations.blocked)[0]).length;
    final totalServices = _workers.fold(0, (sum, w) => sum + (w['totalServices'] as int));

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSmallStatCard(
                AdminTranslations.split(AdminTranslations.activeWorkers)[0],
                AdminTranslations.split(AdminTranslations.activeWorkers)[1],
                '$activeWorkers',
                Icons.people,
                Colors.green
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSmallStatCard(
                AdminTranslations.split(AdminTranslations.blocked)[0],
                AdminTranslations.split(AdminTranslations.blocked)[1],
                '$blockedWorkers',
                Icons.block,
                Colors.red
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSmallStatCard(
                AdminTranslations.split(AdminTranslations.services)[0],
                AdminTranslations.split(AdminTranslations.services)[1],
                '$totalServices',
                Icons.build_circle,
                Colors.blue
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStatCard(String labelEn, String labelAr, String value, IconData icon, Color color) {
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
          Column(
            children: [
              Text(labelEn, style: const TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
              Text(labelAr, style: const TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center, textDirection: TextDirection.rtl),
            ],
          ),
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
              hintText: AdminTranslations.split(AdminTranslations.searchWorkers)[0],
              hintStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
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
              children: [
                _buildFilterChip(AdminTranslations.split(AdminTranslations.all)[0], AdminTranslations.split(AdminTranslations.all)[1]),
                _buildFilterChip(AdminTranslations.split(AdminTranslations.active)[0], AdminTranslations.split(AdminTranslations.active)[1]),
                _buildFilterChip(AdminTranslations.split(AdminTranslations.blocked)[0], AdminTranslations.split(AdminTranslations.blocked)[1]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String statusEn, String statusAr) {
    final isSelected = _filterStatus == statusEn;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(statusEn, style: const TextStyle(fontSize: 12)),
            Text(statusAr, style: const TextStyle(fontSize: 10), textDirection: TextDirection.rtl),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) => setState(() => _filterStatus = statusEn),
        selectedColor: const Color(0xFF6B5B9A),
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
        ),
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
          Column(
            children: [
              Text(
                _workers.isEmpty
                    ? AdminTranslations.split(AdminTranslations.noWorkersYet)[0]
                    : AdminTranslations.split(AdminTranslations.noWorkersFound)[0],
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
              ),
              Text(
                _workers.isEmpty
                    ? AdminTranslations.split(AdminTranslations.noWorkersYet)[1]
                    : AdminTranslations.split(AdminTranslations.noWorkersFound)[1],
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkerCard(Map<String, dynamic> worker) {
    final status = worker['status'] as String;
    final isActive = status == AdminTranslations.split(AdminTranslations.active)[0];

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
                      (worker['name']?.toString().substring(0, 1) ?? 'W').toUpperCase(),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF6B5B9A)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            worker['name']?.toString() ?? 'Unknown',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                        ),
                        const SizedBox(height: 2),
                        Text(
                          worker['nameArabic']?.toString() ?? worker['name']?.toString() ?? '',
                          style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                          textDirection: TextDirection.rtl,
                        ),
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
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                                isActive
                                    ? AdminTranslations.split(AdminTranslations.active)[0]
                                    : AdminTranslations.split(AdminTranslations.blocked)[0],
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isActive ? Colors.green : Colors.red)
                            ),
                            Text(
                              isActive
                                  ? AdminTranslations.split(AdminTranslations.active)[1]
                                  : AdminTranslations.split(AdminTranslations.blocked)[1],
                              style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: isActive ? Colors.green : Colors.red),
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),
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
                  Expanded(child: _buildInfoColumn(
                      AdminTranslations.split(AdminTranslations.services)[0],
                      AdminTranslations.split(AdminTranslations.services)[1],
                      '${worker['totalServices']}',
                      Icons.build,
                      Colors.blue
                  )),
                  Expanded(child: _buildInfoColumn(
                      AdminTranslations.split(AdminTranslations.credit)[0],
                      AdminTranslations.split(AdminTranslations.credit)[1],
                      'SAR ${(worker['creditBalance'] as double).toStringAsFixed(0)}',
                      Icons.credit_card,
                      const Color(0xFF6B5B9A)
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String labelEn, String labelAr, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        Column(
          children: [
            Text(labelEn, style: const TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
            Text(labelAr, style: const TextStyle(fontSize: 9, color: Colors.grey), textAlign: TextAlign.center, textDirection: TextDirection.rtl),
          ],
        ),
      ],
    );
  }

  void _showAddWorkerDialog() {
    final nameController = TextEditingController();
    final nameArabicController = TextEditingController();
    final nationalIdController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final stcPayController = TextEditingController();
    final addressController = TextEditingController();
    final addressArabicController = TextEditingController();
    final initialCreditController = TextEditingController(text: '100');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Text(AdminTranslations.split(AdminTranslations.addWorker)[0]),
            const SizedBox(width: 4),
            Text(
              AdminTranslations.split(AdminTranslations.addWorker)[1],
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: AdminTranslations.split(AdminTranslations.fullNameEnglish)[0],
                  labelStyle: const TextStyle(fontSize: 14),
                  prefixIcon: const Icon(Icons.person),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameArabicController,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  labelText: AdminTranslations.split(AdminTranslations.fullNameArabic)[0],
                  labelStyle: const TextStyle(fontSize: 14),
                  prefixIcon: const Icon(Icons.person_outline),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nationalIdController,
                decoration: InputDecoration(
                  labelText: AdminTranslations.split(AdminTranslations.nationalId)[0],
                  labelStyle: const TextStyle(fontSize: 14),
                  prefixIcon: const Icon(Icons.credit_card),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: AdminTranslations.split(AdminTranslations.email)[0],
                  labelStyle: const TextStyle(fontSize: 14),
                  prefixIcon: const Icon(Icons.email),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: AdminTranslations.split(AdminTranslations.phoneNumber)[0],
                  labelStyle: const TextStyle(fontSize: 14),
                  prefixIcon: const Icon(Icons.phone),
                  border: const OutlineInputBorder(),
                  hintText: AdminTranslations.split(AdminTranslations.phonePlaceholder)[0],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: stcPayController,
                decoration: InputDecoration(
                  labelText: AdminTranslations.split(AdminTranslations.stcPayId)[0],
                  labelStyle: const TextStyle(fontSize: 14),
                  prefixIcon: const Icon(Icons.payment),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: AdminTranslations.split(AdminTranslations.addressEnglish)[0],
                  labelStyle: const TextStyle(fontSize: 14),
                  prefixIcon: const Icon(Icons.location_on),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressArabicController,
                maxLines: 2,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  labelText: AdminTranslations.split(AdminTranslations.addressArabic)[0],
                  labelStyle: const TextStyle(fontSize: 14),
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: initialCreditController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AdminTranslations.split(AdminTranslations.initialCredit)[0],
                  labelStyle: const TextStyle(fontSize: 14),
                  prefixIcon: const Icon(Icons.account_balance_wallet),
                  border: const OutlineInputBorder(),
                  hintText: AdminTranslations.split(AdminTranslations.defaultCredit)[0],
                  helperText: AdminTranslations.split(AdminTranslations.initialCreditHelper)[0],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AdminTranslations.split(AdminTranslations.cancelBtn)[0]),
                const SizedBox(width: 4),
                Text(
                  AdminTranslations.split(AdminTranslations.cancelBtn)[1],
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
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
                  SnackBar(
                    content: Row(
                      children: [
                        Text(AdminTranslations.split(AdminTranslations.fillAllFields)[0]),
                        const SizedBox(width: 4),
                        Text(
                          AdminTranslations.split(AdminTranslations.fillAllFields)[1],
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final initialCredit = double.tryParse(initialCreditController.text.trim());
              if (initialCredit == null || initialCredit < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Text(AdminTranslations.split(AdminTranslations.validCreditAmount)[0]),
                        const SizedBox(width: 4),
                        Text(
                          AdminTranslations.split(AdminTranslations.validCreditAmount)[1],
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
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
                status: AdminTranslations.split(AdminTranslations.active)[0],
                joinedDate: DateTime.now(),
                completedServices: 0,
                creditBalance: initialCredit,
              );

              final success = _authService.addWorker(newWorker);

              // ✅ CRITICAL: Initialize credit in AppStateProvider for new worker
              if (success) {
                Provider.of<AppStateProvider>(context, listen: false)
                    .syncWorkerCredit(newWorkerId, initialCredit);
              }

              Navigator.of(dialogContext).pop();

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(AdminTranslations.split(AdminTranslations.workerAdded)[0]),
                            const SizedBox(width: 4),
                            Text(
                              AdminTranslations.split(AdminTranslations.workerAdded)[1],
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        Text('${nameController.text.trim()} | ${nameArabicController.text.trim()}', textDirection: TextDirection.rtl),
                        Text('${AdminTranslations.split(AdminTranslations.phoneLabel)[0]} ${phoneController.text.trim()}'),
                        Text('${AdminTranslations.split(AdminTranslations.initialCreditLabel)[0]} SAR ${initialCredit.toStringAsFixed(2)}'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 5),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Text(AdminTranslations.split(AdminTranslations.workerExists)[0]),
                        const SizedBox(width: 4),
                        Text(
                          AdminTranslations.split(AdminTranslations.workerExists)[1],
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B5B9A),
              foregroundColor: Colors.white,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AdminTranslations.split(AdminTranslations.addWorker)[0]),
                const SizedBox(width: 4),
                Text(
                  AdminTranslations.split(AdminTranslations.addWorker)[1],
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
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
                        (worker['name']?.toString().substring(0, 1) ?? 'W').toUpperCase(),
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF6B5B9A)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(worker['name']?.toString() ?? 'Unknown', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(
                            worker['nameArabic']?.toString() ?? worker['name']?.toString() ?? '',
                            style: const TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
                            textDirection: TextDirection.rtl,
                          ),
                          const SizedBox(height: 4),
                          Text(worker['id']?.toString() ?? '', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text(
                      AdminTranslations.split(AdminTranslations.personalInformation)[0],
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AdminTranslations.split(AdminTranslations.personalInformation)[1],
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                    Icons.credit_card,
                    AdminTranslations.split(AdminTranslations.nationalIdLabel)[0],
                    AdminTranslations.split(AdminTranslations.nationalIdLabel)[1],
                    worker['nationalId']?.toString() ?? ''
                ),
                _buildDetailRow(
                    Icons.email,
                    AdminTranslations.split(AdminTranslations.emailLabel)[0],
                    AdminTranslations.split(AdminTranslations.emailLabel)[1],
                    worker['email']?.toString() ?? ''
                ),
                _buildDetailRow(
                    Icons.phone,
                    AdminTranslations.split(AdminTranslations.phoneLabel2)[0],
                    AdminTranslations.split(AdminTranslations.phoneLabel2)[1],
                    worker['phone']?.toString() ?? ''
                ),
                _buildDetailRow(
                    Icons.payment,
                    AdminTranslations.split(AdminTranslations.stcPayLabel)[0],
                    AdminTranslations.split(AdminTranslations.stcPayLabel)[1],
                    worker['stcPayId']?.toString() ?? ''
                ),
                _buildBilingualDetailRow(
                  Icons.location_on,
                  AdminTranslations.split(AdminTranslations.addressLabel)[0],
                  AdminTranslations.split(AdminTranslations.addressLabel)[1],
                  worker['address']?.toString() ?? '',
                  worker['addressArabic']?.toString() ?? worker['address']?.toString() ?? '',
                ),
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
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(AdminTranslations.split(AdminTranslations.edit)[0]),
                            const SizedBox(width: 4),
                            Text(
                              AdminTranslations.split(AdminTranslations.edit)[1],
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
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
                        icon: Icon(worker['status'] == AdminTranslations.split(AdminTranslations.active)[0] ? Icons.block : Icons.check_circle),
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(worker['status'] == AdminTranslations.split(AdminTranslations.active)[0]
                                ? AdminTranslations.split(AdminTranslations.blockBtn)[0]
                                : AdminTranslations.split(AdminTranslations.unblockBtn)[0]),
                            const SizedBox(width: 4),
                            Text(
                              worker['status'] == AdminTranslations.split(AdminTranslations.active)[0]
                                  ? AdminTranslations.split(AdminTranslations.blockBtn)[1]
                                  : AdminTranslations.split(AdminTranslations.unblockBtn)[1],
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: worker['status'] == AdminTranslations.split(AdminTranslations.active)[0] ? Colors.red : Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showAddCreditDialog(worker);
                    },
                    icon: const Icon(Icons.add_card),
                    label: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Add Credit'),
                        SizedBox(width: 4),
                        Text(
                          'إضافة رصيد',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B5B9A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddCreditDialog(Map<String, dynamic> worker) {
    final amountController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.add_card, color: Color(0xFF6B5B9A)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text('Add Credit'),
                      SizedBox(width: 4),
                      Text(
                        'إضافة رصيد',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  Text(
                    worker['name']?.toString() ?? 'Unknown',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B5B9A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Text('Current Credit:'),
                        SizedBox(width: 4),
                        Text(
                          'الرصيد الحالي:',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    Text(
                      'SAR ${(worker['creditBalance'] as double).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B5B9A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration:  InputDecoration(
                  labelText: 'Amount to Add | المبلغ المضاف',
                  hintText: 'Enter amount in SAR',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration:  InputDecoration(
                  labelText: 'Notes (Optional) | ملاحظات',
                  hintText: 'Reason for adding credit',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AdminTranslations.split(AdminTranslations.cancelBtn)[0]),
                const SizedBox(width: 4),
                Text(
                  AdminTranslations.split(AdminTranslations.cancelBtn)[1],
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Text('Please enter a valid amount'),
                        SizedBox(width: 4),
                        Text(
                          'يرجى إدخال مبلغ صحيح',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final newBalance = (worker['creditBalance'] as double) + amount;
              final success = _authService.updateWorkerCredit(worker['phone'], newBalance);

              // ✅ CRITICAL: Sync credit to AppStateProvider so worker sees updated balance
              if (success) {
                Provider.of<AppStateProvider>(context, listen: false)
                    .syncWorkerCredit(worker['id'], newBalance);
              }

              Navigator.pop(context);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Added SAR ${amount.toStringAsFixed(2)} to ${worker['name']}\'s credit'),
                            const SizedBox(width: 4),
                            Text(
                              'تم إضافة ${amount.toStringAsFixed(2)} ريال لرصيد ${worker['name']}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
                _loadWorkers();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Text('Failed to update credit for ${worker['name']}'),
                        const SizedBox(width: 4),
                        Text(
                          'فشل في تحديث الرصيد لـ ${worker['name']}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            icon: const Icon(Icons.check),
            label: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Add Credit'),
                SizedBox(width: 4),
                Text(
                  'إضافة',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B5B9A),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBilingualDetailRow(IconData icon, String labelEn, String labelAr, String valueEnglish, String valueArabic) {
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
                Row(
                  children: [
                    Text(labelEn, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(width: 4),
                    Text(
                      labelAr,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(valueEnglish, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  valueArabic,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String labelEn, String labelAr, String value) {
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
                Row(
                  children: [
                    Text(labelEn, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(width: 4),
                    Text(
                      labelAr,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
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
    final nameController = TextEditingController(text: worker['name']?.toString() ?? '');
    final nameArabicController = TextEditingController(text: worker['nameArabic']?.toString() ?? '');
    final nationalIdController = TextEditingController(text: worker['nationalId']?.toString() ?? '');
    final emailController = TextEditingController(text: worker['email']?.toString() ?? '');
    final phoneController = TextEditingController(text: worker['phone']?.toString() ?? '');
    final stcPayController = TextEditingController(text: worker['stcPayId']?.toString() ?? '');
    final addressController = TextEditingController(text: worker['address']?.toString() ?? '');
    final addressArabicController = TextEditingController(text: worker['addressArabic']?.toString() ?? '');
    final creditController = TextEditingController(text: (worker['creditBalance'] as double).toStringAsFixed(2));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Text(AdminTranslations.split(AdminTranslations.edit)[0]),
            const SizedBox(width: 4),
            Text(
              AdminTranslations.split(AdminTranslations.edit)[1],
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: AdminTranslations.split(AdminTranslations.fullNameEnglish)[0],
                  labelStyle: const TextStyle(fontSize: 14),
                  prefixIcon: const Icon(Icons.person),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameArabicController,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  labelText: AdminTranslations.split(AdminTranslations.fullNameArabic)[0],
                  labelStyle: const TextStyle(fontSize: 14),
                  prefixIcon: const Icon(Icons.person_outline),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nationalIdController,
                decoration: InputDecoration(
                  labelText: AdminTranslations.split(AdminTranslations.nationalId)[0],
                  labelStyle: const TextStyle(fontSize: 14),
                  prefixIcon: const Icon(Icons.credit_card),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: AdminTranslations.split(AdminTranslations.email)[0],
                  labelStyle: const TextStyle(fontSize: 14),
                  prefixIcon: const Icon(Icons.email),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: AdminTranslations.split(AdminTranslations.phoneNumber)[0],
                  labelStyle: const TextStyle(fontSize: 14),
                  prefixIcon: const Icon(Icons.phone),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: stcPayController,
                decoration: InputDecoration(
                  labelText: AdminTranslations.split(AdminTranslations.stcPayId)[0],
                  labelStyle: const TextStyle(fontSize: 14),
                  prefixIcon: const Icon(Icons.payment),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: AdminTranslations.split(AdminTranslations.addressEnglish)[0],
                  labelStyle: const TextStyle(fontSize: 14),
                  prefixIcon: const Icon(Icons.location_on),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressArabicController,
                maxLines: 2,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  labelText: AdminTranslations.split(AdminTranslations.addressArabic)[0],
                  labelStyle: const TextStyle(fontSize: 14),
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: creditController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AdminTranslations.split(AdminTranslations.creditBalance)[0],
                  labelStyle: const TextStyle(fontSize: 14),
                  prefixIcon: const Icon(Icons.account_balance_wallet),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AdminTranslations.split(AdminTranslations.cancelBtn)[0]),
                const SizedBox(width: 4),
                Text(
                  AdminTranslations.split(AdminTranslations.cancelBtn)[1],
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  nameArabicController.text.isEmpty ||
                  nationalIdController.text.isEmpty ||
                  emailController.text.isEmpty ||
                  stcPayController.text.isEmpty ||
                  addressController.text.isEmpty ||
                  addressArabicController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Text(AdminTranslations.split(AdminTranslations.fillAllFields)[0]),
                        const SizedBox(width: 4),
                        Text(
                          AdminTranslations.split(AdminTranslations.fillAllFields)[1],
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final credit = double.tryParse(creditController.text) ?? worker['creditBalance'];

              final updatedWorker = WorkerData(
                id: worker['id'],
                name: nameController.text.trim(),
                nameArabic: nameArabicController.text.trim(),
                nationalId: nationalIdController.text.trim(),
                email: emailController.text.trim(),
                phone: worker['phone'],
                stcPayId: stcPayController.text.trim(),
                address: addressController.text.trim(),
                addressArabic: addressArabicController.text.trim(),
                status: worker['status'],
                joinedDate: worker['joinDate'],
                completedServices: worker['totalServices'],
                creditBalance: credit,
              );

              Navigator.of(dialogContext).pop();

              final success = _authService.updateWorker(worker['phone'], updatedWorker);

              // ✅ CRITICAL: Sync credit to AppStateProvider when worker details are updated
              if (success) {
                Provider.of<AppStateProvider>(context, listen: false)
                    .syncWorkerCredit(worker['id'], credit);
              }

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Text('${AdminTranslations.split(AdminTranslations.worker)[0]} ${worker['name']} ${AdminTranslations.split(AdminTranslations.successfullyUpdated)[0]}'),
                        const SizedBox(width: 4),
                        Text(
                          '${AdminTranslations.split(AdminTranslations.worker)[1]} ${worker['name']} ${AdminTranslations.split(AdminTranslations.successfullyUpdated)[1]}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Text('Failed to update worker'),
                        const SizedBox(width: 4),
                        Text(
                          'فشل في تحديث العامل',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B5B9A),
              foregroundColor: Colors.white,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AdminTranslations.split(AdminTranslations.saveBtn)[0]),
                const SizedBox(width: 4),
                Text(
                  AdminTranslations.split(AdminTranslations.saveBtn)[1],
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleWorkerStatus(Map<String, dynamic> worker) {
    final newStatus = worker['status'] == AdminTranslations.split(AdminTranslations.active)[0]
        ? AdminTranslations.split(AdminTranslations.blocked)[0]
        : AdminTranslations.split(AdminTranslations.active)[0];

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Text(
                newStatus == AdminTranslations.split(AdminTranslations.active)[0]
                    ? AdminTranslations.split(AdminTranslations.unblockWorker)[0]
                    : AdminTranslations.split(AdminTranslations.blockWorker)[0]
            ),
            const SizedBox(width: 4),
            Text(
              newStatus == AdminTranslations.split(AdminTranslations.active)[0]
                  ? AdminTranslations.split(AdminTranslations.unblockWorker)[1]
                  : AdminTranslations.split(AdminTranslations.blockWorker)[1],
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        content: Row(
          children: [
            Expanded(
              child: Text(
                  '${newStatus == AdminTranslations.split(AdminTranslations.active)[0]
                      ? AdminTranslations.split(AdminTranslations.unblockConfirmMessage)[0]
                      : AdminTranslations.split(AdminTranslations.blockConfirmMessage)[0]} ${worker['name']}?'
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                '${newStatus == AdminTranslations.split(AdminTranslations.active)[0]
                    ? AdminTranslations.split(AdminTranslations.unblockConfirmMessage)[1]
                    : AdminTranslations.split(AdminTranslations.blockConfirmMessage)[1]} ${worker['name']}؟',
                textDirection: TextDirection.rtl,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AdminTranslations.split(AdminTranslations.cancelBtn)[0]),
                const SizedBox(width: 4),
                Text(
                  AdminTranslations.split(AdminTranslations.cancelBtn)[1],
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();

              final success = _authService.toggleWorkerStatus(worker['phone']);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('${AdminTranslations.split(AdminTranslations.worker)[0]} ${worker['name']} ${newStatus == AdminTranslations.split(AdminTranslations.active)[0] ? AdminTranslations.split(AdminTranslations.workerUnblocked)[0] : AdminTranslations.split(AdminTranslations.workerBlocked)[0]}'),
                            const SizedBox(width: 4),
                            Text(
                              '${AdminTranslations.split(AdminTranslations.worker)[1]} ${worker['name']} ${newStatus == AdminTranslations.split(AdminTranslations.active)[0] ? AdminTranslations.split(AdminTranslations.workerUnblocked)[1] : AdminTranslations.split(AdminTranslations.workerBlocked)[1]}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        Text(worker['nameArabic']?.toString() ?? '', textDirection: TextDirection.rtl, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    backgroundColor: newStatus == AdminTranslations.split(AdminTranslations.active)[0] ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus == AdminTranslations.split(AdminTranslations.active)[0] ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(newStatus == AdminTranslations.split(AdminTranslations.active)[0]
                    ? AdminTranslations.split(AdminTranslations.unblockBtn)[0]
                    : AdminTranslations.split(AdminTranslations.blockBtn)[0]),
                const SizedBox(width: 4),
                Text(
                  newStatus == AdminTranslations.split(AdminTranslations.active)[0]
                      ? AdminTranslations.split(AdminTranslations.unblockBtn)[1]
                      : AdminTranslations.split(AdminTranslations.blockBtn)[1],
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}