import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/user.dart';

class LocalStorageService {
  static const String userBoxName = 'users_box';
  static const String wishlistBoxName = 'wishlist_box';

  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUsername = 'current_username';
  static const String keyFullName = 'current_fullname';

  static Future<void> init() async {
    await Hive.initFlutter();
    final userBox = await Hive.openBox(userBoxName);
    await Hive.openBox(wishlistBoxName);

    if (userBox.isEmpty) {
      final defaultUser = User(
        username: 'ikkeee',
        password: 'password123',
        fullName: 'Ikke S',
      );
      await userBox.put(defaultUser.username, defaultUser.toMap());
    }
  }

  static Future<bool> registerUser(User user) async {
    final box = Hive.box(userBoxName);
    if (box.containsKey(user.username)) {
      return false;   
    }
    await box.put(user.username, user.toMap());
    return true;
  }

  static Future<User?> login(String username, String password) async {
    final box = Hive.box(userBoxName);
    if (!box.containsKey(username)) {
      return null;
    }
    final userData = box.get(username);
    if (userData != null) {
      final user = User.fromMap(Map<dynamic, dynamic>.from(userData));
      if (user.password == password) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(keyIsLoggedIn, true);
        await prefs.setString(keyUsername, user.username);
        await prefs.setString(keyFullName, user.fullName);
        return user;
      }
    }
    return null;
  }

  static Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyIsLoggedIn) ?? false;
  }

  static Future<String> getLoggedInName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyFullName) ?? 'Pengguna';
  }

  static Future<String> getLoggedInUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUsername) ?? '';
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsLoggedIn, false);
    await prefs.remove(keyUsername);
    await prefs.remove(keyFullName);
  }


  static Box getWishlistBox() {
    return Hive.box(wishlistBoxName);
  }

  static bool isInWishlist(int productId) {
    final box = Hive.box(wishlistBoxName);
    return box.containsKey(productId);
  }

  static Future<void> addToWishlist(Product product) async {
    final box = Hive.box(wishlistBoxName);
    await box.put(product.id, product.toMap());
  }

  static Future<void> removeFromWishlist(int productId) async {
    final box = Hive.box(wishlistBoxName);
    await box.delete(productId);
  }

  static Future<bool> toggleWishlist(Product product) async {
    final box = Hive.box(wishlistBoxName);
    if (box.containsKey(product.id)) {
      await box.delete(product.id);
      return false; 
    } else {
      await box.put(product.id, product.toMap());
      return true; 
    }
  }

  static List<Product> getAllWishlist() {
    final box = Hive.box(wishlistBoxName);
    final List<Product> items = [];
    for (var key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        items.add(Product.fromMap(Map<dynamic, dynamic>.from(data)));
      }
    }
    return items;
  }
}
