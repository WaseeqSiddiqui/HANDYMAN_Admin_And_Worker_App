import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/services/worker_auth_service.dart';
import '/providers/app_state_provider.dart';
import '/utils/admin_translations.dart';
import '/models/worker_data_model.dart';
import 'package:flutter/services.dart';

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
        _workers.addAll(
          _authService.getAllWorkers().map((worker) {
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
              'expertise': worker.expertise,
              'profilePhotoUrl': worker.profilePhotoUrl,
            };
          }).toList(),
        );
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

  // 🔥 ADD: Phone number formatting function
  String _formatPhoneNumber(String phone) {
    // Remove any spaces or special characters
    phone = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // If phone starts with 05, convert to +9665
    if (phone.startsWith('05')) {
      phone = '+966${phone.substring(1)}';
    }
    // If phone starts with 5 (without 0), add +966
    else if (phone.startsWith('5') && !phone.startsWith('+')) {
      phone = '+966$phone';
    }
    // If phone doesn't have country code, assume Saudi Arabia
    else if (!phone.startsWith('+')) {
      phone = '+966$phone';
    }

    return phone;
  }

  // 🔥 ADD: Phone number validation function
  bool _isValidSaudiPhone(String phone) {
    // Remove country code for validation
    String digits = phone.replaceAll('+966', '').replaceAll(RegExp(r'\s+'), '');

    // Saudi mobile numbers: 5XXXXXXXX (9 digits starting with 5)
    return digits.length == 9 && digits.startsWith('5');
  }

  // ✅ VALIDATION HELPERS
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidNationalId(String id) {
    return RegExp(r'^\d{10}$').hasMatch(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),

      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AdminTranslations.split(AdminTranslations.workerManagement)[0],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
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
        backgroundColor: const Color(0xFF3B82F6),
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
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 16,
                      bottom: 100,
                    ),
                    itemCount: _filteredWorkers.length,
                    itemBuilder: (context, index) =>
                        _buildWorkerCard(_filteredWorkers[index]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddWorkerDialog,
        backgroundColor: const Color(0xFF3B82F6),
        icon: const Icon(Icons.person_add),
        label: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add Worker', style: TextStyle(fontSize: 14)),
            Text(
              'إضافة عامل',
              style: TextStyle(fontSize: 12),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final activeWorkers = _workers
        .where(
          (w) =>
              w['status'] ==
              AdminTranslations.split(AdminTranslations.active)[0],
        )
        .length;
    final blockedWorkers = _workers
        .where(
          (w) =>
              w['status'] ==
              AdminTranslations.split(AdminTranslations.blocked)[0],
        )
        .length;
    final totalServices = _workers.fold(
      0,
      (sum, w) => sum + (w['totalServices'] as int),
    );

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
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSmallStatCard(
              AdminTranslations.split(AdminTranslations.blocked)[0],
              AdminTranslations.split(AdminTranslations.blocked)[1],
              '$blockedWorkers',
              Icons.block,
              Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSmallStatCard(
              AdminTranslations.split(AdminTranslations.services)[0],
              AdminTranslations.split(AdminTranslations.services)[1],
              '$totalServices',
              Icons.build_circle,
              Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStatCard(
    String labelEn,
    String labelAr,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Column(
            children: [
              Text(
                labelEn,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              Text(
                labelAr,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
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
          // Search Field
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: AdminTranslations.split(
                AdminTranslations.searchWorkers,
              )[0],
              hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade600),
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ✅ FIXED: Filter Buttons with better spacing
          Row(
            children: [
              Expanded(
                child: _buildFilterButton(
                  AdminTranslations.split(AdminTranslations.all)[0],
                  AdminTranslations.split(AdminTranslations.all)[1],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterButton(
                  AdminTranslations.split(AdminTranslations.active)[0],
                  AdminTranslations.split(AdminTranslations.active)[1],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterButton(
                  AdminTranslations.split(AdminTranslations.blocked)[0],
                  AdminTranslations.split(AdminTranslations.blocked)[1],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ✅ NEW: Better filter button widget
  Widget _buildFilterButton(String statusEn, String statusAr) {
    final isSelected = _filterStatus == statusEn;

    return InkWell(
      onTap: () => setState(() => _filterStatus = statusEn),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              statusEn,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              statusAr,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.9)
                    : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
          ],
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
                    : AdminTranslations.split(
                        AdminTranslations.noWorkersFound,
                      )[0],
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _workers.isEmpty
                    ? AdminTranslations.split(AdminTranslations.noWorkersYet)[1]
                    : AdminTranslations.split(
                        AdminTranslations.noWorkersFound,
                      )[1],
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
    final isActive = status == 'Active'; // 🔥 SIMPLIFIED
    final isPending = status == 'Pending';
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
                    backgroundColor: const Color(
                      0xFF3B82F6,
                    ).withValues(alpha: 0.1),
                    backgroundImage:
                        worker['profilePhotoUrl'] != null &&
                            worker['profilePhotoUrl'].toString().isNotEmpty
                        ? NetworkImage(worker['profilePhotoUrl'])
                        : null,
                    child:
                        worker['profilePhotoUrl'] == null ||
                            worker['profilePhotoUrl'].toString().isEmpty
                        ? Text(
                            (worker['name']?.toString().substring(0, 1) ?? 'W')
                                .toUpperCase(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3B82F6),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          worker['name']?.toString() ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          worker['nameArabic']?.toString() ??
                              worker['name']?.toString() ??
                              '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${worker['expertise'] ?? 'General'} • ${worker['id']} • ${worker['phone']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isPending
                          ? Colors.orange.withValues(alpha: 0.1)
                          : // 🔥 NEW: Orange for pending
                            isActive
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPending
                              ? Icons.pending
                              : // 🔥 NEW: Pending icon
                                isActive
                              ? Icons.check_circle
                              : Icons.block,
                          size: 14,
                          color: isPending
                              ? Colors.orange
                              : // 🔥 NEW: Orange for pending
                                isActive
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isActive
                                  ? AdminTranslations.split(
                                      AdminTranslations.active,
                                    )[0]
                                  : AdminTranslations.split(
                                      AdminTranslations.blocked,
                                    )[0],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isActive ? Colors.green : Colors.red,
                              ),
                            ),
                            Text(
                              isActive
                                  ? AdminTranslations.split(
                                      AdminTranslations.active,
                                    )[1]
                                  : AdminTranslations.split(
                                      AdminTranslations.blocked,
                                    )[1],
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: isActive ? Colors.green : Colors.red,
                              ),
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
                  Expanded(
                    child: _buildInfoColumn(
                      AdminTranslations.split(AdminTranslations.services)[0],
                      AdminTranslations.split(AdminTranslations.services)[1],
                      '${worker['totalServices']}',
                      Icons.build,
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoColumn(
                      AdminTranslations.split(AdminTranslations.credit)[0],
                      AdminTranslations.split(AdminTranslations.credit)[1],
                      'SAR ${(worker['creditBalance'] as double).toStringAsFixed(0)}',
                      Icons.credit_card,
                      const Color(0xFF005DFF),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(
    String labelEn,
    String labelAr,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Column(
          children: [
            Text(
              labelEn,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            Text(
              labelAr,
              style: const TextStyle(fontSize: 9, color: Colors.grey),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
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
    String? selectedExpertise;
    final categories = Provider.of<AppStateProvider>(
      context,
      listen: false,
    ).serviceCategories;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
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
                      labelText: AdminTranslations.split(
                        AdminTranslations.fullNameEnglish,
                      )[0],
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
                      labelText: AdminTranslations.split(
                        AdminTranslations.fullNameArabic,
                      )[0],
                      labelStyle: const TextStyle(fontSize: 14),
                      prefixIcon: const Icon(Icons.person_outline),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nationalIdController,
                    decoration: InputDecoration(
                      labelText: AdminTranslations.split(
                        AdminTranslations.nationalId,
                      )[0],
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
                      labelText: AdminTranslations.split(
                        AdminTranslations.email,
                      )[0],
                      labelStyle: const TextStyle(fontSize: 14),
                      prefixIcon: const Icon(Icons.email),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                      LengthLimitingTextInputFormatter(13),
                    ],
                    decoration: InputDecoration(
                      labelText: AdminTranslations.split(
                        AdminTranslations.phoneNumber,
                      )[0],
                      labelStyle: const TextStyle(fontSize: 14),
                      prefixIcon: const Icon(Icons.phone),
                      border: const OutlineInputBorder(),
                      hintText: '5XXXXXXXX',
                      helperText: 'Format: 5XXXXXXXX ',
                      helperStyle: const TextStyle(fontSize: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedExpertise,
                    isExpanded:
                        true, // 🔥 Allow dropdown to expand and handle overflow
                    decoration: InputDecoration(
                      labelText: AdminTranslations.split(
                        AdminTranslations.expertise,
                      )[0],
                      labelStyle: const TextStyle(fontSize: 14),
                      prefixIcon: const Icon(Icons.work),
                      border: const OutlineInputBorder(),
                    ),
                    items: categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat.nameEnglish,
                        child: Text(
                          '${cat.nameEnglish} - ${cat.nameArabic}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => selectedExpertise = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: stcPayController,
                    decoration: InputDecoration(
                      labelText: AdminTranslations.split(
                        AdminTranslations.stcPayId,
                      )[0],
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
                      labelText: AdminTranslations.split(
                        AdminTranslations.addressEnglish,
                      )[0],
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
                      labelText: AdminTranslations.split(
                        AdminTranslations.addressArabic,
                      )[0],
                      labelStyle: const TextStyle(fontSize: 14),
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: initialCreditController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [LengthLimitingTextInputFormatter(4)],
                    decoration: InputDecoration(
                      labelText: AdminTranslations.split(
                        AdminTranslations.initialCredit,
                      )[0],
                      labelStyle: const TextStyle(fontSize: 14),
                      prefixIcon: const Icon(Icons.account_balance_wallet),
                      border: const OutlineInputBorder(),
                      hintText: AdminTranslations.split(
                        AdminTranslations.defaultCredit,
                      )[0],
                      helperText: AdminTranslations.split(
                        AdminTranslations.initialCreditHelper,
                      )[0],
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
                    Text(
                      AdminTranslations.split(AdminTranslations.cancelBtn)[0],
                    ),
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
                    // Show snackbar without closing dialog
                    _showCustomSnackBar(
                      AdminTranslations.split(
                        AdminTranslations.fillAllFields,
                      )[0],
                      AdminTranslations.split(
                        AdminTranslations.fillAllFields,
                      )[1],
                      Colors.red,
                    );
                    return;
                  }

                  // ✅ NEW VALIDATIONS
                  if (!_isValidNationalId(nationalIdController.text.trim())) {
                    _showCustomSnackBar(
                      'Invalid National ID. Must be 10 digits.',
                      'رقم الهوية غير صالح. يجب أن يتكون من 10 أرقام.',
                      Colors.red,
                    );
                    return;
                  }

                  if (!_isValidEmail(emailController.text.trim())) {
                    _showCustomSnackBar(
                      'Invalid Email Address.',
                      'البريد الإلكتروني غير صالح.',
                      Colors.red,
                    );
                    return;
                  }

                  final initialCredit = double.tryParse(
                    initialCreditController.text.trim(),
                  );
                  if (initialCredit == null || initialCredit < 0) {
                    _showCustomSnackBar(
                      AdminTranslations.split(
                        AdminTranslations.validCreditAmount,
                      )[0],
                      AdminTranslations.split(
                        AdminTranslations.validCreditAmount,
                      )[1],
                      Colors.red,
                    );
                    return;
                  }

                  String formattedPhone = _formatPhoneNumber(
                    phoneController.text.trim(),
                  );
                  if (!_isValidSaudiPhone(formattedPhone)) {
                    _showCustomSnackBar(
                      'Invalid Saudi phone number. Use format: 5XXXXXXXX',
                      'رقم هاتف سعودي غير صالح. استخدم التنسيق: 5XXXXXXXX',
                      Colors.red,
                    );
                    return;
                  }

                  // STC Pay Validation (same as phone for now, or just check if it's a valid phone)
                  String formattedStcPay = _formatPhoneNumber(
                    stcPayController.text.trim(),
                  );
                  if (!_isValidSaudiPhone(formattedStcPay)) {
                    _showCustomSnackBar(
                      'Invalid STC Pay number. Use format: 5XXXXXXXX',
                      'رقم STC Pay غير صالح. استخدم التنسيق: 5XXXXXXXX',
                      Colors.red,
                    );
                    return;
                  }

                  // Create worker data
                  final newWorkerId =
                      'W${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
                  final newWorker = WorkerData(
                    id: newWorkerId,
                    name: nameController.text.trim(),
                    nameArabic: nameArabicController.text.trim(),
                    nationalId: nationalIdController.text.trim(),
                    email: emailController.text.trim(),
                    phone: formattedPhone, // 🔥 USE FORMATTED PHONE
                    stcPayId: formattedStcPay, // 🔥 USE FORMATTED STC PAY
                    address: addressController.text.trim(),
                    addressArabic: addressArabicController.text.trim(),
                    status: 'Active', // 🔥 Set as Active by default
                    joinedDate: DateTime.now(),
                    completedServices: 0,
                    creditBalance: initialCredit,
                    expertise: selectedExpertise ?? 'General',
                  );

                  final success = _authService.addWorker(newWorker);

                  // ✅ CRITICAL: Initialize credit in AppStateProvider for new worker
                  if (success) {
                    if (context.mounted) {
                      Provider.of<AppStateProvider>(
                        context,
                        listen: false,
                      ).syncWorkerCredit(newWorkerId, initialCredit);
                    }
                  }

                  if (success) {
                    // ✅ Close dialog ONLY IF SUCCESSFUL
                    if (context.mounted) {
                      Navigator.of(dialogContext).pop();
                    }

                    _showCustomSnackBar(
                      '${AdminTranslations.split(AdminTranslations.workerAdded)[0]} - ${nameController.text.trim()}',
                      '${AdminTranslations.split(AdminTranslations.workerAdded)[1]} - ${nameArabicController.text.trim()}',
                      Colors.green,
                    );
                  } else {
                    // DON'T CLOSE DIALOG if worker exists
                    _showCustomSnackBar(
                      AdminTranslations.split(
                        AdminTranslations.workerExists,
                      )[0],
                      AdminTranslations.split(
                        AdminTranslations.workerExists,
                      )[1],
                      Colors.red,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005DFF),
                  foregroundColor: Colors.white,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AdminTranslations.split(AdminTranslations.addWorker)[0],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AdminTranslations.split(AdminTranslations.addWorker)[1],
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
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
                      backgroundColor: const Color(
                        0xFF005DFF,
                      ).withValues(alpha: 0.1),
                      backgroundImage:
                          worker['profilePhotoUrl'] != null &&
                              worker['profilePhotoUrl'].toString().isNotEmpty
                          ? NetworkImage(worker['profilePhotoUrl'])
                          : null,
                      child:
                          worker['profilePhotoUrl'] == null ||
                              worker['profilePhotoUrl'].toString().isEmpty
                          ? Text(
                              (worker['name']?.toString().substring(0, 1) ??
                                      'W')
                                  .toUpperCase(),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF005DFF),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            worker['name']?.toString() ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            worker['nameArabic']?.toString() ??
                                worker['name']?.toString() ??
                                '',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.blue.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              worker['expertise'] ?? 'General',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            worker['id']?.toString() ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text(
                      AdminTranslations.split(
                        AdminTranslations.personalInformation,
                      )[0],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AdminTranslations.split(
                        AdminTranslations.personalInformation,
                      )[1],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  Icons.work,
                  AdminTranslations.split(AdminTranslations.expertise)[0],
                  AdminTranslations.split(AdminTranslations.expertise)[1],
                  worker['expertise'] ?? 'General',
                ),
                _buildDetailRow(
                  Icons.credit_card,
                  AdminTranslations.split(AdminTranslations.nationalIdLabel)[0],
                  AdminTranslations.split(AdminTranslations.nationalIdLabel)[1],
                  worker['nationalId']?.toString() ?? '',
                ),
                _buildDetailRow(
                  Icons.email,
                  AdminTranslations.split(AdminTranslations.emailLabel)[0],
                  AdminTranslations.split(AdminTranslations.emailLabel)[1],
                  worker['email']?.toString() ?? '',
                ),
                _buildDetailRow(
                  Icons.phone,
                  AdminTranslations.split(AdminTranslations.phoneLabel2)[0],
                  AdminTranslations.split(AdminTranslations.phoneLabel2)[1],
                  worker['phone']?.toString() ?? '',
                ),
                _buildDetailRow(
                  Icons.payment,
                  AdminTranslations.split(AdminTranslations.stcPayLabel)[0],
                  AdminTranslations.split(AdminTranslations.stcPayLabel)[1],
                  worker['stcPayId']?.toString() ?? '',
                ),
                _buildBilingualDetailRow(
                  Icons.location_on,
                  AdminTranslations.split(AdminTranslations.addressLabel)[0],
                  AdminTranslations.split(AdminTranslations.addressLabel)[1],
                  worker['address']?.toString() ?? '',
                  worker['addressArabic']?.toString() ??
                      worker['address']?.toString() ??
                      '',
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
                            Text(
                              AdminTranslations.split(
                                AdminTranslations.edit,
                              )[0],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              AdminTranslations.split(
                                AdminTranslations.edit,
                              )[1],
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF005DFF),
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
                        icon: Icon(
                          worker['status'] ==
                                  AdminTranslations.split(
                                    AdminTranslations.active,
                                  )[0]
                              ? Icons.block
                              : Icons.check_circle,
                        ),
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              worker['status'] ==
                                      AdminTranslations.split(
                                        AdminTranslations.active,
                                      )[0]
                                  ? AdminTranslations.split(
                                      AdminTranslations.blockBtn,
                                    )[0]
                                  : AdminTranslations.split(
                                      AdminTranslations.unblockBtn,
                                    )[0],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              worker['status'] ==
                                      AdminTranslations.split(
                                        AdminTranslations.active,
                                      )[0]
                                  ? AdminTranslations.split(
                                      AdminTranslations.blockBtn,
                                    )[1]
                                  : AdminTranslations.split(
                                      AdminTranslations.unblockBtn,
                                    )[1],
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              worker['status'] ==
                                  AdminTranslations.split(
                                    AdminTranslations.active,
                                  )[0]
                              ? Colors.red
                              : Colors.green,
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
                        Text('إضافة رصيد', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF005DFF),
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

  void _showCustomSnackBar(
    String messageEn,
    String messageAr,
    Color backgroundColor,
  ) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // English text
                Text(
                  messageEn,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Arabic text
                Text(
                  messageAr,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  textDirection: TextDirection.rtl,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Insert overlay
    overlay.insert(overlayEntry);

    // Remove after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  void _showAddCreditDialog(Map<String, dynamic> worker) {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.add_card, color: Color(0xFF005DFF)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Row(
                    children: [
                      Text('Add Credit'),
                      SizedBox(width: 4),
                      Text('إضافة رصيد', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              worker['name']?.toString() ?? 'Unknown',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Credit Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF005DFF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Credit',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          'الرصيد الحالي',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                    Text(
                      'SAR ${(worker['creditBalance'] as double).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF005DFF),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Amount Field
              const Row(
                children: [
                  Text('Amount to Add'),
                  SizedBox(width: 4),
                  Text('المبلغ المضاف', style: TextStyle(fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [LengthLimitingTextInputFormatter(4)],
                decoration: const InputDecoration(
                  hintText: '0.00',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
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
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Cancel'),
                SizedBox(width: 4),
                Text('إلغاء', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount == null || amount <= 0) {
                _showTopSnackBar(
                  context,
                  'Please enter a valid amount',
                  'يرجى إدخال مبلغ صحيح',
                  Colors.red,
                );
                return;
              }

              final currentBalance = worker['creditBalance'] as double;
              final newBalance = currentBalance + amount;

              // ✅ STEP 1: Update credit in WorkerAuthService
              final success = _authService.updateWorkerCredit(
                worker['phone'],
                newBalance,
              );

              // ✅ STEP 2: Sync with AppStateProvider
              if (success) {
                final appStateProvider = Provider.of<AppStateProvider>(
                  context,
                  listen: false,
                );

                // ✅ Sync the new balance
                appStateProvider.syncWorkerCredit(worker['id'], newBalance);

                // ✅ Add transaction record (this will NOT modify balance again)
                appStateProvider.addCreditWithTransaction(
                  worker['id'],
                  amount,
                  'Credit added by administrator',
                );

                debugPrint('✅ Credit added successfully');
                debugPrint('   Worker: ${worker['name']} (${worker['id']})');
                debugPrint('   Amount: +SAR ${amount.toStringAsFixed(2)}');
                debugPrint(
                  '   Balance: ${currentBalance.toStringAsFixed(2)} → ${newBalance.toStringAsFixed(2)}',
                );
              }

              Navigator.pop(context);

              if (success) {
                _showTopSnackBar(
                  context,
                  'Added SAR ${amount.toStringAsFixed(2)} to ${worker['name']}\'s credit',
                  'تم إضافة ${amount.toStringAsFixed(2)} ريال لرصيد ${worker['name']}',
                  Colors.green,
                );
                _loadWorkers();
              } else {
                _showTopSnackBar(
                  context,
                  'Failed to update credit for ${worker['name']}',
                  'فشل في تحديث الرصيد لـ ${worker['name']}',
                  Colors.red,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005DFF),
              foregroundColor: Colors.white,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Add Credit'),
                SizedBox(width: 4),
                Text('إضافة', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBilingualDetailRow(
    IconData icon,
    String labelEn,
    String labelAr,
    String valueEnglish,
    String valueArabic,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF005DFF), size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      labelEn,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      labelAr,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  valueEnglish,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valueArabic,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String labelEn,
    String labelAr,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF005DFF), size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      labelEn,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      labelAr,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditWorkerDialog(Map<String, dynamic> worker) {
    final nameController = TextEditingController(
      text: worker['name']?.toString() ?? '',
    );
    final nameArabicController = TextEditingController(
      text: worker['nameArabic']?.toString() ?? '',
    );
    final nationalIdController = TextEditingController(
      text: worker['nationalId']?.toString() ?? '',
    );
    final emailController = TextEditingController(
      text: worker['email']?.toString() ?? '',
    );
    final phoneController = TextEditingController(
      text: worker['phone']?.toString() ?? '',
    );
    final stcPayController = TextEditingController(
      text: worker['stcPayId']?.toString() ?? '',
    );
    final addressController = TextEditingController(
      text: worker['address']?.toString() ?? '',
    );
    final addressArabicController = TextEditingController(
      text: worker['addressArabic']?.toString() ?? '',
    );
    final creditController = TextEditingController(
      text: (worker['creditBalance'] as double).toStringAsFixed(2),
    );
    String? selectedExpertise = worker['expertise'];
    final categories = Provider.of<AppStateProvider>(
      context,
      listen: false,
    ).serviceCategories;

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
                  labelText: AdminTranslations.split(
                    AdminTranslations.fullNameEnglish,
                  )[0],
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
                  labelText: AdminTranslations.split(
                    AdminTranslations.fullNameArabic,
                  )[0],
                  labelStyle: const TextStyle(fontSize: 14),
                  prefixIcon: const Icon(Icons.person_outline),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nationalIdController,
                decoration: InputDecoration(
                  labelText: AdminTranslations.split(
                    AdminTranslations.nationalId,
                  )[0],
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
                  labelText: AdminTranslations.split(
                    AdminTranslations.email,
                  )[0],
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
                  labelText: AdminTranslations.split(
                    AdminTranslations.phoneNumber,
                  )[0],
                  labelStyle: const TextStyle(fontSize: 14),
                  prefixIcon: const Icon(Icons.phone),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (context, setDropdownState) {
                  return DropdownButtonFormField<String>(
                    value:
                        (selectedExpertise != null &&
                            categories.any(
                              (c) => c.nameEnglish == selectedExpertise,
                            ))
                        ? selectedExpertise
                        : null,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: AdminTranslations.split(
                        AdminTranslations.expertise,
                      )[0],
                      labelStyle: const TextStyle(fontSize: 14),
                      prefixIcon: const Icon(Icons.work),
                      border: const OutlineInputBorder(),
                    ),
                    items: categories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat.nameEnglish,
                        child: Text(
                          '${cat.nameEnglish} - ${cat.nameArabic}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setDropdownState(() => selectedExpertise = val);
                    },
                    hint: Text(
                      selectedExpertise ?? 'Select Expertise / اختر التخصص',
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: stcPayController,
                decoration: InputDecoration(
                  labelText: AdminTranslations.split(
                    AdminTranslations.stcPayId,
                  )[0],
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
                  labelText: AdminTranslations.split(
                    AdminTranslations.addressEnglish,
                  )[0],
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
                  labelText: AdminTranslations.split(
                    AdminTranslations.addressArabic,
                  )[0],
                  labelStyle: const TextStyle(fontSize: 14),
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: creditController,
                keyboardType: TextInputType.number,
                inputFormatters: [LengthLimitingTextInputFormatter(4)],
                decoration: InputDecoration(
                  labelText: AdminTranslations.split(
                    AdminTranslations.creditBalance,
                  )[0],
                  labelStyle: const TextStyle(fontSize: 14),
                  prefixIcon: const Icon(Icons.account_balance_wallet),
                  border: const OutlineInputBorder(),
                  helperText: 'Increase or decrease worker credit balance',
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue.shade600, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Credit changes will appear in worker transaction history',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
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
                _showTopSnackBar(
                  context,
                  'Please fill all fields',
                  'يرجى ملء جميع الحقول',
                  Colors.red,
                );
                return;
              }

              final newCredit =
                  double.tryParse(creditController.text) ??
                  worker['creditBalance'];
              final oldCredit = worker['creditBalance'] as double;
              final creditDifference = newCredit - oldCredit;

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
                creditBalance: newCredit,
                expertise: selectedExpertise ?? 'General',
              );

              Navigator.of(dialogContext).pop();

              final success = _authService.updateWorker(
                worker['phone'],
                updatedWorker,
              );

              // ✅ FIXED: Sync credit correctly
              if (success) {
                final appStateProvider = Provider.of<AppStateProvider>(
                  context,
                  listen: false,
                );

                // ✅ Sync the new credit balance
                appStateProvider.syncWorkerCredit(worker['id'], newCredit);

                // ✅ Add transaction ONLY if credit changed
                if (creditDifference != 0) {
                  final transactionDescription = creditDifference > 0
                      ? 'Credit increased by administrator'
                      : 'Credit decreased by administrator';

                  appStateProvider.addCreditWithTransaction(
                    worker['id'],
                    creditDifference,
                    transactionDescription,
                  );

                  debugPrint('✅ Credit transaction added');
                  debugPrint('   Worker: ${worker['name']} (${worker['id']})');
                  debugPrint(
                    '   Change: ${creditDifference > 0 ? '+' : ''}${creditDifference.toStringAsFixed(2)}',
                  );
                  debugPrint(
                    '   Balance: ${oldCredit.toStringAsFixed(2)} → ${newCredit.toStringAsFixed(2)}',
                  );
                }
              }

              if (success) {
                String message = '';
                String messageAr = '';

                if (creditDifference > 0) {
                  message =
                      'Worker updated - Credit increased by SAR ${creditDifference.toStringAsFixed(2)}';
                  messageAr =
                      'تم تحديث العامل - تم زيادة الرصيد بمقدار ${creditDifference.toStringAsFixed(2)} ريال';
                } else if (creditDifference < 0) {
                  message =
                      'Worker updated - Credit decreased by SAR ${creditDifference.abs().toStringAsFixed(2)}';
                  messageAr =
                      'تم تحديث العامل - تم خصم الرصيد بمقدار ${creditDifference.abs().toStringAsFixed(2)} ريال';
                } else {
                  message = 'Worker updated successfully';
                  messageAr = 'تم تحديث العامل بنجاح';
                }

                _showTopSnackBar(context, message, messageAr, Colors.green);
              } else {
                _showTopSnackBar(
                  context,
                  'Failed to update worker',
                  'فشل في تحديث العامل',
                  Colors.red,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005DFF),
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

  void _showTopSnackBar(
    BuildContext context,
    String messageEn,
    String messageAr,
    Color backgroundColor,
  ) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // English text
                Text(
                  messageEn,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Arabic text
                Text(
                  messageAr,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  textDirection: TextDirection.rtl,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Insert overlay
    overlay.insert(overlayEntry);

    // Remove after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  void _toggleWorkerStatus(Map<String, dynamic> worker) {
    final newStatus =
        worker['status'] == AdminTranslations.split(AdminTranslations.active)[0]
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
                  : AdminTranslations.split(AdminTranslations.blockWorker)[0],
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
                '${newStatus == AdminTranslations.split(AdminTranslations.active)[0] ? AdminTranslations.split(AdminTranslations.unblockConfirmMessage)[0] : AdminTranslations.split(AdminTranslations.blockConfirmMessage)[0]} ${worker['name']}?',
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                '${newStatus == AdminTranslations.split(AdminTranslations.active)[0] ? AdminTranslations.split(AdminTranslations.unblockConfirmMessage)[1] : AdminTranslations.split(AdminTranslations.blockConfirmMessage)[1]} ${worker['name']}؟',
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${AdminTranslations.split(AdminTranslations.worker)[0]} ${worker['name']} ${newStatus == AdminTranslations.split(AdminTranslations.active)[0] ? AdminTranslations.split(AdminTranslations.workerUnblocked)[0] : AdminTranslations.split(AdminTranslations.workerBlocked)[0]}',
                            ),
                            Text(
                              '${AdminTranslations.split(AdminTranslations.worker)[1]} ${worker['name']} ${newStatus == AdminTranslations.split(AdminTranslations.active)[0] ? AdminTranslations.split(AdminTranslations.workerUnblocked)[1] : AdminTranslations.split(AdminTranslations.workerBlocked)[1]}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        Text(
                          worker['nameArabic']?.toString() ?? '',
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    backgroundColor:
                        newStatus ==
                            AdminTranslations.split(AdminTranslations.active)[0]
                        ? Colors.green
                        : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  newStatus ==
                      AdminTranslations.split(AdminTranslations.active)[0]
                  ? Colors.green
                  : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  newStatus ==
                          AdminTranslations.split(AdminTranslations.active)[0]
                      ? AdminTranslations.split(AdminTranslations.unblockBtn)[0]
                      : AdminTranslations.split(AdminTranslations.blockBtn)[0],
                ),
                const SizedBox(width: 4),
                Text(
                  newStatus ==
                          AdminTranslations.split(AdminTranslations.active)[0]
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
