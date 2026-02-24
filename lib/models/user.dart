class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final UserType userType;
  final String? phone;
  final List<String> wishlist;
  final List<String> favoriteStores;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.userType,
    this.phone,
    this.wishlist = const [],
    this.favoriteStores = const [],
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    UserType? userType,
    String? phone,
    List<String>? wishlist,
    List<String>? favoriteStores,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      userType: userType ?? this.userType,
      phone: phone ?? this.phone,
      wishlist: wishlist ?? this.wishlist,
      favoriteStores: favoriteStores ?? this.favoriteStores,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
        'userType': userType.name,
        'phone': phone,
        'wishlist': wishlist,
        'favoriteStores': favoriteStores,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        avatarUrl: json['avatarUrl'] as String?,
        userType: UserType.values.byName(json['userType'] as String),
        phone: json['phone'] as String?,
        wishlist: List<String>.from(json['wishlist'] as List? ?? []),
        favoriteStores:
            List<String>.from(json['favoriteStores'] as List? ?? []),
      );
}

enum UserType { customer, business }
