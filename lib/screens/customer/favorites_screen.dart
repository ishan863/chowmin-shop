import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../providers/menu_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/menu_item_model.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _favoriteItemIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.phone;

      if (userId != null) {
        final doc = await _firestore.collection('users').doc(userId).get();
        if (doc.exists && doc.data()?['favorites'] != null) {
          setState(() {
            _favoriteItemIds = List<String>.from(doc.data()!['favorites'] as List<dynamic>);
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFavorite(String itemId) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.phone;

      if (userId != null) {
        setState(() {
          if (_favoriteItemIds.contains(itemId)) {
            _favoriteItemIds.remove(itemId);
          } else {
            _favoriteItemIds.add(itemId);
          }
        });

        await _firestore.collection('users').doc(userId).set({
          'favorites': _favoriteItemIds,
        }, SetOptions(merge: true));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _favoriteItemIds.contains(itemId)
                    ? '❤️ Added to favorites!'
                    : '💔 Removed from favorites!',
              ),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);

    final favoriteItems = menuProvider.menuItems
        .where((item) => _favoriteItemIds.contains(item.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoriteItems.isEmpty
              ? _buildEmptyState()
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: favoriteItems.length,
                  itemBuilder: (context, index) {
                    final item = favoriteItems[index];
                    return FadeInUp(
                      delay: Duration(milliseconds: index * 100),
                      child: _buildMenuItem(item, cartProvider),
                    );
                  },
                ),
    );
  }

  Widget _buildMenuItem(MenuItem item, CartProvider cartProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with favorite button
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: item.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: item.imageUrl,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 120,
                          color: Colors.grey[300],
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 120,
                          color: Colors.grey[300],
                          child: const Icon(Icons.restaurant, size: 50),
                        ),
                      )
                    : Container(
                        height: 120,
                        color: Colors.grey[300],
                        child: const Icon(Icons.restaurant, size: 50),
                      ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 18,
                  child: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red, size: 20),
                    onPressed: () => _toggleFavorite(item.id),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.isVeg ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.isVeg ? 'VEG' : 'NON-VEG',
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

          // Item details
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${item.price}',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      cartProvider.addItem(item);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${item.name} added to cart!'),
                          duration: const Duration(seconds: 1),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Add', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeIn(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 100, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No favorites yet',
              style: TextStyle(fontSize: 20, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Start adding items to your favorites!',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
