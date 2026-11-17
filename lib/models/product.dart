class Product {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String? brand;
  final String thumbnail;
  final List<String> images;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    this.brand,
    required this.thumbnail,
    required this.images,
  });  

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock'] is int ? json['stock'] : int.tryParse(json['stock'].toString()) ?? 0,
      brand: json['brand']?.toString(),
      thumbnail: json['thumbnail']?.toString() ?? (json['images'] != null && (json['images'] as List).isNotEmpty ? json['images'][0].toString() : ''),
      images: json['images'] != null
          ? List<String>.from((json['images'] as List).map((x) => x.toString()))
          : [],
    ); 
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'discountPercentage': discountPercentage,
      'rating': rating,
      'stock': stock,
      'brand': brand,
      'thumbnail': thumbnail,
      'images': images,
    };
  }

  factory Product.fromMap(Map<dynamic, dynamic> map) {
    return Product(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()) ?? 0,
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      discountPercentage: (map['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      stock: map['stock'] is int ? map['stock'] : int.tryParse(map['stock'].toString()) ?? 0,
      brand: map['brand']?.toString(),
      thumbnail: map['thumbnail']?.toString() ?? '',
      images: map['images'] != null
          ? List<String>.from((map['images'] as List).map((x) => x.toString()))
          : [],
    );
  }
}
