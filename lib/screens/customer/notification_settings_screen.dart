import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:animate_do/animate_do.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _pushNotifications = true;
  bool _orderUpdates = true;
  bool _promotionalOffers = false;
  bool _emailNotifications = false;
  bool _smsNotifications = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _pushNotifications = prefs.getBool('push_notifications') ?? true;
        _orderUpdates = prefs.getBool('order_updates') ?? true;
        _promotionalOffers = prefs.getBool('promotional_offers') ?? false;
        _emailNotifications = prefs.getBool('email_notifications') ?? false;
        _smsNotifications = prefs.getBool('sms_notifications') ?? true;
      });
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePreference(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);

      // Update FCM topic subscription for promotional offers
      if (key == 'promotional_offers') {
        if (value) {
          await FirebaseMessaging.instance.subscribeToTopic('promotions');
        } else {
          await FirebaseMessaging.instance.unsubscribeFromTopic('promotions');
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Preference saved!'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving preference: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // Push Notifications Section
                FadeInDown(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications_active,
                          color: Theme.of(context).primaryColor,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Stay Updated',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Get notified about your orders and offers',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Settings List
                FadeInLeft(
                  delay: const Duration(milliseconds: 100),
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        SwitchListTile(
                          secondary: const Icon(Icons.notifications),
                          title: const Text('Push Notifications'),
                          subtitle: const Text('Receive notifications on this device'),
                          value: _pushNotifications,
                          onChanged: (value) {
                            setState(() => _pushNotifications = value);
                            _savePreference('push_notifications', value);
                          },
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          secondary: const Icon(Icons.shopping_bag),
                          title: const Text('Order Updates'),
                          subtitle: const Text('Get notified about order status changes'),
                          value: _orderUpdates,
                          onChanged: (value) {
                            setState(() => _orderUpdates = value);
                            _savePreference('order_updates', value);
                          },
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          secondary: const Icon(Icons.local_offer),
                          title: const Text('Promotional Offers'),
                          subtitle: const Text('Receive offers and discounts'),
                          value: _promotionalOffers,
                          onChanged: (value) {
                            setState(() => _promotionalOffers = value);
                            _savePreference('promotional_offers', value);
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Other Channels',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                FadeInLeft(
                  delay: const Duration(milliseconds: 200),
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        SwitchListTile(
                          secondary: const Icon(Icons.email),
                          title: const Text('Email Notifications'),
                          subtitle: const Text('Receive updates via email'),
                          value: _emailNotifications,
                          onChanged: (value) {
                            setState(() => _emailNotifications = value);
                            _savePreference('email_notifications', value);
                          },
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          secondary: const Icon(Icons.sms),
                          title: const Text('SMS Notifications'),
                          subtitle: const Text('Receive order updates via SMS'),
                          value: _smsNotifications,
                          onChanged: (value) {
                            setState(() => _smsNotifications = value);
                            _savePreference('sms_notifications', value);
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Info Card
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'You can change these settings anytime. Order confirmations will always be sent.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
