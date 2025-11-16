import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/app_state_provider.dart';
import '/services/worker_auth_service.dart';
import '/services/invoice_service.dart';

class ServiceRequestsScreen extends StatefulWidget {
  const ServiceRequestsScreen({super.key});

  @override
  State<ServiceRequestsScreen> createState() => _AdminServiceRequestsScreenState();
}

class _AdminServiceRequestsScreenState extends State<ServiceRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isDownloadingInvoice = false; // ✅ Prevent duplicate downloads

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        final requestedServices = appState.adminRequestedServices;
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
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Requested'),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${requestedServices.length}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Postponed'),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${postponedServices.length}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Completed'),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${completedServices.length}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
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
              _buildPostponedServicesTab(postponedServices),
              _buildCompletedServicesTab(completedServices),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRequestedServicesTab(List<Map<String, dynamic>> services) {
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

  Widget _buildRequestedServiceCard(Map<String, dynamic> service) {
    // ✅ Check if already assigned
    final isAssigned = service['assignedWorkerId'] != null &&
        service['assignedWorkerId'] != '';

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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    service['id'],
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                // ✅ Show assigned status
                if (isAssigned)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, size: 14, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          'Assigned to ${service['assignedWorkerName']}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              service['service'] ?? service['serviceType'] ?? 'Service',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            _buildInfoRow(Icons.person, service['customer'] ?? 'N/A'),
            _buildInfoRow(Icons.location_on, service['address'] ?? 'N/A'),

            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Amount:', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    'SAR ${((service['price'] ?? service['baseAmount'] ?? 0.0) as num).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF6B5B9A),
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
                    // ✅ Disable if already assigned
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

  Widget _buildPostponedServicesTab(List<Map<String, dynamic>> services) {
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

  Widget _buildPostponedServiceCard(Map<String, dynamic> service) {
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    service['id'],
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.event_busy, size: 14, color: Colors.orange),
                      SizedBox(width: 4),
                      Text(
                        'POSTPONED',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              service['service'] ?? service['serviceType'] ?? 'Service',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            _buildInfoRow(Icons.person, service['customer'] ?? 'N/A'),
            _buildInfoRow(Icons.location_on, service['address'] ?? 'N/A'),
            if (service['worker'] != null)
              _buildInfoRow(Icons.engineering, 'Worker: ${service['worker']}'),

            const SizedBox(height: 12),

            if (service['postponeReason'] != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, size: 16, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          'Postponed by: ${service['postponedBy'] ?? 'Worker'}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Reason: ${service['postponeReason']}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                    onPressed: () => _showRescheduleDialog(service),
                    icon: const Icon(Icons.event, size: 18),
                    label: const Text('Reschedule'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
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

  Widget _buildCompletedServicesTab(List<Map<String, dynamic>> services) {
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

  Widget _buildCompletedServiceCard(Map<String, dynamic> service) {
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    service['id'],
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, size: 14, color: Colors.green),
                      SizedBox(width: 4),
                      Text(
                        'COMPLETED',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              service['serviceType'] ?? service['service'] ?? 'Service',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            _buildInfoRow(Icons.person, service['customer'] ?? 'N/A'),
            if (service['assignedWorker'] != null)
              _buildInfoRow(Icons.engineering, 'Worker: ${service['assignedWorker']}'),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  _buildFinancialRow('Base Amount', (service['baseAmount'] ?? 0.0) as num),
                  if ((service['extraCharges'] ?? 0.0) > 0)
                    _buildFinancialRow('Extra Charges', (service['extraCharges'] ?? 0.0) as num),
                  const Divider(height: 16),
                  _buildFinancialRow('Total Amount', (service['totalAmount'] ?? 0.0) as num, isBold: true),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'VAT: SAR ${((service['vat'] ?? 0.0) as num).toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      Text(
                        'Commission: SAR ${((service['commission'] ?? 0.0) as num).toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
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

  // ✅ FIXED: Assign worker with proper tracking
  void _assignWorker(Map<String, dynamic> service) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Service: ${service['service'] ?? service['serviceType']}'),
              Text('Customer: ${service['customer']}'),
              const SizedBox(height: 16),
              const Text(
                'Select Worker:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
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
                    items: workers.map((worker) {
                      return DropdownMenuItem<WorkerData>(
                        value: worker,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 15,
                              backgroundColor: const Color(0xFF6B5B9A).withOpacity(0.1),
                              child: Text(
                                worker.name[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFF6B5B9A),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(worker.name, style: const TextStyle(fontSize: 14)),
                                  Text(
                                    worker.phone,
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (worker) => setState(() => selectedWorker = worker),
                  ),
                ),
              ),
            ],
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
                // ✅ Assign service to worker
                final appState = Provider.of<AppStateProvider>(
                  this.context,
                  listen: false,
                );

                appState.assignServiceToWorker(
                  service['id'],
                  selectedWorker!.id,
                  selectedWorker!.name,
                );

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text('✅ Service assigned to ${selectedWorker!.name}'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B5B9A),
                foregroundColor: Colors.white,
              ),
              child: const Text('Assign'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRescheduleDialog(Map<String, dynamic> service) {
    final authService = WorkerAuthService();
    // ✅ FIX: Exclude previously assigned worker from the list
    final previousWorkerId = service['assignedWorkerId'];
    final workers = authService.getActiveWorkers()
        .where((worker) => worker.id != previousWorkerId)
        .toList();

    WorkerData? selectedWorker;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.schedule, color: Colors.orange),
              SizedBox(width: 8),
              Text('Reschedule Service'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Service: ${service['service'] ?? service['serviceType']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Customer: ${service['customer']}'),
                const Divider(height: 24),

                const Text(
                  'Select New Worker:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
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
                      items: workers.map((worker) {
                        return DropdownMenuItem<WorkerData>(
                          value: worker,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 15,
                                backgroundColor: const Color(0xFF6B5B9A).withOpacity(0.1),
                                child: Text(
                                  worker.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Color(0xFF6B5B9A),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(worker.name, style: const TextStyle(fontSize: 14)),
                                    Text(
                                      worker.phone,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (worker) => setState(() => selectedWorker = worker),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                const Text(
                  'Select New Date:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
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
                          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        ),
                        const Icon(Icons.calendar_today, size: 20),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Service will be removed from previous worker and assigned to new worker',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange.shade700,
                          ),
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
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedWorker == null
                  ? null
                  : () {
                final appState = Provider.of<AppStateProvider>(
                    this.context,
                    listen: false
                );

                appState.reschedulePostponedService(
                  serviceId: service['id'],
                  newWorkerId: selectedWorker!.id,
                  newWorkerName: selectedWorker!.name,
                  newScheduledDate: selectedDate,
                );

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text('✅ Service rescheduled to ${selectedWorker!.name}'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reschedule'),
            ),
          ],
        ),
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
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialRow(String label, num amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 14 : 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            'SAR ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isBold ? 14 : 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? Colors.green : null,
            ),
          ),
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
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Services will appear here automatically',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _viewServiceDetails(Map<String, dynamic> service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: ListView(
              controller: scrollController,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  service['service'] ?? service['serviceType'] ?? 'Service',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildDetailRow('Service ID', service['id']),
                _buildDetailRow('Customer', service['customer'] ?? 'N/A'),
                _buildDetailRow('Phone', service['customerPhone'] ?? service['phone'] ?? 'N/A'),
                _buildDetailRow('Location', service['location'] ?? 'N/A'),
                _buildDetailRow('Address', service['address'] ?? 'N/A'),
                if (service['worker'] != null || service['assignedWorker'] != null)
                  _buildDetailRow('Worker', service['worker'] ?? service['assignedWorker']),
                _buildDetailRow('Status', (service['status'] ?? 'N/A').toString().toUpperCase()),
                if (service['description'] != null)
                  _buildDetailRow('Description', service['description']),
                if (service['postponeReason'] != null)
                  _buildDetailRow('Postpone Reason', service['postponeReason']),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B5B9A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _downloadInvoice(Map<String, dynamic> service) async {
    // ✅ Prevent duplicate downloads
    if (_isDownloadingInvoice) {
      debugPrint('⚠️ Invoice download already in progress');
      return;
    }

    setState(() => _isDownloadingInvoice = true);

    try {
      final invoiceService = InvoiceService();

      // Get invoice by service ID
      final invoice = invoiceService.getInvoiceByServiceId(service['id']);

      if (invoice != null && invoice.invoiceNumber.isNotEmpty) {
        // Download invoice PDF
        await invoiceService.downloadInvoicePDF(invoice);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Invoice ${invoice.invoiceNumber} downloaded successfully'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Invoice not found - shouldn't happen for completed services
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Invoice not found for this service'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error downloading invoice: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading invoice: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloadingInvoice = false);
      }
    }
  }

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {});
  }
}