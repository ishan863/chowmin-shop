import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';
import '../../providers/cart_provider.dart';
import '../../config/routes.dart';
import '../../models/menu_item_model.dart';
import '../../models/cart_item_model.dart';

class CartScreenEnhanced extends StatefulWidget {
  const CartScreenEnhanced({Key? key}) : super(key: key);

  @override
  State<CartScreenEnhanced> createState() => _CartScreenEnhancedState();
}

class _CartScreenEnhancedState extends State<CartScreenEnhanced>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    
    // Bounce animation for buttons
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _animateButton() {
    _bounceController.forward().then((_) => _bounceController.reverse());
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: FadeInDown(
          duration: const Duration(milliseconds: 500),
          child: const Text('🛒 My Cart'),
        ),
        actions: [
          if (cartProvider.items.isNotEmpty)
            FadeInRight(
              duration: const Duration(milliseconds: 500),
              child: TextButton.icon(
                onPressed: () => _showClearCartDialog(context, cartProvider),
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                label: const Text(
                  'Clear',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: cartProvider.items.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: cartProvider.items.length,
                    itemBuilder: (context, index) {
                      final cartItem = cartProvider.items[index];
                      return FadeInUp(
                        duration: Duration(milliseconds: 300 + (index * 100)),
                        child: SlideInLeft(
                          duration: Duration(milliseconds: 400 + (index * 100)),
                          child: _buildCartItemCard(
                            context,
                            cartItem,
                            cartProvider,
                            index,
                            isDark,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _buildCartSummary(cartProvider, isDark),
              ],
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeIn(
            duration: const Duration(milliseconds: 800),
            child: Lottie.asset(
              'assets/animations/empty_cart.json',
              width: 250,
              height: 250,
              fit: BoxFit.contain,
              repeat: true,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.shopping_cart_outlined,
                  size: 120,
                  color: Colors.grey,
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            child: Text(
              'Your Cart is Empty!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 12),
          FadeInUp(
            duration: const Duration(milliseconds: 800),
            delay: const Duration(milliseconds: 200),
            child: Text(
              'Add delicious items from our menu',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          FadeInUp(
            duration: const Duration(milliseconds: 800),
            delay: const Duration(milliseconds: 400),
            child: ElasticIn(
              duration: const Duration(milliseconds: 1000),
              child: ElevatedButton.icon(
                onPressed: () => Get.back<dynamic>(),
                icon: const Icon(Icons.restaurant_menu),
                label: const Text('Browse Menu'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(
    BuildContext context,
    CartItem cartItem,
    CartProvider cartProvider,
    int index,
    bool isDark,
  ) {
    return Dismissible(
      key: Key(cartItem.menuItem.id ?? ''),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        cartProvider.removeItem(cartItem.menuItem.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${cartItem.menuItem.name} removed from cart'),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () {
                cartProvider.addItem(cartItem.menuItem);
              },
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete_forever,
          color: Colors.white,
          size: 32,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              // Item Image with Hero Animation
              Hero(
                tag: 'cart_item_${cartItem.menuItem.id}',
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(16),
                    ),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: cartItem.menuItem.imageUrl ?? '',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.restaurant, size: 40),
                    ),
                  ),
                ),
              ),
              
              // Item Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Name and Veg/Non-Veg indicator
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              cartItem.menuItem.name ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: (cartItem.menuItem.isVeg ?? true)
                                  ? Colors.green
                                  : Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.circle,
                              size: 8,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      // Price
                      Text(
                        '₹${cartItem.menuItem.price}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Quantity Controls with Animation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Decrease Button
                                _buildQuantityButton(
                                  icon: Icons.remove,
                                  onPressed: () {
                                    _animateButton();
                                    if (cartItem.quantity > 1) {
                                      cartProvider.updateQuantity(
                                        cartItem.menuItem.id!,
                                        cartItem.quantity - 1,
                                      );
                                    } else {
                                      cartProvider.removeItem(
                                        cartItem.menuItem.id!,
                                      );
                                    }
                                  },
                                ),
                                
                                // Quantity Display with Animation
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  transitionBuilder: (child, animation) {
                                    return ScaleTransition(
                                      scale: animation,
                                      child: child,
                                    );
                                  },
                                  child: Container(
                                    key: ValueKey(cartItem.quantity),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      '${cartItem.quantity}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                ),
                                
                                // Increase Button
                                _buildQuantityButton(
                                  icon: Icons.add,
                                  onPressed: () {
                                    _animateButton();
                                    cartProvider.updateQuantity(
                                      cartItem.menuItem.id!,
                                      cartItem.quantity + 1,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          
                          // Total Price with Animation
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: Text(
                              key: ValueKey(cartItem.totalPrice),
                              '₹${cartItem.totalPrice.toStringAsFixed(0)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
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
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 20,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildCartSummary(CartProvider cartProvider, bool isDark) {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bill Details
              _buildBillRow('Subtotal', cartProvider.subtotal),
              _buildBillRow('Delivery Charges', cartProvider.deliveryCharges),
              _buildBillRow('GST (5%)', cartProvider.gstAmount),
              if (cartProvider.discount > 0)
                _buildBillRow('Discount', -cartProvider.discount,
                    isDiscount: true),
              const Divider(height: 24, thickness: 1),
              
              // Total Amount with Pulsing Animation
              Pulse(
                infinite: true,
                duration: const Duration(seconds: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount',
                      style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    Text(
                      '₹${cartProvider.totalAmount.toStringAsFixed(0)}',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Proceed to Checkout Button with Animation
              ScaleTransition(
                scale: _bounceAnimation,
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _animateButton();
                      Get.toNamed<dynamic>(AppRoutes.checkout);
                    },
                    icon: const Icon(Icons.payment, size: 24),
                    label: const Text(
                      'Proceed to Checkout',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBillRow(String label, double amount, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          Text(
            '${isDiscount ? '-' : ''}₹${amount.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDiscount ? Colors.green : null,
                ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, CartProvider cartProvider) {
    showDialog<void>(
      context: context,
      builder: (context) => ZoomIn(
        duration: const Duration(milliseconds: 300),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Clear Cart?'),
          content: const Text(
            'Are you sure you want to remove all items from your cart?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                cartProvider.clearCart();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Cart cleared successfully'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Clear All'),
            ),
          ],
        ),
      ),
    );
  }
}
