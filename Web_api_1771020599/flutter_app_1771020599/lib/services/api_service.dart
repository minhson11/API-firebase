import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/dish.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  static String? _token;
  
  // Authentication Methods
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
    String? address,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/customers/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'full_name': fullName,
          'phone_number': phoneNumber,
          'address': address,
        }),
      );
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 201 && data['success']) {
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Registration failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }
  
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/customers/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        // Save user data to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', json.encode(data['data']));
        
        return {
          'success': true, 
          'data': data['data'],
          'student_id': '1771020599'
        };
      } else {
        return {'success': false, 'error': data['error'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }
  
  static Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }
  
  static Future<String?> getToken() async {
    if (_token != null) return _token;
    
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    return _token;
  }
  
  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    
    if (userData != null) {
      return User.fromJson(json.decode(userData));
    }
    return null;
  }
  
  static Future<bool> isLoggedIn() async {
    final userData = await getCurrentUser();
    return userData != null;
  }
  
  // Menu Items Methods
  static Future<List<MenuItem>> getMenuItems({
    int? page,
    int? limit,
    String? search,
    String? category,
    bool? vegetarianOnly,
    bool? spicyOnly,
    bool? availableOnly,
  }) async {
    try {
      final queryParams = <String, String>{};
      
      if (category != null && category.isNotEmpty) queryParams['category'] = category;
      if (vegetarianOnly != null) queryParams['is_vegetarian'] = vegetarianOnly.toString();
      if (spicyOnly != null) queryParams['is_spicy'] = spicyOnly.toString();
      if (availableOnly != null) queryParams['is_available'] = availableOnly.toString();
      
      final uri = Uri.parse('$baseUrl/menu-items').replace(queryParameters: queryParams);
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return (data['data'] as List)
              .map((json) => MenuItem.fromJson(json))
              .toList();
        }
      }
      throw Exception('Failed to load menu items');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  static Future<List<MenuItem>> getMenuItemsByCategory(String category) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/menu-items/category/$category'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return (data['data'] as List)
              .map((json) => MenuItem.fromJson(json))
              .toList();
        }
      }
      throw Exception('Failed to load menu items by category');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  static Future<MenuItem> getMenuItem(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/menu-items/$id'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return MenuItem.fromJson(data['data']);
        }
      }
      throw Exception('Failed to load menu item');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  static Future<List<MenuItem>> searchMenuItems(String searchTerm) async {
    try {
      // Sử dụng filter thay vì search endpoint riêng
      final response = await http.get(
        Uri.parse('$baseUrl/menu-items')
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          final allItems = (data['data'] as List)
              .map((json) => MenuItem.fromJson(json))
              .toList();
          
          // Filter locally by search term
          return allItems.where((item) => 
            item.name.toLowerCase().contains(searchTerm.toLowerCase()) ||
            (item.description?.toLowerCase().contains(searchTerm.toLowerCase()) ?? false)
          ).toList();
        }
      }
      throw Exception('Failed to search menu items');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  // Helper method to get headers with auth token
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  // Categories for filtering
  static List<String> getCategories() {
    return ['Appetizer', 'Main Course', 'Dessert', 'Beverage', 'Soup'];
  }
  
  static List<String> getCategoriesVietnamese() {
    return ['Khai vị', 'Món chính', 'Tráng miệng', 'Đồ uống', 'Canh/Súp'];
  }
}