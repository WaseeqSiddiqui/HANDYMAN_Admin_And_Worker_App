// worker_dashboard.dart - FIXED VERSION

import 'package:admin_x_technician_panel/screens/auth/role_selection.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '/providers/app_state_provider.dart';
import '/services/worker_auth_service.dart';

// Import all worker screens
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

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: _buildAppBar(),
          drawer: _buildDrawer(appState),
          body: RefreshIndicator(
            onRefresh: () => _refreshData(appState),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWalletCreditCard(appState),
                  _buildQuickStats(appState),
                  _buildQuickActions(),
                  _buildServicesSection(appState),
                ],
              ),
            ),
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
              icon: const Icon(
                  Icons.notifications_outlined, color: Colors.white),
              onPressed: () =>
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (
                        context) => const WorkerNotificationsScreen()),
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

          // Wallet & Credit
          ListTile(
            leading: const Icon(
                Icons.account_balance_wallet, color: Color(0xFF6B5B9A)),
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

          // Transactions
          ListTile(
            leading: const Icon(Icons.receipt_long, color: Color(0xFF6B5B9A)),
            title: const Text('Transactions'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const WorkerTransactionsScreen()),
              );
            },
          ),

          // Completed Services
          ListTile(
            leading: const Icon(Icons.check_circle, color: Color(0xFF6B5B9A)),
            title: const Text('Completed Services'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CompletedServicesScreen(),
                ),
              );
            },
          ),

          const Divider(),

          // Profile
          ListTile(
            leading: const Icon(Icons.person, color: Color(0xFF6B5B9A)),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const WorkerProfileScreen()),
              );
            },
          ),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: _handleLogout,
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCreditCard(AppStateProvider appState) {
    // ✅ FIXED: Get pending amount that matches wallet calculation
    final pendingAmount = appState.pendingClearance; // Use pendingClearance from wallet

    return Container(
      margin: const EdgeInsets.all(16),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
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
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pending Amount',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Text(
                    'SAR ${pendingAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(String title, double amount, IconData icon, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(color: color, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatCard(
            'Available',
            appState.availableServices.length.toString(),
            Colors.orange,
            Icons.pending_actions,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'Active',
            appState.activeServices.length.toString(),
            Colors.blue,
            Icons.build,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'Completed',
            appState.completedServices.length.toString(),
            Colors.green,
            Icons.check_circle,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildQuickActionButton(
                'Top-up Credit',
                Icons.add_circle,
                const Color(0xFF6B5B9A),
                    () =>
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CreditScreen()),
                    ),
              ),
              const SizedBox(width: 12),
              _buildQuickActionButton(
                'Withdraw',
                Icons.account_balance_wallet,
                Colors.green,
                    () =>
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const WalletScreen()),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServicesSection(AppStateProvider appState) {
    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Services',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              labelColor: const Color(0xFF6B5B9A),
              unselectedLabelColor: Colors.grey,
              indicator: BoxDecoration(
                color: const Color(0xFF6B5B9A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              tabs: [
                Tab(text: 'Available (${appState.availableServices.length})'),
                Tab(text: 'Active (${appState.activeServices.length})'),
                Tab(text: 'Postponed (${appState.postponedServices.length})'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 400,
            child: TabBarView(
              children: [
                _buildServicesList(
                    appState, appState.availableServices, 'available'),
                _buildServicesList(appState, appState.activeServices, 'active'),
                _buildServicesList(
                    appState, appState.postponedServices, 'postponed'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesList(AppStateProvider appState,
      List<Map<String, dynamic>> services, String type) {
    if (services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'available' ? Icons.inbox : Icons.check_circle_outline,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              type == 'available'
                  ? 'No services available'
                  : type == 'active'
                  ? 'No active services'
                  : 'No postponed services',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return _buildServiceCard(appState, service, type);
      },
    );
  }

  Widget _buildServiceCard(AppStateProvider appState,
      Map<String, dynamic> service, String type) {
    final totalPrice = (service['price'] as num).toDouble() +
        ((service['extraCharges'] ?? 0.0) as num).toDouble();
    final requiredCredit = totalPrice * 0.35;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceDetailScreen(service: service),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B5B9A).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.build,
                      color: Color(0xFF6B5B9A),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service['service'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          service['customer'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                      Icons.location_on, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      service['address'],
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                      Icons.access_time, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(service['date']),
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  if (service.containsKey('distance')) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.directions_car, size: 16,
                        color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      service['distance'],
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Amount',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                      Text(
                        'SAR ${totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6B5B9A),
                        ),
                      ),
                    ],
                  ),
                  if ((service['extraCharges'] ?? 0.0) > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '+${(service['extraCharges'] as num).toStringAsFixed(
                            0)} SAR extras',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (type == 'available') _buildAvailableActions(
                  appState, service, requiredCredit),
              if (type == 'active') _buildActiveActions(
                  appState, service, requiredCredit),
              if (type == 'postponed') _buildPostponedActions(
                  appState, service, requiredCredit),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableActions(AppStateProvider appState,
      Map<String, dynamic> service, double requiredCredit) {
    final hasEnoughCredit = appState.creditBalance >= requiredCredit;

    return Column(
      children: [
        if (!hasEnoughCredit)
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning, size: 16, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Insufficient credit: Need SAR ${requiredCredit.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: OutlinedButton.icon(
                onPressed: () => _postponeAvailableService(service, appState),
                icon: const Icon(Icons.schedule, size: 18),
                label: const Text('Postpone'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: const BorderSide(color: Colors.orange),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: ElevatedButton.icon(
                onPressed: hasEnoughCredit
                    ? () => _acceptService(service, appState)
                    : null,
                icon: const Icon(Icons.check_circle, size: 18),
                label: const Text('Accept Service'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B5B9A),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ✅ FIXED: Active services should NOT have postpone button
  Widget _buildActiveActions(AppStateProvider appState,
      Map<String, dynamic> service, double requiredCredit) {
    final hasEnoughCredit = appState.creditBalance >= requiredCredit;

    return Column(
      children: [
        if (!hasEnoughCredit)
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning, size: 16, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Need SAR ${requiredCredit.toStringAsFixed(
                        2)} credit to complete',
                    style: const TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        // ✅ REMOVED POSTPONE BUTTON - Only Chat and Complete buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () =>
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(service: service),
                      ),
                    ),
                icon: const Icon(Icons.chat, size: 18),
                label: const Text('Chat'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6B5B9A),
                  side: const BorderSide(color: Color(0xFF6B5B9A)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: hasEnoughCredit ? () =>
                    _completeService(service, appState) : null,
                icon: const Icon(Icons.check_circle, size: 18),
                label: const Text('Complete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPostponedActions(AppStateProvider appState,
      Map<String, dynamic> service, double requiredCredit) {
    final hasEnoughCredit = appState.creditBalance >= requiredCredit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (service.containsKey('postponeReason'))
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Reason: ${service['postponeReason']}',
                    style: const TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),
        if (!hasEnoughCredit)
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning, size: 16, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Need SAR ${requiredCredit.toStringAsFixed(
                        2)} credit to resume',
                    style: const TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ElevatedButton.icon(
          onPressed: hasEnoughCredit
              ? () => _resumeService(service, appState)
              : null,
          icon: const Icon(Icons.play_arrow, size: 18),
          label: const Text('Resume Service'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            minimumSize: const Size(double.infinity, 40),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(dynamic date) {
    try {
      final DateTime dateTime = date is DateTime ? date : DateTime.parse(
          date.toString());
      final now = DateTime.now();
      final difference = dateTime.difference(now);

      if (difference.inDays == 0) {
        if (difference.inHours > 0) {
          return 'In ${difference.inHours}h ${difference.inMinutes.remainder(60)}m';
        } else if (difference.inMinutes > 0) {
          return 'In ${difference.inMinutes}m';
        } else {
          return 'Now';
        }
      } else if (difference.inDays == 1) {
        return 'Tomorrow';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return 'N/A';
    }
  }

  void _acceptService(Map<String, dynamic> service,
      AppStateProvider appState) async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    appState.acceptService(service);

    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Service accepted!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _postponeAvailableService(Map<String, dynamic> service, AppStateProvider appState) {
    String? selectedReason;
    final TextEditingController otherReasonController = TextEditingController();
    final List<String> postponeReasons = [
      'Customer not available',
      'Customer requested reschedule',
      'Wrong address provided',
      'Tools/parts not available',
      'Weather conditions',
      'Emergency situation',
      'Traffic/transportation issue',
      'Not ready to accept now',
      'Other',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.schedule, color: Colors.orange),
              SizedBox(width: 8),
              Text('Postpone Service'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Service: ${service['service']}'),
                Text('Customer: ${service['customer']}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 16),
                const Text(
                  'Select reason for postponement:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text('Choose a reason'),
                      value: selectedReason,
                      items: postponeReasons
                          .map((String reason) => DropdownMenuItem<String>(
                        value: reason,
                        child: Text(reason, style: const TextStyle(fontSize: 14)),
                      ))
                          .toList(),
                      onChanged: (String? newValue) =>
                          setDialogState(() => selectedReason = newValue),
                    ),
                  ),
                ),
                if (selectedReason == 'Other') ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: otherReasonController,
                    decoration: const InputDecoration(
                      labelText: 'Please specify reason',
                      border: OutlineInputBorder(),
                      hintText: 'Enter your reason here...',
                    ),
                    maxLines: 3,
                  ),
                ],
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Service will be postponed and admin will be notified',
                          style: TextStyle(fontSize: 11, color: Colors.orange),
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
              onPressed: () {
                otherReasonController.dispose();
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedReason == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a reason'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                if (selectedReason == 'Other' &&
                    otherReasonController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please specify the reason'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                final finalReason = selectedReason == 'Other'
                    ? otherReasonController.text.trim()
                    : selectedReason!;
                Navigator.pop(context);

                appState.postponeAvailableService(service, finalReason);

                otherReasonController.dispose();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Service postponed: $finalReason'),
                    backgroundColor: Colors.orange,
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Confirm Postpone'),
            ),
          ],
        ),
      ),
    );
  }

  void _completeService(Map<String, dynamic> service,
      AppStateProvider appState) {
    final totalPrice = (service['price'] as num).toDouble() +
        ((service['extraCharges'] ?? 0.0) as num).toDouble();
    final commission = totalPrice * 0.20;
    final vat = totalPrice * 0.15;
    final totalDeduction = commission + vat;

    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
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
                Text(
                  'Mark ${service['service']} as completed?',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                _buildSummaryRow(
                    'Customer Pays', 'SAR ${totalPrice.toStringAsFixed(2)}',
                    isBold: true, color: const Color(0xFF6B5B9A)),
                const SizedBox(height: 12),
                const Text('Deductions from Credit:', style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey)),
                const SizedBox(height: 4),
                _buildSummaryRow('  Commission (20%)',
                    'SAR ${commission.toStringAsFixed(2)}', color: Colors.red),
                _buildSummaryRow('  VAT (15%)', 'SAR ${vat.toStringAsFixed(2)}',
                    color: Colors.red),
                const Divider(),
                _buildSummaryRow(
                    'Added to Wallet', 'SAR ${totalPrice.toStringAsFixed(2)}',
                    isBold: true, color: Colors.green),
                _buildSummaryRow('Deducted from Credit',
                    'SAR ${totalDeduction.toStringAsFixed(2)}', isBold: true,
                    color: Colors.red),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                              Icons.account_balance_wallet, color: Colors.green,
                              size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Full amount (SAR ${totalPrice.toStringAsFixed(
                                  2)}) will be added to your wallet',
                              style: const TextStyle(fontSize: 12, color: Colors
                                  .green, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                              Icons.credit_card, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Commission + VAT (SAR ${totalDeduction
                                  .toStringAsFixed(
                                  2)}) will be deducted from credit',
                              style: const TextStyle(fontSize: 12, color: Colors
                                  .red, fontWeight: FontWeight.w600),
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
                onPressed: () {
                  Navigator.pop(context);
                  appState.completeService(service);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('✅ Service completed!',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Wallet: +SAR ${totalPrice.toStringAsFixed(2)}'),
                          Text('Credit: -SAR ${totalDeduction.toStringAsFixed(
                              2)}'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Complete Service'),
              ),
            ],
          ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isBold = false, Color? color}) {
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

  void _resumeService(Map<String, dynamic> service, AppStateProvider appState) {
    final basePrice = (service['price'] as num).toDouble();
    final extraCharges = ((service['extraCharges'] ?? 0.0) as num).toDouble();
    final totalPrice = basePrice + extraCharges;
    final requiredCredit = totalPrice * 0.35;

    if (appState.creditBalance < requiredCredit) {
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
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
                  const Text(
                      'Cannot resume service due to insufficient credit.'),
                  const SizedBox(height: 12),
                  Text('Required: SAR ${requiredCredit.toStringAsFixed(2)}'),
                  Text('Available: SAR ${appState.creditBalance.toStringAsFixed(
                      2)}'),
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
                      MaterialPageRoute(
                          builder: (context) => const CreditScreen()),
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
      builder: (context) =>
          AlertDialog(
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
                Text('Resume ${service['service']}?'),
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
                  appState.resumeService(service);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${service['service']} resumed'),
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