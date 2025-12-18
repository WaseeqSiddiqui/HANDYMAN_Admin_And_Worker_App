import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/utils/admin_translations.dart';
import '/widgets/bilingual_text.dart';
import '/services/service_management_service.dart';
import '/models/service_model.dart';
import '/models/service_category_model.dart';

class ServiceManagementScreen extends StatefulWidget {
  const ServiceManagementScreen({super.key});

  @override
  State<ServiceManagementScreen> createState() =>
      _ServiceManagementScreenState();
}

class _ServiceManagementScreenState extends State<ServiceManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _serviceManager = ServiceManagementService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _serviceManager.addListener(_onServiceDataChanged);
  }

  void _onServiceDataChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _serviceManager.removeListener(_onServiceDataChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: BilingualText(
          // ✅ Bilingual app bar title
          english: AdminTranslations.split(
            AdminTranslations.serviceManagement,
          )[0],
          arabic: AdminTranslations.split(
            AdminTranslations.serviceManagement,
          )[1],
          englishStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          arabicStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              child: BilingualText(
                // ✅ Bilingual tab
                english: AdminTranslations.split(
                  AdminTranslations.categories,
                )[0],
                arabic: AdminTranslations.split(
                  AdminTranslations.categories,
                )[1],
                englishStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                arabicStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Tab(
              child: BilingualText(
                // ✅ Bilingual tab
                english: AdminTranslations.split(
                  AdminTranslations.subcategories,
                )[0],
                arabic: AdminTranslations.split(
                  AdminTranslations.subcategories,
                )[1],
                englishStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                arabicStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Tab(
              child: BilingualText(
                // ✅ Bilingual tab
                english: AdminTranslations.split(AdminTranslations.services)[0],
                arabic: AdminTranslations.split(AdminTranslations.services)[1],
                englishStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                arabicStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
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
        backgroundColor: const Color(0xFF3B82F6), // Updated to deep purple
        icon: const Icon(Icons.add, color: Colors.white),
        label: BilingualText(
          // ✅ Bilingual FAB label
          english: 'Add New',
          arabic: 'إضافة جديد',
          englishStyle: const TextStyle(color: Colors.white, fontSize: 14),
          arabicStyle: const TextStyle(color: Colors.white, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildCategoriesTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final categories = _serviceManager.getAllCategories();

    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: textColor.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            BilingualText(
              english: 'No categories yet',
              arabic: 'لا توجد فئات حتى الآن',
              englishStyle: TextStyle(
                fontSize: 18,
                color: textColor.withOpacity(0.6),
              ),
              arabicStyle: TextStyle(
                fontSize: 16,
                color: textColor.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          color: cardColor,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(
                  0xFF005DFF,
                ).withOpacity(0.1), // Updated to deep purple
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIconData(category.icon),
                color: const Color(0xFF005DFF),
              ), // Updated to deep purple
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                Text(
                  category.nameArabic,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: BilingualText(
                english: '${category.subcategories.length} subcategories',
                arabic: '${category.subcategories.length} فئة فرعية',
                englishStyle: TextStyle(color: textColor.withOpacity(0.6)),
                arabicStyle: TextStyle(color: textColor.withOpacity(0.6)),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: Color(0xFF3B82F6),
                  ), // Updated to deep purple
                  onPressed: () => _showEditCategoryDialog(category),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDeleteCategory(category),
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
    final categories = _serviceManager.getAllCategories();

    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.list_alt_outlined,
              size: 64,
              color: textColor.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            BilingualText(
              english: 'No categories available',
              arabic: 'لا توجد فئات متاحة',
              englishStyle: TextStyle(
                fontSize: 18,
                color: textColor.withOpacity(0.6),
              ),
              arabicStyle: TextStyle(
                fontSize: 16,
                color: textColor.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, catIndex) {
        final category = categories[catIndex];

        return Card(
          color: cardColor,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  category.nameArabic,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            children: category.subcategories.isEmpty
                ? [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: BilingualText(
                        english: 'No subcategories',
                        arabic: 'لا توجد فئات فرعية',
                        englishStyle: TextStyle(
                          color: textColor.withOpacity(0.5),
                        ),
                        arabicStyle: TextStyle(
                          color: textColor.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ]
                : List.generate(category.subcategories.length, (index) {
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.subcategories[index],
                            style: TextStyle(color: textColor),
                          ),
                          Text(
                            category.subcategoriesArabic[index],
                            style: TextStyle(
                              fontSize: 12,
                              color: textColor.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Color(0xFF3B82F6),
                              size: 20,
                            ), // Updated to deep purple
                            onPressed: () =>
                                _showEditSubcategoryDialog(category, index),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 20,
                            ),
                            onPressed: () =>
                                _confirmDeleteSubcategory(category, index),
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
    final services = _serviceManager.getAllServices();

    if (services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.room_service_outlined,
              size: 64,
              color: textColor.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            BilingualText(
              english: 'No services yet',
              arabic: 'لا توجد خدمات حتى الآن',
              englishStyle: TextStyle(
                fontSize: 18,
                color: textColor.withOpacity(0.6),
              ),
              arabicStyle: TextStyle(
                fontSize: 16,
                color: textColor.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return Card(
          color: cardColor,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
                            service.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: textColor,
                            ),
                          ),
                          Text(
                            service.nameArabic,
                            style: TextStyle(
                              fontSize: 14,
                              color: textColor.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            service.subcategory.isNotEmpty
                                ? '${service.category} > ${service.subcategory}'
                                : service.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: textColor.withOpacity(0.6),
                            ),
                          ),
                          Text(
                            service.subcategoryArabic.isNotEmpty
                                ? '${service.categoryArabic} > ${service.subcategoryArabic}'
                                : service.categoryArabic,
                            style: TextStyle(
                              fontSize: 11,
                              color: textColor.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: service.isActive,
                      onChanged: (value) {
                        _serviceManager.toggleServiceStatus(service.id);
                      },
                      activeColor: const Color(
                        0xFF005DFF,
                      ), // Updated to deep purple
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoChip(
                        'Price',
                        'SAR ${service.basePrice.toStringAsFixed(0)}',
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoChip(
                        'Commission',
                        '${service.commission.toStringAsFixed(0)}%',
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoChip(
                        'VAT',
                        '${service.vat.toStringAsFixed(0)}%',
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
                      label: Text(
                        AdminTranslations.split(AdminTranslations.editBtn)[0],
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(
                          0xFF3B82F6,
                        ), // Updated to deep purple
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _confirmDeleteService(service),
                      icon: const Icon(Icons.delete, size: 18),
                      label: Text(
                        AdminTranslations.split(AdminTranslations.deleteBtn)[0],
                      ),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
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
        title: Text(AdminTranslations.split(AdminTranslations.addCategory)[0]),
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
            child: Text(
              AdminTranslations.split(AdminTranslations.cancelBtn)[0],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  nameArabicController.text.isNotEmpty) {
                final newCategory = ServiceCategory(
                  id: _serviceManager.generateCategoryId(),
                  nameEnglish: nameController.text, // Updated constructor
                  nameArabic: nameArabicController.text,
                  descriptionEnglish: '', // Added required field
                  descriptionArabic: '', // Added required field
                  basePrice: 0.0, // Added required field
                  icon:
                      "category", // ServiceCategory expects String or null, using string
                  subcategories: [],
                  subcategoriesArabic: [],
                );

                if (await _serviceManager.addCategory(newCategory)) {
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Category added successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(
                0xFF3B82F6,
              ), // Updated to deep purple
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddSubcategoryDialog() {
    final categories = _serviceManager.getAllCategories();

    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please add a category first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String? selectedCategoryId;
    final nameController = TextEditingController();
    final nameArabicController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            AdminTranslations.split(AdminTranslations.addSubcategory)[0],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Select Category',
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat.id,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(cat.name),
                          Text(
                            cat.nameArabic,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedCategoryId = value;
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
              child: Text(
                AdminTranslations.split(AdminTranslations.cancelBtn)[0],
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedCategoryId != null &&
                    nameController.text.isNotEmpty &&
                    nameArabicController.text.isNotEmpty) {
                  final success = await _serviceManager
                      .addSubcategoryToCategory(
                        selectedCategoryId!,
                        nameController.text,
                        nameArabicController.text,
                      );

                  if (success) {
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Subcategory added successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                  0xFF3B82F6,
                ), // Updated to deep purple
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
    final categories = _serviceManager.getAllCategories();

    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please add categories first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final nameController = TextEditingController();
    final nameArabicController = TextEditingController();
    final priceController = TextEditingController();
    final commissionController = TextEditingController();
    final vatController = TextEditingController();
    String? selectedCategoryId;
    int? selectedSubcategoryIndex;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final selectedCat = selectedCategoryId != null
              ? _serviceManager.getCategoryById(selectedCategoryId!)
              : null;

          return AlertDialog(
            title: Text(
              AdminTranslations.split(AdminTranslations.addService)[0],
            ),
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
                    value: selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: categories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat.id,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(cat.name),
                            Text(
                              cat.nameArabic,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedCategoryId = value;
                        selectedSubcategoryIndex = null;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  if (selectedCat != null)
                    selectedCat.subcategories.isNotEmpty
                        ? DropdownButtonFormField<int>(
                            value: selectedSubcategoryIndex,
                            decoration: const InputDecoration(
                              labelText: 'Subcategory',
                              border: OutlineInputBorder(),
                            ),
                            items: List.generate(
                              selectedCat.subcategories.length,
                              (index) {
                                return DropdownMenuItem<int>(
                                  value: index,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(selectedCat.subcategories[index]),
                                      Text(
                                        selectedCat.subcategoriesArabic[index],
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
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
                          )
                        : const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "No subcategories available",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Base Price (SAR)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: commissionController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Commission (%)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.percent),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: vatController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
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
                child: Text(
                  AdminTranslations.split(AdminTranslations.cancelBtn)[0],
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Validate empty fields
                  bool isSubcategoryValid = true;
                  if (selectedCat != null &&
                      selectedCat.subcategories.isNotEmpty) {
                    if (selectedSubcategoryIndex == null) {
                      isSubcategoryValid = false;
                    }
                  }

                  if (nameController.text.isEmpty ||
                      nameArabicController.text.isEmpty ||
                      selectedCategoryId == null ||
                      !isSubcategoryValid ||
                      priceController.text.isEmpty ||
                      commissionController.text.isEmpty ||
                      vatController.text.isEmpty ||
                      selectedCat == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('⚠️ Please fill all fields'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  // Safe Parsing & Validation
                  final price = double.tryParse(priceController.text);
                  final commission = double.tryParse(commissionController.text);
                  final vat = double.tryParse(vatController.text);

                  if (price == null || price <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          '❌ Invalid Price. Must be greater than 0.',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (commission == null ||
                      commission < 0 ||
                      commission > 100) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          '❌ Invalid Commission. Must be between 0 and 100.',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (vat == null || vat < 0 || vat > 100) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          '❌ Invalid VAT. Must be between 0 and 100.',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Create Service
                  final hasSubcategories =
                      selectedCat.subcategories.isNotEmpty &&
                      selectedSubcategoryIndex != null;

                  final subId = hasSubcategories
                      ? '${selectedCategoryId}_$selectedSubcategoryIndex'
                      : '';
                  final subName = hasSubcategories
                      ? selectedCat.subcategories[selectedSubcategoryIndex!]
                      : '';
                  final subNameAr = hasSubcategories
                      ? selectedCat
                            .subcategoriesArabic[selectedSubcategoryIndex!]
                      : '';

                  final newService = Service(
                    id: _serviceManager.generateServiceId(),
                    name: nameController.text,
                    nameArabic: nameArabicController.text,
                    categoryId: selectedCategoryId!,
                    category: selectedCat.nameEnglish,
                    categoryArabic: selectedCat.nameArabic,
                    subcategoryId: subId,
                    subcategory: subName,
                    subcategoryArabic: subNameAr,
                    basePrice: price,
                    commission: commission,
                    vat: vat,
                    isActive: true,
                  );

                  if (await _serviceManager.addService(newService)) {
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Service added successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('❌ Failed to add service'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF3B82F6,
                  ), // Updated to deep purple
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

  void _showEditCategoryDialog(ServiceCategory category) {
    final nameController = TextEditingController(
      text: category.nameEnglish,
    ); // Fix getter
    final nameArabicController = TextEditingController(
      text: category.nameArabic,
    );

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
            child: Text(
              AdminTranslations.split(AdminTranslations.cancelBtn)[0],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  nameArabicController.text.isNotEmpty) {
                final updatedCategory = category.copyWith(
                  nameEnglish: nameController.text, // Fix parameter
                  nameArabic: nameArabicController.text,
                );

                final success = await _serviceManager.updateCategory(
                  category.id,
                  updatedCategory,
                );

                if (success) {
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Category updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(
                0xFF3B82F6,
              ), // Updated to deep purple
              foregroundColor: Colors.white,
            ),
            child: Text(AdminTranslations.split(AdminTranslations.saveBtn)[0]),
          ),
        ],
      ),
    );
  }

  void _showEditSubcategoryDialog(ServiceCategory category, int index) {
    final nameController = TextEditingController(
      text: category.subcategories[index],
    );
    final nameArabicController = TextEditingController(
      text: category.subcategoriesArabic[index],
    );

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
            child: Text(
              AdminTranslations.split(AdminTranslations.cancelBtn)[0],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  nameArabicController.text.isNotEmpty) {
                final success = await _serviceManager.updateSubcategory(
                  category.id,
                  index,
                  nameController.text,
                  nameArabicController.text,
                );

                if (success) {
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Subcategory updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(
                0xFF3B82F6,
              ), // Updated to deep purple
              foregroundColor: Colors.white,
            ),
            child: Text(AdminTranslations.split(AdminTranslations.saveBtn)[0]),
          ),
        ],
      ),
    );
  }

  void _showEditServiceDialog(Service service) {
    final nameController = TextEditingController(text: service.name);
    final nameArabicController = TextEditingController(
      text: service.nameArabic,
    );
    final priceController = TextEditingController(
      text: service.basePrice.toString(),
    );
    final commissionController = TextEditingController(
      text: service.commission.toString(),
    );
    final vatController = TextEditingController(text: service.vat.toString());

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
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Base Price (SAR)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commissionController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Commission (%)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.percent),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: vatController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
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
            child: Text(
              AdminTranslations.split(AdminTranslations.cancelBtn)[0],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  nameArabicController.text.isEmpty ||
                  priceController.text.isEmpty ||
                  commissionController.text.isEmpty ||
                  vatController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('⚠️ Please fill all fields'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              // Safe Parsing & Validation
              final price = double.tryParse(priceController.text);
              final commission = double.tryParse(commissionController.text);
              final vat = double.tryParse(vatController.text);

              if (price == null || price <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('❌ Invalid Price. Must be greater than 0.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (commission == null || commission < 0 || commission > 100) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      '❌ Invalid Commission. Must be between 0 and 100.',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (vat == null || vat < 0 || vat > 100) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('❌ Invalid VAT. Must be between 0 and 100.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final updatedService = service.copyWith(
                name: nameController.text,
                nameArabic: nameArabicController.text,
                basePrice: price,
                commission: commission,
                vat: vat,
              );

              if (await _serviceManager.updateService(
                service.id,
                updatedService,
              )) {
                if (!context.mounted) return;
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
              backgroundColor: const Color(
                0xFF3B82F6,
              ), // Updated to deep purple
              foregroundColor: Colors.white,
            ),
            child: Text(AdminTranslations.split(AdminTranslations.saveBtn)[0]),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCategory(ServiceCategory category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          'Are you sure you want to delete "${category.name}"?\n\nThis will also affect all related services.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AdminTranslations.split(AdminTranslations.cancelBtn)[0],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await _serviceManager.deleteCategory(category.id);
              if (success) {
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Category deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      '❌ Cannot delete category - services are using it',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              AdminTranslations.split(AdminTranslations.deleteBtn)[0],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSubcategory(ServiceCategory category, int index) {
    final subcategoryName = category.subcategories[index];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subcategory'),
        content: Text('Are you sure you want to delete "$subcategoryName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AdminTranslations.split(AdminTranslations.cancelBtn)[0],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await _serviceManager.deleteSubcategory(
                category.id,
                index,
              );
              if (success) {
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Subcategory deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      '❌ Cannot delete subcategory - services are using it',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              AdminTranslations.split(AdminTranslations.deleteBtn)[0],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteService(Service service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text('Are you sure you want to delete "${service.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AdminTranslations.split(AdminTranslations.cancelBtn)[0],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (await _serviceManager.deleteService(service.id)) {
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Service deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              AdminTranslations.split(AdminTranslations.deleteBtn)[0],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get IconData from string name
  IconData _getIconData(String? iconName) {
    if (iconName == null) return Icons.category;

    switch (iconName.toLowerCase()) {
      case 'ac_unit':
      case 'ac services':
        return Icons.ac_unit;
      case 'kitchen':
      case 'appliances':
        return Icons.kitchen;
      case 'plumbing':
        return Icons.plumbing;
      case 'cleaning':
        return Icons.cleaning_services;
      case 'electrical':
        return Icons.electrical_services;
      case 'painting':
        return Icons.format_paint;
      case 'carpentry':
        return Icons.carpenter;
      case 'moving':
        return Icons.local_shipping;
      case 'pest control':
        return Icons.pest_control;
      default:
        return Icons.category;
    }
  }
}
