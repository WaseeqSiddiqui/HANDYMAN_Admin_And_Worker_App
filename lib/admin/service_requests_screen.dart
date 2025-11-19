import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '/providers/app_state_provider.dart';
import '/services/worker_auth_service.dart';
import '/services/invoice_service.dart';
import '/models/worker_data_model.dart';
import '/models/service_request_model.dart';
import '../../worker/service_detail_screen.dart';

class ServiceRequestsScreen extends StatefulWidget {
  const ServiceRequestsScreen({super.key});

  @override
  State<ServiceRequestsScreen> createState() => _AdminServiceRequestsScreenState();
}

class _AdminServiceRequestsScreenState extends State<ServiceRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isDownloadingInvoice = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // ✅ 4 tabs now
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        // ✅ Get ServiceRequest lists from provider
        final requestedServices = appState.adminRequestedServices;
        final inProgressServices = appState.adminInProgressServices; // ✅ NEW
        final postponedServices = appState.adminPostponedServices;
        final completedServices = appState.adminCompletedServices;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            title: const Text('Service Requests'),
            backgroundColor: const Color(0xFF6B5B9A),
            foregroundColor: Colors.white,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              isScrollable: true, // ✅ Scrollable for 4 tabs
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Requested'),
                      const SizedBox(width: 4),
                      _buildTabCount(requestedServices.length, Colors.blue),
                    ],
                  ),
                ),
                // ✅ NEW TAB
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('In Progress'),
                      const SizedBox(width: 4),
                      _buildTabCount(inProgressServices.length, Colors.amber),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Postponed'),
                      const SizedBox(width: 4),
                      _buildTabCount(postponedServices.length, Colors.orange),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Completed'),
                      const SizedBox(width: 4),
                      _buildTabCount(completedServices.length, Colors.green),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildRequestedServicesTab(requestedServices),
              _buildInProgressServicesTab(inProgressServices), // ✅ NEW
              _buildPostponedServicesTab(postponedServices),
              _buildCompletedServicesTab(completedServices),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabCount(int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ================= Requested Tab (existing) =================
  Widget _buildRequestedServicesTab(List<ServiceRequest> services) {
    if (services.isEmpty) {
      return _buildEmptyState('No requested services', Icons.assignment_outlined);
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: services.length,
        itemBuilder: (context, index) {
          return _buildRequestedServiceCard(services[index]);
        },
      ),
    );
  }

  Widget _buildRequestedServiceCard(ServiceRequest service) {
    // ✅ Use model properties
    final isAssigned = service.workerId != null && service.workerId!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildIdBadge(service.id, Colors.blue),
                if (isAssigned)
                  _buildStatusBadge('Assigned to ${service.workerName}', Colors.green, Icons.check_circle),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              service.serviceName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.person, service.customerName),
            _buildInfoRow(Icons.location_on, service.address),
            _buildInfoRow(Icons.calendar_today, _formatDateTime(service.requestedDate)),
            const SizedBox(height: 12),
            _buildFinancialRow('Amount', service.totalPrice), // ✅ Using model property
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewServiceDetails(service),
                    icon: const Icon(Icons.info_outline, size: 18),
                    label: const Text('Details'),
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
                    onPressed: isAssigned ? null : () => _assignWorker(service),
                    icon: Icon(
                      isAssigned ? Icons.check_circle : Icons.person_add,
                      size: 18,
                    ),
                    label: Text(isAssigned ? 'Assigned' : 'Assign'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAssigned ? Colors.grey : const Color(0xFF6B5B9A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
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

  // ================= NEW: In Progress Tab =================
  Widget _buildInProgressServicesTab(List<ServiceRequest> services) {
    if (services.isEmpty) {
      return _buildEmptyState('No services in progress', Icons.pending_actions);
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: services.length,
        itemBuilder: (context, index) {
          return _buildInProgressServiceCard(services[index]);
        },
      ),
    );
  }

  Widget _buildInProgressServiceCard(ServiceRequest service) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildIdBadge(service.id, Colors.amber),
                _buildStatusBadge('IN PROGRESS', Colors.amber, Icons.pending_actions),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              service.serviceName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.person, service.customerName),
            _buildInfoRow(Icons.location_on, service.address),
            _buildInfoRow(Icons.engineering, service.workerName ?? 'N/A'),
            _buildInfoRow(Icons.calendar_today, _formatDateTime(service.requestedDate)),
            const SizedBox(height: 12),
            // ✅ Use model properties for financial breakdown
            _buildFinancialRow('Base Price', service.basePrice),
            if (service.extraItems.isNotEmpty)
              _buildFinancialRow('Extra Items', service.totalExtraPrice),
            const Divider(),
            _buildFinancialRow('Total', service.totalPrice, isBold: true),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Worker needs SAR ${service.totalDeduction.toStringAsFixed(2)} credit to complete',
                      style: const TextStyle(fontSize: 12, color: Colors.orange),
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
                    icon: const Icon(Icons.info_outline, size: 18),
                    label: const Text('View Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6B5B9A),
                      side: const BorderSide(color: Color(0xFF6B5B9A)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
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

  // ================= Postponed Tab (existing) =================
  Widget _buildPostponedServicesTab(List<ServiceRequest> services) {
    if (services.isEmpty) {
      return _buildEmptyState('No postponed services', Icons.event_busy);
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: services.length,
        itemBuilder: (context, index) {
          return _buildPostponedServiceCard(services[index]);
        },
      ),
    );
  }

  Widget _buildPostponedServiceCard(ServiceRequest service) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildIdBadge(service.id, Colors.orange),
                _buildStatusBadge('POSTPONED', Colors.orange, Icons.event_busy),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              service.serviceName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.person, service.customerName),
            _buildInfoRow(Icons.location_on, service.address),
            _buildInfoRow(Icons.engineering, service.workerName ?? 'N/A'),
            if (service.postponeReason != null)
              _buildInfoRow(Icons.info_outline, 'Reason: ${service.postponeReason}'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewServiceDetails(service),
                    icon: const Icon(Icons.info_outline, size: 18),
                    label: const Text('Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6B5B9A),
                      side: const BorderSide(color: Color(0xFF6B5B9A)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // ✅ NEW: Reschedule button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _rescheduleService(service),
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: const Text('Reschedule'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
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

  void _rescheduleService(ServiceRequest service) {
    final authService = WorkerAuthService();
    final allWorkers = authService.getActiveWorkers();

    // ✅ Filter out the current assigned worker
    final availableWorkers = allWorkers
        .where((w) => w.id != service.workerId)
        .toList();

    if (availableWorkers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No other workers available for reassignment'),
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
          title: const Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.blue),
              SizedBox(width: 8),
              Text('Reschedule Service'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Service: ${service.serviceName}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Customer: ${service.customerName}'),
                      Text('Previous Worker: ${service.workerName}'),
                      if (service.postponeReason != null)
                        Text('Reason: ${service.postponeReason}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Select new worker
                const Text('Select New Worker:',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<WorkerData>(
                      isExpanded: true,
                      hint: const Text('Choose worker'),
                      value: selectedWorker,
                      items: availableWorkers.map((worker) {
                        return DropdownMenuItem<WorkerData>(
                          value: worker,
                          child: Text(worker.name),
                        );
                      }).toList(),
                      onChanged: (worker) => setState(() => selectedWorker = worker),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Select new date
                const Text('Select New Date:',
                    style: TextStyle(fontWeight: FontWeight.w600)),
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
                        Text(_formatDateTime(selectedDate)),
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
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedWorker == null
                  ? null
                  : () {
                final appState = Provider.of<AppStateProvider>(context, listen: false);

                // Reschedule service
                appState.reschedulePostponedService(
                  serviceId: service.id,
                  newWorkerId: selectedWorker!.id,
                  newWorkerName: selectedWorker!.name,
                  newScheduledDate: selectedDate,
                );

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '✅ Service rescheduled to ${selectedWorker!.name} on ${_formatDateTime(selectedDate)}'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text('Reschedule'),
            ),
          ],
        ),
      ),
    );
  }


  // ================= Completed Tab (existing) =================
  Widget _buildCompletedServicesTab(List<ServiceRequest> services) {
    if (services.isEmpty) {
      return _buildEmptyState('No completed services yet', Icons.check_circle_outline);
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: services.length,
        itemBuilder: (context, index) {
          return _buildCompletedServiceCard(services[index]);
        },
      ),
    );
  }

  Widget _buildCompletedServiceCard(ServiceRequest service) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildIdBadge(service.id, Colors.green),
                _buildStatusBadge('COMPLETED', Colors.green, Icons.check_circle),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              service.serviceName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.person, service.customerName),
            _buildInfoRow(Icons.engineering, service.workerName ?? 'N/A'),
            const SizedBox(height: 12),
            // ✅ Use model properties
            _buildFinancialRow('Base Price', service.basePrice),
            if (service.extraItems.isNotEmpty)
              _buildFinancialRow('Extra Items', service.totalExtraPrice),
            _buildFinancialRow('VAT', service.totalVAT),
            _buildFinancialRow('Commission', service.totalCommission),
            const Divider(),
            _buildFinancialRow('Total', service.totalPrice, isBold: true),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewServiceDetails(service),
                    icon: const Icon(Icons.info_outline, size: 18),
                    label: const Text('Details'),
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
                    onPressed: () => _downloadInvoice(service),
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Invoice'),
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
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
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
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: isBold ? 14 : 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text('SAR ${amount.toStringAsFixed(2)}',
              style: TextStyle(
                  fontSize: isBold ? 14 : 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: isBold ? Colors.green : null)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('Services will appear here automatically', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ],
      ),
    );
  }

  // ================= Worker Assignment =================
  void _assignWorker(ServiceRequest service) {
    final authService = WorkerAuthService();
    final workers = authService.getActiveWorkers();

    if (workers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No active workers available'),
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
          title: const Row(
            children: [
              Icon(Icons.person_add, color: Color(0xFF6B5B9A)),
              SizedBox(width: 8),
              Text('Assign Worker'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Service: ${service.serviceName}'),
              Text('Customer: ${service.customerName}'),
              Text('Date: ${_formatDateTime(service.requestedDate)}'),
              const SizedBox(height: 16),
              const Text('Select Worker:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<WorkerData>(
                    isExpanded: true,
                    hint: const Text('Choose worker'),
                    value: selectedWorker,
                    items: workers.map((worker) {
                      return DropdownMenuItem<WorkerData>(
                        value: worker,
                        child: Text(worker.name),
                      );
                    }).toList(),
                    onChanged: (worker) => setState(() => selectedWorker = worker),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: selectedWorker == null
                  ? null
                  : () {
                final appState = Provider.of<AppStateProvider>(context, listen: false);
                appState.assignServiceToWorker(service.id, selectedWorker!.id, selectedWorker!.name);
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ Service assigned to ${selectedWorker!.name}'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
              child: const Text('Assign'),
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


  void _downloadInvoice(ServiceRequest service) async {
    if (_isDownloadingInvoice) return;
    setState(() => _isDownloadingInvoice = true);
    try {
      final invoiceService = InvoiceService();
      final invoice = invoiceService.getInvoiceByServiceId(service.id);
      if (invoice != null) await invoiceService.downloadInvoicePDF(invoice);
    } finally {
      setState(() => _isDownloadingInvoice = false);
    }
  }

  Future<void> _refreshData() async => await Future.delayed(const Duration(seconds: 1));
}