class Category {
  final int id;
  final String name;
  final bool isActive;

  Category({
    required this.id,
    required this.name,
    required this.isActive,
  });

  // ✅ FROM JSON (an toàn hơn)
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  // ✅ TO JSON (bắt buộc nếu lưu local)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isActive': isActive,
    };
  }
}