// worker_dashboard.dart - SCROLLABLE VERSION WITH LIGHT GRAY BACKGROUND
// ✅ Fixed: Changed background color to light gray
// ✅ Fixed: Screen is now fully scrollable
// ✅ Fixed: Notifications badge shows only English numbers

import 'package:admin_x_technician_panel/screens/auth/role_selection.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '/providers/app_state_provider.dart';
import '/services/worker_auth_service.dart';
import '/models/service_request_model.dart';
import '/utils/worker_translations.dart';

// Import worker screens
import '../../worker/wallet_screen.dart';
import '../../worker/credit_screen.dart';
import '../../worker/chat_screen.dart';
import '../../worker/transactions_screen.dart';
import '../../worker/completed_services_screen.dart';
import '../../worker/service_detail_screen.dart';
import '../../worker/notifications_screen.dart';
import '../../worker/worker_profile_screen.dart';
import '../../services/notification_service.dart';
import '../../services/chat_monitor_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  bool _isBalanceVisible = false;
  bool _showStats = true; // ✅ State for toggling stats visibility

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
          Provider.of<AppStateProvider>(
            context,
            listen: false,
          ).setCurrentWorker(_workerId);

          // ✅ Start listening to notifications
          NotificationService().startListeningToNotifications(_workerId);
        }
      });
    } else {
      _workerName = widget.workerName ?? 'Worker';
      _workerId = 'UNKNOWN';
    }
  }

  String _formatDate(DateTime date) {
    try {
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return WorkerTranslations.getBilingual('N/A', 'غير متوفر');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5), // Light gray background
          appBar: _buildAppBar(),
          drawer: _buildDrawer(appState),
          body: DefaultTabController(
            length: 4,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWalletCreditCard(appState),

                        // Toggle Row
                        _buildStatsToggleRow(),

                        if (_showStats) ...[
                          _buildQuickStats(appState),
                          const SizedBox(height: 8),
                        ],

                        _buildStyledTabBar(),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ];
              },
              body: _buildTabBarContent(appState),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsToggleRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            WorkerTranslations.getBilingual('Overview', 'نظرة عامة'),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                _showStats = !_showStats;
              });
            },
            child: Row(
              children: [
                Text(
                  _showStats
                      ? WorkerTranslations.getBilingual('Hide', 'اخفاء')
                      : WorkerTranslations.getBilingual('Show', 'عرض'),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF3B82F6),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _showStats
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: const Color(0xFF3B82F6),
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(
        0xFF3B82F6,
      ), // Keeping app bar blue for contrast
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            WorkerTranslations.getEnglish(WorkerTranslations.workerDashboard),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            WorkerTranslations.getArabic(WorkerTranslations.workerDashboard),
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 2),
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
                Icons.notifications_outlined,
                color: Colors.white,
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WorkerNotificationsScreen(),
                ),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .orderBy('timestamp', descending: true)
                  .limit(50)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();

                final unreadCount = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final targets = List<String>.from(
                    data['targetUserIds'] ?? [],
                  );
                  final isRead = data['isRead'] == true;
                  // Check if targeted and NOT read
                  return (targets.contains(_workerId) ||
                          targets.contains('All')) &&
                      !isRead;
                }).length;

                if (unreadCount == 0) return const SizedBox.shrink();

                return Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      unreadCount > 9 ? '9+' : '$unreadCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
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
                colors: [Color(0xFF3B82F6), Color(0xFF8B7AB8)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 36, color: Color(0xFF3B82F6)),
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
            leading: const Icon(
              Icons.account_balance_wallet,
              color: Color(0xFF3B82F6),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  WorkerTranslations.getEnglish(WorkerTranslations.wallet),
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  WorkerTranslations.getArabic(WorkerTranslations.wallet),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            trailing: Text(
              '${WorkerTranslations.getEnglish(WorkerTranslations.sar)} ${appState.walletBalance.toStringAsFixed(2)}',
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
            leading: const Icon(Icons.credit_card, color: Color(0xFF3B82F6)),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  WorkerTranslations.getEnglish(WorkerTranslations.credit),
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  WorkerTranslations.getArabic(WorkerTranslations.credit),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            trailing: Text(
              '${WorkerTranslations.getEnglish(WorkerTranslations.sar)} ${appState.creditBalance.toStringAsFixed(2)}',
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
            leading: const Icon(Icons.receipt_long, color: Color(0xFF3B82F6)),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  WorkerTranslations.getEnglish(
                    WorkerTranslations.transactionHistory,
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  WorkerTranslations.getArabic(
                    WorkerTranslations.transactionHistory,
                  ),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WorkerTransactionsScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(
              Icons.check_circle_outline,
              color: Color(0xFF3B82F6),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  WorkerTranslations.getEnglish(
                    WorkerTranslations.completedServices,
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  WorkerTranslations.getArabic(
                    WorkerTranslations.completedServices,
                  ),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            trailing: Text(
              '${appState.completedServices.length}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
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

          ListTile(
            leading: const Icon(Icons.person_outline, color: Color(0xFF3B82F6)),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  WorkerTranslations.getEnglish(WorkerTranslations.profile),
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  WorkerTranslations.getArabic(WorkerTranslations.profile),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WorkerProfileScreen(),
                ),
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  WorkerTranslations.getEnglish(WorkerTranslations.logout),
                  style: const TextStyle(fontSize: 14, color: Colors.red),
                ),
                Text(
                  WorkerTranslations.getArabic(WorkerTranslations.logout),
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                ),
              ],
            ),
            onTap: () => _handleLogout(),
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              WorkerTranslations.getEnglish(WorkerTranslations.logout),
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              WorkerTranslations.getArabic(WorkerTranslations.logout),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              WorkerTranslations.getEnglish(WorkerTranslations.logoutConfirm),
            ),
            const SizedBox(height: 4),
            Text(
              WorkerTranslations.getArabic(WorkerTranslations.logoutConfirm),
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              WorkerTranslations.getEnglish(WorkerTranslations.cancelBtn),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const RoleSelectionScreen(),
                ),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              WorkerTranslations.getEnglish(WorkerTranslations.logout),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCreditCard(AppStateProvider appState) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF8B7AB8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              children: [
                _buildBalanceCard(
                  WorkerTranslations.walletBalance,
                  appState.walletBalance,
                  Icons.account_balance_wallet,
                  Colors.white,
                ),
                const SizedBox(width: 12),
                _buildBalanceCard(
                  WorkerTranslations.creditBalance,
                  appState.creditBalance,
                  Icons.credit_card,
                  Colors.white70,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () {
              setState(() {
                _isBalanceVisible = !_isBalanceVisible;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isBalanceVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(
    String title,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      WorkerTranslations.getEnglish(title),
                      style: TextStyle(color: color, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      WorkerTranslations.getArabic(title),
                      style: TextStyle(color: color, fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _isBalanceVisible
                ? '${WorkerTranslations.getEnglish(WorkerTranslations.sar)} ${amount.toStringAsFixed(2)}'
                : '${WorkerTranslations.getEnglish(WorkerTranslations.sar)} ****',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
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
              WorkerTranslations.getBilingual('Active', 'نشط'),
              '${appState.activeServices.length}',
              Icons.pending_actions,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              WorkerTranslations.getBilingual('Completed', 'مكتمل'),
              '${appState.completedServices.length}',
              Icons.check_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              WorkerTranslations.getBilingual('Available', 'متاح'),
              '${appState.availableServices.length}',
              Icons.assignment,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final labelParts = label.split(' • ');
    final englishLabel = labelParts[0];
    final arabicLabel = labelParts.length > 1 ? labelParts[1] : labelParts[0];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Column(
            children: [
              Text(
                englishLabel,
                style: TextStyle(fontSize: 11, color: Colors.grey[700]),
              ),
              Text(
                arabicLabel,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStyledTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        labelColor: const Color(0xFF3B82F6),
        unselectedLabelColor: Colors.grey,
        indicatorColor: const Color(0xFF3B82F6),
        indicatorWeight: 3,
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        tabs: [
          Tab(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  WorkerTranslations.getEnglish(
                    WorkerTranslations.getBilingual('Available', 'متاح'),
                  ),
                  style: const TextStyle(fontSize: 11),
                ),
                Text(
                  WorkerTranslations.getArabic(
                    WorkerTranslations.getBilingual('Available', 'متاح'),
                  ),
                  style: const TextStyle(fontSize: 9),
                ),
              ],
            ),
          ),
          Tab(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  WorkerTranslations.getEnglish(
                    WorkerTranslations.getBilingual('Active', 'نشط'),
                  ),
                  style: const TextStyle(fontSize: 11),
                ),
                Text(
                  WorkerTranslations.getArabic(
                    WorkerTranslations.getBilingual('Active', 'نشط'),
                  ),
                  style: const TextStyle(fontSize: 9),
                ),
              ],
            ),
          ),
          Tab(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  WorkerTranslations.getEnglish(
                    WorkerTranslations.getBilingual('Complete', 'مكتمل'),
                  ),
                  style: const TextStyle(fontSize: 11),
                ),
                Text(
                  WorkerTranslations.getArabic(
                    WorkerTranslations.getBilingual('Complete', 'مكتمل'),
                  ),
                  style: const TextStyle(fontSize: 9),
                ),
              ],
            ),
          ),
          Tab(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  WorkerTranslations.getEnglish(WorkerTranslations.postpone),
                  style: const TextStyle(fontSize: 11),
                ),
                Text(
                  WorkerTranslations.getArabic(WorkerTranslations.postpone),
                  style: const TextStyle(fontSize: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarContent(AppStateProvider appState) {
    return TabBarView(
      children: [
        _buildServiceList(appState.availableServices, 'available', appState),
        _buildServiceList(appState.activeServices, 'active', appState),
        _buildServiceList(appState.completedServices, 'completed', appState),
        _buildServiceList(appState.postponedServices, 'postponed', appState),
      ],
    );
  }

  Widget _buildServiceList(
    List<ServiceRequest> services,
    String type,
    AppStateProvider appState,
  ) {
    if (services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getEmptyIcon(type), size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Column(
              children: [
                Text(
                  WorkerTranslations.getEnglish(WorkerTranslations.noServices),
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                Text(
                  WorkerTranslations.getArabic(WorkerTranslations.noServices),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
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

  Widget _buildServiceCard(
    ServiceRequest service,
    String type,
    AppStateProvider appState,
  ) {
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
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
                  const Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          WorkerTranslations.getEnglish(
                            WorkerTranslations.customer,
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          service.customerName,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          WorkerTranslations.getEnglish(
                            WorkerTranslations.address,
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          service.address,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        WorkerTranslations.getEnglish(
                          WorkerTranslations.dateTime,
                        ),
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                      Text(
                        '${_formatDate(service.requestedDate)} at ${service.requestedTime}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 12),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        WorkerTranslations.getEnglish(
                          WorkerTranslations.totalAmount,
                        ),
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                      Text(
                        WorkerTranslations.getArabic(
                          WorkerTranslations.totalAmount,
                        ),
                        style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                      ),
                      Text(
                        '${WorkerTranslations.getEnglish(WorkerTranslations.sar)} ${service.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                    ],
                  ),
                  _buildActionButtons(service, type, appState),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    ServiceRequest service,
    String type,
    AppStateProvider appState,
  ) {
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    WorkerTranslations.getEnglish(WorkerTranslations.postpone),
                    style: const TextStyle(fontSize: 11),
                  ),
                  Text(
                    WorkerTranslations.getArabic(WorkerTranslations.postpone),
                    style: const TextStyle(fontSize: 9),
                  ),
                ],
              ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    WorkerTranslations.getEnglish(WorkerTranslations.accept),
                    style: const TextStyle(fontSize: 11),
                  ),
                  Text(
                    WorkerTranslations.getArabic(WorkerTranslations.accept),
                    style: const TextStyle(fontSize: 9),
                  ),
                ],
              ),
            ),
          ],
        );

      case 'active':
        // ✅ FIXED: Added Chat button alongside Service Details
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Chat Button
            OutlinedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    serviceRequest: service,
                    workerName: _workerName,
                  ),
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors
                    .black, // ✅ Fixed: Changed from white to black for visibility
                side: const BorderSide(color: Color(0xFF3B82F6)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.chat_bubble_outline, size: 16),
                  Text(
                    WorkerTranslations.getEnglish(WorkerTranslations.chat),
                    style: const TextStyle(fontSize: 11),
                  ),
                  Text(
                    WorkerTranslations.getArabic(WorkerTranslations.chat),
                    style: const TextStyle(fontSize: 9),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Service Details Button
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServiceDetailScreen(service: service),
                ),
              ).then((_) => setState(() {})),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline, size: 16),
                  Text(
                    WorkerTranslations.getEnglish(
                      WorkerTranslations.serviceDetails,
                    ),
                    style: const TextStyle(fontSize: 11),
                  ),
                  Text(
                    WorkerTranslations.getArabic(
                      WorkerTranslations.serviceDetails,
                    ),
                    style: const TextStyle(fontSize: 9),
                  ),
                ],
              ),
            ),
          ],
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                WorkerTranslations.getEnglish(WorkerTranslations.resume),
                style: const TextStyle(fontSize: 11),
              ),
              Text(
                WorkerTranslations.getArabic(WorkerTranslations.resume),
                style: const TextStyle(fontSize: 9),
              ),
            ],
          ),
        );

      default:
        return const SizedBox();
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
        return WorkerTranslations.getBilingual('Pending', 'معلق');
      case ServiceRequestStatus.assigned:
        return WorkerTranslations.getBilingual('Assigned', 'مخصص');
      case ServiceRequestStatus.accepted:
        return WorkerTranslations.getBilingual('Accepted', 'مقبول');
      case ServiceRequestStatus.inProgress:
        return WorkerTranslations.getBilingual('In Progress', 'قيد التنفيذ');
      case ServiceRequestStatus.completed:
        return WorkerTranslations.getBilingual('Completed', 'مكتمل');
      case ServiceRequestStatus.postponed:
        return WorkerTranslations.getBilingual('Postponed', 'مؤجل');
      case ServiceRequestStatus.cancelled:
        return WorkerTranslations.getBilingual('Cancelled', 'ملغي');
    }
  }

  void _acceptService(ServiceRequest service, AppStateProvider appState) {
    final requiredCredit = appState.getRequiredCredit(service);

    if (!appState.hasEnoughCredit(service)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ FIXED: Using proper translation constant
                    Text(
                      WorkerTranslations.getEnglish(
                        WorkerTranslations.insufficientCredit,
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      WorkerTranslations.getArabic(
                        WorkerTranslations.insufficientCredit,
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                WorkerTranslations.getEnglish(
                  WorkerTranslations.needMoreCredit,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                WorkerTranslations.getArabic(WorkerTranslations.needMoreCredit),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${WorkerTranslations.getEnglish(WorkerTranslations.available)}',
                        ),
                        Text(
                          '${WorkerTranslations.getEnglish(WorkerTranslations.sar)} ${appState.creditBalance.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${WorkerTranslations.getEnglish(WorkerTranslations.getBilingual('Required', 'مطلوب'))}:',
                        ),
                        Text(
                          '${WorkerTranslations.getEnglish(WorkerTranslations.sar)} ${requiredCredit.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
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
              child: Text(
                WorkerTranslations.getEnglish(WorkerTranslations.cancelBtn),
              ),
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
                backgroundColor: const Color(0xFF3B82F6),
              ),
              child: Text(
                WorkerTranslations.getEnglish(WorkerTranslations.topupCredit),
              ),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              WorkerTranslations.getEnglish(WorkerTranslations.acceptService),
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              WorkerTranslations.getArabic(WorkerTranslations.acceptService),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${WorkerTranslations.getEnglish(WorkerTranslations.sar)} ${requiredCredit.toStringAsFixed(2)} ',
            ),
            Text(
              WorkerTranslations.getEnglish(WorkerTranslations.creditReserved),
            ),
            const SizedBox(height: 4),
            Text(
              WorkerTranslations.getArabic(WorkerTranslations.creditReserved),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              WorkerTranslations.getEnglish(WorkerTranslations.cancelBtn),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              appState.acceptService(service.id);
              Navigator.pop(context);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${service.serviceName} ${WorkerTranslations.getEnglish(WorkerTranslations.serviceAccepted)}',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4ADE80),
            ),
            child: Text(
              WorkerTranslations.getEnglish(WorkerTranslations.accept),
            ),
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
              appState.postponeService(
                service.id,
                reasonController.text.trim(),
              );
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

  void _resumeService(ServiceRequest service, AppStateProvider appState) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              WorkerTranslations.getEnglish(WorkerTranslations.resumeService),
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              WorkerTranslations.getArabic(WorkerTranslations.resumeService),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              WorkerTranslations.getEnglish(WorkerTranslations.movedToActive),
            ),
            const SizedBox(height: 4),
            Text(
              WorkerTranslations.getArabic(WorkerTranslations.movedToActive),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              WorkerTranslations.getEnglish(WorkerTranslations.cancelBtn),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              appState.resumeService(service.id);
              Navigator.pop(dialogContext);

              // ✅ Removed setState() - appState.resumeService already calls notifyListeners()
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${service.serviceName} ${WorkerTranslations.getEnglish(WorkerTranslations.serviceResumed)}',
                  ),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Text(
              WorkerTranslations.getEnglish(WorkerTranslations.resume),
            ),
          ),
        ],
      ),
    );
  }
}
