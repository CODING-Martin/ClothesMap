import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/store.dart';
import '../../providers/auth_provider.dart';
import '../../providers/store_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/review_card.dart';
import 'store_management_screen.dart';
import 'product_management_screen.dart';
import 'business_profile_screen.dart';
import 'premium_screen.dart';

class BusinessHomeScreen extends StatefulWidget {
  const BusinessHomeScreen({super.key});

  @override
  State<BusinessHomeScreen> createState() => _BusinessHomeScreenState();
}

class _BusinessHomeScreenState extends State<BusinessHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final storeProvider = context.watch<StoreProvider>();
    final store =
        storeProvider.getStoreByOwnerId(authProvider.currentUser?.id ?? '');

    final screens = [
      _DashboardTab(store: store),
      store != null
          ? ProductManagementScreen(storeId: store.id)
          : const _NoStorePrompt(),
      const BusinessProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2_rounded),
            label: 'Products',
          ),
          NavigationDestination(
            icon: Icon(Icons.manage_accounts_outlined),
            selectedIcon: Icon(Icons.manage_accounts_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  final StoreModel? store;

  const _DashboardTab({this.store});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final storeProvider = context.watch<StoreProvider>();

    if (store == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Business Dashboard')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.store_outlined,
                    size: 80,
                    color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                Text('No Store Yet',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  'Create your store to start selling on ClothesMap',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const StoreManagementScreen()),
                  ),
                  icon: const Icon(Icons.add_business_outlined),
                  label: const Text('Create Store'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final products = storeProvider.getProductsForStore(store.id);
    final reviews = storeProvider.getReviewsForStore(store.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(store.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => StoreManagementScreen(store: store)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.workspace_premium_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PremiumScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Stats row
          Row(
            children: [
              _StatCard(
                label: 'Products',
                value: '${products.length}',
                icon: Icons.checkroom_outlined,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              _StatCard(
                label: 'Reviews',
                value: '${reviews.length}',
                icon: Icons.star_outlined,
                color: Colors.amber.shade600,
              ),
              const SizedBox(width: 8),
              _StatCard(
                label: 'Rating',
                value: store.rating.toString(),
                icon: Icons.trending_up,
                color: Colors.green.shade600,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Store status card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Store Status',
                          style: theme.textTheme.titleSmall),
                      const Spacer(),
                      if (!store.isPremium)
                        TextButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const PremiumScreen()),
                          ),
                          icon: const Icon(Icons.workspace_premium, size: 16),
                          label: const Text('Go Premium'),
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.amber.shade700),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _StatusRow(
                    icon: Icons.verified,
                    label: 'Verified',
                    value: store.isVerified,
                  ),
                  _StatusRow(
                    icon: Icons.workspace_premium,
                    label: 'Premium',
                    value: store.isPremium,
                  ),
                  _StatusRow(
                    icon: Icons.visibility,
                    label: 'Active',
                    value: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Recent products
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Products', style: theme.textTheme.titleSmall),
              TextButton(
                onPressed: () {},
                child: const Text('View all'),
              ),
            ],
          ),
          if (products.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.add_shopping_cart_outlined,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.4)),
                      const SizedBox(height: 8),
                      const Text('No products yet'),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductManagementScreen(storeId: store.id),
                          ),
                        ),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Product'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => SizedBox(
                  width: 160,
                  child: ProductCard(product: products[i]),
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Recent reviews
          if (reviews.isNotEmpty) ...[
            Text('Recent Reviews', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            ...reviews.take(3).map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ReviewCard(review: r),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;

  const _StatusRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon,
              size: 18,
              color: value ? Colors.green : theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(label),
          const Spacer(),
          Icon(
            value ? Icons.check_circle : Icons.cancel_outlined,
            size: 18,
            color: value ? Colors.green : theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _NoStorePrompt extends StatelessWidget {
  const _NoStorePrompt();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: const Center(
        child: Text('Create a store first to manage products'),
      ),
    );
  }
}
