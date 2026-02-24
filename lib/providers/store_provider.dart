import 'package:flutter/foundation.dart';
import '../models/store.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../models/message.dart';
import '../models/notification.dart';

class StoreProvider extends ChangeNotifier {
  final List<StoreModel> _stores = _generateMockStores();
  final List<ProductModel> _products = _generateMockProducts();
  final List<ReviewModel> _reviews = _generateMockReviews();
  final List<ChatModel> _chats = _generateMockChats();
  final List<NotificationModel> _notifications = _generateMockNotifications();

  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedColor = 'All';
  String _selectedSize = '';
  String _selectedPriceRange = 'Any';

  List<StoreModel> get stores => _stores;
  List<ProductModel> get products => _products;
  List<ReviewModel> get reviews => _reviews;
  List<ChatModel> get chats => _chats;
  List<NotificationModel> get notifications => _notifications;
  int get unreadNotificationsCount =>
      _notifications.where((n) => !n.isRead).length;
  int get unreadMessagesCount =>
      _chats.fold(0, (sum, c) => sum + c.unreadCount);

  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get selectedColor => _selectedColor;
  String get selectedSize => _selectedSize;
  String get selectedPriceRange => _selectedPriceRange;

  List<StoreModel> get filteredStores {
    var result = List<StoreModel>.from(_stores);

    // Sort: premium first
    result.sort((a, b) {
      if (a.isPremium && !b.isPremium) return -1;
      if (!a.isPremium && b.isPremium) return 1;
      return b.rating.compareTo(a.rating);
    });

    if (_searchQuery.isNotEmpty) {
      result = result
          .where((s) =>
              s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              s.description.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_selectedCategory != 'All') {
      result = result
          .where((s) => s.categories.contains(_selectedCategory))
          .toList();
    }

    return result;
  }

  List<ProductModel> getProductsForStore(String storeId) =>
      _products.where((p) => p.storeId == storeId).toList();

  List<ProductModel> get filteredProducts {
    var result = List<ProductModel>.from(_products);

    if (_searchQuery.isNotEmpty) {
      result = result
          .where((p) =>
              p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.description.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_selectedCategory != 'All') {
      result = result.where((p) => p.category == _selectedCategory).toList();
    }

    if (_selectedColor != 'All' && _selectedColor.isNotEmpty) {
      result =
          result.where((p) => p.colors.contains(_selectedColor)).toList();
    }

    if (_selectedSize.isNotEmpty) {
      result = result.where((p) => p.sizes.contains(_selectedSize)).toList();
    }

    if (_selectedPriceRange != 'Any') {
      result = result.where((p) {
        final price = p.effectivePrice;
        switch (_selectedPriceRange) {
          case 'Under €20':
            return price < 20;
          case '€20 - €50':
            return price >= 20 && price <= 50;
          case '€50 - €100':
            return price > 50 && price <= 100;
          case 'Over €100':
            return price > 100;
          default:
            return true;
        }
      }).toList();
    }

    return result;
  }

  List<ReviewModel> getReviewsForStore(String storeId) =>
      _reviews.where((r) => r.storeId == storeId).toList();

  ChatModel? getChatForStore(String storeId, String customerId) {
    try {
      return _chats.firstWhere(
          (c) => c.storeId == storeId && c.customerId == customerId);
    } catch (_) {
      return null;
    }
  }

  ChatModel getOrCreateChat({
    required String storeId,
    required String storeName,
    required String customerId,
    required String customerName,
    String? storeLogoUrl,
  }) {
    final existing = getChatForStore(storeId, customerId);
    if (existing != null) return existing;

    final chat = ChatModel(
      id: 'chat_${DateTime.now().millisecondsSinceEpoch}',
      customerId: customerId,
      customerName: customerName,
      storeId: storeId,
      storeName: storeName,
      storeLogoUrl: storeLogoUrl,
      messages: const [],
      lastActivity: DateTime.now(),
    );
    _chats.add(chat);
    notifyListeners();
    return chat;
  }

  void sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String content,
  }) {
    final idx = _chats.indexWhere((c) => c.id == chatId);
    if (idx == -1) return;

    final msg = MessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      content: content,
      timestamp: DateTime.now(),
    );

