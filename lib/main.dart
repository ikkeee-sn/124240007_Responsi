import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/product_list_screen.dart';
import 'services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalStorageService.init();

  final bool isLoggedIn = await LocalStorageService.isUserLoggedIn();
  final String userName = await LocalStorageService.getLoggedInName();

  runApp(ShoppingHubApp(
    isLoggedIn: isLoggedIn,
    userName: userName,
  ));
}

class ShoppingHubApp extends StatelessWidget {
  final bool isLoggedIn;
  final String userName;

  const ShoppingHubApp({
    super.key,
    required this.isLoggedIn,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShoppingHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        fontFamily: null,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          primary: const Color(0xFF4F46E5),
          secondary: const Color(0xFFE11D48),
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 1,
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF0F172A),
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
          iconTheme: IconThemeData(
            color: Color(0xFF0F172A),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
        ),
      ),
      home: isLoggedIn
          ? ProductListScreen(userName: userName)
          : const LoginScreen(),
    );
  }
}
 