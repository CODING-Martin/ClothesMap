import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/store_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/store_card.dart';
import '../../widgets/product_card.dart';
import '../../widgets/filter_chip_widget.dart';
import 'store_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final storeProvider = context.watch<StoreProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.storefront_outlined), text: 'Stores'),
            Tab(icon: Icon(Icons.checkroom_outlined), text: 'Products'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search stores and products...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: storeProvider.searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchCtrl.clear();
                                storeProvider.setSearchQuery('');
                              },
                            )
                          : null,
                    ),
                    onChanged: storeProvider.setSearchQuery,
                  ),
                ),
                const SizedBox(width: 8),
                Badge(
                  isLabelVisible: _hasActiveFilters(storeProvider),
                  child: IconButton.filled(
                    onPressed: () =>
                        setState(() => _showFilters = !_showFilters),
                    icon: Icon(
                        _showFilters ? Icons.filter_list_off : Icons.tune),
                  ),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: _buildFilters(storeProvider),
            secondChild: const SizedBox.shrink(),
            crossFadeState: _showFilters
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 250),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Stores tab
                _buildStoresList(storeProvider, authProvider),
                // Products tab
                _buildProductsGrid(storeProvider, authProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _hasActiveFilters(StoreProvider p) =>
      p.selectedCategory != 'All' ||
      p.selectedColor != 'All' ||
      p.selectedSize.isNotEmpty ||
      p.selectedPriceRange != 'Any';

  Widget _buildFilters(StoreProvider storeProvider) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(
            bottom: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filters', style: theme.textTheme.titleSmall),
              TextButton(
                onPressed: storeProvider.clearFilters,
                child: const Text('Clear all'),
              ),
            ],
          ),
          Text('Category', style: theme.textTheme.labelMedium),
          const SizedBox(height: 4),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: AppConstants.categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                final cat = AppConstants.categories[i];
                return FilterChipWidget(
                  label: cat,
                  isSelected: storeProvider.selectedCategory == cat,
                  onTap: () => storeProvider.setCategory(cat),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text('Color', style: theme.textTheme.labelMedium),
          const SizedBox(height: 4),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: AppConstants.colors.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                final color = AppConstants.colors[i];
                return ColorFilterChip(
                  colorName: color,
                  isSelected: storeProvider.selectedColor == color,
                  onTap: () => storeProvider.setColor(color),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Size', style: theme.textTheme.labelMedium),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: AppConstants.sizes.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 6),
                        itemBuilder: (_, i) {
                          final size = AppConstants.sizes[i];
                          return FilterChipWidget(
                            label: size,
                            isSelected: storeProvider.selectedSize == size,
                            onTap: () => storeProvider.setSize(
                                storeProvider.selectedSize == size ? '' : size),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Price Range', style: theme.textTheme.labelMedium),
          const SizedBox(height: 4),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: AppConstants.priceRanges.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                final range = AppConstants.priceRanges[i];
                return FilterChipWidget(
                  label: range,
                  isSelected: storeProvider.selectedPriceRange == range,
                  onTap: () => storeProvider.setPriceRange(range),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildStoresList(StoreProvider storeProvider, AuthProvider auth) {
    final stores = storeProvider.filteredStores;
    if (stores.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('No stores found', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: stores.length,
      itemBuilder: (_, i) {
        final store = stores[i];
        final isFav =
            auth.currentUser?.favoriteStores.contains(store.id) ?? false;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: StoreCard(
            store: store,
            isFavorite: isFav,
            onFavoriteToggle: () => auth.toggleFavoriteStore(store.id),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => StoreDetailScreen(store: store)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductsGrid(StoreProvider storeProvider, AuthProvider auth) {
    final products = storeProvider.filteredProducts;
    if (products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.checkroom_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('No products found', style: TextStyle(color: Colors.grey)),
          ],
        ),
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
            auth.currentUser?.wishlist.contains(product.id) ?? false;
        return ProductCard(
          product: product,
          isWishlisted: isWishlisted,
          onWishlistToggle: () => auth.toggleWishlistItem(product.id),
        );
      },
    );
  }
}
