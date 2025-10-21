import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../config/routes.dart';
import 'package:animate_do/animate_do.dart';
import 'saved_addresses_screen.dart';
import 'favorites_screen.dart';
import 'notification_settings_screen.dart';
import 'language_selection_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      body: SafeArea(
        child: user == null
          ? _buildSignInPrompt(context)
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Header
                  FadeInDown(
                    child: _buildProfileHeader(context, user.phone),
                  ),
                  const SizedBox(height: 24),
                  
                  // Menu Options
                  FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    child: _buildMenuCard(
                      context,
                      icon: Icons.history,
                      title: 'Order History',
                      subtitle: 'View all your orders',
                      onTap: () {
                        // Already on home screen, just switch tab
                        // Navigate to order history tab
                      },
                    ),
                  ),
                  
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: _buildMenuCard(
                      context,
                      icon: Icons.location_on,
                      title: 'Saved Addresses',
                      subtitle: 'Manage delivery addresses',
                      onTap: () {
                        Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(builder: (context) => const SavedAddressesScreen()),
                        );
                      },
                    ),
                  ),
                  
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: _buildMenuCard(
                      context,
                      icon: Icons.favorite,
                      title: 'Favorites',
                      subtitle: 'Your favorite items',
                      onTap: () {
                        Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(builder: (context) => const FavoritesScreen()),
                        );
                      },
                    ),
                  ),
                  
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: _buildMenuCard(
                      context,
                      icon: Icons.notifications,
                      title: 'Notifications',
                      subtitle: 'Manage notification preferences',
                      onTap: () {
                        Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(builder: (context) => const NotificationSettingsScreen()),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Settings Section
                  FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(
                              themeProvider.isDarkMode
                                  ? Icons.dark_mode
                                  : Icons.light_mode,
                              color: Theme.of(context).primaryColor,
                            ),
                            title: const Text('Dark Mode'),
                            subtitle: Text(
                              themeProvider.isDarkMode ? 'Enabled' : 'Disabled',
                            ),
                            trailing: Switch(
                              value: themeProvider.isDarkMode,
                              onChanged: (value) {
                                themeProvider.toggleTheme();
                              },
                            ),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: Icon(
                              Icons.language,
                              color: Theme.of(context).primaryColor,
                            ),
                            title: const Text('Language'),
                            subtitle: const Text('English'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.push<void>(
                                context,
                                MaterialPageRoute<void>(builder: (context) => const LanguageSelectionScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Help & Support Section
                  FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    child: _buildMenuCard(
                      context,
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      subtitle: 'Get help and contact us',
                      onTap: () {
                        _showHelpDialog(context);
                      },
                    ),
                  ),
                  
                  FadeInUp(
                    delay: const Duration(milliseconds: 700),
                    child: _buildMenuCard(
                      context,
                      icon: Icons.info_outline,
                      title: 'About',
                      subtitle: 'App version & info',
                      onTap: () {
                        _showAboutDialog(context);
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Logout Button
                  FadeInUp(
                    delay: const Duration(milliseconds: 800),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _handleLogout(context, authProvider),
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, String phone) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.7),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome!',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phone,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            
            // Edit Button
            IconButton(
              onPressed: () {
                Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(builder: (context) => const EditProfileScreen()),
                );
              },
              icon: const Icon(Icons.edit),
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSignInPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeInDown(
              child: Icon(
                Icons.person_outline,
                size: 100,
                color: Colors.grey[300],
              ),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              child: Text(
                'Sign in to continue',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 12),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Text(
                'Access your orders, profile, and more',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ),
            const SizedBox(height: 32),
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.offAllNamed<void>(AppRoutes.login);
                },
                icon: const Icon(Icons.login),
                label: const Text('Sign In'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context, AuthProvider authProvider) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.logout();
              Get.offAllNamed<void>(AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.construction, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            const Text('Coming Soon'),
          ],
        ),
        content: Text('$feature feature will be available soon!'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need help? Contact us:'),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.phone, size: 20),
                SizedBox(width: 8),
                Text('+91 801885973'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.email, size: 20),
                SizedBox(width: 8),
                Text('support@rajeevchowmin.com'),
              ],
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rajeev Chowmin Center',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('Version 1.0.0'),
            SizedBox(height: 16),
            Text(
              'Your favorite chowmin and noodles, delivered fresh and hot!',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 16),
            Text(
              '© 2025 Rajeev Chowmin Center',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
