class UserModel {
  final int id;
  final String email;
  final String fullname;
  final String role;
  final String? token;

  UserModel({
    required this.id,
    required this.email,
    required this.fullname,
    required this.role,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      fullname: json['fullname'] ?? json['name'] ?? '',
      role: json['role'] ?? 'pasien',
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullname': fullname,
      'role': role,
      'token': token,
    };
  }
}