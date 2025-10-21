import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import 'package:animate_do/animate_do.dart';

class Address {
  final String id;
  final String name;
  final String addressLine;
  final String city;
  final String pincode;
  final String phone;
  final bool isDefault;

  Address({
    required this.id,
    required this.name,
    required this.addressLine,
    required this.city,
    required this.pincode,
    required this.phone,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'addressLine': addressLine,
        'city': city,
        'pincode': pincode,
        'phone': phone,
        'isDefault': isDefault,
      };

  factory Address.fromMap(Map<String, dynamic> map) => Address(
        id: map['id']?.toString() ?? '',
        name: map['name']?.toString() ?? '',
        addressLine: map['addressLine']?.toString() ?? '',
        city: map['city']?.toString() ?? '',
        pincode: map['pincode']?.toString() ?? '',
        phone: map['phone']?.toString() ?? '',
        isDefault: map['isDefault'] == true,
      );
}

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Address> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.phone;

      if (userId != null) {
        final doc = await _firestore.collection('users').doc(userId).get();
        if (doc.exists && doc.data()?['addresses'] != null) {
          final addressList = doc.data()!['addresses'] as List<dynamic>;
          setState(() {
            _addresses = addressList.map((a) => Address.fromMap(a as Map<String, dynamic>)).toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading addresses: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAddresses() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.phone;

      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({
          'addresses': _addresses.map((a) => a.toMap()).toList(),
        });
      }
    } catch (e) {
      debugPrint('Error saving addresses: $e');
    }
  }

  void _showAddAddressDialog({Address? address}) {
    final nameController = TextEditingController(text: address?.name);
    final addressController = TextEditingController(text: address?.addressLine);
    final cityController = TextEditingController(text: address?.city);
    final pincodeController = TextEditingController(text: address?.pincode);
    final phoneController = TextEditingController(text: address?.phone);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(address == null ? 'Add Address' : 'Edit Address'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    prefixIcon: Icon(Icons.home),
                  ),
                  maxLines: 2,
                  validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: cityController,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: pincodeController,
                  decoration: const InputDecoration(
                    labelText: 'Pincode',
                    prefixIcon: Icon(Icons.pin_drop),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  validator: (v) => v?.length != 6 ? 'Enter 6-digit pincode' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  validator: (v) => v?.length != 10 ? 'Enter 10-digit phone' : null,
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
              if (formKey.currentState!.validate()) {
                final newAddress = Address(
                  id: address?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text.trim(),
                  addressLine: addressController.text.trim(),
                  city: cityController.text.trim(),
                  pincode: pincodeController.text.trim(),
                  phone: phoneController.text.trim(),
                  isDefault: address?.isDefault ?? _addresses.isEmpty,
                );

                setState(() {
                  if (address == null) {
                    _addresses.add(newAddress);
                  } else {
                    final index = _addresses.indexWhere((a) => a.id == address.id);
                    if (index != -1) {
                      _addresses[index] = newAddress;
                    }
                  }
                });

                await _saveAddresses();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(address == null ? 'Address added!' : 'Address updated!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteAddress(Address address) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _addresses.removeWhere((a) => a.id == address.id);
      });
      await _saveAddresses();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Address deleted!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _setDefaultAddress(Address address) async {
    setState(() {
      _addresses = _addresses.map((a) {
        return Address(
          id: a.id,
          name: a.name,
          addressLine: a.addressLine,
          city: a.city,
          pincode: a.pincode,
          phone: a.phone,
          isDefault: a.id == address.id,
        );
      }).toList();
    });
    await _saveAddresses();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Default address updated!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Addresses'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAddressDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Address'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _addresses.length,
                  itemBuilder: (context, index) {
                    final address = _addresses[index];
                    return FadeInUp(
                      delay: Duration(milliseconds: index * 100),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: address.isDefault
                              ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
                              : BorderSide.none,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Icon(
                            address.isDefault ? Icons.home : Icons.location_on,
                            color: address.isDefault ? Theme.of(context).primaryColor : null,
                            size: 32,
                          ),
                          title: Row(
                            children: [
                              Text(
                                address.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              if (address.isDefault) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Default',
                                    style: TextStyle(color: Colors.white, fontSize: 10),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${address.addressLine}\n${address.city}, ${address.pincode}\n${address.phone}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'edit', child: Text('Edit')),
                              if (!address.isDefault)
                                const PopupMenuItem(value: 'default', child: Text('Set as Default')),
                              const PopupMenuItem(value: 'delete', child: Text('Delete')),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showAddAddressDialog(address: address);
                              } else if (value == 'default') {
                                _setDefaultAddress(address);
                              } else if (value == 'delete') {
                                _deleteAddress(address);
                              }
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeIn(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 100, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No saved addresses',
              style: TextStyle(fontSize: 20, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Add an address to get started',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
