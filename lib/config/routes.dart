import 'package:get/get.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/customer/home_screen.dart';
import '../screens/customer/menu_screen.dart';
import '../screens/customer/cart_screen_enhanced.dart';
import '../screens/customer/checkout_screen_enhanced.dart';
import '../screens/customer/order_tracking_screen.dart';
import '../screens/customer/order_history_screen.dart';
import '../screens/customer/profile_screen.dart';
import '../screens/admin/admin_login_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_menu_management_screen.dart';
import '../screens/admin/admin_order_management_screen.dart';
import '../screens/admin/admin_offers_screen.dart';
import '../widgets/menu_items_populator.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String menu = '/menu';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderTracking = '/order-tracking';
  static const String orderHistory = '/order-history';
  static const String profile = '/profile';
  
  // Admin routes
  static const String adminLogin = '/admin/login';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminMenu = '/admin/menu';
  static const String adminOrders = '/admin/orders';
  static const String adminOffers = '/admin/offers';
  static const String populateMenu = '/populate_menu';

  static final routes = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: register, page: () => const RegisterScreen()),
    GetPage(name: home, page: () => const HomeScreen()),
    GetPage(name: menu, page: () => const MenuScreen()),
    GetPage(name: cart, page: () => const CartScreenEnhanced()),
    GetPage(name: checkout, page: () => const CheckoutScreenEnhanced()),
    GetPage(name: orderTracking, page: () => const OrderTrackingScreen()),
    GetPage(name: orderHistory, page: () => const OrderHistoryScreen()),
    GetPage(name: profile, page: () => const ProfileScreen()),
    
    // Admin routes
    GetPage(name: adminLogin, page: () => const AdminLoginScreen()),
    GetPage(name: adminDashboard, page: () => const AdminDashboardScreen()),
    GetPage(name: adminMenu, page: () => const AdminMenuManagementScreen()),
    GetPage(name: adminOrders, page: () => const AdminOrderManagementScreen()),
    GetPage(name: adminOffers, page: () => const AdminOffersScreen()),
    
    // Setup route
    GetPage(name: populateMenu, page: () => const MenuItemsPopulator()),
  ];
}
