import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/app_state_provider.dart';
import '/services/worker_auth_service.dart';
import '/models/worker_data_model.dart';
import '/utils/worker_translations.dart';

class WorkerProfileScreen extends StatefulWidget {
  const WorkerProfileScreen({super.key});

  @override
  State<WorkerProfileScreen> createState() => _WorkerProfileScreenState();
}

class _WorkerProfileScreenState extends State<WorkerProfileScreen> {
  final _authService = WorkerAuthService();
  WorkerData? _workerData;

  @override
  void initState() {
    super.initState();
    _loadWorkerData();
  }

  void _loadWorkerData() {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final workerId = appState.currentWorkerId;

    if (workerId != null) {
      final allWorkers = _authService.getAllWorkers();
      _workerData = allWorkers.firstWhere(
            (w) => w.id == workerId,
        orElse: () => WorkerData(
          id: workerId,
          name: WorkerTranslations.getEnglish(WorkerTranslations.activeWorker),
          nameArabic: WorkerTranslations.getArabic(WorkerTranslations.activeWorker),
          phone: '',
          email: '',
          nationalId: '',
          stcPayId: '',
          address: '',
          addressArabic: '',
          status: WorkerTranslations.getEnglish(WorkerTranslations.active),
          joinedDate: DateTime.now(),
        ),
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(WorkerTranslations.profile),
        backgroundColor: const Color(0xFF6B5B9A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditProfileDialog(),
          ),
        ],
      ),
      body: _workerData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildInfoCard(),
            const SizedBox(height: 16),
            _buildStatsCard(),
            const SizedBox(height: 16),
            _buildFinancialCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B5B9A), Color(0xFF8B7AB8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B5B9A).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Text(
              _workerData!.name.isNotEmpty
                  ? _workerData!.name[0].toUpperCase()
                  : 'W',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6B5B9A),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _workerData!.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _workerData!.nameArabic,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _workerData!.status == WorkerTranslations.getEnglish(WorkerTranslations.active)
                  ? Colors.green.withOpacity(0.3)
                  : Colors.red.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _workerData!.status == WorkerTranslations.getEnglish(WorkerTranslations.active) ? Icons.check_circle : Icons.block,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  _workerData!.status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              WorkerTranslations.personalInformation,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.credit_card, WorkerTranslations.getEnglish(WorkerTranslations.fullName), _workerData!.name),
            _buildInfoRow(Icons.badge, WorkerTranslations.getEnglish(WorkerTranslations.nationalID), _workerData!.nationalId),
            _buildInfoRow(Icons.email, WorkerTranslations.getEnglish(WorkerTranslations.email), _workerData!.email),
            _buildInfoRow(Icons.phone, WorkerTranslations.getEnglish(WorkerTranslations.phone), _workerData!.phone),
            _buildInfoRow(Icons.payment, WorkerTranslations.getEnglish(WorkerTranslations.stcPayID), _workerData!.stcPayId),
            _buildInfoRow(Icons.location_on, WorkerTranslations.getEnglish(WorkerTranslations.address), _workerData!.address),
            _buildInfoRow(
              Icons.location_on_outlined,
              WorkerTranslations.getArabic(WorkerTranslations.address),
              _workerData!.addressArabic,
              isRtl: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              WorkerTranslations.statistics,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatBox(
                    WorkerTranslations.getEnglish(WorkerTranslations.completedServices),
                    _workerData!.completedServices.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatBox(
                    WorkerTranslations.getEnglish(WorkerTranslations.joinedOn),
                    '${_workerData!.joinedDate.day}/${_workerData!.joinedDate.month}/${_workerData!.joinedDate.year}',
                    Icons.calendar_today,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialCard() {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  WorkerTranslations.financialInfo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatBox(
                        WorkerTranslations.getEnglish(WorkerTranslations.walletBalance),
                        '${WorkerTranslations.sar.split(' • ')[0]} ${appState.walletBalance.toStringAsFixed(0)}',
                        Icons.account_balance_wallet,
                        const Color(0xFF6B5B9A),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatBox(
                        WorkerTranslations.getEnglish(WorkerTranslations.creditBalance),
                        '${WorkerTranslations.sar.split(' • ')[0]} ${appState.creditBalance.toStringAsFixed(0)}',
                        Icons.credit_card,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isRtl = false}) {
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
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    if (_workerData == null) return;

    final nameController = TextEditingController(text: _workerData!.name);
    final nameArabicController = TextEditingController(text: _workerData!.nameArabic);
    final emailController = TextEditingController(text: _workerData!.email);
    final stcPayController = TextEditingController(text: _workerData!.stcPayId);
    final addressController = TextEditingController(text: _workerData!.address);
    final addressArabicController = TextEditingController(text: _workerData!.addressArabic);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(WorkerTranslations.editProfile),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: WorkerTranslations.getEnglish(WorkerTranslations.fullName),
                  prefixIcon: const Icon(Icons.person),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameArabicController,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  labelText: WorkerTranslations.getArabic(WorkerTranslations.fullName),
                  prefixIcon: const Icon(Icons.person_outline),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: WorkerTranslations.getEnglish(WorkerTranslations.email),
                  prefixIcon: const Icon(Icons.email),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: stcPayController,
                decoration: InputDecoration(
                  labelText: WorkerTranslations.getEnglish(WorkerTranslations.stcPayID),
                  prefixIcon: const Icon(Icons.payment),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: WorkerTranslations.getEnglish(WorkerTranslations.address),
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
                  labelText: WorkerTranslations.getArabic(WorkerTranslations.address),
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: const OutlineInputBorder(),
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
              emailController.dispose();
              stcPayController.dispose();
              addressController.dispose();
              addressArabicController.dispose();
              Navigator.pop(context);
            },
            child: Text(WorkerTranslations.cancelBtn),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedWorker = _workerData!.copyWith(
                name: nameController.text.trim(),
                nameArabic: nameArabicController.text.trim(),
                email: emailController.text.trim(),
                stcPayId: stcPayController.text.trim(),
                address: addressController.text.trim(),
                addressArabic: addressArabicController.text.trim(),
              );

              _authService.updateWorker(_workerData!.phone, updatedWorker);

              setState(() {
                _workerData = updatedWorker;
              });

              nameController.dispose();
              nameArabicController.dispose();
              emailController.dispose();
              stcPayController.dispose();
              addressController.dispose();
              addressArabicController.dispose();

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(WorkerTranslations.getBilingual('Profile updated successfully', 'تم تحديث الملف الشخصي بنجاح')),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B5B9A),
              foregroundColor: Colors.white,
            ),
            child: Text(WorkerTranslations.saveBtn),
          ),
        ],
      ),
    );
  }
}