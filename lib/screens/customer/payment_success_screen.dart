import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:get/get.dart';
import '../../config/routes.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final String orderId;
  final double amount;
  final String paymentMethod;
  final String? transactionId;

  const PaymentSuccessScreen({
    Key? key,
    required this.orderId,
    required this.amount,
    required this.paymentMethod,
    this.transactionId,
  }) : super(key: key);

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    // Start animations
    Future.delayed(const Duration(milliseconds: 300), () {
      _confettiController.play();
      _scaleController.forward();
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                particleDrag: 0.05,
                emissionFrequency: 0.05,
                numberOfParticles: 30,
                gravity: 0.2,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.orange,
                  Colors.purple,
                  Colors.red,
                  Colors.blue,
                  Colors.yellow,
                ],
              ),
            ),

            // Content
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // Success Animation
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Animated checkmark
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 1000),
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green.withOpacity(0.3),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 80,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Success Text
                    SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          const Text(
                            'Payment Successful!',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Your order has been placed successfully',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Order Details Card
                    SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          children: [
                            // Order ID
                            _buildDetailRow(
                              'Order ID',
                              '#${widget.orderId.substring(widget.orderId.length - 8)}',
                              Icons.receipt_long,
                            ),
                            const Divider(height: 24),
                            
                            // Amount
                            _buildDetailRow(
                              'Amount Paid',
                              '₹${widget.amount.toStringAsFixed(0)}',
                              Icons.payment,
                              isHighlighted: true,
                            ),
                            const Divider(height: 24),
                            
                            // Payment Method
                            _buildDetailRow(
                              'Payment Method',
                              widget.paymentMethod,
                              Icons.account_balance_wallet,
                            ),
                            
                            if (widget.transactionId != null) ...[
                              const Divider(height: 24),
                              _buildDetailRow(
                                'Transaction ID',
                                widget.transactionId!,
                                Icons.confirmation_number,
                              ),
                            ],
                            
                            const Divider(height: 24),
                            
                            // Status
                            _buildDetailRow(
                              'Status',
                              'Confirmed',
                              Icons.check_circle,
                              statusColor: Colors.green,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Info Card
                    SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'You will receive order updates via notifications',
                                style: TextStyle(
                                  color: Colors.blue.shade900,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Action Buttons
                    SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          // Track Order Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Get.offAllNamed<dynamic>(AppRoutes.orderHistory);
                              },
                              icon: const Icon(Icons.location_on),
                              label: const Text(
                                'Track Order',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Back to Home Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Get.offAllNamed<dynamic>(AppRoutes.home);
                              },
                              icon: const Icon(Icons.home),
                              label: const Text(
                                'Back to Home',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey[300]!, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    bool isHighlighted = false,
    Color? statusColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor?.withOpacity(0.1) ?? Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: statusColor ?? Colors.orange,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: isHighlighted ? 20 : 16,
                  fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
                  color: isHighlighted ? Colors.green : Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
