import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/app_state_provider.dart';
import '/models/customer_model.dart';
import '/models/customer_service_model.dart';
import '/utils/admin_translations.dart';
import '/widgets/bilingual_text.dart';

class CustomerManagementScreen extends StatefulWidget {
  const CustomerManagementScreen({super.key});

  @override
  State<CustomerManagementScreen> createState() =>
      _CustomerManagementScreenState();
}

class _CustomerManagementScreenState extends State<CustomerManagementScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AdminTranslations.split(AdminTranslations.customerManagement)[0],
        ),
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          final customers = appState.registeredCustomers;

          final filteredCustomers = customers.where((customer) {
            final query = _searchQuery.toLowerCase();
            return customer.name.toLowerCase().contains(query) ||
                customer.phone.toLowerCase().contains(query) ||
                (customer.email?.toLowerCase().contains(query) ?? false);
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: AdminTranslations.split(
                      AdminTranslations.searchCustomers,
                    )[0],
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
              ),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF005DFF), Color(0xFF005DFF)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      AdminTranslations.split(
                        AdminTranslations.totalCustomers,
                      )[0],
                      AdminTranslations.split(
                        AdminTranslations.totalCustomers,
                      )[1],
                      customers.length.toString(),
                      Icons.people,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.blue.withValues(alpha: 0.1),
                    ),
                    _buildStatItem(
                      AdminTranslations.split(
                        AdminTranslations.activeServices,
                      )[0],
                      AdminTranslations.split(
                        AdminTranslations.activeServices,
                      )[1],
                      _getCustomerActiveServices(
                        customers,
                        appState,
                      ).toString(),
                      Icons.build,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: filteredCustomers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchQuery.isEmpty
                                  ? Icons.people_outline
                                  : Icons.search_off,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            BilingualText(
                              english: _searchQuery.isEmpty
                                  ? AdminTranslations.split(
                                      AdminTranslations.noCustomersYet,
                                    )[0]
                                  : AdminTranslations.split(
                                      AdminTranslations.noCustomersFound,
                                    )[0],
                              arabic: _searchQuery.isEmpty
                                  ? AdminTranslations.split(
                                      AdminTranslations.noCustomersYet,
                                    )[1]
                                  : AdminTranslations.split(
                                      AdminTranslations.noCustomersFound,
                                    )[1],
                              englishStyle: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            BilingualText(
                              english: _searchQuery.isEmpty
                                  ? AdminTranslations.split(
                                      AdminTranslations.customersWillAppear,
                                    )[0]
                                  : AdminTranslations.split(
                                      AdminTranslations.tryDifferentSearch,
                                    )[0],
                              arabic: _searchQuery.isEmpty
                                  ? AdminTranslations.split(
                                      AdminTranslations.customersWillAppear,
                                    )[1]
                                  : AdminTranslations.split(
                                      AdminTranslations.tryDifferentSearch,
                                    )[1],
                              englishStyle: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredCustomers.length,
                        itemBuilder: (context, index) {
                          final customer = filteredCustomers[index];
                          return _buildCustomerCard(customer, appState);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(
    String labelEn,
    String labelAr,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        BilingualText(
          english: labelEn,
          arabic: labelAr,
          englishStyle: const TextStyle(color: Colors.white70, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  int _getCustomerActiveServices(
    List<Customer> customers,
    AppStateProvider appState,
  ) {
    int count = 0;
    for (var customer in customers) {
      final customerServices = appState.getCustomerServices(customer.id);
      // Filter for active statuses only
      final activeCount = customerServices.where((s) {
        final status = s.status.toLowerCase();
        return status == 'pending' ||
            status == 'assigned' ||
            status == 'inprogress' ||
            status == 'postponed'; // ✅ Include postponed as active
      }).length;
      count += activeCount;
    }
    return count;
  }

  Widget _buildCustomerCard(Customer customer, AppStateProvider appState) {
    final customerServices = appState.getCustomerServices(customer.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showCustomerDetails(customer, customerServices),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF005DFF),
                    radius: 28,
                    child: Text(
                      customer.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              customer.phone,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        if (customer.email != null &&
                            customer.email!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.email,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  customer.email!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                    onPressed: () =>
                        _showCustomerDetails(customer, customerServices),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.shopping_bag,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${customerServices.length} ${AdminTranslations.split(AdminTranslations.servicesLowercase)[0]}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${AdminTranslations.split(AdminTranslations.registered)[0]}: ${customer.registeredAt.day}/${customer.registeredAt.month}/${customer.registeredAt.year}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCustomerDetails(Customer customer, List<CustomerService> services) {
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
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF005DFF),
                      radius: 32,
                      child: Text(
                        customer.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          BilingualText(
                            english: AdminTranslations.split(
                              AdminTranslations.customerDetails,
                            )[0],
                            arabic: AdminTranslations.split(
                              AdminTranslations.customerDetails,
                            )[1],
                            englishStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildDetailRow(
                  AdminTranslations.split(AdminTranslations.phoneNumber)[0],
                  AdminTranslations.split(AdminTranslations.phoneNumber)[1],
                  customer.phone,
                  Icons.phone,
                ),
                if (customer.email != null && customer.email!.isNotEmpty)
                  _buildDetailRow(
                    AdminTranslations.split(AdminTranslations.email)[0],
                    AdminTranslations.split(AdminTranslations.email)[1],
                    customer.email!,
                    Icons.email,
                  ),
                _buildDetailRow(
                  AdminTranslations.split(AdminTranslations.registered)[0],
                  AdminTranslations.split(AdminTranslations.registered)[1],
                  '${customer.registeredAt.day}/${customer.registeredAt.month}/${customer.registeredAt.year}',
                  Icons.calendar_today,
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                BilingualText(
                  english:
                      '${AdminTranslations.split(AdminTranslations.serviceHistory)[0]} (${services.length})',
                  arabic:
                      '${AdminTranslations.split(AdminTranslations.serviceHistory)[1]} (${services.length})',
                  englishStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (services.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.inbox, size: 48, color: Colors.grey[300]),
                          const SizedBox(height: 12),
                          BilingualText(
                            english: AdminTranslations.split(
                              AdminTranslations.noServicesYet,
                            )[0],
                            arabic: AdminTranslations.split(
                              AdminTranslations.noServicesYet,
                            )[1],
                            englishStyle: TextStyle(color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...services.map(
                    (service) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(
                            service.status,
                          ).withValues(alpha: 0.2),
                          child: Icon(
                            _getStatusIcon(service.status),
                            color: _getStatusColor(service.status),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          service.service,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${service.status} • ${service.id}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Text(
                          'SAR ${service.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005DFF),
                    foregroundColor: Colors.white, // ✅ White text
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    AdminTranslations.split(AdminTranslations.closeBtn)[0],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(
    String labelEn,
    String labelAr,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF6B5B9A)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BilingualText(
                  english: labelEn,
                  arabic: labelAr,
                  englishStyle: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in progress':
        return Colors.blue;
      case 'postponed':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'in progress':
        return Icons.build;
      case 'postponed':
        return Icons.event_busy;
      default:
        return Icons.pending;
    }
  }
}
