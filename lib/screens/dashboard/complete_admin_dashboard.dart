import 'package:admin_x_technician_panel/screens/auth/role_selection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/services/financial_service.dart';
import '/providers/app_state_provider.dart';
import '/models/financial_transaction_model.dart';
import '/utils/admin_translations.dart';
import '/widgets/bilingual_text.dart'; // Add this import

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
    final report = _financialService.getReportSummary();
    final totalRevenue = report.totalRevenue;
    final totalCommission = report.totalCommission;
    final totalVAT = report.totalVAT;
    final currentBalance = _financialService.getCurrentBalance(); // ✅ Get current admin wallet balance

    final appState = Provider.of<AppStateProvider>(context, listen: false);
    // ✅ FIXED: Only count services with assigned workers
    final assignedServices = appState.adminAssignedServices.length;
    final inProgressServices = appState.adminInProgressServices.length;
    final postponedServices = appState.adminPostponedServices.length;
    final activeServices = assignedServices + inProgressServices + postponedServices;
    final completedServices = _financialService.getCompletedServices().length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: BilingualText( // ✅ Bilingual app bar title
          english: AdminTranslations.split(AdminTranslations.adminDashboard)[0],
          arabic: AdminTranslations.split(AdminTranslations.adminDashboard)[1],
          englishStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          arabicStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
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
            tooltip: AdminTranslations.split(AdminTranslations.refreshBtn)[0],
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
          await Future.delayed(const Duration(seconds: 1));
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFinancialOverview(currentBalance, totalRevenue, totalCommission, totalVAT),
                    const SizedBox(height: 20),
                    _buildQuickStats(activeServices, completedServices),
                    const SizedBox(height: 20),
                    _buildQuickAccessGrid(),
                    const SizedBox(height: 20),
                    _buildRecentActivity(),
                    const SizedBox(height: 20), // Extra bottom padding to prevent overflow
                  ],
                ),
              ),
            );
          },
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
                    BilingualText( // ✅ Bilingual admin panel title
                      english: AdminTranslations.split(AdminTranslations.adminPanel)[0],
                      arabic: AdminTranslations.split(AdminTranslations.adminPanel)[1],
                      englishStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      arabicStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
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
                _buildDrawerSection(AdminTranslations.financial, [
                  _buildDrawerItem(Icons.account_balance_wallet, AdminTranslations.wallet, () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminWalletScreen()));
                  }),
                  _buildDrawerItem(Icons.money, AdminTranslations.commission, () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CommissionManagementScreen()));
                  }),
                  _buildDrawerItem(Icons.receipt_long, AdminTranslations.vat, () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const VATManagementScreen()));
                  }),
                  _buildDrawerItem(Icons.analytics, AdminTranslations.reports, () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const FinancialReportsScreen()));
                  }),
                ]),
                const Divider(height: 1),
                _buildDrawerSection(AdminTranslations.operations, [
                  _buildDrawerItem(Icons.assignment, AdminTranslations.serviceRequests, () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ServiceRequestsScreen()));
                  }),
                  _buildDrawerItem(Icons.account_balance, AdminTranslations.withdrawals, () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const WithdrawalRequestsScreen()));
                  }),
                  _buildDrawerItem(Icons.build, AdminTranslations.serviceManagement, () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ServiceManagementScreen()));
                  }),
                  _buildDrawerItem(Icons.people, AdminTranslations.workers, () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const WorkerManagementScreen()));
                  }),
                  _buildDrawerItem(Icons.person, AdminTranslations.customers, () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomerManagementScreen()));
                  }),
                  _buildDrawerItem(Icons.receipt, AdminTranslations.invoices, () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const InvoiceManagementScreen()));
                  }),
                ]),
                const Divider(height: 1),
                _buildDrawerSection(AdminTranslations.support, [
                  _buildDrawerItem(Icons.rate_review, AdminTranslations.reviews, () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ReviewsScreen()));
                  }),
                  _buildDrawerItem(Icons.notifications, AdminTranslations.notifications, () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
                  }),
                ]),
              ],
            ),
          ),

          // Simple Logout button at bottom - FIXED ARABIC FONT SIZE
          const Divider(height: 1),
          SafeArea(
            top: false,
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: BilingualText( // ✅ Bilingual logout - FIXED ARABIC FONT SIZE
                english: AdminTranslations.split(AdminTranslations.logout)[0],
                arabic: AdminTranslations.split(AdminTranslations.logout)[1],
                englishStyle: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: 15, // English font size
                ),
                arabicStyle: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: 13, // Smaller Arabic font size
                ),
              ),
              onTap: _handleLogout,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerSection(String bilingualTitle, List<Widget> items) {
    final titleParts = AdminTranslations.split(bilingualTitle);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: BilingualText( // ✅ Bilingual section titles
            english: titleParts[0],
            arabic: titleParts[1],
            englishStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
            arabicStyle: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _buildDrawerItem(IconData icon, String bilingualTitle, VoidCallback onTap) {
    final titleParts = AdminTranslations.split(bilingualTitle);

    return ListTile(
      leading: Icon(icon, size: 22, color: const Color(0xFF6B5B9A)),
      title: BilingualText( // ✅ Bilingual drawer items
        english: titleParts[0],
        arabic: titleParts[1],
        englishStyle: const TextStyle(fontSize: 15),
        arabicStyle: const TextStyle(fontSize: 14),
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
            BilingualText( // ✅ Bilingual logout title - FIXED ARABIC FONT SIZE
              english: AdminTranslations.split(AdminTranslations.logout)[0],
              arabic: AdminTranslations.split(AdminTranslations.logout)[1],
              englishStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              arabicStyle: const TextStyle(
                fontSize: 16, // Smaller Arabic font size
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: BilingualText( // ✅ Bilingual logout confirmation - FIXED ARABIC FONT SIZE
          english: AdminTranslations.split(AdminTranslations.logoutConfirm)[0],
          arabic: AdminTranslations.split(AdminTranslations.logoutConfirm)[1],
          englishStyle: const TextStyle(
            fontSize: 14,
          ),
          arabicStyle: const TextStyle(
            fontSize: 13, // Smaller Arabic font size
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: BilingualText(
              english: AdminTranslations.split(AdminTranslations.cancelBtn)[0],
              arabic: AdminTranslations.split(AdminTranslations.cancelBtn)[1],
              englishStyle: const TextStyle(fontSize: 14),
              arabicStyle: const TextStyle(fontSize: 13), // Smaller Arabic font size
            ),
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
            child: BilingualText(
              english: AdminTranslations.split(AdminTranslations.logout)[0],
              arabic: AdminTranslations.split(AdminTranslations.logout)[1],
              englishStyle: const TextStyle(fontSize: 14),
              arabicStyle: const TextStyle(fontSize: 13), // Smaller Arabic font size
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialOverview(double currentBalance, double totalRevenue, double totalCommission, double totalVAT) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              const Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              BilingualText( // ✅ Bilingual financial overview title
                english: AdminTranslations.split(AdminTranslations.financialOverview)[0],
                arabic: AdminTranslations.split(AdminTranslations.financialOverview)[1],
                englishStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                arabicStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // ✅ CURRENT BALANCE - Most Prominent (matches admin wallet screen)
          Center(
            child: Column(
              children: [
                const Text(
                  'Current Balance | الرصيد الحالي',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'SAR ${currentBalance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          // ✅ Total Revenue
          _buildFinancialMetric(
            AdminTranslations.totalRevenue,
            'SAR ${totalRevenue.toStringAsFixed(2)}',
            Icons.trending_up,
            Colors.greenAccent,
          ),
          const SizedBox(height: 12),
          // ✅ Commission & VAT
          Row(
            children: [
              Expanded(
                child: _buildFinancialMetric(
                  AdminTranslations.commission,
                  'SAR ${totalCommission.toStringAsFixed(2)}',
                  Icons.money,
                  Colors.amberAccent,
                  isCompact: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFinancialMetric(
                  AdminTranslations.vat,
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

  Widget _buildFinancialMetric(String bilingualLabel, String value, IconData icon, Color iconColor,
      {bool isCompact = false}) {
    final labelParts = AdminTranslations.split(bilingualLabel);

    return Container(
      padding: EdgeInsets.all(isCompact ? 10 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: isCompact ? 18 : 24),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BilingualText( // ✅ Bilingual metric labels
                  english: labelParts[0],
                  arabic: labelParts[1],
                  englishStyle: TextStyle(
                    color: Colors.white70,
                    fontSize: isCompact ? 10 : 13,
                    height: 1.2,
                  ),
                  arabicStyle: TextStyle(
                    color: Colors.white70,
                    fontSize: isCompact ? 9 : 12,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isCompact ? 12 : 18,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
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
            AdminTranslations.activeServices,
            activeServices.toString(),
            Icons.pending_actions,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            AdminTranslations.completed,
            completedServices.toString(),
            Icons.check_circle,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String bilingualLabel, String value, IconData icon, Color color) {
    final labelParts = AdminTranslations.split(bilingualLabel);

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
          const SizedBox(height: 4),
          BilingualText( // ✅ Bilingual stat labels
            english: labelParts[0],
            arabic: labelParts[1],
            englishStyle: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.2,
            ),
            arabicStyle: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              height: 1.2,
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
        BilingualText( // ✅ Bilingual quick access title
          english: AdminTranslations.split(AdminTranslations.quickAccess)[0],
          arabic: AdminTranslations.split(AdminTranslations.quickAccess)[1],
          englishStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          arabicStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.0, // Reduced from 1.1 to prevent overflow
          children: [
            _buildQuickAccessCard(
              AdminTranslations.wallet,
              Icons.account_balance_wallet,
              Colors.blue,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminWalletScreen())),
            ),
            _buildQuickAccessCard(
              AdminTranslations.commission,
              Icons.money,
              Colors.purple,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CommissionManagementScreen())),
            ),
            _buildQuickAccessCard(
              AdminTranslations.vat,
              Icons.receipt_long,
              Colors.orange,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VATManagementScreen())),
            ),
            _buildQuickAccessCard(
              AdminTranslations.reports,
              Icons.analytics,
              Colors.green,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FinancialReportsScreen())),
            ),
            _buildQuickAccessCard(
              AdminTranslations.services,
              Icons.assignment,
              Colors.red,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ServiceRequestsScreen())),
            ),
            _buildQuickAccessCard(
              AdminTranslations.workers,
              Icons.people,
              Colors.teal,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WorkerManagementScreen())),
            ),
            _buildQuickAccessCard(
              AdminTranslations.serviceMgmt,
              Icons.build,
              Colors.deepPurple,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ServiceManagementScreen())),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard(String bilingualLabel, IconData icon, Color color, VoidCallback onTap) {
    final labelParts = AdminTranslations.split(bilingualLabel);

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
            Icon(icon, color: color, size: 28), // Reduced from 32
            const SizedBox(height: 6), // Reduced from 8
            BilingualText( // ✅ Bilingual quick access labels
              english: labelParts[0],
              arabic: labelParts[1],
              englishStyle: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 11, // Reduced from 12
                height: 1.2,
              ),
              arabicStyle: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 10, // Reduced from 11
                height: 1.2,
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
            BilingualText( // ✅ Bilingual recent services title
              english: AdminTranslations.split(AdminTranslations.recentServices)[0],
              arabic: AdminTranslations.split(AdminTranslations.recentServices)[1],
              englishStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              arabicStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FinancialReportsScreen()),
              ),
              child: BilingualText(
                english: AdminTranslations.split(AdminTranslations.viewAll)[0],
                arabic: AdminTranslations.split(AdminTranslations.viewAll)[1],
                englishStyle: const TextStyle(fontSize: 14),
                arabicStyle: const TextStyle(fontSize: 13), // Smaller Arabic font size
              ),
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
                  BilingualText( // ✅ Bilingual empty state
                    english: AdminTranslations.split(AdminTranslations.noRecentServices)[0],
                    arabic: AdminTranslations.split(AdminTranslations.noRecentServices)[1],
                    englishStyle: TextStyle(color: Colors.grey[600]),
                    arabicStyle: TextStyle(color: Colors.grey[600]),
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