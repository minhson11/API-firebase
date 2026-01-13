import 'package:flutter/material.dart';
import '../models/dish.dart';
import '../services/api_service.dart';
import '../widgets/menu_item_card.dart';
import '../widgets/category_filter.dart';
import '../widgets/search_bar_widget.dart';
import 'menu_item_detail_screen.dart';
import 'login_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<MenuItem> menuItems = [];
  List<MenuItem> filteredMenuItems = [];
  String? selectedCategory;
  bool isLoading = true;
  String error = '';
  String searchQuery = '';
  bool vegetarianOnly = false;
  bool spicyOnly = false;
  bool availableOnly = true;

  @override
  void initState() {
    super.initState();
    loadMenuItems();
  }

  Future<void> loadMenuItems() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final items = await ApiService.getMenuItems(
        category: selectedCategory,
        vegetarianOnly: vegetarianOnly ? true : null,
        spicyOnly: spicyOnly ? true : null,
        availableOnly: availableOnly ? true : null,
      );
      
      setState(() {
        menuItems = items;
        filteredMenuItems = items;
        isLoading = false;
      });
      
      _applyFilters();
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      filteredMenuItems = menuItems.where((item) {
        // Search filter
        if (searchQuery.isNotEmpty) {
          final query = searchQuery.toLowerCase();
          if (!item.name.toLowerCase().contains(query) &&
              !(item.description?.toLowerCase().contains(query) ?? false)) {
            return false;
          }
        }
        
        // Category filter
        if (selectedCategory != null && item.category != selectedCategory) {
          return false;
        }
        
        // Vegetarian filter
        if (vegetarianOnly && !item.isVegetarian) {
          return false;
        }
        
        // Spicy filter
        if (spicyOnly && !item.isSpicy) {
          return false;
        }
        
        // Available filter
        if (availableOnly && !item.isAvailable) {
          return false;
        }
        
        return true;
      }).toList();
    });
  }

  void _onCategoryChanged(String? category) {
    setState(() {
      selectedCategory = category;
    });
    loadMenuItems();
  }

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
    });
    _applyFilters();
  }

  void _onFilterChanged() {
    loadMenuItems();
  }

  Future<void> _logout() async {
    await ApiService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Bộ lọc'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    title: const Text('Chỉ món chay'),
                    value: vegetarianOnly,
                    onChanged: (value) {
                      setDialogState(() {
                        vegetarianOnly = value ?? false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Chỉ món cay'),
                    value: spicyOnly,
                    onChanged: (value) {
                      setDialogState(() {
                        spicyOnly = value ?? false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Chỉ món có sẵn'),
                    value: availableOnly,
                    onChanged: (value) {
                      setDialogState(() {
                        availableOnly = value ?? true;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      // Apply filters
                    });
                    Navigator.of(context).pop();
                    _onFilterChanged();
                  },
                  child: const Text('Áp dụng'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Nhà Hàng'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadMenuItems,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Đăng xuất'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Colors.orange,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SearchBarWidget(
              onSearchChanged: _onSearchChanged,
            ),
          ),
          
          // Category filter
          CategoryFilter(
            selectedCategory: selectedCategory,
            onCategoryChanged: _onCategoryChanged,
          ),
          
          // Filter summary
          if (vegetarianOnly || spicyOnly || !availableOnly || searchQuery.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey[100],
              child: Wrap(
                spacing: 8,
                children: [
                  if (searchQuery.isNotEmpty)
                    Chip(
                      label: Text('Tìm: "$searchQuery"'),
                      onDeleted: () => _onSearchChanged(''),
                      deleteIcon: const Icon(Icons.close, size: 16),
                    ),
                  if (vegetarianOnly)
                    Chip(
                      label: const Text('Món chay'),
                      backgroundColor: Colors.green[100],
                    ),
                  if (spicyOnly)
                    Chip(
                      label: const Text('Món cay'),
                      backgroundColor: Colors.red[100],
                    ),
                  if (!availableOnly)
                    Chip(
                      label: const Text('Bao gồm hết món'),
                      backgroundColor: Colors.grey[200],
                    ),
                ],
              ),
            ),
          
          // Menu items list
          Expanded(
            child: _buildMenuContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuContent() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.orange),
            SizedBox(height: 16),
            Text('Đang tải menu...'),
          ],
        ),
      );
    }

    if (error.isNotEmpty) {
      return Center(
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
            const Text(
              'Vui lòng kiểm tra server API đang chạy\ntại http://localhost:3000',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: loadMenuItems,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (filteredMenuItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              searchQuery.isNotEmpty 
                  ? 'Không tìm thấy món ăn phù hợp'
                  : 'Không có món ăn nào',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (searchQuery.isNotEmpty || vegetarianOnly || spicyOnly)
              TextButton(
                onPressed: () {
                  setState(() {
                    searchQuery = '';
                    vegetarianOnly = false;
                    spicyOnly = false;
                    selectedCategory = null;
                  });
                  loadMenuItems();
                },
                child: const Text('Xóa bộ lọc'),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadMenuItems,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredMenuItems.length,
        itemBuilder: (context, index) {
          final menuItem = filteredMenuItems[index];
          return MenuItemCard(
            menuItem: menuItem,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MenuItemDetailScreen(menuItem: menuItem),
                ),
              );
            },
          );
        },
      ),
    );
  }
}