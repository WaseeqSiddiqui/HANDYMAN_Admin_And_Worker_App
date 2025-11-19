import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  String _selectedFilter = 'Pending';

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
        title: const Text('Withdrawal Requests'),
        backgroundColor: const Color(0xFF6B5B9A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: 'Refresh',
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
            child: _buildFilterChip('Pending', Icons.pending_actions, Colors.orange),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildFilterChip('Approved', Icons.check_circle, Colors.green),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildFilterChip('Rejected', Icons.cancel, Colors.red),
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
    final pendingRequests = _financialService.getWithdrawalRequests(status: 'Pending');
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
              'Pending Requests',
              pendingRequests.length.toString(),
              Icons.pending_actions,
              Colors.orange,
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          Expanded(
            child: _buildStatItem(
              'Total Amount',
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

    Color statusColor;
    IconData statusIcon;
    switch (request.status) {
      case 'Approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'Rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
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
                        'Request ID: ${request.id}',
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
            _buildDetailRow(Icons.phone, 'Phone', workerData.phone),
            _buildDetailRow(Icons.payment, 'STC Pay', workerData.stcPayId.isEmpty ? 'Not provided' : workerData.stcPayId),
            _buildDetailRow(Icons.work, 'Completed Services', '${workerData.completedServices} services'),

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
                  const Row(
                    children: [
                      Icon(Icons.account_balance_wallet, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Withdrawal Amount',
                        style: TextStyle(fontWeight: FontWeight.w600),
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
            _buildDetailRow(Icons.calendar_today, 'Requested', _formatDate(request.requestDate)),

            // Processed Date (if approved/rejected)
            if (request.processedDate != null)
              _buildDetailRow(Icons.check_circle_outline, 'Processed', _formatDate(request.processedDate!)),

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
                          const Text(
                            'Rejection Reason:',
                            style: TextStyle(
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
            if (request.status == 'Pending') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showRejectDialog(request),
                      icon: const Icon(Icons.cancel, size: 18),
                      label: const Text('Reject'),
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
                      label: const Text('Approve & Process'),
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
    String message;
    IconData icon;
    switch (_selectedFilter) {
      case 'Approved':
        message = 'No approved withdrawals';
        icon = Icons.check_circle_outline;
        break;
      case 'Rejected':
        message = 'No rejected withdrawals';
        icon = Icons.cancel_outlined;
        break;
      default:
        message = 'No pending withdrawal requests';
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
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Approve Withdrawal'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you sure you want to approve this withdrawal request?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Divider(),
              _buildInfoRow('Worker', workerData.name),
              _buildInfoRow('Phone', workerData.phone),
              _buildInfoRow('STC Pay ID', workerData.stcPayId.isEmpty ? 'Not provided' : workerData.stcPayId),
              _buildInfoRow('Amount', 'SAR ${request.amount.toStringAsFixed(2)}', isBold: true),
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
                    const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'This action will:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Deduct SAR ${request.amount.toStringAsFixed(2)} from worker\'s wallet',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      '• Deduct SAR ${request.amount.toStringAsFixed(2)} from admin wallet',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const Text(
                      '• Update financial reports',
                      style: TextStyle(fontSize: 12),
                    ),
                    const Text(
                      '• Send notification to worker',
                      style: TextStyle(fontSize: 12),
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _approveWithdrawal(request);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Approve & Process'),
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
        title: const Row(
          children: [
            Icon(Icons.cancel, color: Colors.red),
            SizedBox(width: 8),
            Text('Reject Withdrawal'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reject withdrawal request from ${request.workerName}?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason',
                hintText: 'Enter reason for rejection...',
                border: OutlineInputBorder(),
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
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Worker will be notified about the rejection',
                      style: TextStyle(fontSize: 11, color: Colors.red),
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide a rejection reason'),
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
            child: const Text('Reject'),
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
                  const Text(
                    '✅ Withdrawal Approved',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('SAR ${request.amount.toStringAsFixed(2)} processed successfully'),
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
            content: Text('Error: $e'),
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
            content: Text('Withdrawal request rejected: $reason'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
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
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
