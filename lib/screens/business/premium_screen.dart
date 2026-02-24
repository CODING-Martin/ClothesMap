import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/store_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/store.dart';
import '../../utils/constants.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final storeProvider = context.watch<StoreProvider>();
    final authProvider = context.watch<AuthProvider>();
    final store =
        storeProvider.getStoreByOwnerId(authProvider.currentUser?.id ?? '');

    return Scaffold(
      appBar: AppBar(title: const Text('Premium Plans')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.amber.shade600,
                  Colors.orange.shade700,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(Icons.workspace_premium,
                    color: Colors.white, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Go Premium',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Boost your store visibility and reach more customers',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          if (store?.isPremium == true) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'You have an active premium plan!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          'Current plan: ${store!.premiumTier?.name.toUpperCase() ?? "PRO"}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Benefits list
          Text('Why go premium?', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          ...const [
            _BenefitRow(
              icon: Icons.trending_up,
              title: 'Top Search Results',
              subtitle: 'Appear at the top of customer searches',
            ),
            _BenefitRow(
              icon: Icons.map_rounded,
              title: 'Map Priority',
              subtitle: 'Featured placement on the map',
            ),
            _BenefitRow(
              icon: Icons.verified,
              title: 'Premium Badge',
              subtitle: 'Build trust with verified badge',
            ),
            _BenefitRow(
              icon: Icons.bar_chart,
              title: 'Analytics',
              subtitle: 'Track views, clicks, and conversions',
            ),
            _BenefitRow(
              icon: Icons.campaign,
              title: 'Promotions',
              subtitle: 'Send promotional notifications to customers',
            ),
          ],
          const SizedBox(height: 24),

          // Plans
          Text('Choose a Plan', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          ...AppConstants.premiumPlans.asMap().entries.map((entry) {
            final idx = entry.key;
            final plan = entry.value;
            final isPro = idx == 1;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PlanCard(
                plan: plan,
                isRecommended: isPro,
                isCurrentPlan: store?.isPremium == true &&
                    store!.premiumTier?.name ==
                        PremiumTier.values[idx].name,
                onSelect: () => _selectPlan(context, plan, store),
              ),
            );
          }),
          const SizedBox(height: 16),
          Text(
            '* This is a demo app. No real payments are processed.',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _selectPlan(
      BuildContext context, Map<String, dynamic> plan, StoreModel? store) {
    if (store == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create a store first!')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${plan['name']} Plan'),
        content: Text(
          'Subscribe to ${plan['name']} for €${plan['price']}/${plan['period']}?\n\n'
          'This is a demo — no real payment required.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final storeProvider = context.read<StoreProvider>();
              final tierIndex = AppConstants.premiumPlans.indexOf(plan);
              final updatedStore = store.copyWith(
                isPremium: true,
                premiumTier: PremiumTier.values[tierIndex],
                isVerified: true,
              );
              storeProvider.updateStore(updatedStore);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '🎉 ${plan['name']} plan activated!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.amber.shade700,
            ),
            child: const Text('Activate Plan'),
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _BenefitRow(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.amber.shade700, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  final bool isRecommended;
  final bool isCurrentPlan;
  final VoidCallback onSelect;

  const _PlanCard({
    required this.plan,
    required this.isRecommended,
    required this.isCurrentPlan,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: isRecommended ? 6 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isRecommended
              ? Colors.amber.shade600
              : isCurrentPlan
                  ? Colors.green
                  : Colors.transparent,
          width: isRecommended || isCurrentPlan ? 2 : 0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  plan['name'] as String,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (isRecommended)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade600,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'RECOMMENDED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (isCurrentPlan)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '€${plan['price']}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade700,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '/${plan['period']}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...(plan['features'] as List<String>).map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 16, color: Colors.green.shade600),
                    const SizedBox(width: 6),
                    Text(f, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: isCurrentPlan
                  ? OutlinedButton(
                      onPressed: null,
                      child: const Text('Current Plan'),
                    )
                  : FilledButton(
                      onPressed: onSelect,
                      style: FilledButton.styleFrom(
                        backgroundColor: isRecommended
                            ? Colors.amber.shade700
                            : null,
                      ),
                      child: const Text('Select Plan'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