    final chat = _chats[idx];
    final updatedMessages = [...chat.messages, msg];
    _chats[idx] = ChatModel(
      id: chat.id,
      customerId: chat.customerId,
      customerName: chat.customerName,
      storeId: chat.storeId,
      storeName: chat.storeName,
      storeLogoUrl: chat.storeLogoUrl,
      messages: updatedMessages,
      lastActivity: DateTime.now(),
    );

    // Auto-reply from vendor after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      _autoReply(chatId, chat.storeId, chat.storeName);
    });

    notifyListeners();
  }

  void _autoReply(String chatId, String storeId, String storeName) {
    final replies = [
      'Thank you for your message! How can we help you today?',
      'We have that item in stock! Would you like to know more?',
      'Great choice! We also have a promotion this week.',
      'Feel free to visit us anytime. We\'re open until 9 PM!',
    ];
    final reply = replies[DateTime.now().millisecond % replies.length];
    sendMessage(
      chatId: chatId,
      senderId: storeId,
      senderName: storeName,
      content: reply,
    );
  }

  void addReview({
    required String storeId,
    required String userId,
    required String userName,
    required double rating,
    required String comment,
  }) {
    final review = ReviewModel(
      id: 'review_${DateTime.now().millisecondsSinceEpoch}',
      storeId: storeId,
      userId: userId,
      userName: userName,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );
    _reviews.add(review);

    final idx = _stores.indexWhere((s) => s.id == storeId);
    if (idx != -1) {
      final store = _stores[idx];
      final allRatings = getReviewsForStore(storeId).map((r) => r.rating);
      final newRating =
          allRatings.reduce((a, b) => a + b) / allRatings.length;
      _stores[idx] = store.copyWith(
        rating: double.parse(newRating.toStringAsFixed(1)),
        reviewCount: store.reviewCount + 1,
      );
    }
    notifyListeners();
  }

  void markNotificationRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllNotificationsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setColor(String color) {
    _selectedColor = color;
    notifyListeners();
  }

  void setSize(String size) {
    _selectedSize = size;
    notifyListeners();
  }

  void setPriceRange(String range) {
    _selectedPriceRange = range;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = 'All';
    _selectedColor = 'All';
    _selectedSize = '';
    _selectedPriceRange = 'Any';
    notifyListeners();
  }

  // Business methods
  void addStore(StoreModel store) {
    _stores.add(store);
    notifyListeners();
  }

  void updateStore(StoreModel updated) {
    final idx = _stores.indexWhere((s) => s.id == updated.id);
    if (idx != -1) {
      _stores[idx] = updated;
      notifyListeners();
    }
  }

  void addProduct(ProductModel product) {
    _products.add(product);
    notifyListeners();
  }

  void updateProduct(ProductModel updated) {
    final idx = _products.indexWhere((p) => p.id == updated.id);
    if (idx != -1) {
      _products[idx] = updated;
      notifyListeners();
    }
  }

  void deleteProduct(String productId) {
    _products.removeWhere((p) => p.id == productId);
    notifyListeners();
  }

  StoreModel? getStoreByOwnerId(String ownerId) {
    try {
      return _stores.firstWhere((s) => s.ownerId == ownerId);
    } catch (_) {
      return null;
    }
  }

  StoreModel? getStoreById(String id) {
    try {
      return _stores.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}

List<StoreModel> _generateMockStores() => [
      const StoreModel(
        id: 'store_1',
        ownerId: 'business_1',
        name: 'Moda Madrid',
        description:
            'Your one-stop fashion destination in the heart of Madrid. We offer the latest trends from top European designers.',
        address: 'Calle Gran Vía 32, Madrid',
        latitude: 40.4200,
        longitude: -3.7025,
        categories: ['Tops', 'Dresses', 'Outerwear', 'Accessories'],
        rating: 4.7,
        reviewCount: 128,
        isVerified: true,
        isPremium: true,
        premiumTier: PremiumTier.pro,
        phone: '+34 91 000 0001',
        website: 'https://modamadrid.es',
        openingHours: {
          'Mon-Fri': '10:00 - 21:00',
          'Sat': '10:00 - 22:00',
          'Sun': '11:00 - 20:00',
        },
        productIds: ['product_1', 'product_2', 'product_3'],
      ),
      const StoreModel(
        id: 'store_2',
        ownerId: 'business_2',
        name: 'Urban Threads',
        description:
            'Streetwear and urban fashion for the modern trendsetter. Exclusive collections and limited editions.',
        address: 'Calle Fuencarral 45, Madrid',
        latitude: 40.4245,
        longitude: -3.7012,
        categories: ['Tops', 'Bottoms', 'Footwear', 'Sportswear'],
        rating: 4.4,
        reviewCount: 89,
        isVerified: true,
        isPremium: false,
        phone: '+34 91 000 0002',
        openingHours: {
          'Mon-Sat': '11:00 - 21:00',
          'Sun': 'Closed',
        },
        productIds: ['product_4', 'product_5', 'product_6'],
      ),
      const StoreModel(
        id: 'store_3',
        ownerId: 'business_3',
        name: 'Eleganza',
        description:
            'Luxury and formal wear for special occasions. Tailoring and bespoke services available.',
        address: 'Paseo de la Castellana 10, Madrid',
        latitude: 40.4180,
        longitude: -3.6935,
        categories: ['Formal', 'Dresses', 'Accessories'],
        rating: 4.9,
        reviewCount: 214,
        isVerified: true,
        isPremium: true,
        premiumTier: PremiumTier.enterprise,
        phone: '+34 91 000 0003',
        website: 'https://eleganza.es',
        openingHours: {
          'Mon-Fri': '10:00 - 20:00',
          'Sat': '10:00 - 19:00',
          'Sun': 'Closed',
        },
        productIds: ['product_7', 'product_8'],
      ),
      const StoreModel(
        id: 'store_4',
        ownerId: 'business_4',
        name: 'Sport & Style',
        description:
            'Performance sportswear meets street style. Everything you need for an active lifestyle.',
        address: 'Calle Serrano 22, Madrid',
        latitude: 40.4235,
        longitude: -3.6880,
        categories: ['Sportswear', 'Footwear', 'Casual'],
        rating: 4.2,
        reviewCount: 67,
        isVerified: false,
        isPremium: false,
        phone: '+34 91 000 0004',
        openingHours: {
          'Mon-Sun': '09:00 - 22:00',
        },
        productIds: ['product_9', 'product_10'],
      ),
      const StoreModel(
        id: 'store_5',
        ownerId: 'business_5',
        name: 'Vintage Vibes',
        description:
            'Curated vintage and second-hand fashion. Unique pieces from the 70s to 2000s.',
        address: 'Calle Corredera Baja 15, Madrid',
        latitude: 40.4150,
        longitude: -3.7055,
        categories: ['Casual', 'Tops', 'Bottoms', 'Accessories'],
        rating: 4.6,
        reviewCount: 103,
        isVerified: true,
        isPremium: false,
        phone: '+34 91 000 0005',
        openingHours: {
          'Tue-Sun': '12:00 - 20:00',
          'Mon': 'Closed',
        },
        productIds: ['product_11', 'product_12'],
      ),
    ];

List<ProductModel> _generateMockProducts() => [
      // Moda Madrid products
      const ProductModel(
        id: 'product_1',
        storeId: 'store_1',
        name: 'Floral Summer Dress',
        description:
            'Beautiful floral print dress perfect for summer days. Lightweight fabric with a flattering A-line cut.',
        price: 89.99,
        discountPrice: 64.99,
        images: [],
        category: 'Dresses',
        sizes: ['XS', 'S', 'M', 'L'],
        colors: ['White', 'Pink', 'Blue'],
        isAvailable: true,
        stockCount: 15,
      ),
      const ProductModel(
        id: 'product_2',
        storeId: 'store_1',
        name: 'Classic White Blouse',
        description:
            'Timeless white blouse with elegant button details. Versatile enough for office or casual wear.',
        price: 45.00,
        images: [],
        category: 'Tops',
        sizes: ['XS', 'S', 'M', 'L', 'XL'],
        colors: ['White', 'Multicolor'],
        isAvailable: true,
        stockCount: 30,
      ),
      const ProductModel(
        id: 'product_3',
        storeId: 'store_1',
        name: 'Silk Evening Scarf',
        description:
            'Luxurious 100% silk scarf with abstract print. The perfect accessory for any outfit.',
        price: 35.00,
        images: [],
        category: 'Accessories',
        sizes: [],
        colors: ['Multicolor', 'Blue', 'Red'],
        isAvailable: true,
        stockCount: 50,
      ),
      // Urban Threads products
      const ProductModel(
        id: 'product_4',
        storeId: 'store_2',
        name: 'Oversized Graphic Tee',
        description:
            'Bold graphic tee with exclusive street art print. Made from 100% organic cotton.',
        price: 29.99,
        images: [],
        category: 'Tops',
        sizes: ['S', 'M', 'L', 'XL', 'XXL'],
        colors: ['Black', 'White', 'Grey'],
        isAvailable: true,
        stockCount: 45,
      ),
      const ProductModel(
        id: 'product_5',
        storeId: 'store_2',
        name: 'Cargo Joggers',
        description:
            'Comfortable cargo joggers with multiple pockets. Perfect for a relaxed street look.',
        price: 59.99,
        discountPrice: 44.99,
        images: [],
        category: 'Bottoms',
        sizes: ['S', 'M', 'L', 'XL'],
        colors: ['Black', 'Brown', 'Green'],
        isAvailable: true,
        stockCount: 22,
      ),
      const ProductModel(
        id: 'product_6',
        storeId: 'store_2',
        name: 'High-Top Sneakers',
        description:
            'Limited edition high-top sneakers with premium leather upper. Collector\'s item.',
        price: 149.99,
        images: [],
        category: 'Footwear',
        sizes: ['37', '38', '39', '40', '41', '42'],
        colors: ['White', 'Black'],
        isAvailable: true,
        stockCount: 8,
      ),
      // Eleganza products
      const ProductModel(
        id: 'product_7',
        storeId: 'store_3',
        name: 'Cocktail Evening Gown',
        description:
            'Stunning evening gown in royal blue with intricate beadwork. Perfect for galas and formal events.',
        price: 349.00,
        images: [],
        category: 'Formal',
        sizes: ['XS', 'S', 'M', 'L'],
        colors: ['Blue', 'Black', 'Red'],
        isAvailable: true,
        stockCount: 5,
      ),
      const ProductModel(
        id: 'product_8',
        storeId: 'store_3',
        name: 'Pearl Necklace Set',
        description:
            'Elegant pearl necklace and earring set. Freshwater pearls with gold-plated clasps.',
        price: 189.00,
        images: [],
        category: 'Accessories',
        sizes: [],
        colors: ['White'],
        isAvailable: true,
        stockCount: 12,
      ),
      // Sport & Style products
      const ProductModel(
        id: 'product_9',
        storeId: 'store_4',
        name: 'Performance Running Shorts',
        description:
            'Lightweight and breathable running shorts with moisture-wicking technology.',
        price: 34.99,
        images: [],
        category: 'Sportswear',
        sizes: ['S', 'M', 'L', 'XL'],
        colors: ['Black', 'Blue', 'Red'],
        isAvailable: true,
        stockCount: 60,
      ),
      const ProductModel(
        id: 'product_10',
        storeId: 'store_4',
        name: 'Trail Running Shoes',
        description:
            'Durable trail running shoes with advanced grip technology. Waterproof upper.',
        price: 119.99,
        discountPrice: 89.99,
        images: [],
        category: 'Footwear',
        sizes: ['37', '38', '39', '40', '41', '42'],
        colors: ['Grey', 'Blue'],
        isAvailable: true,
        stockCount: 18,
      ),
      // Vintage Vibes products
      const ProductModel(
        id: 'product_11',
        storeId: 'store_5',
        name: '90s Denim Jacket',
        description:
            'Authentic 90s oversized denim jacket in excellent vintage condition.',
        price: 65.00,
        images: [],
        category: 'Outerwear',
        sizes: ['M', 'L', 'XL'],
        colors: ['Blue'],
        isAvailable: true,
        stockCount: 3,
      ),
      const ProductModel(
        id: 'product_12',
        storeId: 'store_5',
        name: 'Retro Band Tee',
        description:
            'Original vintage band t-shirt from the 80s. Unique collectible piece.',
        price: 45.00,
        images: [],
        category: 'Tops',
        sizes: ['S', 'M', 'L'],
        colors: ['Black', 'White'],
        isAvailable: true,
        stockCount: 7,
      ),
    ];

List<ReviewModel> _generateMockReviews() => [
      ReviewModel(
        id: 'review_1',
        storeId: 'store_1',
        userId: 'user_demo_1',
        userName: 'Sofia R.',
        rating: 5.0,
        comment:
            'Absolutely love this store! The staff is so helpful and the selection is amazing. Found my perfect outfit for a wedding here.',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      ReviewModel(
        id: 'review_2',
        storeId: 'store_1',
        userId: 'user_demo_2',
        userName: 'Carlos M.',
        rating: 4.0,
        comment:
            'Great variety and good prices. The floral dress I bought got so many compliments. Will definitely come back!',
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
      ),
      ReviewModel(
        id: 'review_3',
        storeId: 'store_2',
        userId: 'user_demo_3',
        userName: 'Juan P.',
        rating: 5.0,
        comment:
            'Best streetwear in Madrid! The graphic tees are fire and the prices are fair.',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      ReviewModel(
        id: 'review_4',
        storeId: 'store_3',
        userId: 'user_demo_4',
        userName: 'Isabella F.',
        rating: 5.0,
        comment:
            'The gown I purchased for my gala was absolutely stunning. Top-notch quality and the alteration service was perfect.',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      ReviewModel(
        id: 'review_5',
        storeId: 'store_3',
        userId: 'user_demo_5',
        userName: 'María G.',
        rating: 5.0,
        comment:
            'Exceptional quality and service. The pearl set I bought was even more beautiful in person.',
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
    ];

List<ChatModel> _generateMockChats() => [
      ChatModel(
        id: 'chat_1',
        customerId: 'customer_1',
        customerName: 'Alex Customer',
        storeId: 'store_1',
        storeName: 'Moda Madrid',
        messages: [
          MessageModel(
            id: 'msg_1',
            chatId: 'chat_1',
            senderId: 'store_1',
            senderName: 'Moda Madrid',
            content: 'Hello! Welcome to Moda Madrid. How can we help you today?',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            isRead: true,
          ),
          MessageModel(
            id: 'msg_2',
            chatId: 'chat_1',
            senderId: 'customer_1',
            senderName: 'Alex Customer',
            content: 'Hi! Do you have the floral dress in size S?',
            timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 55)),
            isRead: true,
          ),
          MessageModel(
            id: 'msg_3',
            chatId: 'chat_1',
            senderId: 'store_1',
            senderName: 'Moda Madrid',
            content:
                'Yes, we have it in S! We also have a 25% discount on it this week. Come visit us!',
            timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
            isRead: false,
          ),
        ],
        lastActivity: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
      ),
    ];

List<NotificationModel> _generateMockNotifications() => [
      NotificationModel(
        id: 'notif_1',
        userId: 'customer_1',
        title: 'New message from Moda Madrid',
        body: 'Yes, we have it in S! We also have a 25% discount...',
        type: NotificationType.message,
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
        referenceId: 'chat_1',
      ),
      NotificationModel(
        id: 'notif_2',
        userId: 'customer_1',
        title: '🎉 Flash Sale at Urban Threads!',
        body: 'Up to 40% off on all streetwear today only. Don\'t miss out!',
        type: NotificationType.promotion,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        referenceId: 'store_2',
      ),
      NotificationModel(
        id: 'notif_3',
        userId: 'customer_1',
        title: 'New Store Near You',
        body: 'Vintage Vibes has opened near your location. Check it out!',
        type: NotificationType.newStore,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        referenceId: 'store_5',
        isRead: true,
      ),
      NotificationModel(
        id: 'notif_4',
        userId: 'customer_1',
        title: 'Weekend Special at Eleganza',
        body: '15% off on all formal wear this weekend. Use code ELEGANCE15.',
        type: NotificationType.promotion,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        referenceId: 'store_3',
        isRead: true,
      ),
    ];
