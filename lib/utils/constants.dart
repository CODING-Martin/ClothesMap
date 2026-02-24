class AppConstants {
  static const String appName = 'ClothesMap';
  static const String appVersion = '1.0.0';

  // Map defaults (Madrid, Spain)
  static const double defaultLatitude = 40.4168;
  static const double defaultLongitude = -3.7038;
  static const double defaultZoom = 14.0;

  // Clothing categories
  static const List<String> categories = [
    'All',
    'Tops',
    'Bottoms',
    'Dresses',
    'Outerwear',
    'Footwear',
    'Accessories',
    'Sportswear',
    'Formal',
    'Casual',
  ];

  // Clothing sizes
  static const List<String> sizes = [
    'XS',
    'S',
    'M',
    'L',
    'XL',
    'XXL',
    '36',
    '37',
    '38',
    '39',
    '40',
    '41',
    '42',
  ];

  // Clothing colors
  static const List<String> colors = [
    'All',
    'Black',
    'White',
    'Red',
    'Blue',
    'Green',
    'Yellow',
    'Pink',
    'Purple',
    'Brown',
    'Grey',
    'Orange',
    'Multicolor',
  ];

  // Price ranges
  static const List<String> priceRanges = [
    'Any',
    'Under €20',
    '€20 - €50',
    '€50 - €100',
    'Over €100',
  ];

  // Premium plans
  static const List<Map<String, dynamic>> premiumPlans = [
    {
      'name': 'Basic',
      'price': 9.99,
      'period': 'month',
      'features': [
        'Top 10 search results',
        'Store badge',
        'Basic analytics',
      ],
    },
    {
      'name': 'Pro',
      'price': 24.99,
      'period': 'month',
      'features': [
        'Top 3 search results',
        'Premium badge',
        'Advanced analytics',
        'Promotional banners',
        'Priority support',
      ],
    },
    {
      'name': 'Enterprise',
      'price': 59.99,
      'period': 'month',
      'features': [
        '#1 search results',
        'Enterprise badge',
        'Full analytics suite',
        'Unlimited promotions',
        'Dedicated support',
        'Custom store page',
      ],
    },
  ];
}
