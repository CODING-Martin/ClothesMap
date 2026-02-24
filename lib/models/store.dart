class StoreModel {
  final String id;
  final String ownerId;
  final String name;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final String? logoUrl;
  final String? bannerUrl;
  final List<String> categories;
  final double rating;
  final int reviewCount;
  final bool isVerified;
  final bool isPremium;
  final PremiumTier? premiumTier;
  final String phone;
  final String? website;
  final Map<String, String> openingHours;
  final List<String> productIds;

  const StoreModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.logoUrl,
    this.bannerUrl,
    this.categories = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isVerified = false,
    this.isPremium = false,
    this.premiumTier,
    required this.phone,
    this.website,
    this.openingHours = const {},
    this.productIds = const [],
  });

  StoreModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    String? logoUrl,
    String? bannerUrl,
    List<String>? categories,
    double? rating,
    int? reviewCount,
    bool? isVerified,
    bool? isPremium,
    PremiumTier? premiumTier,
    String? phone,
    String? website,
    Map<String, String>? openingHours,
    List<String>? productIds,
  }) {
    return StoreModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      logoUrl: logoUrl ?? this.logoUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      categories: categories ?? this.categories,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isVerified: isVerified ?? this.isVerified,
      isPremium: isPremium ?? this.isPremium,
      premiumTier: premiumTier ?? this.premiumTier,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      openingHours: openingHours ?? this.openingHours,
      productIds: productIds ?? this.productIds,
    );
  }
}

enum PremiumTier { basic, pro, enterprise }
