import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import 'package:animate_do/animate_do.dart';

class AdminOrderManagementScreen extends StatefulWidget {
  const AdminOrderManagementScreen({super.key});

  @override
  State<AdminOrderManagementScreen> createState() => _AdminOrderManagementScreenState();
}

class _AdminOrderManagementScreenState extends State<AdminOrderManagementScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    await orderProvider.fetchAllOrders();
    setState(() => _isLoading = false);
  }

  List<OrderModel> _getFilteredOrders(List<OrderModel> orders) {
    var filtered = orders;
    
    // Filter by status
    if (_selectedFilter != 'All') {
      filtered = filtered.where((order) {
        switch (_selectedFilter) {
          case 'Pending':
            return order.orderStatus == OrderStatus.placed;
          case 'Preparing':
            return order.orderStatus == OrderStatus.preparing ||
                   order.orderStatus == OrderStatus.accepted;
          case 'Ready':
            return order.orderStatus == OrderStatus.ready;
          case 'Delivered':
            return order.orderStatus == OrderStatus.delivered;
          default:
            return true;
        }
      }).toList();
    }
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((order) {
        final query = _searchQuery.toLowerCase();
        return order.id.toLowerCase().contains(query) ||
               order.userName.toLowerCase().contains(query) ||
               order.userPhone.contains(query);
      }).toList();
    }
    
    return filtered;
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
        return Colors.orange;
      case OrderStatus.accepted:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.purple;
      case OrderStatus.ready:
        return Colors.teal;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
        return 'Placed';
      case OrderStatus.accepted:
        return 'Accepted';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final orders = _getFilteredOrders(orderProvider.orders);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
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
                hintText: 'Search by order ID, name, or phone...',
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
          
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('All'),
                const SizedBox(width: 8),
                _buildFilterChip('Pending'),
                const SizedBox(width: 8),
                _buildFilterChip('Preparing'),
                const SizedBox(width: 8),
                _buildFilterChip('Ready'),
                const SizedBox(width: 8),
                _buildFilterChip('Delivered'),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Orders List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : orders.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadOrders,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: orders.length,
                          itemBuilder: (context, index) {
                            return FadeInUp(
                              duration: Duration(milliseconds: 300 + (index * 50)),
                              child: _buildOrderCard(orders[index]),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedFilter = label);
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            child: Icon(
              Icons.receipt_long_outlined,
              size: 100,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            child: Text(
              'No orders found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 8),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Text(
              _searchQuery.isNotEmpty
                  ? 'Try a different search'
                  : 'Orders will appear here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final dateFormat = DateFormat('MMM dd, hh:mm a');
    final timeAgo = _getTimeAgo(order.createdAt);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showOrderDetails(order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Order ID
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#${order.id?.substring(0, 8) ?? 'N/A'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          timeAgo,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.orderStatus).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(order.orderStatus),
                      style: TextStyle(
                        color: _getStatusColor(order.orderStatus),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              
              const Divider(height: 24),
              
              // Customer Info
              Row(
                children: [
                  Icon(Icons.person, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.userName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.phone, size: 20),
                    onPressed: () => _makePhoneCall(order.userPhone),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.green.withOpacity(0.1),
                      foregroundColor: Colors.green,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Items and Total
              Row(
                children: [
                  Icon(Icons.restaurant_menu, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text('${order.items.length} item${order.items.length > 1 ? 's' : ''}'),
                  const Spacer(),
                  Text(
                    '₹${order.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showOrderDetails(order),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('View Details'),
                    ),
                  ),
                  if (order.orderStatus != OrderStatus.delivered &&
                      order.orderStatus != OrderStatus.cancelled) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _updateOrderStatus(order),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Update Status'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd').format(dateTime);
    }
  }

  void _makePhoneCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone dialer')),
        );
      }
    }
  }

  void _showOrderDetails(OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
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
              const SizedBox(height: 20),
              
              // Title and Call Button
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Order #${order.id.substring(0, 12)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _makePhoneCall(order.userPhone),
                    icon: const Icon(Icons.phone, size: 18),
                    label: const Text('Call'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.orderStatus).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 12,
                      color: _getStatusColor(order.orderStatus),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getStatusText(order.orderStatus),
                      style: TextStyle(
                        color: _getStatusColor(order.orderStatus),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Divider(height: 32),
              
              // Customer Details
              _buildSectionTitle('Customer Details'),
              _buildDetailRow('Name', order.userName),
              _buildDetailRow('Phone', order.userPhone),
              _buildDetailRow('Address', order.deliveryAddress ?? 'N/A'),
              if (order.specialInstructions != null && order.specialInstructions!.isNotEmpty)
                _buildDetailRow('Instructions', order.specialInstructions!),
              
              const Divider(height: 32),
              
              // Order Items
              _buildSectionTitle('Order Items'),
              const SizedBox(height: 12),
              ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: item.isVeg 
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            item.isVeg 
                                ? Icons.circle 
                                : Icons.circle,
                            size: 12,
                            color: item.isVeg 
                                ? Colors.green 
                                : Colors.red,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                'Qty: ${item.quantity}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '₹${item.price}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )),
              
              const Divider(height: 32),
              
              // Payment Details
              _buildSectionTitle('Payment Details'),
              _buildDetailRow('Payment Method', order.paymentMode == PaymentMode.payAtShop ? 'Pay at Shop' : 'Online'),
              _buildDetailRow('Payment Status', order.paymentStatus.name.toUpperCase()),
              if (order.transactionId != null)
                _buildDetailRow('Transaction ID', order.transactionId!),
              
              const Divider(height: 32),
              
              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    '₹${order.totalAmount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Update Status Button
              if (order.orderStatus != OrderStatus.delivered &&
                  order.orderStatus != OrderStatus.cancelled)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _updateOrderStatus(order);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Update Order Status'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
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
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _updateOrderStatus(OrderModel order) {
    final nextStatus = _getNextStatus(order.orderStatus);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Order Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current: ${_getStatusText(order.orderStatus)}'),
            const SizedBox(height: 8),
            Text(
              'Update to: ${_getStatusText(nextStatus)}?',
              style: TextStyle(
                color: _getStatusColor(nextStatus),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final orderProvider = Provider.of<OrderProvider>(context, listen: false);
              final success = await orderProvider.updateOrderStatus(
                order.id!,
                nextStatus,
              );
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Order status updated to ${_getStatusText(nextStatus)}'
                          : 'Failed to update order status',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
              
              await _loadOrders();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  OrderStatus _getNextStatus(OrderStatus currentStatus) {
    switch (currentStatus) {
      case OrderStatus.placed:
        return OrderStatus.accepted;
      case OrderStatus.accepted:
        return OrderStatus.preparing;
      case OrderStatus.preparing:
        return OrderStatus.ready;
      case OrderStatus.ready:
        return OrderStatus.delivered;
      default:
        return currentStatus;
    }
  }
}
