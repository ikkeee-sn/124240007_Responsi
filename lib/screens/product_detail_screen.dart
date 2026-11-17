import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isWishlisted = false;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
    _checkWishlistStatus();
  }

  void _checkWishlistStatus() {
    setState(() {
      _isWishlisted = LocalStorageService.isInWishlist(widget.productId);
    });
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final product = await ApiService.getSingleProduct(widget.productId);
      if (mounted) {
        setState(() {
          _product = product;
          _isLoading = false;
        });
        _checkWishlistStatus();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleWishlist() async {
    if (_product == null) return;

    final added = await LocalStorageService.toggleWishlist(_product!);

    setState(() {
      _isWishlisted = added;
    });

    if (!mounted) return;

    if (added) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('${_product!.title} berhasil ditambahkan ke Wishlist!'),
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
                child: Text('${_product!.title} dihapus dari Wishlist!'),
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
        title: const Text('Detail Produk'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        actions: [
          if (_product != null)
            Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  _isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: _isWishlisted ? const Color(0xFFE11D48) : const Color(0xFF64748B),
                  size: 24,
                ),
                tooltip: _isWishlisted ? 'Hapus dari Wishlist' : 'Tambah ke Wishlist',
                onPressed: _toggleWishlist,
              ),
            ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _product != null ? _buildBottomActionBar() : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
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
              'Memuat data detail produk...',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty || _product == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 60, color: Color(0xFFE11D48)),
              const SizedBox(height: 14),
              Text(
                'Gagal memuat produk: $_errorMessage',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFE11D48)),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchDetail,
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

    final product = _product!;
    final originalPrice = product.discountPercentage > 0
        ? product.price / (1 - (product.discountPercentage / 100))
        : null;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 320,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Stack(
              children: [
                product.images.isNotEmpty
                    ? PageView.builder(
                        itemCount: product.images.length,
                        onPageChanged: (idx) {
                          setState(() => _currentImageIndex = idx);
                        },
                        itemBuilder: (context, idx) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Image.network(
                                product.images[idx],
                                fit: BoxFit.contain,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                  child: Icon(Icons.image_not_supported_outlined,
                                      size: 64, color: Colors.grey),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Image.network(
                          product.thumbnail,
                          fit: BoxFit.contain,
                        ),
                      ),

                if (product.images.length > 1)
                  Positioned(
                    bottom: 14,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        product.images.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: _currentImageIndex == index ? 22 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _currentImageIndex == index
                                ? const Color(0xFF4F46E5)
                                : const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(6),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFC7D2FE)),
                        ),
                        child: Text(
                          product.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                      ),
                      if (product.discountPercentage > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE4E6),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFECDD3)),
                          ),
                          child: Text(
                            'Diskon ${product.discountPercentage.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFE11D48),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.4,
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF059669),
                            ),
                          ),
                          if (originalPrice != null)
                            Text(
                              '\$${originalPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 13.5,
                                color: Colors.grey.shade400,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 20),
                            const SizedBox(width: 4),
                            Text(
                              product.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: Color(0xFFB45309),
                              ),
                            ),
                            const Text(
                              ' / 5.0',
                              style: TextStyle(fontSize: 11, color: Color(0xFF92400E)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 28, color: Color(0xFFF1F5F9)),

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.storefront_rounded, size: 15, color: Color(0xFF64748B)),
                                  SizedBox(width: 4),
                                  Text(
                                    'Brand / Merek',
                                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                (product.brand != null && product.brand!.trim().isNotEmpty)
                                    ? product.brand!
                                    : 'Tidak tersedia',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.5,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.inventory_2_rounded, size: 15, color: Color(0xFF64748B)),
                                  SizedBox(width: 4),
                                  Text(
                                    'Informasi Stok',
                                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product.stock > 0
                                    ? '${product.stock} Unit Tersedia'
                                    : 'Stok Habis',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.5,
                                  color: product.stock > 0
                                      ? const Color(0xFF059669)
                                      : const Color(0xFFE11D48),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Deskripsi Produk',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    textAlign: TextAlign.justify,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF475569),
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isWishlisted
                  ? [const Color(0xFFE11D48), const Color(0xFFF43F5E)]
                  : [const Color(0xFF4F46E5), const Color(0xFF6366F1)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (_isWishlisted ? const Color(0xFFE11D48) : const Color(0xFF4F46E5)).withAlpha(80),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _toggleWishlist,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isWishlisted
                          ? 'Hapus dari Wishlist'
                          : 'Tambahkan ke Wishlist',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
