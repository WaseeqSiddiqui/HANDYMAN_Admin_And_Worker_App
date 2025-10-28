import 'package:flutter/material.dart';
import '../auth/role_selection.dart';

// Admin screens imports
import '../../admin/service_management_screen.dart';
import '../../admin/worker_management_screen.dart';
import '../../admin/customer_management_screen.dart';
import '../../admin/service_requests_screen.dart';
import '../../admin/invoice_management_screen.dart';
import '../../admin/financial_reports_screen.dart';
import '../../admin/credit_wallet_logs_screen.dart';
import '../../admin/complaints_screen.dart';
import '../../admin/notifications_screen.dart';
import '../../admin/admin_wallet_screen.dart';
import '../../admin/vat_management_screen.dart';
import '../../admin/commission_management_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String phoneNumber;

  const AdminDashboardScreen({super.key, required this.phoneNumber});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;

  final List<Map<String, dynamic>> _dashboardStats = [
    {
      'title': 'Total Services',
      'value': '1,247',
      'icon': Icons.build_circle,
      'color': const Color(0xFF2196F3),
      'change': '+12%',
      'trend': 'up',
    },
    {
      'title': 'Active Workers',
      'value': '156',
      'icon': Icons.people,
      'color': const Color(0xFF4CAF50),
      'change': '+8%',
      'trend': 'up',
    },
    {
      'title': 'VAT Collected',
      'value': 'SAR 24.5K',
      'icon': Icons.account_balance_wallet,
      'color': const Color(0xFFFF9800),
      'change': '+15%',
      'trend': 'up',
    },
    {
      'title': 'Commission',
      'value': 'SAR 18.2K',
      'icon': Icons.money,
      'color': const Color(0xFF9C27B0),
      'change': '+10%',
      'trend': 'up',
    },
  ];

  final List<Map<String, dynamic>> _recentActivities = [
    {
      'title': 'New service request',
      'subtitle': 'AC Repair - Ahmed Ali',
      'time': '2 min ago',
      'icon': Icons.assignment_outlined,
      'color': Colors.blue,
    },
    {
      'title': 'Worker joined',
      'subtitle': 'Mohammed Hassan',
      'time': '15 min ago',
      'icon': Icons.person_add_outlined,
      'color': Colors.green,
    },
    {
      'title': 'Service completed',
      'subtitle': 'Refrigerator Repair',
      'time': '1 hour ago',
      'icon': Icons.check_circle_outline,
      'color': Colors.orange,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FA);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundColor,
      drawer: _buildDrawer(),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildStatsGrid(),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                  const SizedBox(height: 24),
                  _buildRecentActivities(),
                  const SizedBox(height: 24),
                  _buildManagementGrid(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // AppBar
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: const Color(0xFF6B5B9A),
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      flexibleSpace: const FlexibleSpaceBar(
        title: Text(
          'Admin Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      actions: [
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.notifications_outlined, color: Colors.white),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration:
                  const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: const Text(
                    '3',
                    style: TextStyle(
                        color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotificationsScreen()),
          ),
        ),
      ],
    );
  }

  // Stats grid
  Widget _buildStatsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.4,
      ),
      itemCount: _dashboardStats.length,
      itemBuilder: (context, index) => _buildStatCard(_dashboardStats[index]),
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Icon(stat['icon'], color: stat['color']),
            Text(stat['change'],
                style: const TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold)),
          ]),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(stat['value'],
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(stat['title'], style: const TextStyle(fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  // Quick Actions
  Widget _buildQuickActions() {
    return Container(); // (keeping this as-is for now)
  }

  // Recent Activities
  Widget _buildRecentActivities() {
    return Container(); // (keeping this as-is for now)
  }

  // Management Section — now includes Commission, VAT & Admin Wallet
  // Management Section — now includes Commission, VAT, Admin Wallet, Wallet Logs & Complaints
  Widget _buildManagementGrid() {
    final List<Map<String, dynamic>> sections = [
      {
        'title': 'Services',
        'icon': Icons.build_circle,
        'color': const Color(0xFF2196F3),
        'route': const ServiceManagementScreen(),
      },
      {
        'title': 'Workers',
        'icon': Icons.construction,
        'color': const Color(0xFF4CAF50),
        'route': const WorkerManagementScreen(),
      },
      {
        'title': 'Customers',
        'icon': Icons.people,
        'color': const Color(0xFFFF9800),
        'route': const CustomerManagementScreen(),
      },
      {
        'title': 'Requests',
        'icon': Icons.assignment,
        'color': const Color(0xFF9C27B0),
        'route': const ServiceRequestsScreen(),
      },
      {
        'title': 'Invoices',
        'icon': Icons.receipt_long,
        'color': const Color(0xFF00BCD4),
        'route': const InvoiceManagementScreen(),
      },
      {
        'title': 'Reports',
        'icon': Icons.analytics,
        'color': const Color(0xFFF44336),
        'route': const FinancialReportsScreen(),
      },
      {
        'title': 'Admin Wallet',
        'icon': Icons.account_balance_wallet,
        'color': const Color(0xFF4CAF50),
        'route': const AdminWalletScreen(),
      },
      {
        'title': 'Wallet Logs',
        'icon': Icons.history,
        'color': const Color(0xFF607D8B),
        'route': const CreditWalletLogsScreen(),
      },
      {
        'title': 'Complaints',
        'icon': Icons.report_problem,
        'color': const Color(0xFFE91E63),
        'route': const ComplaintsScreen(),
      },
      {
        'title': 'VAT Management',
        'icon': Icons.receipt_long,
        'color': const Color(0xFFFF9800),
        'route': const VATManagementScreen(),
      },
      {
        'title': 'Commission',
        'icon': Icons.monetization_on,
        'color': const Color(0xFF9C27B0),
        'route': const CommissionManagementScreen(),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.3),
      itemCount: sections.length,
      itemBuilder: (context, index) => InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => sections[index]['route']),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: sections[index]['color'].withOpacity(0.2), blurRadius: 8)
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(sections[index]['icon'], color: sections[index]['color'], size: 36),
              const SizedBox(height: 12),
              Text(sections[index]['title'],
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }


  // Drawer — fixed logout + added Admin Wallet / VAT / Commission
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF6B5B9A), Color(0xFF7C3AED)]),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.admin_panel_settings,
                        color: Color(0xFF6B5B9A), size: 36)),
                const SizedBox(height: 12),
                Text(widget.phoneNumber,
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
          ),
          _drawerItem(Icons.account_balance_wallet, 'Admin Wallet',
                  () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AdminWalletScreen()))),
          _drawerItem(Icons.receipt_long, 'VAT Management',
                  () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const VATManagementScreen()))),
          _drawerItem(Icons.monetization_on, 'Commission Management',
                  () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const CommissionManagementScreen()))),
          const Divider(),
          _drawerItem(Icons.logout, 'Logout', () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                  (route) => false,
            );
          }, color: Colors.red),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap,
      {Color color = Colors.black87}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      onTap: onTap,
    );
  }
}
