import 'package:flutter/material.dart';
import '../models/service_request_model.dart';
import '../utils/worker_translations.dart';

class AddExtraItemsScreen extends StatefulWidget {
  final ServiceRequest service;
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // English title
            Text(
              WorkerTranslations.split(WorkerTranslations.addExtraItems)[0],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            // Arabic title
            Text(
              WorkerTranslations.split(WorkerTranslations.addExtraItems)[1],
              style: const TextStyle(fontSize: 14),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
        backgroundColor: const Color(0xFF005DFF),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Service Info Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF005DFF).withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service name
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${WorkerTranslations.split(WorkerTranslations.service)[0]} ${widget.service.serviceName}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${WorkerTranslations.split(WorkerTranslations.service)[1]} ${widget.service.serviceName}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Customer name
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${WorkerTranslations.split(WorkerTranslations.customer)[0]} ${widget.service.customerName}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      '${WorkerTranslations.split(WorkerTranslations.customer)[1]} ${widget.service.customerName}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Extra Items List
          Expanded(
            child: _extraItems.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inbox, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  // No items message
                  Column(
                    children: [
                      Text(
                        WorkerTranslations.split(WorkerTranslations.noExtraItemsAdded)[0],
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      Text(
                        WorkerTranslations.split(WorkerTranslations.noExtraItemsAdded)[1],
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
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
                    subtitle: Text(
                      '${WorkerTranslations.split(WorkerTranslations.type)[0]} ${item.type} • ${WorkerTranslations.split(WorkerTranslations.sar)[0]} ${item.price.toStringAsFixed(2)}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeItem(index),
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
                      color: const Color(0xFF005DFF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        // English total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              WorkerTranslations.split(WorkerTranslations.totalExtraCharges)[0],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${WorkerTranslations.split(WorkerTranslations.sar)[0]} ${_totalExtraCharges.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Arabic total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              WorkerTranslations.split(WorkerTranslations.totalExtraCharges)[1],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                            Text(
                              '${WorkerTranslations.split(WorkerTranslations.sar)[1]} ${_totalExtraCharges.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ],
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
                        label: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(WorkerTranslations.split(WorkerTranslations.addService)[0]),
                            Text(
                              WorkerTranslations.split(WorkerTranslations.addService)[1],
                              style: const TextStyle(fontSize: 10),
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005DFF),
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
                        label: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(WorkerTranslations.split(WorkerTranslations.addPart)[0]),
                            Text(
                              WorkerTranslations.split(WorkerTranslations.addPart)[1],
                              style: const TextStyle(fontSize: 10),
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(WorkerTranslations.split(WorkerTranslations.saveReturn)[0]),
                        Text(
                          WorkerTranslations.split(WorkerTranslations.saveReturn)[1],
                          style: const TextStyle(fontSize: 12),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${WorkerTranslations.split(WorkerTranslations.addBtn)[0]} $type'),
            Text(
              '${WorkerTranslations.split(WorkerTranslations.addBtn)[1]} ${type == 'Service' ? 'خدمة' : 'قطعة'}',
              style: const TextStyle(fontSize: 14),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Instruction Text
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF005DFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      'Enter name in English or Arabic',
                      style: TextStyle(
                        color: const Color(0xFF005DFF),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'أدخل الاسم بالإنجليزية أو العربية',
                      style: TextStyle(
                        color: const Color(0xFF005DFF),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Single Name Field
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        type == 'Service'
                            ? '${WorkerTranslations.split(WorkerTranslations.serviceName)[0]} • ${WorkerTranslations.split(WorkerTranslations.serviceName)[1]}'
                            : '${WorkerTranslations.split(WorkerTranslations.partName)[0]} • ${WorkerTranslations.split(WorkerTranslations.partName)[1]}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: type == 'Service'
                            ? 'Enter service name / أدخل اسم الخدمة'
                            : 'Enter part name / أدخل اسم القطعة',
                        hintStyle: const TextStyle(fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Price Field
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        '${WorkerTranslations.split(WorkerTranslations.priceSAR)[0]} • ${WorkerTranslations.split(WorkerTranslations.priceSAR)[1]}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        hintText: '0.00',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        prefixText: 'SAR ',
                        prefixStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      textInputAction: TextInputAction.done,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(WorkerTranslations.split(WorkerTranslations.cancelBtn)[0]),
                Text(
                  WorkerTranslations.split(WorkerTranslations.cancelBtn)[1],
                  style: const TextStyle(fontSize: 12),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _addItem(type),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005DFF),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(WorkerTranslations.split(WorkerTranslations.addBtn)[0]),
                Text(
                  WorkerTranslations.split(WorkerTranslations.addBtn)[1],
                  style: const TextStyle(fontSize: 12),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
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
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(WorkerTranslations.split(WorkerTranslations.pleaseFillAllFields)[0]),
              Text(
                WorkerTranslations.split(WorkerTranslations.pleaseFillAllFields)[1],
                style: const TextStyle(fontSize: 12),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final price = double.tryParse(priceText);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(WorkerTranslations.split(WorkerTranslations.pleaseEnterValidPrice)[0]),
              Text(
                WorkerTranslations.split(WorkerTranslations.pleaseEnterValidPrice)[1],
                style: const TextStyle(fontSize: 12),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$type ${WorkerTranslations.split(WorkerTranslations.addedSuccessfully)[0]}'),
            Text(
              '${type == 'Service' ? 'خدمة' : 'قطعة'} ${WorkerTranslations.split(WorkerTranslations.addedSuccessfully)[1]}',
              style: const TextStyle(fontSize: 12),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      _extraItems.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(WorkerTranslations.split(WorkerTranslations.itemRemoved)[0]),
            Text(
              WorkerTranslations.split(WorkerTranslations.itemRemoved)[1],
              style: const TextStyle(fontSize: 12),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _saveAndReturn() {
    widget.onItemsAdded(_totalExtraCharges, _extraItems);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // English success message
            Text(
              '${WorkerTranslations.split(WorkerTranslations.extraCharges)[0]} ${WorkerTranslations.split(WorkerTranslations.sar)[0]} ${_totalExtraCharges.toStringAsFixed(2)} ${WorkerTranslations.split(WorkerTranslations.added)[0]}',
            ),
            // Arabic success message
            Text(
              '${WorkerTranslations.split(WorkerTranslations.extraCharges)[1]} ${WorkerTranslations.split(WorkerTranslations.sar)[1]} ${_totalExtraCharges.toStringAsFixed(2)} ${WorkerTranslations.split(WorkerTranslations.added)[1]}',
              style: const TextStyle(fontSize: 12),
              textDirection: TextDirection.rtl,
            ),
          ],
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