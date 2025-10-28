import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CompletedServicesScreen extends StatefulWidget {
  const CompletedServicesScreen({super.key});

  @override
  State<CompletedServicesScreen> createState() => _CompletedServicesScreenState();
}

class _CompletedServicesScreenState extends State<CompletedServicesScreen> {
  String _filterPeriod = 'All';

  final List<Map<String, dynamic>> _completedServices = [
    {
      'id': '#SRV045',
      'customer': 'Ali Hassan',
      'service': 'AC Installation',
      'date': DateTime(2025, 10, 20),
      'completedDate': DateTime(2025, 10, 20, 14, 30),
      'address': 'DHA Phase 8, Block A, Lahore',
      'price': 800.0,
      'commission': 80.0,
      'vat': 40.0,
      'phone': '+966501234567',
      'rating': 5,
      'paymentMethod': 'Cash',
      'extraItems': [
        {'name': 'Extra Piping', 'price': 50.0},
        {'name': 'Gas Refill', 'price': 100.0},
      ],
    },
    {
      'id': '#SRV044',
      'customer': 'Sara Ahmed',
      'service': 'Washing Machine Repair',
      'date': DateTime(2025, 10, 19),
      'completedDate': DateTime(2025, 10, 19, 11, 15),
      'address': 'Johar Town, Block D, Lahore',
      'price': 350.0,
      'commission': 35.0,
      'vat': 17.5,
      'phone': '+966507654321',
      'rating': 4,
      'paymentMethod': 'Online',
      'extraItems': [],
    },
    {
      'id': '#SRV043',
      'customer': 'Mohammed Khan',
      'service': 'Refrigerator Repair',
      'date': DateTime(2025, 10, 18),
      'completedDate': DateTime(2025, 10, 18, 16, 45),
      'address': 'Model Town, Street 12, Lahore',
      'price': 550.0,
      'commission': 55.0,
      'vat': 27.5,
      'phone': '+966509876543',
      'rating': 5,
      'paymentMethod': 'Cash',
      'extraItems': [
        {'name': 'Thermostat Replacement', 'price': 150.0},
      ],
    },
    {
      'id': '#SRV042',
      'customer': 'Fatima Ali',
      'service': 'Microwave Service',
      'date': DateTime(2025, 10, 17),
      'completedDate': DateTime(2025, 10, 17, 10, 20),
      'address': 'Gulberg III, Block M, Lahore',
      'price': 250.0,
      'commission': 25.0,
      'vat': 12.5,
      'phone': '+966501112222',
      'rating': 4,
      'paymentMethod': 'Online',
      'extraItems': [],
    },
    {
      'id': '#SRV041',
      'customer': 'Hassan Raza',
      'service': 'AC Repair',
      'date': DateTime(2025, 10, 16),
      'completedDate': DateTime(2025, 10, 16, 13, 30),
      'address': 'Bahria Town, Phase 4, Lahore',
      'price': 450.0,
      'commission': 45.0,
      'vat': 22.5,
      'phone': '+966503334444',
      'rating': 5,
      'paymentMethod': 'Cash',
      'extraItems': [],
    },
  ];

  List<Map<String, dynamic>> get _filteredServices {
    final now = DateTime.now();
    return _completedServices.where((service) {
      switch (_filterPeriod) {
        case 'Today':
          return service['completedDate'].day == now.day &&
              service['completedDate'].month == now.month;
        case 'This Week':
          final weekAgo = now.subtract(const Duration(days: 7));
          return service['completedDate'].isAfter(weekAgo);
        case 'This Month':
          return service['completedDate'].month == now.month;
        default:
          return true;
      }
    }).toList();
  }

  double get _totalEarnings {
    return _filteredServices.fold(0, (sum, service) {
      final extraTotal = (service['extraItems'] as List).fold(
          0.0, (sum, item) => sum + (item['price'] as double));
      return sum + service['price'] + extraTotal - service['commission'] - service['vat'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FA);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Completed Services'),
        backgroundColor: const Color(0xFF6B5B9A),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          _buildSummaryCard(cardColor, textColor),
          Expanded(
            child: _filteredServices.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No completed services found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredServices.length,
                    itemBuilder: (context, index) {
                      return _buildServiceCard(
                          _filteredServices[index], cardColor, textColor);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: ['All', 'Today', 'This Week', 'This Month']
            .map((period) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(period),
                    selected: _filterPeriod == period,
                    onSelected: (selected) {
                      setState(() => _filterPeriod = period);
                    },
                    selectedColor: const Color(0xFF6B5B9A),
                    labelStyle: TextStyle(
                      color: _filterPeriod == period ? Colors.white : null,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildSummaryCard(Color cardColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF45a049)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Services',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_filteredServices.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 2,
            height: 50,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Earned',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SAR ${_totalEarnings.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
      Map<String, dynamic> service, Color cardColor, Color textColor) {
    final extraTotal = (service['extraItems'] as List)
        .fold(0.0, (sum, item) => sum + (item['price'] as double));
    final totalPrice = service['price'] + extraTotal;
    final netEarning =
        totalPrice - service['commission'] - service['vat'];

    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.check_circle, color: Colors.green),
        ),
        title: Text(
          service['service'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: textColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              service['id'],
              style: const TextStyle(
                color: Color(0xFF6B5B9A),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Completed: ${DateFormat('MMM dd, yyyy - hh:mm a').format(service['completedDate'])}',
              style: TextStyle(
                fontSize: 12,
                color: textColor.withOpacity(0.6),
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'SAR ${totalPrice.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: textColor,
              ),
            ),
            _buildRatingStars(service['rating']),
          ],
        ),
        children: [
          const Divider(),
          _buildDetailRow(Icons.person, 'Customer', service['customer'], textColor),
          _buildDetailRow(Icons.phone, 'Phone', service['phone'], textColor),
          _buildDetailRow(Icons.location_on, 'Address', service['address'], textColor),
          _buildDetailRow(Icons.payment, 'Payment', service['paymentMethod'], textColor),
          
          if ((service['extraItems'] as List).isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Extra Items:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            ...(service['extraItems'] as List).map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '• ${item['name']}',
                        style: TextStyle(
                          fontSize: 13,
                          color: textColor.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        'SAR ${item['price'].toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
          
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildPriceRow('Base Price', service['price'], textColor),
                if (extraTotal > 0)
                  _buildPriceRow('Extra Items', extraTotal, textColor),
                _buildPriceRow('Commission', -service['commission'], textColor, color: Colors.red),
                _buildPriceRow('VAT', -service['vat'], textColor, color: Colors.orange),
                const Divider(),
                _buildPriceRow('Net Earning', netEarning, textColor, isBold: true, color: Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: textColor.withOpacity(0.6)),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: textColor.withOpacity(0.7),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, Color textColor, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? textColor.withOpacity(0.8),
            ),
          ),
          Text(
            '${amount < 0 ? '-' : ''}SAR ${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color ?? textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          size: 14,
          color: Colors.orange,
        );
      }),
    );
  }
}
