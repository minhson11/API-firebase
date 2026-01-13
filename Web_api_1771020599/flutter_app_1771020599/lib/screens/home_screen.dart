import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/dish.dart';
import '../services/api_service.dart';
import '../widgets/category_card.dart';
import '../widgets/dish_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Category> categories = [];
  List<Dish> dishes = [];
  int? selectedCategoryId;
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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