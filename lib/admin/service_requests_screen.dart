import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/utils/admin_translations.dart';
import '/widgets/bilingual_text.dart';
import 'package:intl/intl.dart' as intl;
import '/providers/app_state_provider.dart';
import '/services/worker_auth_service.dart';
import '/services/invoice_service.dart';
import '/models/worker_data_model.dart';
import '/models/service_request_model.dart';
import '../../worker/service_detail_screen.dart';

class ServiceRequestsScreen extends StatefulWidget {
  const ServiceRequestsScreen({super.key});

  @override
  State<ServiceRequestsScreen> createState() =>
      _AdminServiceRequestsScreenState();
}

class _AdminServiceRequestsScreenState extends State<ServiceRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isDownloadingInvoice = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dateTime, String time) {
    final date = intl.DateFormat('MMM dd, yyyy').format(dateTime);
    if (time.isNotEmpty) return '$date • $time';
    return intl.DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        final requestedServices = appState.adminRequestedServices;
        final inProgressServices = appState.adminInProgressServices;
        final postponedServices = appState.adminPostponedServices;
        final completedServices = appState.adminCompletedServices;

        return Scaffold(
          backgroundColor: Colors.white, // White background
          appBar: AppBar(
            title: BilingualText(
              english: AdminTranslations.split(
                AdminTranslations.serviceRequests,
              )[0],
              arabic: AdminTranslations.split(
                AdminTranslations.serviceRequests,
              )[1],
              englishStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              arabicStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: const Color(0xFF3B82F6),
            foregroundColor: Colors.white,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              isScrollable: true,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BilingualText(
                        english: AdminTranslations.split(
                          AdminTranslations.requested,
                        )[0],
                        arabic: AdminTranslations.split(
                          AdminTranslations.requested,
                        )[1],
                        englishStyle: const TextStyle(fontSize: 12),
                        arabicStyle: const TextStyle(fontSize: 10),
                      ),
                      const SizedBox(width: 8),
                      _buildTabCount(requestedServices.length, Colors.blue),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BilingualText(
                        english: AdminTranslations.split(
                          AdminTranslations.inProgress,
                        )[0],
                        arabic: AdminTranslations.split(
                          AdminTranslations.inProgress,
                        )[1],
                        englishStyle: const TextStyle(fontSize: 12),
                        arabicStyle: const TextStyle(fontSize: 10),
                      ),
                      const SizedBox(width: 8),
                      _buildTabCount(inProgressServices.length, Colors.amber),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BilingualText(
                        english: AdminTranslations.split(
                          AdminTranslations.postponed,
                        )[0],
                        arabic: AdminTranslations.split(
                          AdminTranslations.postponed,
                        )[1],
                        englishStyle: const TextStyle(fontSize: 12),
                        arabicStyle: const TextStyle(fontSize: 10),
                      ),
                      const SizedBox(width: 8),
                      _buildTabCount(postponedServices.length, Colors.orange),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BilingualText(
                        english: AdminTranslations.split(
                          AdminTranslations.completed,
                        )[0],
                        arabic: AdminTranslations.split(
                          AdminTranslations.completed,
                        )[1],
                        englishStyle: const TextStyle(fontSize: 12),
                        arabicStyle: const TextStyle(fontSize: 10),
                      ),
                      const SizedBox(width: 8),
                      _buildTabCount(completedServices.length, Colors.green),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: Container(
            color: Colors.white, // White background for the body
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRequestedServicesTab(requestedServices),
                _buildInProgressServicesTab(inProgressServices),
                _buildPostponedServicesTab(postponedServices),
                _buildCompletedServicesTab(completedServices),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabCount(int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // ================= Requested Tab =================
  Widget _buildRequestedServicesTab(List<ServiceRequest> services) {
    if (services.isEmpty) {
      return _buildEmptyState(
        AdminTranslations.noRequestedServices,
        Icons.assignment_outlined,
      );
    }

    // Sort: Unassigned first, then Assigned
    // Secondary Sort: Newest date first
    final sortedServices = List<ServiceRequest>.from(services)
      ..sort((a, b) {
        final aAssigned = a.workerId != null && a.workerId!.isNotEmpty;
        final bAssigned = b.workerId != null && b.workerId!.isNotEmpty;

        if (aAssigned != bAssigned) {
          return aAssigned
              ? 1
              : -1; // Unassigned (false) comes before Assigned (true)
        }
        // If same status, sort by date descending (newest first)
        return b.requestedDate.compareTo(a.requestedDate);
      });

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Container(
        color: Colors.white, // White background for the list
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sortedServices.length,
          itemBuilder: (context, index) {
            return _buildRequestedServiceCard(sortedServices[index]);
          },
        ),
      ),
    );
  }

  Widget _buildRequestedServiceCard(ServiceRequest service) {
    final isAssigned = service.workerId != null && service.workerId!.isNotEmpty;
    final isArabicCustomer = service.customerPrefersArabic;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white, // White card
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row with ID and Language
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildIdBadge(service.id, Colors.blue),
                // Language badge - Bilingual
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isArabicCustomer
                        ? Colors.blue.shade50
                        : Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isArabicCustomer ? 'عربي • Arabic' : 'English • إنجليزي',
                    style: TextStyle(
                      fontSize: 10,
                      color: isArabicCustomer ? Colors.blue : Colors.purple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Service name - Bilingual with white text
            Builder(
              builder: (context) {
                final englishName = AdminTranslations.getEnglish(
                  service.serviceName,
                );
                final arabicName = AdminTranslations.getArabic(
                  service.serviceName,
                );
                final isIdentical = englishName == arabicName;

                return BilingualText(
                  english: englishName,
                  arabic: isIdentical ? '' : arabicName,
                  englishStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  arabicStyle: isIdentical
                      ? const TextStyle(fontSize: 0) // Hide if identical
                      : const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                );
              },
            ),

            const SizedBox(height: 12),

            // Customer name - in original entered language with white text
            _buildInfoRow(
              Icons.person,
              service.customerName,
              isArabic: isArabicCustomer,
            ),

            // Address - in original entered language with white text
            _buildInfoRow(
              Icons.location_on,
              service.address,
              isArabic: isArabicCustomer,
            ),

            // Date time - Bilingual format with white text
            _buildInfoRow(
              Icons.calendar_today,
              _formatDateTime(service.requestedDate, service.requestedTime),
              isArabic: false,
            ),

            // Customer notes - in original entered language (if available) with white text
            if (service.customerNotes != null &&
                service.customerNotes!.isNotEmpty)
              _buildInfoRow(
                Icons.note,
                service.customerNotes!,
                isArabic: isArabicCustomer,
              ),

            const SizedBox(height: 16),

            // Assigned Worker Section - Show only if assigned
            if (isAssigned && service.workerName != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.green[100],
                          backgroundImage:
                              service.workerId != null &&
                                  WorkerAuthService()
                                          .getWorkerById(service.workerId!)
                                          ?.profilePhotoUrl !=
                                      null
                              ? NetworkImage(
                                  WorkerAuthService()
                                      .getWorkerById(service.workerId!)!
                                      .profilePhotoUrl!,
                                )
                              : null,
                          child:
                              service.workerId == null ||
                                  WorkerAuthService()
                                          .getWorkerById(service.workerId!)
                                          ?.profilePhotoUrl ==
                                      null
                              ? Icon(
                                  Icons.person,
                                  size: 12,
                                  color: Colors.green[700],
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Assigned To • مُعين إلى',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.workerName!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (service.workerNameArabic != null &&
                        service.workerNameArabic!.isNotEmpty)
                      Text(
                        service.workerNameArabic!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        textDirection: TextDirection.rtl,
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Amount - Bilingual with white text and proper layout
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: BilingualText(
                      english: AdminTranslations.split(
                        AdminTranslations.amount,
                      )[0],
                      arabic: AdminTranslations.split(
                        AdminTranslations.amount,
                      )[1],
                      englishStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      arabicStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Text(
                    'SAR ${service.totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Buttons - Bilingual with better spacing
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewServiceDetails(service),
                    icon: const Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Color(0xFF3B82F6),
                    ),
                    label: BilingualText(
                      english: AdminTranslations.split(
                        AdminTranslations.detailsBtn,
                      )[0],
                      arabic: AdminTranslations.split(
                        AdminTranslations.detailsBtn,
                      )[1],
                      englishStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF3B82F6),
                      side: const BorderSide(color: Color(0xFF3B82F6)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isAssigned ? null : () => _assignWorker(service),
                    icon: Icon(
                      isAssigned ? Icons.check_circle : Icons.person_add,
                      size: 18,
                      color: isAssigned ? Colors.grey : Colors.white,
                    ),
                    label: BilingualText(
                      english: isAssigned
                          ? AdminTranslations.split(
                              AdminTranslations.assignedBtn,
                            )[0]
                          : AdminTranslations.split(
                              AdminTranslations.assignBtn,
                            )[0],
                      arabic: isAssigned
                          ? AdminTranslations.split(
                              AdminTranslations.assignedBtn,
                            )[1]
                          : AdminTranslations.split(
                              AdminTranslations.assignBtn,
                            )[1],
                      englishStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isAssigned ? Colors.grey : Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAssigned
                          ? Colors.grey[600]
                          : const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================= In Progress Tab =================
  Widget _buildInProgressServicesTab(List<ServiceRequest> services) {
    if (services.isEmpty) {
      return _buildEmptyState(
        AdminTranslations.noInProgressServices,
        Icons.pending_actions,
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Container(
        color: Colors.white, // White background for the list
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: services.length,
          itemBuilder: (context, index) {
            return _buildInProgressServiceCard(services[index]);
          },
        ),
      ),
    );
  }

  Widget _buildInProgressServiceCard(ServiceRequest service) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white, // White card
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildIdBadge(service.id, Colors.amber),
                _buildStatusBadge(
                  AdminTranslations.inProgressStatus,
                  Colors.amber,
                  Icons.pending_actions,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Assigned Worker Section
            if (service.workerName != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.amber[100],
                          backgroundImage:
                              service.workerId != null &&
                                  WorkerAuthService()
                                          .getWorkerById(service.workerId!)
                                          ?.profilePhotoUrl !=
                                      null
                              ? NetworkImage(
                                  WorkerAuthService()
                                      .getWorkerById(service.workerId!)!
                                      .profilePhotoUrl!,
                                )
                              : null,
                          child:
                              service.workerId == null ||
                                  WorkerAuthService()
                                          .getWorkerById(service.workerId!)
                                          ?.profilePhotoUrl ==
                                      null
                              ? Icon(
                                  Icons.person,
                                  size: 12,
                                  color: Colors.amber[700],
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Assigned To • مُعين إلى',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.workerName!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (service.workerNameArabic != null &&
                        service.workerNameArabic!.isNotEmpty)
                      Text(
                        service.workerNameArabic!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        textDirection: TextDirection.rtl,
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            Builder(
              builder: (context) {
                final englishName = AdminTranslations.split(
                  service.serviceName,
                )[0];
                final arabicName = AdminTranslations.split(
                  service.serviceName,
                )[1];
                final isIdentical = englishName == arabicName;

                return BilingualText(
                  english: englishName,
                  arabic: isIdentical ? '' : arabicName,
                  englishStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  arabicStyle: isIdentical
                      ? const TextStyle(fontSize: 0)
                      : const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                );
              },
            ),

            const SizedBox(height: 12),

            _buildInfoRow(Icons.person, service.customerName, isArabic: false),
            _buildInfoRow(
              Icons.location_on,
              service.address,
              isArabic: service.customerPrefersArabic,
            ),
            _buildInfoRow(
              Icons.calendar_today,
              _formatDateTime(service.requestedDate, service.requestedTime),
              isArabic: false,
            ),

            const SizedBox(height: 16),

            // Financial Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildFinancialRow(
                    '${AdminTranslations.split(AdminTranslations.basePriceLabel)[0]} • ${AdminTranslations.split(AdminTranslations.basePriceLabel)[1]}',
                    service.basePrice,
                  ),
                  if (service.extraItems.isNotEmpty) ...[
                    _buildFinancialRow(
                      '${AdminTranslations.split(AdminTranslations.extraItemsLabel)[0]} • ${AdminTranslations.split(AdminTranslations.extraItemsLabel)[1]}',
                      service.totalExtraPrice,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: service.extraItems.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '• ${item.name}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  'SAR ${item.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                  const Divider(color: Colors.grey),
                  _buildFinancialRow(
                    '${AdminTranslations.split(AdminTranslations.totalLabel)[0]} • ${AdminTranslations.split(AdminTranslations.totalLabel)[1]}',
                    service.totalPrice,
                    isBold: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.orange,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${AdminTranslations.split(AdminTranslations.workerNeedsCredit)[0]} ${service.totalDeduction.toStringAsFixed(2)} ${AdminTranslations.split(AdminTranslations.creditToComplete)[0]}',
                      style: TextStyle(fontSize: 12, color: Colors.orange[800]),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewServiceDetails(service),
                    icon: const Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Color(0xFF3B82F6),
                    ),
                    label: BilingualText(
                      english: AdminTranslations.split(
                        AdminTranslations.viewDetailsBtn,
                      )[0],
                      arabic: AdminTranslations.split(
                        AdminTranslations.viewDetailsBtn,
                      )[1],
                      englishStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF3B82F6),
                      side: const BorderSide(color: Color(0xFF3B82F6)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================= Postponed Tab =================
  Widget _buildPostponedServicesTab(List<ServiceRequest> services) {
    if (services.isEmpty) {
      return _buildEmptyState(
        AdminTranslations.noPostponedServices,
        Icons.event_busy,
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Container(
        color: Colors.white, // White background for the list
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: services.length,
          itemBuilder: (context, index) {
            return _buildPostponedServiceCard(services[index]);
          },
        ),
      ),
    );
  }

  Widget _buildPostponedServiceCard(ServiceRequest service) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white, // White card
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildIdBadge(service.id, Colors.orange),
                _buildStatusBadge(
                  AdminTranslations.postponedStatus,
                  Colors.orange,
                  Icons.event_busy,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Assigned Worker Section
            if (service.workerName != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.orange[100],
                          backgroundImage:
                              service.workerId != null &&
                                  WorkerAuthService()
                                          .getWorkerById(service.workerId!)
                                          ?.profilePhotoUrl !=
                                      null
                              ? NetworkImage(
                                  WorkerAuthService()
                                      .getWorkerById(service.workerId!)!
                                      .profilePhotoUrl!,
                                )
                              : null,
                          child:
                              service.workerId == null ||
                                  WorkerAuthService()
                                          .getWorkerById(service.workerId!)
                                          ?.profilePhotoUrl ==
                                      null
                              ? Icon(
                                  Icons.person,
                                  size: 12,
                                  color: Colors.orange[700],
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Assigned To • مُعين إلى',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.workerName!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (service.workerNameArabic != null &&
                        service.workerNameArabic!.isNotEmpty)
                      Text(
                        service.workerNameArabic!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        textDirection: TextDirection.rtl,
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            BilingualText(
              english: AdminTranslations.split(service.serviceName)[0],
              arabic:
                  AdminTranslations.split(service.serviceName)[0] ==
                      AdminTranslations.split(service.serviceName)[1]
                  ? ''
                  : AdminTranslations.split(service.serviceName)[1],
              englishStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              arabicStyle: TextStyle(
                fontSize:
                    AdminTranslations.split(service.serviceName)[0] ==
                        AdminTranslations.split(service.serviceName)[1]
                    ? 0
                    : 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 12),

            _buildInfoRow(Icons.person, service.customerName, isArabic: false),
            _buildInfoRow(
              Icons.location_on,
              service.address,
              isArabic: service.customerPrefersArabic,
            ),
            if (service.postponeReason != null)
              _buildInfoRow(
                Icons.info_outline,
                '${AdminTranslations.split(AdminTranslations.reasonLabel)[0]} ${service.postponeReason}',
                isArabic: false,
              ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewServiceDetails(service),
                    icon: const Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Color(0xFF3B82F6),
                    ),
                    label: BilingualText(
                      english: AdminTranslations.split(
                        AdminTranslations.detailsBtn,
                      )[0],
                      arabic: AdminTranslations.split(
                        AdminTranslations.detailsBtn,
                      )[1],
                      englishStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF3B82F6),
                      side: const BorderSide(color: Color(0xFF3B82F6)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _rescheduleService(service),
                    icon: const Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: BilingualText(
                      english: AdminTranslations.split(
                        AdminTranslations.reschedule,
                      )[0],
                      arabic: AdminTranslations.split(
                        AdminTranslations.reschedule,
                      )[1],
                      englishStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================= Completed Tab =================
  Widget _buildCompletedServicesTab(List<ServiceRequest> services) {
    if (services.isEmpty) {
      return _buildEmptyState(
        AdminTranslations.noCompletedServices,
        Icons.check_circle_outline,
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Container(
        color: Colors.white, // White background for the list
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: services.length,
          itemBuilder: (context, index) {
            return _buildCompletedServiceCard(services[index]);
          },
        ),
      ),
    );
  }

  Widget _buildCompletedServiceCard(ServiceRequest service) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white, // White card
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildIdBadge(service.id, Colors.green),
                _buildStatusBadge(
                  AdminTranslations.completedStatus,
                  Colors.green,
                  Icons.check_circle,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Assigned Worker Section
            if (service.workerName != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.green[100],
                          backgroundImage:
                              service.workerId != null &&
                                  WorkerAuthService()
                                          .getWorkerById(service.workerId!)
                                          ?.profilePhotoUrl !=
                                      null
                              ? NetworkImage(
                                  WorkerAuthService()
                                      .getWorkerById(service.workerId!)!
                                      .profilePhotoUrl!,
                                )
                              : null,
                          child:
                              service.workerId == null ||
                                  WorkerAuthService()
                                          .getWorkerById(service.workerId!)
                                          ?.profilePhotoUrl ==
                                      null
                              ? Icon(
                                  Icons.person,
                                  size: 12,
                                  color: Colors.green[700],
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Assigned To • مُعين إلى',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.workerName!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (service.workerNameArabic != null &&
                        service.workerNameArabic!.isNotEmpty)
                      Text(
                        service.workerNameArabic!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        textDirection: TextDirection.rtl,
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            BilingualText(
              english: AdminTranslations.split(service.serviceName)[0],
              arabic:
                  AdminTranslations.split(service.serviceName)[0] ==
                      AdminTranslations.split(service.serviceName)[1]
                  ? ''
                  : AdminTranslations.split(service.serviceName)[1],
              englishStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              arabicStyle: TextStyle(
                fontSize:
                    AdminTranslations.split(service.serviceName)[0] ==
                        AdminTranslations.split(service.serviceName)[1]
                    ? 0
                    : 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 12),

            _buildInfoRow(Icons.person, service.customerName, isArabic: false),
            _buildInfoRow(
              Icons.engineering,
              service.workerName ??
                  AdminTranslations.split(AdminTranslations.naPlaceholder)[0],
              isArabic: false,
            ),

            const SizedBox(height: 16),

            // Financial Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildFinancialRow(
                    '${AdminTranslations.split(AdminTranslations.basePriceLabel)[0]} • ${AdminTranslations.split(AdminTranslations.basePriceLabel)[1]}',
                    service.basePrice,
                  ),
                  if (service.extraItems.isNotEmpty) ...[
                    _buildFinancialRow(
                      '${AdminTranslations.split(AdminTranslations.extraItemsLabel)[0]} • ${AdminTranslations.split(AdminTranslations.extraItemsLabel)[1]}',
                      service.totalExtraPrice,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: service.extraItems.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '• ${item.name}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  'SAR ${item.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                  _buildFinancialRow(
                    '${AdminTranslations.split(AdminTranslations.vatLabel)[0]} • ${AdminTranslations.split(AdminTranslations.vatLabel)[1]}',
                    service.totalVAT,
                  ),
                  _buildFinancialRow(
                    '${AdminTranslations.split(AdminTranslations.commissionLabel)[0]} • ${AdminTranslations.split(AdminTranslations.commissionLabel)[1]}',
                    service.totalCommission,
                  ),
                  const Divider(color: Colors.grey),
                  _buildFinancialRow(
                    '${AdminTranslations.split(AdminTranslations.totalLabel)[0]} • ${AdminTranslations.split(AdminTranslations.totalLabel)[1]}',
                    service.totalPrice,
                    isBold: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewServiceDetails(service),
                    icon: const Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Color(0xFF3B82F6),
                    ),
                    label: BilingualText(
                      english: AdminTranslations.split(
                        AdminTranslations.detailsBtn,
                      )[0],
                      arabic: AdminTranslations.split(
                        AdminTranslations.detailsBtn,
                      )[1],
                      englishStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF3B82F6),
                      side: const BorderSide(color: Color(0xFF3B82F6)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _downloadInvoice(service),
                    icon: const Icon(
                      Icons.download,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: BilingualText(
                      english: AdminTranslations.split(
                        AdminTranslations.invoiceBtn,
                      )[0],
                      arabic: AdminTranslations.split(
                        AdminTranslations.invoiceBtn,
                      )[1],
                      englishStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================= Helper Widgets =================
  Widget _buildIdBadge(String id, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        id,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: BilingualText(
              english: AdminTranslations.split(text)[0],
              arabic: AdminTranslations.split(text)[1],
              englishStyle: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {bool isArabic = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialRow(
    String label,
    double amount, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isBold ? 15 : 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            'SAR ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isBold ? 15 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? Colors.black : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String messageKey, IconData icon) {
    return Container(
      color: Colors.white, // White background for empty state
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            BilingualText(
              english: AdminTranslations.split(messageKey)[0],
              arabic: AdminTranslations.split(messageKey)[1],
              englishStyle: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            BilingualText(
              english: AdminTranslations.split(
                AdminTranslations.servicesAutoAppear,
              )[0],
              arabic: AdminTranslations.split(
                AdminTranslations.servicesAutoAppear,
              )[1],
              englishStyle: TextStyle(fontSize: 13, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ================= Worker Assignment =================
  void _assignWorker(ServiceRequest service) {
    final authService = WorkerAuthService();
    final workers = authService.getActiveWorkers();

    if (workers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AdminTranslations.split(AdminTranslations.noActiveWorkers)[0],
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    WorkerData? selectedWorker;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.person_add, color: Color(0xFF005DFF)),
              const SizedBox(width: 8),
              BilingualText(
                english: AdminTranslations.split(
                  AdminTranslations.assignWorker,
                )[0],
                arabic: AdminTranslations.split(
                  AdminTranslations.assignWorker,
                )[1],
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AdminTranslations.split(AdminTranslations.serviceLabel)[0]}: ${AdminTranslations.split(service.serviceName)[0]}',
              ),
              Text(
                '${AdminTranslations.split(AdminTranslations.customerLabel)[0]}: ${service.customerName}',
              ),
              Text(
                '${AdminTranslations.split(AdminTranslations.date)[0]}: ${_formatDateTime(service.requestedDate, service.requestedTime)}',
              ),
              const SizedBox(height: 16),
              Text(
                AdminTranslations.split(AdminTranslations.selectWorker)[0],
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<WorkerData>(
                    isExpanded: true,
                    hint: Text(
                      AdminTranslations.split(
                        AdminTranslations.chooseWorker,
                      )[0],
                    ),
                    value: selectedWorker,
                    items: workers.map((worker) {
                      return DropdownMenuItem<WorkerData>(
                        value: worker,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              worker.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              worker.nameArabic,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (worker) =>
                        setState(() => selectedWorker = worker),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                AdminTranslations.split(AdminTranslations.cancelBtn)[0],
              ),
            ),
            ElevatedButton(
              onPressed: selectedWorker == null
                  ? null
                  : () {
                      final appState = Provider.of<AppStateProvider>(
                        context,
                        listen: false,
                      );
                      appState.assignServiceToWorker(
                        service.id,
                        selectedWorker!.id,
                        selectedWorker!.name,
                      );
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${AdminTranslations.split(AdminTranslations.serviceAssignedSuccess)[0]} ${selectedWorker!.name}',
                              ),
                              Text(
                                selectedWorker!.nameArabic,
                                style: const TextStyle(fontSize: 12),
                                textDirection: TextDirection.rtl,
                              ),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    },
              child: Text(
                AdminTranslations.split(AdminTranslations.assignBtn)[0],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _viewServiceDetails(ServiceRequest service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceDetailScreen(service: service),
      ),
    );
  }

  void _rescheduleService(ServiceRequest service) {
    final authService = WorkerAuthService();
    final allWorkers = authService.getActiveWorkers();

    final availableWorkers = allWorkers
        .where((w) => w.id != (service.workerId ?? ''))
        .toList();

    if (availableWorkers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AdminTranslations.split(AdminTranslations.noOtherWorkers)[0],
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    WorkerData? selectedWorker;
    DateTime selectedDate = service.requestedDate;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.blue),
              const SizedBox(width: 8),
              BilingualText(
                english: AdminTranslations.split(
                  AdminTranslations.rescheduleService,
                )[0],
                arabic: AdminTranslations.split(
                  AdminTranslations.rescheduleService,
                )[1],
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${AdminTranslations.split(AdminTranslations.serviceLabel)[0]}: ${AdminTranslations.split(service.serviceName)[0]}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${AdminTranslations.split(AdminTranslations.customerLabel)[0]}: ${service.customerName}',
                      ),
                      if (service.workerName != null) ...[
                        Text(
                          '${AdminTranslations.split(AdminTranslations.previousWorker)[0]}: ${service.workerName}',
                        ),
                        if (service.workerNameArabic != null)
                          Text(
                            service.workerNameArabic!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                      ],
                      if (service.postponeReason != null)
                        Text(
                          '${AdminTranslations.split(AdminTranslations.reasonLabel)[0]} ${service.postponeReason}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AdminTranslations.split(AdminTranslations.selectNewWorker)[0],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<WorkerData>(
                      isExpanded: true,
                      hint: Text(
                        AdminTranslations.split(
                          AdminTranslations.chooseWorker,
                        )[0],
                      ),
                      value: selectedWorker,
                      items: availableWorkers.map((worker) {
                        return DropdownMenuItem<WorkerData>(
                          value: worker,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                worker.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                worker.nameArabic,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (worker) =>
                          setState(() => selectedWorker = worker),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AdminTranslations.split(AdminTranslations.selectNewDate)[0],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDateTime(selectedDate, service.requestedTime),
                        ),
                        const Icon(Icons.calendar_today, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                AdminTranslations.split(AdminTranslations.cancelBtn)[0],
              ),
            ),
            ElevatedButton(
              onPressed: selectedWorker == null
                  ? null
                  : () {
                      final appState = Provider.of<AppStateProvider>(
                        context,
                        listen: false,
                      );

                      appState.reschedulePostponedService(
                        serviceId: service.id,
                        newWorkerId: selectedWorker!.id,
                        newWorkerName: selectedWorker!.name,
                        newScheduledDate: selectedDate,
                      );

                      Navigator.pop(dialogContext);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${AdminTranslations.split(AdminTranslations.serviceRescheduledSuccess)[0]} ${selectedWorker!.name} ${AdminTranslations.split(AdminTranslations.onDate)[0]} ${_formatDateTime(selectedDate, service.requestedTime)}',
                              ),
                              Text(
                                selectedWorker!.nameArabic,
                                style: const TextStyle(fontSize: 12),
                                textDirection: TextDirection.rtl,
                              ),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: Text(
                AdminTranslations.split(AdminTranslations.reschedule)[0],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _downloadInvoice(ServiceRequest service) async {
    if (_isDownloadingInvoice) return;
    setState(() => _isDownloadingInvoice = true);
    try {
      final invoiceService = InvoiceService();
      final invoice = invoiceService.getInvoiceByServiceId(service.id);

      if (invoice != null) {
        await invoiceService.downloadInvoicePDF(invoice);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${AdminTranslations.split(AdminTranslations.invoiceDownloaded)[0]}',
              ), // Using English part or fallback
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invoice not found / فاتورة غير موجودة'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloadingInvoice = false);
      }
    }
  }

  Future<void> _refreshData() async =>
      await Future.delayed(const Duration(seconds: 1));
}
