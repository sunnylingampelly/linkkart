import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
import 'providers/store_provider.dart';
import 'providers/product_provider.dart';
import 'services/iap_service.dart';
import 'utils/app_theme.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Clean up any corrupted saved URL from previous versions
  await AppConstants.cleanupSavedUrl();

  // Load saved API settings
  try {
    final prefs = await SharedPreferences.getInstance();
    final savedIp = prefs.getString('api_ip');
    final savedPort = prefs.getString('api_port');
    
    if (savedIp != null && savedPort != null) {
      // baseUrl must be host:port ONLY — endpoint constants add /api/v1 themselves
      AppConstants.baseUrl = 'http://$savedIp:$savedPort';
      debugPrint('Loaded saved API URL: ${AppConstants.baseUrl}');
    } else {
      debugPrint('Using default API URL: ${AppConstants.baseUrl}');
    }
  } catch (e) {
    debugPrint('Error loading API settings: $e');
  }
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
  
  // Force light mode - Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StoreProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => IapService()..initialize()),
      ],
      child: MaterialApp(
        title: 'LinkKart',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,
        home: const SplashScreen(),
      ),
    );
  }
}
