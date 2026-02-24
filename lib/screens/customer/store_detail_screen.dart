import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../../models/store.dart';
import '../../providers/store_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/review_card.dart';
import 'chat_screen.dart';

class StoreDetailScreen extends StatefulWidget {
  final StoreModel store;

  const StoreDetailScreen({super.key, required this.store});

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showReviewForm = false;
  double _newRating = 5.0;
  final _reviewCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reviewCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final storeProvider = context.watch<StoreProvider>();
    final authProvider = context.watch<AuthProvider>();

    final store = storeProvider.getStoreById(widget.store.id) ?? widget.store;
    final products = storeProvider.getProductsForStore(store.id);
    final reviews = storeProvider.getReviewsForStore(store.id);
    final isFavorite =
        authProvider.currentUser?.favoriteStores.contains(store.id) ?? false;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildBanner(theme, store),
              title: Text(
                store.name,
                style: const TextStyle(
                  shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: () => authProvider.toggleFavoriteStore(store.id),
              ),
              IconButton(
                icon: const Icon(Icons.chat_outlined, color: Colors.white),
                onPressed: () => _openChat(context, store, authProvider),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: _buildStoreInfo(theme, store),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: 'Products (${products.length})'),
                  Tab(text: 'Reviews (${reviews.length})'),
                  const Tab(text: 'Info'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildProductsTab(products, authProvider),
            _buildReviewsTab(reviews, store, authProvider),
            _buildInfoTab(theme, store),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openChat(context, store, authProvider),
        icon: const Icon(Icons.chat_rounded),
        label: const Text('Chat with Store'),
      ),
    );
  }

  Widget _buildBanner(ThemeData theme, StoreModel store) {
    return Container(
      color: theme.colorScheme.primaryContainer,
      child: Center(
        child: Icon(
          Icons.storefront_rounded,
          size: 80,
          color: theme.colorScheme.primary.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildStoreInfo(ThemeData theme, StoreModel store) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          store.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (store.isVerified) ...[
                          const SizedBox(width: 6),
                          Icon(Icons.verified,
                              size: 20, color: theme.colorScheme.primary),
                        ],
                        if (store.isPremium) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade700,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.workspace_premium,
                                    size: 12, color: Colors.white),
                                const SizedBox(width: 2),
                                Text(
                                  store.premiumTier?.name.toUpperCase() ??
                                      'PRO',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star_rounded,
                            size: 16, color: Colors.amber.shade600),
                        const SizedBox(width: 2),
                        Text(
                          '${store.rating} · ${store.reviewCount} reviews',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(store.description, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: 16, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  store.address,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.phone_outlined,
                  size: 16, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                store.phone,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTab(products, AuthProvider authProvider) {
    if (products.isEmpty) {
      return const Center(
        child: Text('No products available yet.'),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: products.length,
      itemBuilder: (_, i) {
        final product = products[i];
        final isWishlisted =
            authProvider.currentUser?.wishlist.contains(product.id) ?? false;
        return ProductCard(
          product: product,
          isWishlisted: isWishlisted,
          onWishlistToggle: () =>
              authProvider.toggleWishlistItem(product.id),
        );
      },
    );
  }

  Widget _buildReviewsTab(
      reviews, StoreModel store, AuthProvider authProvider) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        if (authProvider.isAuthenticated &&
            authProvider.currentUser?.userType.name == 'customer') ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Leave a Review',
                          style: Theme.of(context).textTheme.titleSmall),
                      TextButton(
                        onPressed: () =>
                            setState(() => _showReviewForm = !_showReviewForm),
                        child:
                            Text(_showReviewForm ? 'Cancel' : 'Write Review'),
                      ),
                    ],
                  ),
                  if (_showReviewForm) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: RatingBar.builder(
                        initialRating: _newRating,
                        minRating: 1,
                        itemCount: 5,
                        itemBuilder: (_, __) => Icon(
                          Icons.star_rounded,
                          color: Colors.amber.shade600,
                        ),
                        onRatingUpdate: (r) =>
                            setState(() => _newRating = r),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _reviewCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Write your review...',
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          if (_reviewCtrl.text.trim().isEmpty) return;
                          context.read<StoreProvider>().addReview(
                                storeId: store.id,
                                userId: authProvider.currentUser!.id,
                                userName: authProvider.currentUser!.name,
                                rating: _newRating,
                                comment: _reviewCtrl.text.trim(),
                              );
                          _reviewCtrl.clear();
                          setState(() {
                            _showReviewForm = false;
                            _newRating = 5.0;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Review submitted!')),
                          );
                        },
                        child: const Text('Submit Review'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        ...reviews.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ReviewCard(review: r),
            )),
        if (reviews.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('No reviews yet. Be the first to review!'),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoTab(ThemeData theme, StoreModel store) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (store.openingHours.isNotEmpty) ...[
          Text('Opening Hours', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: store.openingHours.entries.map((e) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.key,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500)),
                        Text(e.value),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Text('Categories', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: store.categories
              .map((c) => Chip(label: Text(c)))
              .toList(),
        ),
        const SizedBox(height: 16),
        if (store.website != null) ...[
          Text('Website', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          ListTile(
            leading: Icon(Icons.language, color: theme.colorScheme.primary),
            title: Text(store.website!,
                style: TextStyle(color: theme.colorScheme.primary)),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ],
    );
  }

  void _openChat(
      BuildContext context, StoreModel store, AuthProvider authProvider) {
    if (!authProvider.isAuthenticated) {
      Navigator.of(context).pushNamed('/login');
      return;
    }
    final storeProvider = context.read<StoreProvider>();
    final chat = storeProvider.getOrCreateChat(
      storeId: store.id,
      storeName: store.name,
      customerId: authProvider.currentUser!.id,
      customerName: authProvider.currentUser!.name,
    );
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ChatScreen(chatId: chat.id, storeName: store.name),
    ));
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  const _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}
