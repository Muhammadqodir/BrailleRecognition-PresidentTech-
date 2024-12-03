import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class User {
  String name;
  String token;
  String email;
  String phone;
  String role;
  String photo_url;

  User({
    required this.name,
    required this.token,
    required this.email,
    required this.phone,
    required this.role,
    required this.photo_url,
  });

  User.undefined({
    this.name = "Undefined",
    this.token = "Undefined",
    this.email = "Undefined",
    this.phone = "Undefined",
    this.role = "Undefined",
    this.photo_url = "Undefined",
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'token': token,
      'email': email,
      'phone': phone,
      'role': role,
      'photo_url': photo_url,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'] as String,
      token: map['token'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      role: map['role'] as String,
      photo_url: map['photo_url'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);
}
