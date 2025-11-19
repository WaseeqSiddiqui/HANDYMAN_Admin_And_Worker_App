// complete_admin_dashboard.dart - FIXED VERSION

import 'package:admin_x_technician_panel/screens/auth/role_selection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/services/financial_service.dart';
import '/providers/app_state_provider.dart';
import '/models/financial_transaction_model.dart';

// Import admin screens
import '/admin/admin_wallet_screen.dart';
import '/admin/commission_management_screen.dart';
import '/admin/vat_management_screen.dart';
import '/admin/financial_reports_screen.dart';
import '/admin/service_requests_screen.dart';
import '/admin/withdrawl_requests_screen.dart';
import '/admin/worker_management_screen.dart';
import '/admin/customer_management_screen.dart';
import '/admin/service_management_screen.dart';
import '/admin/invoice_management_screen.dart';
import '/admin/reviews_screen.dart';
import '/admin/notifications_screen.dart';

class AdminDashboard extends StatefulWidget {
  final String phoneNumber;

  const AdminDashboard({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<AdminDashboard> createState() => AdminDashboardState();
}

class AdminDashboardState extends State<AdminDashboard> {
  final _financialService = FinancialService();

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
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Get proper summary object from financial service
    final report = _financialService.getReportSummary();

    final totalRevenue = report.totalRevenue;
    final totalCommission = report.totalCommission;
    final totalVAT = report.totalVAT;

    // ✅ Get counts from AppStateProvider using model lists
    final appState = Provider.of<AppStateProvider>(context, listen: false);

    // ✅ FIXED: Active services = Requested + In Progress + Postponed
    // (All non-completed services visible to admin)
    final activeServices = appState.adminRequestedServices.length +
        appState.adminInProgressServices.length +
        appState.adminPostponedServices.length;

    final completedServices = _financialService.getCompletedServices().length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF6B5B9A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationsScreen()),
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
                    '5',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFinancialOverview(totalRevenue, totalCommission, totalVAT),
              const SizedBox(height: 20),
              _buildQuickStats(activeServices, completedServices),
              const SizedBox(height: 20),
              _buildQuickAccessGrid(),
              const SizedBox(height: 20),
              _buildRecentActivity(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6B5B9A), Color(0xFF4A3B7A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.admin_panel_settings, size: 32, color: Color(0xFF6B5B9A)),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Admin Panel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.phoneNumber,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Scrollable content
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerSection('Financial', [
                  _buildDrawerItem(Icons.account_balance_wallet, 'Wallet', () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminWalletScreen()));
                  }),
                  _buildDrawerItem(Icons.money, 'Commission', () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CommissionManagementScreen()));
                  }),
                  _buildDrawerItem(Icons.receipt_long, 'VAT', () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const VATManagementScreen()));
                  }),
                  _buildDrawerItem(Icons.analytics, 'Reports', () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const FinancialReportsScreen()));
                  }),
                ]),
                const Divider(height: 1),
                _buildDrawerSection('Operations', [
                  _buildDrawerItem(Icons.assignment, 'Service Requests', () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ServiceRequestsScreen()));
                  }),
                  _buildDrawerItem(Icons.account_balance, 'Withdrawals', () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const WithdrawalRequestsScreen()));
                  }),
                  _buildDrawerItem(Icons.build, 'Service Management', () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ServiceManagementScreen()));
                  }),
                  _buildDrawerItem(Icons.people, 'Workers', () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const WorkerManagementScreen()));
                  }),
                  _buildDrawerItem(Icons.person, 'Customers', () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomerManagementScreen()));
                  }),
                  _buildDrawerItem(Icons.receipt, 'Invoices', () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const InvoiceManagementScreen()));
                  }),
                ]),
                const Divider(height: 1),
                _buildDrawerSection('Support', [
                  _buildDrawerItem(Icons.rate_review, 'Reviews', () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ReviewsScreen()));
                  }),
                  _buildDrawerItem(Icons.notifications, 'Notifications', () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
                  }),
                ]),
              ],
            ),
          ),

          // Simple Logout button at bottom
          const Divider(height: 1),
          SafeArea(
            top: false,
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: _handleLogout,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, size: 22, color: const Color(0xFF6B5B9A)),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15),
      ),
      onTap: onTap,
      dense: true,
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
        content: const Text('Are you sure you want to logout from Admin Panel?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                    (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialOverview(double totalRevenue, double totalCommission, double totalVAT) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B5B9A), Color(0xFF4A3B7A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B5B9A).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance_wallet, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Text(
                'Financial Overview',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildFinancialMetric(
            'Total Revenue',
            'SAR ${totalRevenue.toStringAsFixed(2)}',
            Icons.trending_up,
            Colors.greenAccent,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFinancialMetric(
                  'Commission',
                  'SAR ${totalCommission.toStringAsFixed(2)}',
                  Icons.money,
                  Colors.amberAccent,
                  isCompact: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFinancialMetric(
                  'VAT',
                  'SAR ${totalVAT.toStringAsFixed(2)}',
                  Icons.receipt,
                  Colors.orangeAccent,
                  isCompact: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialMetric(String label, String value, IconData icon, Color iconColor,
      {bool isCompact = false}) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: isCompact ? 20 : 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isCompact ? 11 : 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isCompact ? 14 : 18,
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

  Widget _buildQuickStats(int activeServices, int completedServices) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Active Services',
            activeServices.toString(),
            Icons.pending_actions,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Completed',
            completedServices.toString(),
            Icons.check_circle,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Access',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: [
            _buildQuickAccessCard(
              'Wallet',
              Icons.account_balance_wallet,
              Colors.blue,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminWalletScreen())),
            ),
            _buildQuickAccessCard(
              'Commission',
              Icons.money,
              Colors.purple,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CommissionManagementScreen())),
            ),
            _buildQuickAccessCard(
              'VAT',
              Icons.receipt_long,
              Colors.orange,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VATManagementScreen())),
            ),
            _buildQuickAccessCard(
              'Reports',
              Icons.analytics,
              Colors.green,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FinancialReportsScreen())),
            ),
            _buildQuickAccessCard(
              'Services',
              Icons.assignment,
              Colors.red,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ServiceRequestsScreen())),
            ),
            _buildQuickAccessCard(
              'Workers',
              Icons.people,
              Colors.teal,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WorkerManagementScreen())),
            ),
            _buildQuickAccessCard(
              'Service Mgmt',
              Icons.build,
              Colors.deepPurple,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ServiceManagementScreen())),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    final recentServices = _financialService.getCompletedServices().take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Services',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FinancialReportsScreen()),
              ),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (recentServices.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.inbox, size: 48, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text(
                    'No recent services',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          )
        else
          ...recentServices.map((service) => _buildServiceCard(service)).toList(),
      ],
    );
  }

  Widget _buildServiceCard(FinancialTransaction service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.check_circle, color: Colors.green, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.serviceName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${service.workerName} • ${service.customerName}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'SAR ${service.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF6B5B9A),
                ),
              ),
              Text(
                '${service.completionDate.day}/${service.completionDate.month}/${service.completionDate.year}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}