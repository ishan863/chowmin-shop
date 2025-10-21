import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:confetti/confetti.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'dart:developer' as developer;
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../config/routes.dart';
import '../../models/order_model.dart';
import 'payment_success_screen.dart';

class CheckoutScreenEnhanced extends StatefulWidget {
  const CheckoutScreenEnhanced({Key? key}) : super(key: key);

  @override
  State<CheckoutScreenEnhanced> createState() => _CheckoutScreenEnhancedState();
}

class _CheckoutScreenEnhancedState extends State<CheckoutScreenEnhanced>
    with TickerProviderStateMixin {
  late Razorpay _razorpay;
  late ConfettiController _confettiController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  final _couponController = TextEditingController();

  String selectedPaymentMethod = 'online'; // online, cod
  bool isProcessing = false;
  bool isCouponApplied = false;

  @override
  void initState() {
    super.initState();

    // Initialize Razorpay
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    // Confetti controller for success animation
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Shake animation for errors
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).chain(
      CurveTween(curve: Curves.elasticIn),
    ).animate(_shakeController);
  }

  @override
  void dispose() {
    _razorpay.clear();
    _confettiController.dispose();
    _shakeController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    developer.log('Payment Success: ${response.paymentId}');
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    await _createOrderWithSuccess(
      response.paymentId ?? 'RAZ${DateTime.now().millisecondsSinceEpoch}',
      'Razorpay',
      cartProvider.totalAmount,
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    developer.log('Payment Error: ${response.code} - ${response.message}');
    _shakeController.forward().then((_) => _shakeController.reverse());
    
    setState(() {
      isProcessing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Failed: ${response.message}'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    developer.log('External Wallet: ${response.walletName}');
  }

  Future<void> _createOrder(String? paymentId) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    final order = OrderModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: authProvider.currentUser?.id ?? '',
      userName: authProvider.currentUser?.name ?? 'Guest',
      userPhone: _phoneController.text,
      deliveryAddress: _addressController.text,
      items: cartProvider.items.map((item) => OrderItem(
        menuItemId: item.menuItem.id,
        name: item.menuItem.name,
        price: item.menuItem.price,
        quantity: item.quantity,
        isVeg: item.menuItem.isVeg,
      )).toList(),
      totalAmount: cartProvider.totalAmount,
      orderType: OrderType.homeDelivery,
      paymentMode: selectedPaymentMethod == 'Cash on Delivery' 
          ? PaymentMode.payAtShop 
          : PaymentMode.online,
      paymentStatus: selectedPaymentMethod == 'Cash on Delivery'
          ? PaymentStatus.pending
          : PaymentStatus.paid,
      orderStatus: OrderStatus.placed,
      transactionId: paymentId,
      specialInstructions: _notesController.text,
      createdAt: DateTime.now(),
    );

    try {
      await orderProvider.placeOrder(order);
      cartProvider.clearCart();

      setState(() {
        isProcessing = false;
      });

      // Show success dialog
      _showSuccessDialog(order.id);
    } catch (e) {
      setState(() {
        isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _createOrderWithSuccess(String transactionId, String paymentMethod, double amount) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    final order = OrderModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: authProvider.currentUser?.id ?? '',
      userName: authProvider.currentUser?.name ?? 'Guest',
      userPhone: _phoneController.text,
      deliveryAddress: _addressController.text,
      items: cartProvider.items.map((item) => OrderItem(
        menuItemId: item.menuItem.id,
        name: item.menuItem.name,
        price: item.menuItem.price,
        quantity: item.quantity,
        isVeg: item.menuItem.isVeg,
      )).toList(),
      totalAmount: cartProvider.totalAmount,
      orderType: OrderType.homeDelivery,
      paymentMode: PaymentMode.online,
      paymentStatus: PaymentStatus.paid,
      orderStatus: OrderStatus.placed,
      transactionId: transactionId,
      specialInstructions: _notesController.text,
      createdAt: DateTime.now(),
    );

    try {
      await orderProvider.placeOrder(order);
      cartProvider.clearCart();

      // Navigate to success screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (context) => PaymentSuccessScreen(
              orderId: order.id,
              amount: amount,
              paymentMethod: paymentMethod,
              transactionId: transactionId,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _processOrder() async {
    if (_addressController.text.isEmpty || _phoneController.text.isEmpty) {
      _shakeController.forward().then((_) => _shakeController.reverse());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isProcessing = true;
    });

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final totalAmount = cartProvider.totalAmount;

    if (selectedPaymentMethod == 'UPI Payment') {
      // UPI Payment - Show confirmation dialog
      _showUPIPaymentDialog(totalAmount);
    } else if (selectedPaymentMethod == 'online') {
      // Open Razorpay payment gateway
      var options = {
        'key': 'rzp_test_1DP5mmOlF5G5ag', // Replace with your Razorpay key
        'amount': (totalAmount * 100).toInt(), // Amount in paise
        'name': 'Rajeev Chowmin Center',
        'description': 'Order Payment',
        'prefill': {
          'contact': _phoneController.text,
          'email': 'customer@rajeevchowmin.com',
        },
        'theme': {
          'color': '#D32F2F',
        },
      };

      try {
        _razorpay.open(options);
      } catch (e) {
        setState(() {
          isProcessing = false;
        });
        developer.log('Razorpay Error: $e');
      }
    } else {
      // Cash on Delivery
      await _createOrder(null);
    }
  }

  void _showUPIPaymentDialog(double amount) {
    setState(() => isProcessing = false);
    
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.account_balance_wallet, color: Colors.green.shade700),
            ),
            const SizedBox(width: 12),
            const Text('UPI Payment'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pay the amount using UPI:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green),
              ),
              child: Column(
                children: [
                  const Text('UPI ID:', style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 8),
                  SelectableText(
                    '801885973@ybl',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Amount: ₹${amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'After payment, confirm below to verify',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.check_circle),
            label: const Text('I have paid'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed == true) {
        // Show verification dialog
        _showPaymentVerificationDialog(amount);
      }
    });
  }

  void _showPaymentVerificationDialog(double amount) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            const Text(
              'Verifying Payment...',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we confirm your payment',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    // Simulate payment verification (In production, verify with your backend)
    Future.delayed(const Duration(seconds: 3), () async {
      Navigator.pop(context); // Close verification dialog
      
      // Create order with UPI transaction ID
      final transactionId = 'UPI${DateTime.now().millisecondsSinceEpoch}';
      await _createOrderWithSuccess(transactionId, 'UPI Payment', amount);
    });
  }

  void _applyCoupon() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final couponCode = _couponController.text.trim();

    if (couponCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a coupon code')),
      );
      return;
    }

    cartProvider.applyCoupon(couponCode);

    setState(() {
      isCouponApplied = cartProvider.discount > 0;
    });

    if (isCouponApplied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Coupon applied! You saved ₹${cartProvider.discount.toStringAsFixed(0)}'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid coupon code'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessDialog(String orderId) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Stack(
        children: [
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [
                Colors.red,
                Colors.orange,
                Colors.yellow,
                Colors.green,
                Colors.blue,
              ],
              numberOfParticles: 30,
            ),
          ),

          // Success Dialog
          Center(
            child: ZoomIn(
              duration: const Duration(milliseconds: 500),
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Success Icon
                    ElasticIn(
                      duration: const Duration(milliseconds: 800),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Success Message
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      child: const Text(
                        'Order Placed Successfully!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Order ID
                    FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 200),
                      child: Text(
                        'Order ID: #$orderId',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Track Order Button
                    FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 400),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Get.offAllNamed<dynamic>(AppRoutes.home);
                            Get.toNamed<dynamic>(AppRoutes.orderTracking,
                                arguments: orderId);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Track Order'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Back to Home
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Get.offAllNamed<dynamic>(AppRoutes.home);
                      },
                      child: const Text('Back to Home'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
          child: const Text('💳 Checkout'),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              // Delivery Details Card
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                child: _buildSectionCard(
                  title: '📍 Delivery Details',
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _shakeAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(_shakeAnimation.value, 0),
                            child: child,
                          );
                        },
                        child: Column(
                          children: [
                            TextField(
                              controller: _addressController,
                              decoration: InputDecoration(
                                labelText: 'Delivery Address *',
                                prefixIcon: const Icon(Icons.location_on),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _phoneController,
                              decoration: InputDecoration(
                                labelText: 'Phone Number *',
                                prefixIcon: const Icon(Icons.phone),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _notesController,
                              decoration: InputDecoration(
                                labelText: 'Special Instructions (Optional)',
                                prefixIcon: const Icon(Icons.note),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Coupon Card
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                child: _buildSectionCard(
                  title: '🎫 Apply Coupon',
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _couponController,
                          decoration: InputDecoration(
                            hintText: 'Enter coupon code',
                            prefixIcon: const Icon(Icons.local_offer),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          textCapitalization: TextCapitalization.characters,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _applyCoupon,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Payment Method Card
              FadeInUp(
                duration: const Duration(milliseconds: 700),
                child: _buildSectionCard(
                  title: '💰 Payment Method',
                  child: Column(
                    children: [
                      _buildPaymentOption(
                        'UPI Payment',
                        'Pay via GooglePay, PhonePe, Paytm',
                        Icons.account_balance_wallet,
                        'upi',
                      ),
                      const SizedBox(height: 12),
                      _buildPaymentOption(
                        'Online Payment',
                        'Pay using Card, Net Banking',
                        Icons.payment,
                        'online',
                      ),
                      const SizedBox(height: 12),
                      _buildPaymentOption(
                        'Cash on Delivery',
                        'Pay when you receive',
                        Icons.money,
                        'cod',
                      ),
                      if (selectedPaymentMethod == 'UPI Payment')
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Pay to our UPI ID:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              SelectableText(
                                '801885973@ybl',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.green.shade900,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      // Copy to clipboard
                                      Clipboard.setData(const ClipboardData(text: '801885973@ybl'));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('UPI ID copied to clipboard!'),
                                          duration: Duration(seconds: 2),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.copy, size: 16),
                                    label: const Text('Copy UPI ID'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'OR scan QR code after placing order',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Order Summary Card
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                child: _buildSectionCard(
                  title: '📋 Order Summary',
                  child: Column(
                    children: [
                      _buildBillRow('Items Total', cartProvider.subtotal),
                      _buildBillRow('Delivery Charges', cartProvider.deliveryCharges),
                      _buildBillRow('GST (5%)', cartProvider.gstAmount),
                      if (cartProvider.discount > 0)
                        _buildBillRow('Discount', -cartProvider.discount,
                            isDiscount: true),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Pulse(
                            infinite: true,
                            duration: const Duration(seconds: 2),
                            child: Text(
                              '₹${cartProvider.totalAmount.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 100), // Space for floating button
            ],
          ),

          // Floating Place Order Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: FadeInUp(
              duration: const Duration(milliseconds: 800),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isProcessing ? null : _processOrder,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: isProcessing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Place Order',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
    String title,
    String subtitle,
    IconData icon,
    String value,
  ) {
    final isSelected = selectedPaymentMethod == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Theme.of(context).primaryColor : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
              ),
          ],
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
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            '${isDiscount ? '-' : ''}₹${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDiscount ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }
}
