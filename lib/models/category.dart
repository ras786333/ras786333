class Category {
  final String id;
  final String name;
  final String image;

  Category({
    required this.id,
    required this.name,
    required this.image,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
    };
  }
}

final List<Category> categories = [
  Category(
    id: '1',
    name: 'Smartphones',
    image: 'https://example.com/smartphones.jpg',
  ),
  Category(
    id: '2',
    name: 'Tablets',
    image: 'https://example.com/tablets.jpg',
  ),
  Category(
    id: '3',
    name: 'Laptops',
    image: 'https://example.com/laptops.jpg',
  ),
  Category(
    id: '4',
    name: 'Accessories',
    image: 'https://example.com/accessories.jpg',
  ),
  Category(
    id: '5',
    name: 'Wearables',
    image: 'https://example.com/wearables.jpg',
  ),
  Category(
    id: '6',
    name: 'Gaming',
    image: 'https://example.com/gaming.jpg',
  ),
];
