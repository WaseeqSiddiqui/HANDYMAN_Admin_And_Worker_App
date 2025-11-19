import 'package:flutter/material.dart';
import '../models/service_request_model.dart';

class AddExtraItemsScreen extends StatefulWidget {
  final ServiceRequest service; // ✅ Now accepts ServiceRequest model
  final Function(double, List<ExtraItem>) onItemsAdded;

  const AddExtraItemsScreen({
    super.key,
    required this.service,
    required this.onItemsAdded,
  });

  @override
  State<AddExtraItemsScreen> createState() => _AddExtraItemsScreenState();
}

class _AddExtraItemsScreenState extends State<AddExtraItemsScreen> {
  final List<ExtraItem> _extraItems = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  double get _totalExtraCharges {
    return _extraItems.fold(
      0.0,
          (sum, item) => sum + item.price,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Extra Items'),
        backgroundColor: const Color(0xFF6B5B9A),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Service Info Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF6B5B9A).withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Service: ${widget.service.serviceName}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Customer: ${widget.service.customerName}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          // Extra Items List
          Expanded(
            child: _extraItems.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No extra items added',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _extraItems.length,
              itemBuilder: (context, index) {
                final item = _extraItems[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: item.type == 'Service'
                          ? Colors.blue
                          : Colors.orange,
                      child: Icon(
                        item.type == 'Service'
                            ? Icons.build
                            : Icons.inventory,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(item.name),
                    subtitle: Text('Type: ${item.type}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'SAR ${item.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeItem(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Total and Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Total Display section
                if (_extraItems.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B5B9A).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Extra Charges:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'SAR ${_totalExtraCharges.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddItemDialog('Service'),
                        icon: const Icon(Icons.build),
                        label: const Text('Add Service'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B5B9A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showAddItemDialog('Part'),
                        icon: const Icon(Icons.inventory),
                        label: const Text('Add Part'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _extraItems.isEmpty ? null : _saveAndReturn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Save & Return'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(String type) {
    _nameController.clear();
    _priceController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add $type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '$type Name',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(
                  type == 'Service' ? Icons.build : Icons.inventory,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price (SAR)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _addItem(type),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B5B9A),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addItem(String type) {
    final name = _nameController.text.trim();
    final priceText = _priceController.text.trim();

    if (name.isEmpty || priceText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final price = double.tryParse(priceText);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid price'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _extraItems.add(ExtraItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        type: type,
        price: price,
      ));
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$type added successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      _extraItems.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item removed'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _saveAndReturn() {
    widget.onItemsAdded(_totalExtraCharges, _extraItems);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Extra charges: SAR ${_totalExtraCharges.toStringAsFixed(2)} added',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}