import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';
import 'product_list_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isLoginFailed = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _isLoginFailed = true;
        _errorMessage = 'Username dan password wajib diisi!';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(_errorMessage)),
            ],
          ),
          backgroundColor: const Color(0xFFE11D48),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _isLoginFailed = false;
      _errorMessage = '';
    });

    final user = await LocalStorageService.login(username, password);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Selamat datang, ${user.fullName}!')),
            ],
          ),
          backgroundColor: const Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProductListScreen(userName: user.fullName),
        ),
      );
    } else {
      setState(() {
        _isLoginFailed = true;
        _errorMessage = 'Username atau password salah!';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(_errorMessage)),
            ],
          ),
          backgroundColor: const Color(0xFFE11D48),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withAlpha(80),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    size: 46,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // Title & Subtitle
                const Text(
                  'ShoppingHub',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Temukan & simpan produk favoritmu dengan mudah',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 32),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(8),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(26.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Masuk Akun',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Gunakan akun terdaftar Anda',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 22),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          hintText: 'Masukkan username',
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                          prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF64748B)),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: _isLoginFailed ? const Color(0xFFE11D48) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: _isLoginFailed ? const Color(0xFFE11D48) : const Color(0xFFE2E8F0),
                              width: _isLoginFailed ? 1.5 : 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFF4F46E5),
                              width: 1.8,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Masukkan password',
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                          prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF64748B)),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: const Color(0xFF64748B),
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: _isLoginFailed ? const Color(0xFFE11D48) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: _isLoginFailed ? const Color(0xFFE11D48) : const Color(0xFFE2E8F0),
                              width: _isLoginFailed ? 1.5 : 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFF4F46E5),
                              width: 1.8,
                            ),
                          ),
                        ),
                      ),

                      if (_isLoginFailed) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: Color(0xFFE11D48), size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _errorMessage,
                                style: const TextStyle(
                                  color: Color(0xFFE11D48),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 24),
                      Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4F46E5).withAlpha(80),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: _isLoading ? null : _handleLogin,
                            child: Center(
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.2,
                                      ),
                                    )
                                  : const Text(
                                      'Masuk ke ShoppingHub',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Belum punya akun? ',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13.5),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Daftar di sini',
                        style: TextStyle(
                          color: Color(0xFF4F46E5),
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
