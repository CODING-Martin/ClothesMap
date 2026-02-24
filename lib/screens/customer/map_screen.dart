import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../providers/store_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/store.dart';
import '../../utils/constants.dart';
import 'store_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  StoreModel? _selectedStore;
  bool _showPremiumOnly = false;
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final storeProvider = context.watch<StoreProvider>();
    final authProvider = context.watch<AuthProvider>();

    final stores = storeProvider.filteredStores.where((s) {
      if (_showPremiumOnly && !s.isPremium) return false;
      if (_selectedCategory != 'All' &&
          !s.categories.contains(_selectedCategory)) return false;
      return true;
    }).toList();

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(
                  AppConstants.defaultLatitude, AppConstants.defaultLongitude),
              initialZoom: AppConstants.defaultZoom,
              onTap: (_, __) => setState(() => _selectedStore = null),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.clothesmap.app',
              ),
              MarkerLayer(
                markers: stores.map((store) {
                  final isSelected = _selectedStore?.id == store.id;
                  return Marker(
                    point: LatLng(store.latitude, store.longitude),
                    width: isSelected ? 56 : 44,
                    height: isSelected ? 56 : 44,
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedStore = store),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: store.isPremium
                              ? Colors.amber.shade600
                              : isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : Colors.white,
                            width: isSelected ? 3 : 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.storefront_rounded,
                          size: isSelected ? 28 : 22,
                          color: isSelected
                              ? Colors.white
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          // Top search bar
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(28),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(28),
                            onTap: () {
                              Navigator.of(context).pushNamed('/search');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.search,
                                      color: theme.colorScheme.onSurfaceVariant),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Search stores & products...',
                                    style: TextStyle(
                                        color:
                                            theme.colorScheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        elevation: 4,
                        shape: const CircleBorder(),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: theme.colorScheme.surface,
                          child: IconButton(
                            icon: Icon(
                              Icons.favorite_border,
                              color: theme.colorScheme.primary,
                            ),
                            onPressed: () =>
                                Navigator.of(context).pushNamed('/wishlist'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Category filter chips
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: AppConstants.categories.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return FilterChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.workspace_premium,
                                  size: 14,
                                  color: _showPremiumOnly
                                      ? Colors.amber.shade700
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                const Text('Premium'),
                              ],
                            ),
                            selected: _showPremiumOnly,
                            onSelected: (v) =>
                                setState(() => _showPremiumOnly = v),
                            backgroundColor: theme.colorScheme.surface,
                            selectedColor: Colors.amber.shade100,
                          );
                        }
                        final cat = AppConstants.categories[index - 1];
                        return FilterChip(
                          label: Text(cat),
                          selected: _selectedCategory == cat,
                          onSelected: (_) => setState(
                              () => _selectedCategory = cat),
                          backgroundColor: theme.colorScheme.surface,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Store info card
          if (_selectedStore != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _StoreInfoCard(
                store: _selectedStore!,
                isFavorite: authProvider.currentUser?.favoriteStores
                        .contains(_selectedStore!.id) ??
                    false,
                onFavoriteToggle: () =>
                    authProvider.toggleFavoriteStore(_selectedStore!.id),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        StoreDetailScreen(store: _selectedStore!),
                  ));
                },
              ),
            ),
          // My location button
          Positioned(
            bottom: _selectedStore != null ? 180 : 24,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'my_location',
              onPressed: () {
                _mapController.move(
                  const LatLng(AppConstants.defaultLatitude,
                      AppConstants.defaultLongitude),
                  AppConstants.defaultZoom,
                );
              },
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreInfoCard extends StatelessWidget {
  final StoreModel store;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback onTap;

  const _StoreInfoCard({
    required this.store,
    required this.isFavorite,
    this.onFavoriteToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 8,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.storefront_rounded,
                  color: theme.colorScheme.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          store.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (store.isVerified) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.verified,
                              size: 16, color: theme.colorScheme.primary),
                        ],
                      ],
                    ),
                    Text(
                      store.address,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star_rounded,
                            size: 14, color: Colors.amber.shade600),
                        const SizedBox(width: 2),
                        Text(
                          '${store.rating} (${store.reviewCount})',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : null,
                    ),
                    onPressed: onFavoriteToggle,
                  ),
                  Text('Details',
                      style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
