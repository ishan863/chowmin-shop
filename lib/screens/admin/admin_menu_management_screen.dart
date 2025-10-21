import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/menu_provider.dart';
import '../../models/menu_item_model.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AdminMenuManagementScreen extends StatefulWidget {
  const AdminMenuManagementScreen({super.key});

  @override
  State<AdminMenuManagementScreen> createState() => _AdminMenuManagementScreenState();
}

class _AdminMenuManagementScreenState extends State<AdminMenuManagementScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  Future<void> _loadMenuItems() async {
    setState(() => _isLoading = true);
    final menuProvider = Provider.of<MenuProvider>(context, listen: false);
    await menuProvider.fetchMenuItems();
    setState(() => _isLoading = false);
  }

  List<MenuItem> _getFilteredItems(List<MenuItem> items) {
    var filtered = items;
    
    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered.where((item) => item.category == _selectedCategory).toList();
    }
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        final query = _searchQuery.toLowerCase();
        return item.name.toLowerCase().contains(query) ||
               item.description.toLowerCase().contains(query);
      }).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);
    final items = _getFilteredItems(menuProvider.menuItems);
    final categories = ['All', ...menuProvider.categories];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Management'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMenuItems,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search menu items...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          
          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = category);
                    },
                    selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    checkmarkColor: Theme.of(context).primaryColor,
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Menu Items Grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : items.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadMenuItems,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.68,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            return FadeInUp(
                              duration: Duration(milliseconds: 300 + (index * 50)),
                              child: _buildMenuItemCard(items[index]),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            child: Icon(
              Icons.restaurant_menu,
              size: 100,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            child: Text(
              'No menu items found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 8),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Text(
              _searchQuery.isNotEmpty
                  ? 'Try a different search'
                  : 'Add your first menu item!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemCard(MenuItem item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showAddEditDialog(item: item),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Builder(
                    builder: (context) {
                      print('Admin - Loading image for ${item.name}: "${item.imageUrl}"');
                      print('Admin - ImageUrl isEmpty: ${item.imageUrl.isEmpty}');
                      
                      if (item.imageUrl.isEmpty) {
                        return Container(
                          height: 120,
                          color: Colors.grey[300],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.restaurant_menu, size: 40, color: Colors.grey[600]),
                              const SizedBox(height: 4),
                              Text(
                                'No Image URL',
                                style: TextStyle(color: Colors.grey[600], fontSize: 10),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return CachedNetworkImage(
                        imageUrl: item.imageUrl,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 120,
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) {
                          print('Admin - Image error for ${item.name}: $error');
                          return Container(
                            height: 120,
                            color: Colors.red[100],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, size: 30, color: Colors.red[700]),
                                const SizedBox(height: 4),
                                Text(
                                  'Error Loading',
                                  style: TextStyle(color: Colors.red[700], fontSize: 10),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                
                // VEG/NON-VEG Badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.circle,
                      size: 12,
                      color: item.isVeg ? Colors.green : Colors.red,
                    ),
                  ),
                ),
                
                // Available Toggle
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.isAvailable ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.isAvailable ? 'Available' : 'Unavailable',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${item.price}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 16),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => _showAddEditDialog(item: item),
                            ),
                            const SizedBox(width: 2),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 16),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              color: Colors.red,
                              onPressed: () => _deleteItem(item),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEditDialog({MenuItem? item}) {
    final isEdit = item != null;
    final nameController = TextEditingController(text: item?.name ?? '');
    final descriptionController = TextEditingController(text: item?.description ?? '');
    final priceController = TextEditingController(text: item?.price.toString() ?? '');
    final imageUrlController = TextEditingController(text: item?.imageUrl ?? '');
    String selectedCategory = item?.category ?? 'Chowmin';
    bool isVeg = item?.isVeg ?? true;
    bool isAvailable = item?.isAvailable ?? true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Menu Item' : 'Add Menu Item'),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(),
                    prefixText: '₹',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Chowmin', 'Noodles', 'Rice', 'Starters', 'Beverages']
                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedCategory = value!);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Image URL',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Vegetarian'),
                  value: isVeg,
                  onChanged: (value) {
                    setState(() => isVeg = value);
                  },
                ),
                SwitchListTile(
                  title: const Text('Available'),
                  value: isAvailable,
                  onChanged: (value) {
                    setState(() => isAvailable = value);
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || priceController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all required fields')),
                );
                return;
              }

              final price = double.tryParse(priceController.text);
              if (price == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid price')),
                );
                return;
              }

              Navigator.pop(context);

              final itemData = {
                'name': nameController.text,
                'description': descriptionController.text,
                'price': price,
                'category': selectedCategory,
                'isVeg': isVeg,
                'isAvailable': isAvailable,
                'imageUrl': imageUrlController.text.isEmpty
                    ? 'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=400'
                    : imageUrlController.text,
              };

              try {
                if (isEdit) {
                  await FirebaseFirestore.instance
                      .collection('menu_items')
                      .doc(item.id)
                      .update(itemData);
                } else {
                  await FirebaseFirestore.instance
                      .collection('menu_items')
                      .add(itemData);
                }

                await _loadMenuItems();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEdit ? 'Item updated!' : 'Item added!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(isEdit ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _deleteItem(MenuItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              try {
                await FirebaseFirestore.instance
                    .collection('menu_items')
                    .doc(item.id)
                    .delete();

                await _loadMenuItems();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Item deleted!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
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
