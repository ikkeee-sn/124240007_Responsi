import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';
import '../services/local_storage_service.dart';
import 'product_detail_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Wishlist Saya'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: ValueListenableBuilder(
        valueListenable: LocalStorageService.getWishlistBox().listenable(),
        builder: (context, Box box, _) {
          final List<Product> wishlistProducts = [];
          for (var key in box.keys) {
            final data = box.get(key);
            if (data != null) {
              wishlistProducts.add(
                Product.fromMap(Map<dynamic, dynamic>.from(data)),
              );
            }
          }

          if (wishlistProducts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE4E6),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE11D48).withAlpha(40),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_outline_rounded,
                        size: 50,
                        color: Color(0xFFE11D48),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Wishlist Anda Masih Kosong',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Belum ada produk yang disimpan di Local Database. Jelajahi katalog dan tekan ikon hati untuk menyimpannya.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13.5, color: Color(0xFF64748B), height: 1.4),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      height: 48,
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
                          onTap: () => Navigator.pop(context),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Jelajahi Produk',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.storage_rounded,
                            color: Color(0xFF4F46E5), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Wishlist Tersimpan (${wishlistProducts.length} Produk)',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(14),
                  itemCount: wishlistProducts.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final product = wishlistProducts[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(6),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
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
                                builder: (context) =>
                                    ProductDetailScreen(productId: product.id),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    color: const Color(0xFFF8FAFC),
                                    padding: const EdgeInsets.all(6),
                                    child: Image.network(
                                      product.thumbnail,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Center(
                                        child: Icon(
                                          Icons.image_not_supported_outlined,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEEF2FF),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          product.category.toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF4F46E5),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        product.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Text(
                                            '\$${product.price.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w900,
                                              color: Color(0xFF059669),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Row(
                                            children: [
                                              const Icon(Icons.star_rounded,
                                                  color: Color(0xFFF59E0B), size: 16),
                                              const SizedBox(width: 2),
                                              Text(
                                                product.rating.toStringAsFixed(1),
                                                style: const TextStyle(
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF334155),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFE4E6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: Color(0xFFE11D48),
                                      size: 20,
                                    ),
                                    tooltip: 'Hapus dari Wishlist',
                                    onPressed: () async {
                                      await LocalStorageService.removeFromWishlist(
                                        product.id,
                                      );
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                const Icon(
                                                  Icons.remove_circle_outline_rounded,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    '${product.title} dihapus dari wishlist',
                                                  ),
                                                ),
                                              ],
                                            ),
                                            backgroundColor: const Color(0xFFE11D48),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
