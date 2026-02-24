import 'package:flutter/foundation.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  // Mock user database
  final List<Map<String, dynamic>> _mockUsers = [
    {
      'id': 'customer_1',
      'name': 'Alex Customer',
      'email': 'customer@demo.com',
      'password': 'password',
      'userType': 'customer',
      'phone': '+34 600 000 001',
      'favoriteStores': ['store_1', 'store_3'],
      'wishlist': ['product_1', 'product_5'],
    },
    {
      'id': 'business_1',
      'name': 'Maria Business',
      'email': 'business@demo.com',
      'password': 'password',
      'userType': 'business',
      'phone': '+34 600 000 002',
      'favoriteStores': <String>[],
      'wishlist': <String>[],
    },
  ];

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  bool get isBusinessUser => _currentUser?.userType == UserType.business;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final userMap = _mockUsers.firstWhere(
      (u) => u['email'] == email && u['password'] == password,
      orElse: () => {},
    );

    if (userMap.isEmpty) {
      _error = 'Invalid email or password';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _currentUser = UserModel(
      id: userMap['id'] as String,
      name: userMap['name'] as String,
      email: userMap['email'] as String,
      userType: UserType.values.byName(userMap['userType'] as String),
      phone: userMap['phone'] as String?,
      favoriteStores: List<String>.from(userMap['favoriteStores'] as List),
      wishlist: List<String>.from(userMap['wishlist'] as List),
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required UserType userType,
    String? phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final exists = _mockUsers.any((u) => u['email'] == email);
    if (exists) {
      _error = 'Email already in use';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final newId =
        '${userType.name}_${DateTime.now().millisecondsSinceEpoch}';
    final newUser = {
      'id': newId,
      'name': name,
      'email': email,
      'password': password,
      'userType': userType.name,
      'phone': phone,
      'favoriteStores': <String>[],
      'wishlist': <String>[],
    };
    _mockUsers.add(newUser);

    _currentUser = UserModel(
      id: newId,
      name: name,
      email: email,
      userType: userType,
      phone: phone,
      favoriteStores: const [],
      wishlist: const [],
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void updateProfile({String? name, String? phone}) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(name: name, phone: phone);
    notifyListeners();
  }

  void toggleFavoriteStore(String storeId) {
    if (_currentUser == null) return;
    final favorites = List<String>.from(_currentUser!.favoriteStores);
    if (favorites.contains(storeId)) {
      favorites.remove(storeId);
    } else {
      favorites.add(storeId);
    }
    _currentUser = _currentUser!.copyWith(favoriteStores: favorites);
    notifyListeners();
  }

  void toggleWishlistItem(String productId) {
    if (_currentUser == null) return;
    final wishlist = List<String>.from(_currentUser!.wishlist);
    if (wishlist.contains(productId)) {
      wishlist.remove(productId);
    } else {
      wishlist.add(productId);
    }
    _currentUser = _currentUser!.copyWith(wishlist: wishlist);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
