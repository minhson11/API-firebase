import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiTest {
  static const String baseUrl = 'http://localhost:3000';
  
  static Future<void> testConnection() async {
    print('🔄 Testing API connection...');
    
    try {
      // Test server health
      final healthResponse = await http.get(Uri.parse('$baseUrl/health'));
      print('📊 Health check: ${healthResponse.statusCode}');
      if (healthResponse.statusCode == 200) {
        final healthData = json.decode(healthResponse.body);
        print('✅ Server is running: ${healthData['status']}');
        print('📅 Timestamp: ${healthData['timestamp']}');
        print('💾 Database: ${healthData['database']}');
      }
      
      // Test menu items endpoint
      final menuResponse = await http.get(Uri.parse('$baseUrl/api/menu-items'));
      print('🍽️ Menu items: ${menuResponse.statusCode}');
      if (menuResponse.statusCode == 200) {
        final menuData = json.decode(menuResponse.body);
        if (menuData['success']) {
          print('✅ Menu items loaded: ${menuData['data'].length} items');
        } else {
          print('❌ Menu items failed: ${menuData['error']}');
        }
      }
      
      // Test customers endpoint
      final customersResponse = await http.get(Uri.parse('$baseUrl/api/customers'));
      print('👥 Customers: ${customersResponse.statusCode}');
      if (customersResponse.statusCode == 200) {
        final customersData = json.decode(customersResponse.body);
        if (customersData['success']) {
          print('✅ Customers loaded: ${customersData['data'].length} customers');
        } else {
          print('❌ Customers failed: ${customersData['error']}');
        }
      }
      
    } catch (e) {
      print('❌ Connection failed: $e');
      print('💡 Make sure the API server is running on http://localhost:3000');
    }
  }
  
  static Future<void> testLogin() async {
    print('\n🔐 Testing login...');
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/customers/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': 'john.doe@email.com',
          'password': 'password123',
        }),
      );
      
      print('🔑 Login response: ${response.statusCode}');
      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        print('✅ Login successful');
        print('👤 User: ${data['data']['full_name']}');
        print('📧 Email: ${data['data']['email']}');
        print('🎯 Loyalty Points: ${data['data']['loyalty_points']}');
      } else {
        print('❌ Login failed: ${data['error']}');
        print('💡 This is expected if no test user exists in database');
      }
    } catch (e) {
      print('❌ Login test failed: $e');
    }
  }
}