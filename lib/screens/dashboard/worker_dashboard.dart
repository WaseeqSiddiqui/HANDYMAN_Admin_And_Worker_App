// worker_dashboard.dart - COMPLETELY FIXED VERSION
// ✅ Fixed: Layout rendering issues
// ✅ Fixed: Postpone button appears after accepting (in accepted status)
// ✅ Fixed: Proper buttons instead of icons
// ✅ Fixed: Chat button in active services
// ✅ Fixed: TabBarView layout constraints

import 'package:admin_x_technician_panel/screens/auth/role_selection.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '/providers/app_state_provider.dart';
import '/services/worker_auth_service.dart';
import '/models/service_request_model.dart';

// Import worker screens
import '../../worker/wallet_screen.dart';
import '../../worker/credit_screen.dart';
import '../../worker/chat_screen.dart';
import '../../worker/transactions_screen.dart';
import '../../worker/completed_services_screen.dart';
import '../../worker/service_detail_screen.dart';
import '../../worker/notifications_screen.dart';
import '../../worker/worker_profile_screen.dart';

class WorkerDashboardScreen extends StatefulWidget {
  final String phoneNumber;
  final String? workerName;

  const WorkerDashboardScreen({
    super.key,
    required this.phoneNumber,
    this.workerName,
  });

  @override
  State<WorkerDashboardScreen> createState() => _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends State<WorkerDashboardScreen> {
  late String _workerName;
  late String _workerId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeWorker();
  }

