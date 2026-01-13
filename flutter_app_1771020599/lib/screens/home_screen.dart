import 'package:flutter/material.dart';
<<<<<<< HEAD
import '../models/category.dart';
import '../models/dish.dart';
import '../services/api_service.dart';
import '../widgets/category_card.dart';
import '../widgets/dish_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
=======
import '../models/customer_model.dart';
import 'menu_screen.dart';
import 'reservation_screen.dart';
import 'my_reservations_screen.dart';
import 'login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final CustomerModel customer;

  const HomeScreen({super.key, required this.customer});
>>>>>>> 6cf7f17 (Initial commit)

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
<<<<<<< HEAD
  List<Category> categories = [];
  List<Dish> dishes = [];
  int? selectedCategoryId;
  bool isLoading = true;
  String error = '';
=======
  int _currentIndex = 0;

  late List<Widget> _screens;
>>>>>>> 6cf7f17 (Initial commit)

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final categoriesData = await ApiService.getCategories();
      final dishesData = await ApiService.getDishes(categoryId: selectedCategoryId);
      
      setState(() {
        categories = categoriesData;
        dishes = dishesData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> filterByCategory(int? categoryId) async {
    setState(() {
      selectedCategoryId = categoryId;
      isLoading = true;
    });

    try {
      final dishesData = await ApiService.getDishes(categoryId: categoryId);
      setState(() {
        dishes = dishesData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
=======
    _screens = [
      MenuScreen(customer: widget.customer),
      ReservationScreen(customer: widget.customer),
      MyReservationsScreen(customer: widget.customer),
    ];
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('customerId');
    await prefs.remove('customerName');

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
>>>>>>> 6cf7f17 (Initial commit)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
<<<<<<< HEAD
        title: const Text('Menu Nhà Hàng'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Categories Section
          Container(
            height: 120,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Danh mục',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // All categories option
                      GestureDetector(
                        onTap: () => filterByCategory(null),
                        child: Container(
                          width: 80,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: selectedCategoryId == null 
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.restaurant_menu,
                                color: selectedCategoryId == null 
                                    ? Colors.white 
                                    : Colors.grey[600],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tất cả',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: selectedCategoryId == null 
                                      ? Colors.white 
                                      : Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Category items
                      ...categories.map((category) => CategoryCard(
                        category: category,
                        isSelected: selectedCategoryId == category.id,
                        onTap: () => filterByCategory(category.id),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Dishes Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    selectedCategoryId == null 
                        ? 'Tất cả món ăn (${dishes.length})'
                        : '${categories.firstWhere((c) => c.id == selectedCategoryId, orElse: () => Category(id: 0, name: '', createdAt: DateTime.now(), updatedAt: DateTime.now())).name} (${dishes.length})',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                
                if (isLoading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (error.isNotEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            'Lỗi kết nối API',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Vui lòng kiểm tra server API đang chạy',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: loadData,
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (dishes.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restaurant, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Không có món ăn nào'),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: dishes.length,
                      itemBuilder: (context, index) {
                        return DishCard(dish: dishes[index]);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
=======
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
            ),
          ),
        ),
        title: const Row(
          children: [
            Icon(Icons.restaurant, size: 28),
            SizedBox(width: 8),
            Text(
              'Nhà Hàng XYZ',
              style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 18, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.customer.loyaltyPoints} điểm',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Row(
                    children: [
                      Icon(Icons.logout, color: Color(0xFF1A237E)),
                      SizedBox(width: 8),
                      Text('Đăng xuất'),
                    ],
                  ),
                  content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _logout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400],
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Đăng xuất'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: const Color(0xFF3949AB),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu),
              label: 'Menu',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.table_restaurant),
              label: 'Đặt bàn',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Lịch sử',
            ),
          ],
        ),
      ),
    );
  }
}
>>>>>>> 6cf7f17 (Initial commit)
