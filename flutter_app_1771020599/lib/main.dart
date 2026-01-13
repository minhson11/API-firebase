import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'services/api_service.dart';
import 'screens/login_screen.dart';
import 'screens/menu_screen.dart';
import 'test_api.dart';

void main() {
=======
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'services/firebase_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'repositories/customer_repository.dart';
import 'models/customer_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
>>>>>>> 6cf7f17 (Initial commit)
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
<<<<<<< HEAD
      title: 'Restaurant App - 1771020599',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
=======
      title: 'Restaurant App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
        textTheme: GoogleFonts.notoSansTextTheme(),
      ),
      home: const SplashScreen(),
>>>>>>> 6cf7f17 (Initial commit)
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
<<<<<<< HEAD
  bool _isTestingApi = false;
  String _testResult = '';

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Delay để hiển thị splash screen
    await Future.delayed(const Duration(seconds: 2));
    
    final isLoggedIn = await ApiService.isLoggedIn();
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => isLoggedIn 
              ? const MenuScreen() 
              : const LoginScreen(),
        ),
      );
    }
  }

  Future<void> _testApiConnection() async {
    setState(() {
      _isTestingApi = true;
      _testResult = 'Testing API connection...';
    });

    try {
      await ApiTest.testConnection();
      await ApiTest.testLogin();
      
      setState(() {
        _testResult = 'API test completed! Check console for details.';
      });
    } catch (e) {
      setState(() {
        _testResult = 'API test failed: $e';
      });
    } finally {
      setState(() {
        _isTestingApi = false;
      });
=======
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    try {
      // Initialize Firebase Service
      await FirebaseService().initialize();

      final prefs = await SharedPreferences.getInstance();
      final customerId = prefs.getString('customerId');

      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        if (customerId != null) {
          // Lấy thông tin customer
          CustomerRepository customerRepo = CustomerRepository();
          CustomerModel? customer = await customerRepo.getCustomerById(customerId);

          if (customer != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(customer: customer),
              ),
            );
            return;
          }
        }

        // Không có customer, về login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
>>>>>>> 6cf7f17 (Initial commit)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      backgroundColor: Colors.orange,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.restaurant,
                size: 60,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Restaurant App',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Mã sinh viên: 1771020599',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 48),
            if (_isTestingApi)
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            else
              Column(
                children: [
                  ElevatedButton(
                    onPressed: _testApiConnection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.orange,
                    ),
                    child: const Text('Test API Connection'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.orange,
                    ),
                    child: const Text('Continue to App'),
                  ),
                ],
              ),
            if (_testResult.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _testResult,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
=======
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange.shade400,
              Colors.orange.shade800,
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.restaurant,
                size: 100,
                color: Colors.white,
              ),
              SizedBox(height: 24),
              Text(
                'Nhà Hàng XYZ',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 48),
              CircularProgressIndicator(
                color: Colors.white,
              ),
            ],
          ),
>>>>>>> 6cf7f17 (Initial commit)
        ),
      ),
    );
  }
}
