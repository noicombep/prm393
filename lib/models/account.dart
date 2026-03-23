class Account {
  final int id;
  final String username;
  final String email;
  final String? fullName;
  final int roleId; // 👈 thêm
  final String? roleName; // 👈 optional (nếu backend trả)

  Account({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    required this.roleId,
    this.roleName,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      username: json['username'] ?? "",
      email: json['email'] ?? "",
      fullName: json['fullName'],
      roleId: json['roleId'] ?? 2, // 👈 default customer
      roleName: json['role'], // 👈 nếu backend trả "Admin"
    );
  }
}
