class Category {
  final int id;
  final String name;
  final bool isActive;
  // Note: products is omitted to avoid circular reference

  Category({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      isActive: json['isActive'],
    );
  }
}