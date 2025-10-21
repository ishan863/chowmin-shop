import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import '../../providers/auth_provider.dart';
import '../../config/routes.dart';
import '../../config/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final phone = _phoneController.text.trim();
    
    // Check if admin phone number
    if (phone == '9999999999' || phone == '1234567890' || phone == '9876543210') {
      // Admin login - redirect to admin dashboard
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.loginAsAdmin(phone);
      setState(() => _isLoading = false);
      Get.offAllNamed<dynamic>(AppRoutes.adminDashboard);
      return;
    }

    // Regular customer login
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(phone);

    setState(() => _isLoading = false);

    if (success) {
      Get.offAllNamed<dynamic>(AppRoutes.home);
    } else {
      Get.snackbar(
        'Login Failed',
        'Phone number not registered. Please register first.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                
                // Logo
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(
                    Icons.restaurant_menu,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Welcome Text
                Text(
                  'Welcome Back!',
                  style: Theme.of(context).textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Login to continue ordering',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 48),
                
                // Phone Input
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                    hintText: 'Enter 10-digit phone number',
                    counterText: '',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    if (!AppConstants.phoneRegex.hasMatch(value)) {
                      return 'Please enter valid phone number';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Login Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text('Login'),
                ),
                
                const SizedBox(height: 16),
                
                // Admin Login Button
                OutlinedButton(
                  onPressed: () => Get.toNamed<dynamic>(AppRoutes.adminLogin),
                  child: const Text('Admin Login'),
                ),
                
                const SizedBox(height: 32),
                
                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed<dynamic>(AppRoutes.register),
                      child: const Text('Register'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
