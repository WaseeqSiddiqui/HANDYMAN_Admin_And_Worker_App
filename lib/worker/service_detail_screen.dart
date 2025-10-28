import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'add_extra_items_screen.dart';
import 'generate_invoice_screen.dart';

class ServiceDetailScreen extends StatefulWidget {
  final Map<String, dynamic> service;

  const ServiceDetailScreen({super.key, required this.service});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  late Map<String, dynamic> _service;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _service = Map<String, dynamic>.from(widget.service);
  }

  // Calculate required credit
  double get _requiredCredit {
    double total = _service['price'] + (_service['extraCharges'] ?? 0.0);
    double commission = _service['commission'];
    double vat = _service['vat'];
    return commission + vat;
  }

  // Get current worker credit (Replace with actual Firebase call)
  double get _currentCredit => 250.0; // From dashboard state

  // Check if worker can accept service
  bool get _canAcceptService => _currentCredit >= _requiredCredit;

  // Format date safely
  String _formatDate(dynamic dateValue) {
    try {
      DateTime dateTime;
      if (dateValue is DateTime) {
        dateTime = dateValue;
      } else if (dateValue is String) {
        dateTime = DateTime.parse(dateValue);
      } else {
        return 'N/A';
      }
      return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FA);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(_service['service']),
        backgroundColor: const Color(0xFF6B5B9A),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildServiceHeader(cardColor, textColor),
            const SizedBox(height: 16),
            _buildCustomerInfo(cardColor, textColor),
            const SizedBox(height: 16),
            _buildPriceBreakdown(cardColor, textColor),
            const SizedBox(height: 16),
            _buildCreditValidation(cardColor, textColor),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceHeader(Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _service['id'],
                style: const TextStyle(
                  color: Color(0xFF6B5B9A),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              _buildStatusBadge(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _service['service'],
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatDate(_service['date']),
            style: TextStyle(
              color: textColor.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color statusColor;
    switch (_service['status']) {
      case 'Pending':
        statusColor = Colors.orange;
        break;
      case 'In Progress':
        statusColor = Colors.blue;
        break;
      case 'Completed':
        statusColor = Colors.green;
        break;
      case 'Postponed':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor),
      ),
      child: Text(
        _service['status'],
        style: TextStyle(
          color: statusColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCustomerInfo(Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.person, 'Name', _service['customer'], textColor),
          _buildInfoRow(Icons.phone, 'Phone', _service['phone'], textColor),
          _buildInfoRow(Icons.location_on, 'Address', _service['address'], textColor),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF6B5B9A)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown(Color cardColor, Color textColor) {
    double extraCharges = _service['extraCharges'] ?? 0.0;
    double total = _service['price'] + extraCharges;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildPriceRow('Base Price', _service['price'], textColor),
          if (extraCharges > 0)
            _buildPriceRow('Extra Items', extraCharges, textColor, color: Colors.orange),
          const Divider(height: 24),
          _buildPriceRow('Commission (10%)', _service['commission'], textColor, color: Colors.red),
          _buildPriceRow('VAT (5%)', _service['vat'], textColor, color: Colors.red),
          const Divider(height: 24),
          _buildPriceRow('Total Amount', total, textColor, isTotal: true),
          _buildPriceRow('Your Earnings', total - _requiredCredit, textColor, color: Colors.green),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, Color textColor, {Color? color, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              color: color ?? textColor,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            'SAR ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: color ?? textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditValidation(Color cardColor, Color textColor) {
    bool hasEnoughCredit = _canAcceptService;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: hasEnoughCredit
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasEnoughCredit ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasEnoughCredit ? Icons.check_circle : Icons.error,
                color: hasEnoughCredit ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                'Credit Validation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: hasEnoughCredit ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Required Credit:',
                style: TextStyle(color: textColor.withOpacity(0.7)),
              ),
              Text(
                'SAR ${_requiredCredit.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Credit:',
                style: TextStyle(color: textColor.withOpacity(0.7)),
              ),
              Text(
                'SAR ${_currentCredit.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: hasEnoughCredit ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          if (!hasEnoughCredit) ...[
            const SizedBox(height: 12),
            Text(
              '⚠️ Insufficient credit! Please top-up to accept this service.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_service['status'] == 'Pending') ...[
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _canAcceptService ? _acceptService : _showCreditError,
              icon: const Icon(Icons.check_circle),
              label: const Text('Accept Service'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _canAcceptService ? Colors.green : Colors.grey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: _rejectService,
              icon: const Icon(Icons.cancel),
              label: const Text('Reject Service'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
        if (_service['status'] == 'In Progress') ...[
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _addExtraItems,
              icon: const Icon(Icons.add),
              label: const Text('Add Extra Items'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _canAcceptService ? _generateInvoice : _showCreditError,
              icon: const Icon(Icons.receipt_long),
              label: const Text('Generate Invoice'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _canAcceptService ? const Color(0xFF6B5B9A) : Colors.grey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: _postponeService,
              icon: const Icon(Icons.schedule),
              label: const Text('Postpone Service'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showCreditError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Insufficient Credit'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Required Credit: SAR ${_requiredCredit.toStringAsFixed(2)}'),
            Text('Your Credit: SAR ${_currentCredit.toStringAsFixed(2)}'),
            const SizedBox(height: 12),
            const Text(
              'Please top-up your credit to accept this service and cover the VAT + Commission.',
              style: TextStyle(fontSize: 12),
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
              // Navigate to credit screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Redirecting to Credit Top-up...')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B5B9A),
            ),
            child: const Text('Top-up Now'),
          ),
        ],
      ),
    );
  }

  void _acceptService() async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _service['status'] = 'In Progress';
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Service accepted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _rejectService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Service?'),
        content: const Text('Are you sure you want to reject this service?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Service rejected')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _addExtraItems() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExtraItemsScreen(
          service: _service,
          onItemsAdded: (extraCharges) {
            setState(() {
              _service['extraCharges'] = extraCharges;
            });
          },
        ),
      ),
    );
  }

  void _generateInvoice() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GenerateInvoiceScreen(service: _service),
      ),
    );
  }

  void _postponeService() {
    String? selectedReason;
    final TextEditingController otherReasonController = TextEditingController();

    // Predefined postpone reasons
    final List<String> postponeReasons = [
      'Customer not available',
      'Customer requested reschedule',
      'Wrong address provided',
      'Tools/parts not available',
      'Weather conditions',
      'Emergency situation',
      'Traffic/transportation issue',
      'Customer not ready',
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
                const Text(
                  'Select reason for postponement:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
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
                      icon: const Icon(Icons.arrow_drop_down),
                      items: postponeReasons.map((String reason) {
                        return DropdownMenuItem<String>(
                          value: reason,
                          child: Text(
                            reason,
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setDialogState(() {
                          selectedReason = newValue;
                        });
                      },
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
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Admin will be notified about the postponement',
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

                if (selectedReason == 'Other' && otherReasonController.text.trim().isEmpty) {
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

                setState(() {
                  _service['status'] = 'Postponed';
                  _service['postponeReason'] = finalReason;
                });

                otherReasonController.dispose();
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Service postponed: $finalReason'),
                    backgroundColor: Colors.orange,
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text('Confirm Postpone'),
            ),
          ],
        ),
      ),
    );
  }
}