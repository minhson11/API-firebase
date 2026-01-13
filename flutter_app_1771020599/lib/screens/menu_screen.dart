import 'package:flutter/material.dart';
<<<<<<< HEAD
import '../models/dish.dart';
import '../services/api_service.dart';
import '../widgets/menu_item_card.dart';
import '../widgets/category_filter.dart';
import '../widgets/search_bar_widget.dart';
import 'menu_item_detail_screen.dart';
import 'login_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});
=======
import 'package:intl/intl.dart';
import '../models/customer_model.dart';
import '../models/menu_item_model.dart';
import '../repositories/menu_item_repository.dart';

class MenuScreen extends StatefulWidget {
  final CustomerModel customer;

  const MenuScreen({super.key, required this.customer});
>>>>>>> 6cf7f17 (Initial commit)

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
<<<<<<< HEAD
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
=======
  final MenuItemRepository _menuItemRepository = MenuItemRepository();
  final TextEditingController _searchController = TextEditingController();
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  String? _selectedCategory;
  bool _filterVegetarian = false;
  bool _filterSpicy = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MenuItemModel> _filterItems(List<MenuItemModel> items) {
    return items.where((item) {
      // Filter by search
      if (_searchQuery.isNotEmpty) {
        String searchLower = _searchQuery.toLowerCase();
        bool matches = item.name.toLowerCase().contains(searchLower) ||
            item.description.toLowerCase().contains(searchLower) ||
            item.ingredients.any((i) => i.toLowerCase().contains(searchLower));
        if (!matches) return false;
      }

      // Filter by category
      if (_selectedCategory != null && item.category != _selectedCategory) {
        return false;
      }

      // Filter by vegetarian
      if (_filterVegetarian && !item.isVegetarian) {
        return false;
      }

      // Filter by spicy
      if (_filterSpicy && !item.isSpicy) {
        return false;
      }

      return true;
    }).toList();
  }

  void _showItemDetail(MenuItemModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Image placeholder
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFF3949AB).withOpacity(0.1), const Color(0xFF5C6BC0).withOpacity(0.1)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: item.imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              item.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildPlaceholderImage(item),
                            ),
                          )
                        : _buildPlaceholderImage(item),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                      ),
                      if (item.isVegetarian)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: const Text(
                            '🥬 Chay',
                            style: TextStyle(color: Colors.green, fontSize: 12),
                          ),
                        ),
                      const SizedBox(width: 8),
                      if (item.isSpicy)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: const Text(
                            '🌶️ Cay',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber.shade600, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              item.rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time, color: Colors.grey.shade600, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '${item.preparationTime} phút',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _currencyFormat.format(item.price),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Mô tả',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Nguyên liệu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: item.ingredients.map((ingredient) {
                      return Chip(
                        label: Text(ingredient),
                        backgroundColor: const Color(0xFF3949AB).withOpacity(0.1),
                        labelStyle: const TextStyle(color: Color(0xFF3949AB)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  if (!item.isAvailable)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cancel, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Món này hiện đã hết',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(MenuItemModel item) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant,
            size: 60,
            color: const Color(0xFF3949AB).withOpacity(0.5),
          ),
          const SizedBox(height: 8),
          Text(
            item.category,
            style: const TextStyle(
              color: Color(0xFF3949AB),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
>>>>>>> 6cf7f17 (Initial commit)
    );
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
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
=======
    return Column(
      children: [
        // Header với search
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3949AB), Color(0xFF5C6BC0)],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm món ăn...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF3949AB)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              const SizedBox(height: 16),
              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Category filter
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        hint: const Text('Danh mục', style: TextStyle(color: Colors.white)),
                        dropdownColor: const Color(0xFF3949AB),
                        iconEnabledColor: Colors.white,
                        underline: const SizedBox(),
                        style: const TextStyle(color: Colors.white),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Tất cả'),
                          ),
                          ...MenuItemModel.categories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }),
                        ],
                        onChanged: (value) => setState(() => _selectedCategory = value),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilterChip(
                      label: const Text('🥬 Chay'),
                      selected: _filterVegetarian,
                      onSelected: (selected) {
                        setState(() => _filterVegetarian = selected);
                      },
                      selectedColor: Colors.green.shade100,
                      backgroundColor: Colors.white.withOpacity(0.9),
                      checkmarkColor: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('🌶️ Cay'),
                      selected: _filterSpicy,
                      onSelected: (selected) {
                        setState(() => _filterSpicy = selected);
                      },
                      selectedColor: Colors.red.shade100,
                      backgroundColor: Colors.white.withOpacity(0.9),
                      checkmarkColor: Colors.red,
                    ),
>>>>>>> 6cf7f17 (Initial commit)
                  ],
                ),
              ),
            ],
          ),
<<<<<<< HEAD
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
=======
        ),

        const SizedBox(height: 8),

        // Menu items list
        Expanded(
          child: StreamBuilder<List<MenuItemModel>>(
            stream: _menuItemRepository.getMenuItemsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF3949AB)),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text('Lỗi: ${snapshot.error}'),
                    ],
                  ),
                );
              }

              List<MenuItemModel> items = snapshot.data ?? [];
              List<MenuItemModel> filteredItems = _filterItems(items);

              if (filteredItems.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.no_food, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      const Text(
                        'Không tìm thấy món ăn',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  MenuItemModel item = filteredItems[index];
                  return _buildMenuItemCard(item);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItemCard(MenuItemModel item) {
    return GestureDetector(
      onTap: () => _showItemDetail(item),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFF3949AB).withOpacity(0.1), const Color(0xFF5C6BC0).withOpacity(0.1)],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: item.imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: Image.network(
                              item.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                Icons.restaurant,
                                size: 50,
                                color: const Color(0xFF3949AB).withOpacity(0.4),
                              ),
                            ),
                          )
                        : Icon(
                            Icons.restaurant,
                            size: 50,
                            color: const Color(0xFF3949AB).withOpacity(0.4),
                          ),
                  ),
                ),
                // Info
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF1A237E),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber.shade600,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              item.rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const Spacer(),
                            if (item.isVegetarian)
                              const Text('🥬', style: TextStyle(fontSize: 12)),
                            if (item.isSpicy)
                              const Text('🌶️', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        Text(
                          _currencyFormat.format(item.price),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF3949AB),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Badge "Hết món"
            if (!item.isAvailable)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Hết món',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
>>>>>>> 6cf7f17 (Initial commit)
