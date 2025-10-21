import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Widget to populate Firestore with all menu items
/// This will run when you tap the button in the app
class MenuItemsPopulator extends StatefulWidget {
  const MenuItemsPopulator({Key? key}) : super(key: key);

  @override
  State<MenuItemsPopulator> createState() => _MenuItemsPopulatorState();
}

class _MenuItemsPopulatorState extends State<MenuItemsPopulator> {
  bool _isPopulating = false;
  List<String> _logs = [];
  int _successCount = 0;
  int _errorCount = 0;

  Future<void> _populateMenuItems() async {
    setState(() {
      _isPopulating = true;
      _logs.clear();
      _successCount = 0;
      _errorCount = 0;
    });

    _addLog('🚀 Starting menu items population...');

    final firestore = FirebaseFirestore.instance;

    // All 22 menu items with complete details
    final List<Map<String, dynamic>> menuItems = [
      // CHOWMIN ITEMS (12 items)
      {
        'name': 'Veg Chowmin',
        'price': 80.0,
        'category': 'Chowmin',
        'description':
            'Classic vegetarian noodles stir-fried with fresh vegetables and aromatic sauces',
        'ingredients': [
          'Noodles',
          'Cabbage',
          'Carrot',
          'Capsicum',
          'Onion',
          'Soy Sauce',
          'Green Chilli'
        ],
        'image':
            'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=500',
        'isVeg': true,
        'isAvailable': true,
        'rating': 4.5,
        'preparationTime': 15,
        'spiceLevel': 'Medium',
      },
      {
        'name': 'Chicken Chowmin',
        'price': 120.0,
        'category': 'Chowmin',
        'description':
            'Delicious noodles tossed with tender chicken pieces and fresh vegetables',
        'ingredients': [
          'Noodles',
          'Chicken',
          'Cabbage',
          'Carrot',
          'Capsicum',
          'Onion',
          'Soy Sauce',
          'Garlic'
        ],
        'image':
            'https://images.unsplash.com/photo-1612929633738-8fe44f7ec841?w=500',
        'isVeg': false,
        'isAvailable': true,
        'rating': 4.7,
        'preparationTime': 20,
        'spiceLevel': 'Medium',
      },
      {
        'name': 'Egg Chowmin',
        'price': 100.0,
        'category': 'Chowmin',
        'description':
            'Scrambled eggs mixed with noodles and crunchy vegetables',
        'ingredients': [
          'Noodles',
          'Eggs',
          'Cabbage',
          'Carrot',
          'Onion',
          'Soy Sauce',
          'Spring Onion'
        ],
        'image':
            'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=500',
        'isVeg': false,
        'isAvailable': true,
        'rating': 4.4,
        'preparationTime': 15,
        'spiceLevel': 'Mild',
      },
      {
        'name': 'Paneer Chowmin',
        'price': 110.0,
        'category': 'Chowmin',
        'description':
            'Soft paneer cubes cooked with noodles and vegetables in special sauces',
        'ingredients': [
          'Noodles',
          'Paneer',
          'Cabbage',
          'Carrot',
          'Capsicum',
          'Onion',
          'Soy Sauce',
          'Ginger'
        ],
        'image':
            'https://images.unsplash.com/photo-1626844131082-256783844137?w=500',
        'isVeg': true,
        'isAvailable': true,
        'rating': 4.6,
        'preparationTime': 18,
        'spiceLevel': 'Medium',
      },
      {
        'name': 'Schezwan Chowmin',
        'price': 90.0,
        'category': 'Chowmin',
        'description':
            'Spicy schezwan sauce based noodles with mixed vegetables',
        'ingredients': [
          'Noodles',
          'Mixed Vegetables',
          'Schezwan Sauce',
          'Garlic',
          'Green Chilli',
          'Vinegar'
        ],
        'image':
            'https://images.unsplash.com/photo-1555126634-323283e090fa?w=500',
        'isVeg': true,
        'isAvailable': true,
        'rating': 4.8,
        'preparationTime': 16,
        'spiceLevel': 'Hot',
      },
      {
        'name': 'Hakka Noodles',
        'price': 85.0,
        'category': 'Chowmin',
        'description':
            'Indo-Chinese style hakka noodles with crunchy vegetables',
        'ingredients': [
          'Hakka Noodles',
          'Cabbage',
          'Carrot',
          'Beans',
          'Onion',
          'Soy Sauce',
          'Chilli Sauce'
        ],
        'image':
            'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=500',
        'isVeg': true,
        'isAvailable': true,
        'rating': 4.5,
        'preparationTime': 15,
        'spiceLevel': 'Medium',
      },
      {
        'name': 'Singapore Chowmin',
        'price': 130.0,
        'category': 'Chowmin',
        'description':
            'Exotic Singapore style curry noodles with mixed vegetables and spices',
        'ingredients': [
          'Rice Noodles',
          'Mixed Vegetables',
          'Curry Powder',
          'Coconut Milk',
          'Garlic',
          'Chilli'
        ],
        'image':
            'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=500',
        'isVeg': true,
        'isAvailable': true,
        'rating': 4.7,
        'preparationTime': 22,
        'spiceLevel': 'Hot',
      },
      {
        'name': 'Triple Schezwan Rice',
        'price': 140.0,
        'category': 'Chowmin',
        'description':
            'Combination of schezwan rice, noodles and gravy - a complete meal',
        'ingredients': [
          'Rice',
          'Noodles',
          'Mixed Vegetables',
          'Schezwan Sauce',
          'Manchurian Gravy',
          'Spices'
        ],
        'image':
            'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=500',
        'isVeg': true,
        'isAvailable': true,
        'rating': 4.9,
        'preparationTime': 25,
        'spiceLevel': 'Hot',
      },
      {
        'name': 'Manchurian Noodles',
        'price': 125.0,
        'category': 'Chowmin',
        'description':
            'Noodles served with vegetable manchurian balls in delicious gravy',
        'ingredients': [
          'Noodles',
          'Manchurian Balls',
          'Cabbage',
          'Carrot',
          'Capsicum',
          'Manchurian Sauce',
          'Cornflour'
        ],
        'image':
            'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=500',
        'isVeg': true,
        'isAvailable': true,
        'rating': 4.6,
        'preparationTime': 20,
        'spiceLevel': 'Medium',
      },
      {
        'name': 'American Chopsuey',
        'price': 150.0,
        'category': 'Chowmin',
        'description':
            'Crispy fried noodles topped with sweet and sour vegetable gravy',
        'ingredients': [
          'Crispy Noodles',
          'Mixed Vegetables',
          'Tomato Sauce',
          'Vinegar',
          'Sugar',
          'Cornflour',
          'Pineapple'
        ],
        'image':
            'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=500',
        'isVeg': true,
        'isAvailable': true,
        'rating': 4.8,
        'preparationTime': 30,
        'spiceLevel': 'Mild',
      },
      {
        'name': 'Mushroom Chowmin',
        'price': 115.0,
        'category': 'Chowmin',
        'description':
            'Fresh mushrooms stir-fried with noodles and vegetables',
        'ingredients': [
          'Noodles',
          'Mushrooms',
          'Cabbage',
          'Carrot',
          'Capsicum',
          'Soy Sauce',
          'Garlic',
          'Black Pepper'
        ],
        'image':
            'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=500',
        'isVeg': true,
        'isAvailable': true,
        'rating': 4.5,
        'preparationTime': 18,
        'spiceLevel': 'Medium',
      },
      {
        'name': 'Prawn Chowmin',
        'price': 160.0,
        'category': 'Chowmin',
        'description':
            'Premium prawn noodles with exotic spices and fresh vegetables',
        'ingredients': [
          'Noodles',
          'Prawns',
          'Cabbage',
          'Carrot',
          'Capsicum',
          'Onion',
          'Garlic',
          'Ginger',
          'Spices'
        ],
        'image':
            'https://images.unsplash.com/photo-1633321702518-40b6c2c3c26d?w=500',
        'isVeg': false,
        'isAvailable': true,
        'rating': 4.9,
        'preparationTime': 25,
        'spiceLevel': 'Hot',
      },

      // ROLLS (6 items)
      {
        'name': 'Veg Roll',
        'price': 60.0,
        'category': 'Rolls',
        'description':
            'Crispy wrap filled with fresh vegetables and tangy sauces',
        'ingredients': [
          'Paratha',
          'Cabbage',
          'Carrot',
          'Onion',
          'Capsicum',
          'Green Chutney',
          'Tamarind Chutney'
        ],
        'image':
            'https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=500',
        'isVeg': true,
        'isAvailable': true,
        'rating': 4.3,
        'preparationTime': 10,
        'spiceLevel': 'Medium',
      },
      {
        'name': 'Chicken Roll',
        'price': 90.0,
        'category': 'Rolls',
        'description':
            'Tender chicken pieces wrapped in soft paratha with special sauces',
        'ingredients': [
          'Paratha',
          'Chicken Tikka',
          'Onion',
          'Tomato',
          'Lettuce',
          'Mayonnaise',
          'Mint Chutney'
        ],
        'image':
            'https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=500',
        'isVeg': false,
        'isAvailable': true,
        'rating': 4.7,
        'preparationTime': 15,
        'spiceLevel': 'Medium',
      },
      {
        'name': 'Paneer Roll',
        'price': 80.0,
        'category': 'Rolls',
        'description':
            'Grilled paneer tikka wrapped with fresh veggies and chutneys',
        'ingredients': [
          'Paratha',
          'Paneer Tikka',
          'Onion',
          'Capsicum',
          'Tomato',
          'Green Chutney',
          'Cheese'
        ],
        'image':
            'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=500',
        'isVeg': true,
        'isAvailable': true,
        'rating': 4.5,
        'preparationTime': 12,
        'spiceLevel': 'Medium',
      },
      {
        'name': 'Egg Roll',
        'price': 50.0,
        'category': 'Rolls',
        'description': 'Classic egg roll with scrambled eggs and vegetables',
        'ingredients': [
          'Paratha',
          'Eggs',
          'Onion',
          'Green Chilli',
          'Coriander',
          'Tomato Sauce',
          'Chilli Sauce'
        ],
        'image':
            'https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=500',
        'isVeg': false,
        'isAvailable': true,
        'rating': 4.4,
        'preparationTime': 8,
        'spiceLevel': 'Mild',
      },
      {
        'name': 'Mutton Roll',
        'price': 130.0,
        'category': 'Rolls',
        'description': 'Premium mutton keema wrapped in crispy paratha',
        'ingredients': [
          'Paratha',
          'Mutton Keema',
          'Onion',
          'Tomato',
          'Spices',
          'Mint Chutney',
          'Lemon'
        ],
        'image':
            'https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=500',
        'isVeg': false,
        'isAvailable': true,
        'rating': 4.8,
        'preparationTime': 18,
        'spiceLevel': 'Hot',
      },
      {
        'name': 'Cheese Roll',
        'price': 70.0,
        'category': 'Rolls',
        'description': 'Loaded with cheese and vegetables for cheese lovers',
        'ingredients': [
          'Paratha',
          'Cheese',
          'Cabbage',
          'Carrot',
          'Capsicum',
          'Onion',
          'Mayonnaise',
          'Oregano'
        ],
        'image':
            'https://images.unsplash.com/photo-1619096252214-ef06c45683e3?w=500',
        'isVeg': true,
        'isAvailable': true,
        'rating': 4.6,
        'preparationTime': 10,
        'spiceLevel': 'Mild',
      },

      // BEVERAGES (4 items)
      {
        'name': 'Cold Drink',
        'price': 30.0,
        'category': 'Beverages',
        'description': 'Chilled soft drinks - Coke, Pepsi, Sprite, Fanta',
        'ingredients': ['Soft Drink (Choice of Flavor)'],
        'image':
            'https://images.unsplash.com/photo-1629203851122-3726ecdf080e?w=500',
        'isVeg': true,
        'isAvailable': true,
        'rating': 4.2,
        'preparationTime': 2,
        'spiceLevel': 'None',
      },
      {
        'name': 'Mineral Water',
        'price': 20.0,
        'category': 'Beverages',
        'description': 'Packaged drinking water bottle (1 Liter)',
        'ingredients': ['Purified Water'],
        'image':
            'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=500',
        'isVeg': true,
        'isAvailable': true,
        'rating': 4.0,
        'preparationTime': 1,
        'spiceLevel': 'None',
      },
      {
        'name': 'Fresh Lime Soda',
        'price': 40.0,
        'category': 'Beverages',
        'description': 'Refreshing lime soda with fresh lemon juice and soda',
        'ingredients': ['Fresh Lemon', 'Soda', 'Sugar', 'Salt', 'Mint', 'Ice'],
        'image':
            'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=500',
        'isVeg': true,
        'isAvailable': true,
        'rating': 4.5,
        'preparationTime': 5,
        'spiceLevel': 'None',
      },
      {
        'name': 'Mango Juice',
        'price': 50.0,
        'category': 'Beverages',
        'description': 'Fresh mango juice blended with milk and sugar',
        'ingredients': [
          'Fresh Mango',
          'Milk',
          'Sugar',
          'Ice',
          'Cardamom'
        ],
        'image':
            'https://images.unsplash.com/photo-1546173159-315724a31696?w=500',
        'isVeg': true,
        'isAvailable': true,
        'rating': 4.7,
        'preparationTime': 8,
        'spiceLevel': 'None',
      },
    ];

    _addLog('📝 Preparing to add ${menuItems.length} menu items...\n');

    // Add each item to Firestore
    for (var item in menuItems) {
      try {
        await firestore.collection('menu_items').add({
          ...item,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        _successCount++;
        _addLog(
            '✅ Added: ${item['name']} (${item['category']}) - ₹${item['price']}');
      } catch (e) {
        _errorCount++;
        _addLog('❌ Error adding ${item['name']}: $e');
      }
    }

    _addLog('\n' + '=' * 60);
    _addLog('📊 SUMMARY:');
    _addLog('=' * 60);
    _addLog('✅ Successfully added: $_successCount items');
    _addLog('❌ Failed: $_errorCount items');
    _addLog('📦 Total items in database: $_successCount');
    _addLog('=' * 60);

    if (_successCount == menuItems.length) {
      _addLog('\n🎉 ALL MENU ITEMS POPULATED SUCCESSFULLY! 🎉');
      _addLog('\n📱 You can now:');
      _addLog('   1. Go to Home Screen to see all items');
      _addLog('   2. Check Firestore Console to verify');
      _addLog('   3. Browse Menu by categories');
    } else {
      _addLog('\n⚠️  Some items failed to add. Please check errors above.');
    }

    setState(() {
      _isPopulating = false;
    });

    // Show success dialog
    if (_successCount == menuItems.length && context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('✅ Success!'),
          content: Text(
              'All $_successCount menu items have been added to Firestore!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _addLog(String message) {
    setState(() {
      _logs.add(message);
    });
    debugPrint(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Populate Menu Items'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.restaurant_menu, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'Click below to add all 22 menu items to Firestore',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '12 Chowmin • 6 Rolls • 4 Beverages',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _isPopulating ? null : _populateMenuItems,
                      icon: _isPopulating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add_circle),
                      label: Text(_isPopulating
                          ? 'Adding Items...'
                          : 'Add Menu Items'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_logs.isNotEmpty) ...[
              const Text(
                'Logs:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          _logs[index],
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'Courier',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
