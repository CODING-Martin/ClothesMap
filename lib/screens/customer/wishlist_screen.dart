import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/store_provider.dart';
import '../../widgets/store_card.dart';
import '../../widgets/product_card.dart';
import 'store_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final storeProvider = context.watch<StoreProvider>();

    final favoriteStores = storeProvider.stores
        .where((s) =>
            authProvider.currentUser?.favoriteStores.contains(s.id) ?? false)
        .toList();

    final wishlistProducts = storeProvider.products
        .where((p) =>
            authProvider.currentUser?.wishlist.contains(p.id) ?? false)
        .toList();

    final promotions = storeProvider.products
        .where((p) => p.hasDiscount)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist & Promotions'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Favorites (${favoriteStores.length})'),
            Tab(text: 'Wishlist (${wishlistProducts.length})'),
            Tab(text: 'Deals (${promotions.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Favorite stores
          favoriteStores.isEmpty
              ? _buildEmpty(context, Icons.favorite_border,
                  'No favorite stores yet', 'Visit stores and tap the heart to save them')
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: favoriteStores.length,
                  itemBuilder: (_, i) {
                    final store = favoriteStores[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: StoreCard(
                        store: store,
                        isFavorite: true,
                        onFavoriteToggle: () =>
                            authProvider.toggleFavoriteStore(store.id),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => StoreDetailScreen(store: store),
                          ),
                        ),
                      ),
                    );
                  },
                ),
          // Wishlist products
          wishlistProducts.isEmpty
              ? _buildEmpty(context, Icons.shopping_bag_outlined,
                  'Your wishlist is empty', 'Save products you love by tapping the heart')
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: wishlistProducts.length,
                  itemBuilder: (_, i) {
                    final product = wishlistProducts[i];
                    return ProductCard(
                      product: product,
                      isWishlisted: true,
                      onWishlistToggle: () =>
                          authProvider.toggleWishlistItem(product.id),
                    );
                  },
                ),
          // Promotions / deals
          promotions.isEmpty
              ? _buildEmpty(context, Icons.local_offer_outlined,
                  'No promotions right now', 'Check back later for amazing deals!')
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.shade400,
                            Colors.deepOrange.shade500
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.local_fire_department,
                              color: Colors.white, size: 32),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hot Deals 🔥',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Limited time discounts from your local stores',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: promotions.length,
                      itemBuilder: (_, i) {
                        final product = promotions[i];
                        final isWishlisted =
                            authProvider.currentUser?.wishlist
                                    .contains(product.id) ??
                                false;
                        return ProductCard(
                          product: product,
                          isWishlisted: isWishlisted,
                          onWishlistToggle: () =>
                              authProvider.toggleWishlistItem(product.id),
                        );
                      },
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildEmpty(
      BuildContext context, IconData icon, String title, String subtitle) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 80,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(title,
                style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
