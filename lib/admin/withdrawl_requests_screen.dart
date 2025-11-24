import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/utils/admin_translations.dart';
import '/services/financial_service.dart';
import '/providers/app_state_provider.dart';
import '/services/worker_auth_service.dart';
import '../models/withdrawl_requests_model.dart';
import '/models/worker_data_model.dart';

class WithdrawalRequestsScreen extends StatefulWidget {
  const WithdrawalRequestsScreen({super.key});

  @override
  State<WithdrawalRequestsScreen> createState() => _WithdrawalRequestsScreenState();
}

class _WithdrawalRequestsScreenState extends State<WithdrawalRequestsScreen> {
  final _financialService = FinancialService();
  String _selectedFilter = "Pending";

  @override
  void initState() {
    super.initState();
    _financialService.addListener(_onFinancialUpdate);
  }

  @override
  void dispose() {
    _financialService.removeListener(_onFinancialUpdate);
    super.dispose();
  }

  void _onFinancialUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FA);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(AdminTranslations.split(AdminTranslations.withdrawalRequests)[0]),
        backgroundColor: const Color(0xFF6B5B9A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: AdminTranslations.split(AdminTranslations.refreshBtn)[0],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterTabs(),
          _buildStatsSummary(cardColor),
          Expanded(
            child: _buildRequestsList(cardColor),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterChip(
              AdminTranslations.split(AdminTranslations.pending)[0],
              Icons.pending_actions,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildFilterChip(
              AdminTranslations.split(AdminTranslations.approved)[0],
              Icons.check_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildFilterChip(
              AdminTranslations.split(AdminTranslations.rejected)[0],
              Icons.cancel,
              Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, Color color) {
    final isSelected = _selectedFilter == label;
    final requests = _financialService.getWithdrawalRequests(status: label);

    return InkWell(
      onTap: () => setState(() => _selectedFilter = label),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${requests.length}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSummary(Color cardColor) {
    final pendingRequests = _financialService.getWithdrawalRequests(
      status: AdminTranslations.split(AdminTranslations.pending)[0],
    );
    final totalPendingAmount = pendingRequests.fold<double>(
      0.0,
          (sum, req) => sum + req.amount,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              AdminTranslations.split(AdminTranslations.pendingRequests)[0],
              pendingRequests.length.toString(),
              Icons.pending_actions,
              Colors.orange,
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          Expanded(
            child: _buildStatItem(
              AdminTranslations.split(AdminTranslations.totalAmount)[0],
              'SAR ${totalPendingAmount.toStringAsFixed(0)}',
              Icons.account_balance_wallet,
              Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRequestsList(Color cardColor) {
    final requests = _financialService.getWithdrawalRequests(status: _selectedFilter);

    if (requests.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return _buildRequestCard(request, cardColor);
      },
    );
  }

  Widget _buildRequestCard(WithdrawalRequest request, Color cardColor) {
    final workerAuthService = WorkerAuthService();
    final workerData = workerAuthService.getAllWorkers().firstWhere(
          (w) => w.id == request.workerId,
      orElse: () => WorkerData(
        id: request.workerId,
        name: request.workerName,
        nameArabic: '',
        phone: '',
        email: '',
        nationalId: '',
        stcPayId: '',
        address: '',
        addressArabic: '',
        status: 'Active',
        joinedDate: DateTime.now(),
      ),
    );

    // Extract English values from bilingual strings
    final approvedEn = AdminTranslations.split(AdminTranslations.approved)[0];
    final rejectedEn = AdminTranslations.split(AdminTranslations.rejected)[0];

    // Determine status color and icon
    Color statusColor;
    IconData statusIcon;

    if (request.status == approvedEn) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (request.status == rejectedEn) {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
    } else {
      statusColor = Colors.orange;
      statusIcon = Icons.pending_actions;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.workerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${AdminTranslations.split(AdminTranslations.requestId)[0]}: ${request.id}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    request.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Worker Details
            _buildDetailRow(
              Icons.phone,
              AdminTranslations.split(AdminTranslations.phone)[0],
              workerData.phone,
            ),
            _buildDetailRow(
              Icons.payment,
              AdminTranslations.split(AdminTranslations.stcPay)[0],
              workerData.stcPayId.isEmpty
                  ? AdminTranslations.split(AdminTranslations.notProvided)[0]
                  : workerData.stcPayId,
            ),
            _buildDetailRow(
              Icons.work,
              AdminTranslations.split(AdminTranslations.completedServices)[0],
              '${workerData.completedServices} ${AdminTranslations.split(AdminTranslations.servicesLowercase)[0]}',
            ),

            const SizedBox(height: 12),

            // Amount
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        AdminTranslations.split(AdminTranslations.withdrawalAmount)[0],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Text(
                    'SAR ${request.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Request Date
            _buildDetailRow(
              Icons.calendar_today,
              AdminTranslations.split(AdminTranslations.requested)[0],
              _formatDate(request.requestDate),
            ),

            // Processed Date (if approved/rejected)
            if (request.processedDate != null)
              _buildDetailRow(
                Icons.check_circle_outline,
                AdminTranslations.split(AdminTranslations.processedDate)[0],
                _formatDate(request.processedDate!),
              ),

            // Admin Notes (if rejected)
            if (request.adminNotes != null && request.adminNotes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${AdminTranslations.split(AdminTranslations.rejectionReason)[0]}:',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            request.adminNotes!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Action Buttons (only for pending)
            if (request.status == AdminTranslations.split(AdminTranslations.pending)[0]) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showRejectDialog(request),
                      icon: const Icon(Icons.cancel, size: 18),
                      label: Text(AdminTranslations.split(AdminTranslations.reject)[0]),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () => _showApproveDialog(request, workerData),
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: Text(AdminTranslations.split(AdminTranslations.approveAndProcess)[0]),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    // Extract English values from bilingual strings
    final approvedEn = AdminTranslations.split(AdminTranslations.approved)[0];
    final rejectedEn = AdminTranslations.split(AdminTranslations.rejected)[0];

    // Determine empty state message and icon
    String message;
    IconData icon;

    if (_selectedFilter == approvedEn) {
      message = AdminTranslations.split(AdminTranslations.noApprovedWithdrawals)[0];
      icon = Icons.check_circle_outline;
    } else if (_selectedFilter == rejectedEn) {
      message = AdminTranslations.split(AdminTranslations.noRejectedWithdrawals)[0];
      icon = Icons.cancel_outlined;
    } else {
      message = AdminTranslations.split(AdminTranslations.noWithdrawalRequests)[0];
      icon = Icons.pending_actions_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _showApproveDialog(WithdrawalRequest request, WorkerData workerData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Text(AdminTranslations.split(AdminTranslations.approveWithdrawal)[0]),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AdminTranslations.split(AdminTranslations.approveConfirmTitle)[0],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Divider(),
              _buildInfoRow(
                AdminTranslations.split(AdminTranslations.worker)[0],
                workerData.name,
              ),
              _buildInfoRow(
                AdminTranslations.split(AdminTranslations.phone)[0],
                workerData.phone,
              ),
              _buildInfoRow(
                AdminTranslations.split(AdminTranslations.stcPayId)[0],
                workerData.stcPayId.isEmpty
                    ? AdminTranslations.split(AdminTranslations.notProvided)[0]
                    : workerData.stcPayId,
              ),
              _buildInfoRow(
                AdminTranslations.split(AdminTranslations.amount)[0],
                'SAR ${request.amount.toStringAsFixed(2)}',
                isBold: true,
              ),
              const Divider(),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${AdminTranslations.split(AdminTranslations.thisActionWill)[0]}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• ${AdminTranslations.split(AdminTranslations.deductFromWorkerWallet)[0]} SAR ${request.amount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      '• ${AdminTranslations.split(AdminTranslations.deductFromAdminWallet)[0]} SAR ${request.amount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      '• ${AdminTranslations.split(AdminTranslations.updateFinancialReports)[0]}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      '• ${AdminTranslations.split(AdminTranslations.sendNotificationToWorker)[0]}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AdminTranslations.split(AdminTranslations.cancelBtn)[0]),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _approveWithdrawal(request);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: Text(AdminTranslations.split(AdminTranslations.approveAndProcess)[0]),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(WithdrawalRequest request) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.cancel, color: Colors.red),
            const SizedBox(width: 8),
            Text(AdminTranslations.split(AdminTranslations.rejectWithdrawal)[0]),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AdminTranslations.split(AdminTranslations.rejectWithdrawal)[0]} from ${request.workerName}?',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: AdminTranslations.split(AdminTranslations.rejectionReason)[0],
                hintText: AdminTranslations.split(AdminTranslations.enterRejectionReason)[0],
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AdminTranslations.split(AdminTranslations.workerNotified)[0],
                      style: const TextStyle(fontSize: 11, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              reasonController.dispose();
              Navigator.pop(context);
            },
            child: Text(AdminTranslations.split(AdminTranslations.cancelBtn)[0]),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AdminTranslations.split(AdminTranslations.provideRejectionReason)[0]),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(context);
              _rejectWithdrawal(request, reasonController.text.trim());
              reasonController.dispose();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(AdminTranslations.split(AdminTranslations.reject)[0]),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _approveWithdrawal(WithdrawalRequest request) async {
    final appState = Provider.of<AppStateProvider>(context, listen: false);

    try {
      // Process withdrawal through financial service
      final result = await _financialService.processWithdrawalRequest(
        request: request,
        appState: appState,
        approve: true,
      );

      if (result.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AdminTranslations.split(AdminTranslations.withdrawalApprovedSuccess)[0],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('SAR ${request.amount.toStringAsFixed(2)} ${AdminTranslations.split(AdminTranslations.processedSuccessfully)[0]}'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AdminTranslations.split(AdminTranslations.error)[0]}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _rejectWithdrawal(WithdrawalRequest request, String reason) async {
    try {
      final result = await _financialService.processWithdrawalRequest(
        request: request,
        appState: Provider.of<AppStateProvider>(context, listen: false),
        approve: false,
        adminNotes: reason,
      );

      if (result.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AdminTranslations.split(AdminTranslations.withdrawalRequestRejected)[0]} $reason'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AdminTranslations.split(AdminTranslations.error)[0]}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} ${AdminTranslations.split(AdminTranslations.minutesAgo)[0]}';
      }
      return '${difference.inHours} ${AdminTranslations.split(AdminTranslations.hoursAgo)[0]}';
    } else if (difference.inDays == 1) {
      return AdminTranslations.split(AdminTranslations.yesterday)[0];
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${AdminTranslations.split(AdminTranslations.daysAgo)[0]}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}