import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import 'login_screen.dart';
import 'product_detail_screen.dart';
import 'wishlist_screen.dart';

class ProductListScreen extends StatefulWidget {
  final String userName;

  const ProductListScreen({super.key, required this.userName});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> _allProducts = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';
  String _searchQuery = ''; 

  bool _isLoadingProducts = true;
  bool _isLoadingCategories = true;
  String _errorMessage = '';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    try {
      final categories = await ApiService.getCategories();
      if (mounted) {
        setState(() {
          _categories = ['All', ...categories];
          _isLoadingCategories = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _categories = ['All'];
          _isLoadingCategories = false;
        });
      }
    }
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoadingProducts = true;
      _errorMessage = '';
    });

    try {
      List<Product> fetchedProducts;
      if (_selectedCategory == 'All') {
        fetchedProducts = await ApiService.getProducts(limit: 30);
      } else {
        fetchedProducts =
            await ApiService.getProductsByCategory(_selectedCategory);
      }

      if (mounted) {
        setState(() {
          _allProducts = fetchedProducts;
          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoadingProducts = false;
        });
      }
    }
  }

  void _onCategorySelected(String category) {
    if (_selectedCategory == category) return;
    setState(() {
      _selectedCategory = category;
    });
    _fetchProducts();
  }

  List<Product> get _filteredProducts {
    if (_searchQuery.trim().isEmpty) {
      return _allProducts;
    }
    final query = _searchQuery.toLowerCase();
    return _allProducts.where((p) {
      final matchTitle = p.title.toLowerCase().contains(query);
      final matchCat = p.category.toLowerCase().contains(query);
      final matchBrand = (p.brand ?? '').toLowerCase().contains(query);
      return matchTitle || matchCat || matchBrand;
    }).toList();
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFE11D48)),
            SizedBox(width: 10),
            Text(
              'Konfirmasi Logout',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari akun ShoppingHub?',
          style: TextStyle(color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await LocalStorageService.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _toggleWishlistCard(Product product) async {
    final added = await LocalStorageService.toggleWishlist(product);
    if (!mounted) return;

    if (added) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('${product.title} ditambahkan ke Wishlist!'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.remove_circle_outline_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('${product.title} dihapus dari Wishlist!'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFE11D48),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  widget.userName.isNotEmpty
                      ? widget.userName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ShoppingHub',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.4,
                    ),
                  ),
                  Text(
                    'Halo, ${widget.userName} 👋',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ValueListenableBuilder(
            valueListenable: LocalStorageService.getWishlistBox().listenable(),
            builder: (context, Box box, _) {
              final count = box.length;
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.favorite_rounded, color: Color(0xFFE11D48)),
                      tooltip: 'Buka Wishlist',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WishlistScreen(),
                          ),
                        ).then((_) => setState(() {}));
                      },
                    ),
                  ),
                  if (count > 0)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE11D48),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          '$count',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          Container(
            margin: const EdgeInsets.only(right: 12, left: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: Color(0xFF64748B)),
              tooltip: 'Keluar',
              onPressed: _handleLogout,
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() => _searchQuery = val);
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari produk, kategori, atau brand...',
                    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF4F46E5), size: 22),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF64748B)),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildCategorySlider(),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.grid_view_rounded, size: 16, color: Color(0xFF4F46E5)),
                    const SizedBox(width: 6),
                    Text(
                      _isLoadingProducts
                          ? 'Memuat katalog...'
                          : '${_filteredProducts.length} Produk Tersedia',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
                if (_selectedCategory != 'All')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFC7D2FE)),
                    ),
                    child: Text(
                      _selectedCategory,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF4F46E5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Expanded(child: _buildProductContent()),
        ],
      ),
    );
  }

  Widget _buildCategorySlider() {
    if (_isLoadingCategories) {
      return const SizedBox(
        height: 38,
        child: Center(
          child: Text(
            'Mengambil kategori produk...',
            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          ),
        ),
      );
    }

    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _onCategorySelected(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                        )
                      : null,
                  color: isSelected ? null : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF4F46E5).withAlpha(60),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    cat == 'All' ? '🌟 Semua' : cat,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF475569),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductContent() {
    if (_isLoadingProducts) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFF4F46E5),
              strokeWidth: 2.5,
            ),
            SizedBox(height: 14),
            Text(
              'Memuat data produk...',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 60, color: Color(0xFFE11D48)),
              const SizedBox(height: 14),
              Text(
                'Terjadi kesalahan:\n$_errorMessage',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFE11D48)),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchProducts,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final displayList = _filteredProducts;

    if (displayList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 64, color: Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Tidak ada produk untuk "$_searchQuery"'
                  : 'Tidak ada produk pada kategori ini.',
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF4F46E5),
      onRefresh: _fetchProducts,
      child: GridView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: displayList.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemBuilder: (context, index) {
          final product = displayList[index];
          return _buildProductCard(product);
        },
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(productId: product.id),
              ),
            ).then((_) => setState(() {}));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Image.network(
                        product.thumbnail,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(Icons.broken_image_outlined, color: Colors.grey),
                        ),
                      ),
                    ),

                    if (product.discountPercentage > 0)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE11D48),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '-${product.discountPercentage.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),

                    Positioned(
                      top: 8,
                      right: 8,
                      child: ValueListenableBuilder(
                        valueListenable: LocalStorageService.getWishlistBox().listenable(),
                        builder: (context, Box box, _) {
                          final isWishlisted = box.containsKey(product.id);
                          return GestureDetector(
                            onTap: () => _toggleWishlistCard(product),
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(30),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                size: 17,
                                color: isWishlisted ? const Color(0xFFE11D48) : const Color(0xFF64748B),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    Positioned(
                      bottom: 6,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(220),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 13),
                            const SizedBox(width: 2),
                            Text(
                              product.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Kategori Label
                          Text(
                            product.category.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF4F46E5),
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 3),

                          Text(
                            product.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),

                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