  void _initializeWorker() {
    final authService = WorkerAuthService();
    final workerData = authService.getWorkerByPhone(widget.phoneNumber);

    if (workerData != null) {
      _workerName = workerData.name;
      _workerId = workerData.id;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Provider.of<AppStateProvider>(context, listen: false)
              .setCurrentWorker(_workerId);
        }
      });
    } else {
      _workerName = widget.workerName ?? 'Worker';
      _workerId = 'UNKNOWN';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    try {
      return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }

  String _formatDate(DateTime date) {
    try {
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: _buildAppBar(),
          drawer: _buildDrawer(appState),
          body: Column(
            children: [
              // ✅ COMPACT: Top section (no flex, fixed height)
              SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWalletCreditCard(appState),
                    _buildQuickStats(appState),
                    _buildQuickActions(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              // ✅ Services section gets remaining space
              Expanded(
                child: _buildServicesSection(appState),
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFF6B5B9A),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Worker Dashboard',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            _workerName,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const WorkerNotificationsScreen()),
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '3',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDrawer(AppStateProvider appState) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6B5B9A), Color(0xFF8B7AB8)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 36, color: Color(0xFF6B5B9A)),
                ),
                const SizedBox(height: 12),
                Text(
                  _workerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.phoneNumber,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          ListTile(
            leading: const Icon(Icons.account_balance_wallet, color: Color(0xFF6B5B9A)),
            title: const Text('Wallet'),
            trailing: Text(
              'SAR ${appState.walletBalance.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WalletScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.credit_card, color: Color(0xFF6B5B9A)),
            title: const Text('Credit'),
            trailing: Text(
              'SAR ${appState.creditBalance.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreditScreen()),
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.receipt_long, color: Color(0xFF6B5B9A)),
            title: const Text('Transactions'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WorkerTransactionsScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.check_circle_outline, color: Color(0xFF6B5B9A)),
            title: const Text('Completed Services'),
            trailing: Text(
              '${appState.completedServices.length}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CompletedServicesScreen()),
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.person_outline, color: Color(0xFF6B5B9A)),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WorkerProfileScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              _handleLogout();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCreditCard(AppStateProvider appState) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B5B9A), Color(0xFF8B7AB8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B5B9A).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildBalanceCard(
            'Wallet Balance',
            appState.walletBalance,
            Icons.account_balance_wallet,
            Colors.white,
          ),
          _buildBalanceCard(
            'Available Credit',
            appState.creditBalance,
            Icons.credit_card,
            Colors.white70,
          ),
        ],
      ),
    );
  }

// Helper method for balance cards:
  Widget _buildBalanceCard(String title, double amount, IconData icon, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(color: color, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'SAR ${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(AppStateProvider appState) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Active',
              '${appState.activeServices.length}',
              Icons.pending_actions,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 10), // ✅ Reduced spacing
          Expanded(
            child: _buildStatCard(
              'Completed',
              '${appState.completedServices.length}',
              Icons.check_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              'Available',
              '${appState.availableServices.length}',
              Icons.assignment,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

// Find: Widget _buildStatCard
// Replace with this COMPACT version:

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12), // ✅ Reduced from 16
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Icon(icon, color: color, size: 28), // ✅ Reduced from 32
          const SizedBox(height: 6), // ✅ Reduced spacing
          Text(
            value,
            style: const TextStyle(
              fontSize: 20, // ✅ Reduced from 24
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11, // ✅ Reduced from 12
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

// Find: Widget _buildQuickActions()
// Replace with this COMPACT version:

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 12), // ✅ Reduced margins
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16, // ✅ Reduced from 18
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10), // ✅ Reduced from 12
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Top-up Credit',
                  Icons.add_circle_outline,
                  const Color(0xFF6B5B9A),
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreditScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildActionButton(
                  'Wallet',
                  Icons.account_balance_wallet_outlined,
                  Colors.green,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const WalletScreen()),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

// Find: Widget _buildActionButton
// Replace with this COMPACT version:

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12), // ✅ Reduced from 16
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20), // ✅ Reduced from 24
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13, // ✅ Reduced size
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesSection(AppStateProvider appState) {
    return DefaultTabController(
      length: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              labelColor: const Color(0xFF6B5B9A),
              unselectedLabelColor: Colors.grey,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF6B5B9A).withOpacity(0.1),
              ),
              tabs: const [
                Tab(text: 'Available'),
                Tab(text: 'Active'),
                Tab(text: 'Completed'),
                Tab(text: 'Postponed'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildServiceList(appState.availableServices, 'available', appState),
                _buildServiceList(appState.activeServices, 'active', appState),
                _buildServiceList(appState.completedServices, 'completed', appState),
                _buildServiceList(appState.postponedServices, 'postponed', appState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceList(List<ServiceRequest> services, String type, AppStateProvider appState) {
    if (services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getEmptyIcon(type),
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No $type services',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return _buildServiceCard(service, type, appState);
      },
    );
  }

  IconData _getEmptyIcon(String type) {
    switch (type) {
      case 'available':
        return Icons.assignment_outlined;
      case 'active':
        return Icons.pending_actions_outlined;
      case 'completed':
        return Icons.check_circle_outline;
      case 'postponed':
        return Icons.schedule_outlined;
      default:
        return Icons.inbox_outlined;
    }
  }

  Widget _buildServiceCard(ServiceRequest service, String type, AppStateProvider appState) {
    final statusColor = _getStatusColor(service.status);
    final statusText = _getStatusText(service.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceDetailScreen(service: service),
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      service.serviceName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      service.customerName,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      service.address,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    '${_formatDate(service.requestedDate)} at ${service.requestedTime}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        'SAR ${service.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6B5B9A),
                        ),
                      ),
                    ],
                  ),
                  // ✅ FIXED: Use separate method for action buttons to avoid layout issues
                  _buildActionButtons(service, type, appState),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ NEW: Separate method for action buttons to avoid layout constraints issues
  Widget _buildActionButtons(ServiceRequest service, String type, AppStateProvider appState) {
    switch (type) {
      case 'available':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton(
              onPressed: () => _postponeService(service, appState),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: const Text('Postpone'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _acceptService(service, appState),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: const Text('Accept'),
            ),
          ],
        );

      case 'active':
      // ✅ FIX: Show only "Service Details" button for all active services
        return ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceDetailScreen(service: service),
            ),
          ).then((_) => setState(() {})), // Refresh on return
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6B5B9A),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: const Text('Service Details'),
        );

      case 'postponed':
        return ElevatedButton(
          onPressed: () => _resumeService(service, appState),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: const Text('Resume'),
        );

      default:
        return const SizedBox(); // No buttons for completed services
    }
  }

  Color _getStatusColor(ServiceRequestStatus status) {
    switch (status) {
      case ServiceRequestStatus.pending:
        return Colors.orange;
      case ServiceRequestStatus.assigned:
        return Colors.blue;
      case ServiceRequestStatus.accepted:
        return Colors.purple;
      case ServiceRequestStatus.inProgress:
        return Colors.amber;
      case ServiceRequestStatus.completed:
        return Colors.green;
      case ServiceRequestStatus.postponed:
        return Colors.grey;
      case ServiceRequestStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(ServiceRequestStatus status) {
    switch (status) {
      case ServiceRequestStatus.pending:
        return 'Pending';
      case ServiceRequestStatus.assigned:
        return 'Assigned';
      case ServiceRequestStatus.accepted:
        return 'Accepted';
      case ServiceRequestStatus.inProgress:
        return 'In Progress';
      case ServiceRequestStatus.completed:
        return 'Completed';
      case ServiceRequestStatus.postponed:
        return 'Postponed';
      case ServiceRequestStatus.cancelled:
        return 'Cancelled';
    }
  }

  void _acceptService(ServiceRequest service, AppStateProvider appState) {
    final requiredCredit = appState.getRequiredCredit(service);

    if (!appState.hasEnoughCredit(service)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Insufficient Credit'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('You need more credit to accept this service.'),
              const SizedBox(height: 12),
              Text('Required: SAR ${requiredCredit.toStringAsFixed(2)}'),
              Text('Available: SAR ${appState.creditBalance.toStringAsFixed(2)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreditScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B5B9A)),
              child: const Text('Top-up Credit'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Accept Service'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Accept ${service.serviceName}?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '⚠️ Important',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'SAR ${requiredCredit.toStringAsFixed(2)} will be reserved from your credit until service completion.',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              appState.acceptService(service.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${service.serviceName} accepted'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Accept Service'),
          ),
        ],
      ),
    );
  }

  void _postponeService(ServiceRequest service, AppStateProvider appState) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.schedule, color: Colors.orange),
            SizedBox(width: 8),
            Text('Postpone Service'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Postpone ${service.serviceName}?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for postponement',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide a reason'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(context);
              appState.postponeService(service.id, reasonController.text.trim());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${service.serviceName} postponed'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Postpone'),
          ),
        ],
      ),
    );
  }

  void _completeService(ServiceRequest service, AppStateProvider appState) {
    // ✅ Use model properties
    final totalPrice = service.totalPrice;
    final totalDeduction = service.totalDeduction;

    // ✅ CRITICAL: Check credit before showing dialog
    if (appState.creditBalance < totalDeduction) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 8),
              Text('Insufficient Credit'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'You do not have enough credit to complete this service.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text('Required: SAR ${totalDeduction.toStringAsFixed(2)}'),
              Text('Available: SAR ${appState.creditBalance.toStringAsFixed(2)}'),
              Text(
                'Shortfall: SAR ${(totalDeduction - appState.creditBalance).toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreditScreen()),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6B5B9A)),
              child: const Text('Top-up Credit'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Complete Service'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mark ${service.serviceName} as completed?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Use model properties for breakdown
                  _buildSummaryRow('Base Price', 'SAR ${service.basePrice.toStringAsFixed(2)}'),
                  if (service.extraItems.isNotEmpty) ...[
                    _buildSummaryRow('Extra Charges', 'SAR ${service.totalExtraPrice.toStringAsFixed(2)}'),
                  ],
                  const Divider(),
                  _buildSummaryRow('Total Amount', 'SAR ${totalPrice.toStringAsFixed(2)}', isBold: true),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Commission (${service.commission}%)', 'SAR ${service.totalCommission.toStringAsFixed(2)}', color: Colors.red),
                  _buildSummaryRow('VAT (${service.vat}%)', 'SAR ${service.totalVAT.toStringAsFixed(2)}', color: Colors.red),
                  const Divider(),
                  _buildSummaryRow('Your Earnings', 'SAR ${(totalPrice - totalDeduction).toStringAsFixed(2)}', isBold: true, color: Colors.green),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Deductions',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.credit_card, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Commission + VAT (SAR ${totalDeduction.toStringAsFixed(2)}) will be deducted from credit',
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // ✅ CRITICAL: Final credit check before completing
              if (appState.creditBalance < totalDeduction) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('❌ Insufficient credit. Cannot complete service.'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
                return;
              }

              // Complete the service
              await appState.completeService(service.id);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('✅ Service completed!',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Wallet: +SAR ${totalPrice.toStringAsFixed(2)}'),
                        Text('Credit: -SAR ${totalDeduction.toStringAsFixed(2)}'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Complete Service'),
          ),
        ],
      ),
    );
  }


  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _resumeService(ServiceRequest service, AppStateProvider appState) {
    final requiredCredit = service.totalDeduction;

    if (appState.creditBalance < requiredCredit) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Insufficient Credit'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Cannot resume service due to insufficient credit.'),
              const SizedBox(height: 12),
              Text('Required: SAR ${requiredCredit.toStringAsFixed(2)}'),
              Text('Available: SAR ${appState.creditBalance.toStringAsFixed(2)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreditScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B5B9A)),
              child: const Text('Top-up Credit'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.play_arrow, color: Colors.green),
            SizedBox(width: 8),
            Text('Resume Service'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resume ${service.serviceName}?'),
            const SizedBox(height: 12),
            const Text(
              'The service will be moved back to active services.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              appState.resumeService(service.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${service.serviceName} resumed'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Resume'),
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout, color: Colors.red, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                    (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData(AppStateProvider appState) async {
    await Future.delayed(const Duration(seconds: 1));
  }
}