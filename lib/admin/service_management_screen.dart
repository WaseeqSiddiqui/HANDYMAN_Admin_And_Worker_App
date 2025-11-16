import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ServiceManagementScreen extends StatefulWidget {
  const ServiceManagementScreen({super.key});

  @override
  State<ServiceManagementScreen> createState() => _ServiceManagementScreenState();
}

class _ServiceManagementScreenState extends State<ServiceManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'cat1',
      'name': 'AC Services',
      'nameArabic': 'خدمات التكييف',
      'icon': Icons.ac_unit,
      'subcategories': ['Repair', 'Installation', 'Maintenance'],
      'subcategoriesArabic': ['إصلاح', 'تركيب', 'صيانة'],
    },
    {
      'id': 'cat2',
      'name': 'Appliances',
      'nameArabic': 'الأجهزة المنزلية',
      'icon': Icons.kitchen,
      'subcategories': ['Washing Machine', 'Refrigerator', 'Microwave'],
      'subcategoriesArabic': ['غسالة', 'ثلاجة', 'ميكروويف'],
    },
    {
      'id': 'cat3',
      'name': 'Plumbing',
      'nameArabic': 'السباكة',
      'icon': Icons.plumbing,
      'subcategories': ['Leak Repair', 'Installation', 'Drain Cleaning'],
      'subcategoriesArabic': ['إصلاح التسريبات', 'تركيب', 'تنظيف المصارف'],
    },
  ];

  final List<Map<String, dynamic>> _services = [
    {
      'id': 'srv1',
      'name': 'AC Repair',
      'nameArabic': 'إصلاح التكييف',
      'category': 'AC Services',
      'categoryArabic': 'خدمات التكييف',
      'subcategory': 'Repair',
      'subcategoryArabic': 'إصلاح',
      'basePrice': 450.0,
      'commission': 10.0,
      'vat': 5.0,
      'isActive': true,
    },
    {
      'id': 'srv2',
      'name': 'Washing Machine Service',
      'nameArabic': 'صيانة الغسالة',
      'category': 'Appliances',
      'categoryArabic': 'الأجهزة المنزلية',
      'subcategory': 'Washing Machine',
      'subcategoryArabic': 'غسالة',
      'basePrice': 300.0,
      'commission': 10.0,
      'vat': 5.0,
      'isActive': true,
    },
    {
      'id': 'srv3',
      'name': 'Refrigerator Repair',
      'nameArabic': 'إصلاح الثلاجة',
      'category': 'Appliances',
      'categoryArabic': 'الأجهزة المنزلية',
      'subcategory': 'Refrigerator',
      'subcategoryArabic': 'ثلاجة',
      'basePrice': 550.0,
      'commission': 10.0,
      'vat': 5.0,
      'isActive': false,
    },
  ];

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Service Management'),
        backgroundColor: const Color(0xFF6B5B9A),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Categories'),
            Tab(text: 'Subcategories'),
            Tab(text: 'Services'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoriesTab(),
          _buildSubcategoriesTab(),
          _buildServicesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(),
        backgroundColor: const Color(0xFF6B5B9A),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add New', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildCategoriesTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return Card(
          color: cardColor,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF6B5B9A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(category['icon'], color: const Color(0xFF6B5B9A)),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                Text(
                  category['nameArabic'],
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${category['subcategories'].length} subcategories',
                style: TextStyle(color: textColor.withOpacity(0.6)),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF6B5B9A)),
                  onPressed: () => _showEditCategoryDialog(category),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete('category', category['name']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubcategoriesTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _categories.length,
      itemBuilder: (context, catIndex) {
        final category = _categories[catIndex];
        final subcats = category['subcategories'] as List<String>;
        final subcatsArabic = category['subcategoriesArabic'] as List<String>;

        return Card(
          color: cardColor,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category['name'],
                  style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                ),
                Text(
                  category['nameArabic'],
                  style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.6)),
                ),
              ],
            ),
            children: List.generate(subcats.length, (index) {
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subcats[index], style: TextStyle(color: textColor)),
                    Text(
                      subcatsArabic[index],
                      style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.6)),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF6B5B9A), size: 20),
                      onPressed: () => _showEditSubcategoryDialog(category, index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () => _confirmDelete('subcategory', subcats[index]),
                    ),
                  ],
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildServicesTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _services.length,
      itemBuilder: (context, index) {
        final service = _services[index];
        return Card(
          color: cardColor,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: textColor,
                            ),
                          ),
                          Text(
                            service['nameArabic'],
                            style: TextStyle(
                              fontSize: 14,
                              color: textColor.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${service['category']} > ${service['subcategory']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: textColor.withOpacity(0.6),
                            ),
                          ),
                          Text(
                            '${service['categoryArabic']} > ${service['subcategoryArabic']}',
                            style: TextStyle(
                              fontSize: 11,
                              color: textColor.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: service['isActive'],
                      onChanged: (value) {
                        setState(() {
                          service['isActive'] = value;
                        });
                      },
                      activeColor: const Color(0xFF6B5B9A),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoChip(
                        'Price',
                        'SAR ${service['basePrice']}',
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoChip(
                        'Commission',
                        '${service['commission']}%',
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoChip(
                        'VAT',
                        '${service['vat']}%',
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showEditServiceDialog(service),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF6B5B9A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _confirmDelete('service', service['name']),
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text('Delete'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    final currentTab = _tabController.index;
    if (currentTab == 0) {
      _showAddCategoryDialog();
    } else if (currentTab == 1) {
      _showAddSubcategoryDialog();
    } else {
      _showAddServiceDialog();
    }
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    final nameArabicController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Category'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name (English)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.abc),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameArabicController,
                decoration: const InputDecoration(
                  labelText: 'Category Name (Arabic)',
                  hintText: 'اسم الفئة بالعربية',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.language),
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && nameArabicController.text.isNotEmpty) {
                setState(() {
                  _categories.add({
                    'id': 'cat${_categories.length + 1}',
                    'name': nameController.text,
                    'nameArabic': nameArabicController.text,
                    'icon': Icons.category,
                    'subcategories': [],
                    'subcategoriesArabic': [],
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Category added successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B5B9A),
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddSubcategoryDialog() {
    String? selectedCategory;
    final nameController = TextEditingController();
    final nameArabicController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Subcategory'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Select Category',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat['id'],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(cat['name']),
                          Text(
                            cat['nameArabic'],
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedCategory = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Subcategory Name (English)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.abc),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameArabicController,
                  decoration: const InputDecoration(
                    labelText: 'Subcategory Name (Arabic)',
                    hintText: 'اسم الفئة الفرعية بالعربية',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.language),
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedCategory != null &&
                    nameController.text.isNotEmpty &&
                    nameArabicController.text.isNotEmpty) {
                  setState(() {
                    final category = _categories.firstWhere(
                          (cat) => cat['id'] == selectedCategory,
                    );
                    (category['subcategories'] as List).add(nameController.text);
                    (category['subcategoriesArabic'] as List).add(nameArabicController.text);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Subcategory added successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B5B9A),
                foregroundColor: Colors.white,
              ),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddServiceDialog() {
    final nameController = TextEditingController();
    final nameArabicController = TextEditingController();
    final priceController = TextEditingController();
    final commissionController = TextEditingController();
    final vatController = TextEditingController();
    String? selectedCategory;
    int? selectedSubcategoryIndex;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final selectedCat = selectedCategory != null
              ? _categories.firstWhere((cat) => cat['id'] == selectedCategory)
              : null;

          return AlertDialog(
            title: const Text('Add Service'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Service Name (English)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.abc),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameArabicController,
                    decoration: const InputDecoration(
                      labelText: 'Service Name (Arabic)',
                      hintText: 'اسم الخدمة بالعربية',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.language),
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: _categories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat['id'],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(cat['name']),
                            Text(
                              cat['nameArabic'],
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedCategory = value;
                        selectedSubcategoryIndex = null;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  if (selectedCat != null)
                    DropdownButtonFormField<int>(
                      value: selectedSubcategoryIndex,
                      decoration: const InputDecoration(
                        labelText: 'Subcategory',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(
                        (selectedCat['subcategories'] as List).length,
                            (index) {
                          return DropdownMenuItem<int>(
                            value: index,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(selectedCat['subcategories'][index]),
                                Text(
                                  selectedCat['subcategoriesArabic'][index],
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedSubcategoryIndex = value;
                        });
                      },
                    ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Base Price (SAR)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: commissionController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Commission (%)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.percent),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: vatController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'VAT (%)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.receipt_long),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty &&
                      nameArabicController.text.isNotEmpty &&
                      selectedCategory != null &&
                      selectedSubcategoryIndex != null &&
                      priceController.text.isNotEmpty &&
                      commissionController.text.isNotEmpty &&
                      vatController.text.isNotEmpty) {

                    final category = _categories.firstWhere((cat) => cat['id'] == selectedCategory);

                    setState(() {
                      _services.add({
                        'id': 'srv${_services.length + 1}',
                        'name': nameController.text,
                        'nameArabic': nameArabicController.text,
                        'category': category['name'],
                        'categoryArabic': category['nameArabic'],
                        'subcategory': category['subcategories'][selectedSubcategoryIndex!],
                        'subcategoryArabic': category['subcategoriesArabic'][selectedSubcategoryIndex!],
                        'basePrice': double.parse(priceController.text),
                        'commission': double.parse(commissionController.text),
                        'vat': double.parse(vatController.text),
                        'isActive': true,
                      });
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Service added successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B5B9A),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditCategoryDialog(Map<String, dynamic> category) {
    final nameController = TextEditingController(text: category['name']);
    final nameArabicController = TextEditingController(text: category['nameArabic']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Category'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name (English)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.abc),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameArabicController,
                decoration: const InputDecoration(
                  labelText: 'Category Name (Arabic)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.language),
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && nameArabicController.text.isNotEmpty) {
                setState(() {
                  category['name'] = nameController.text;
                  category['nameArabic'] = nameArabicController.text;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Category updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B5B9A),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditSubcategoryDialog(Map<String, dynamic> category, int index) {
    final subcats = category['subcategories'] as List<String>;
    final subcatsArabic = category['subcategoriesArabic'] as List<String>;

    final nameController = TextEditingController(text: subcats[index]);
    final nameArabicController = TextEditingController(text: subcatsArabic[index]);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Subcategory'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Subcategory Name (English)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.abc),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameArabicController,
                decoration: const InputDecoration(
                  labelText: 'Subcategory Name (Arabic)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.language),
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && nameArabicController.text.isNotEmpty) {
                setState(() {
                  subcats[index] = nameController.text;
                  subcatsArabic[index] = nameArabicController.text;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Subcategory updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B5B9A),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditServiceDialog(Map<String, dynamic> service) {
    final nameController = TextEditingController(text: service['name']);
    final nameArabicController = TextEditingController(text: service['nameArabic']);
    final priceController = TextEditingController(text: service['basePrice'].toString());
    final commissionController = TextEditingController(text: service['commission'].toString());
    final vatController = TextEditingController(text: service['vat'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Service'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Service Name (English)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.abc),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameArabicController,
                decoration: const InputDecoration(
                  labelText: 'Service Name (Arabic)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.language),
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Base Price (SAR)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commissionController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Commission (%)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.percent),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: vatController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'VAT (%)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.receipt_long),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && nameArabicController.text.isNotEmpty) {
                setState(() {
                  service['name'] = nameController.text;
                  service['nameArabic'] = nameArabicController.text;
                  service['basePrice'] = double.parse(priceController.text);
                  service['commission'] = double.parse(commissionController.text);
                  service['vat'] = double.parse(vatController.text);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Service updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B5B9A),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String type, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $type'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ $type deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}