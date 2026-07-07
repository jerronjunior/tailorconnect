import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../providers/auth_providers.dart';

/// Tailor dashboard shell (Module 1).
///
/// Stat values are wired to live order/earnings aggregation queries in
/// Module 5 (Order Management) and Module 8 (Earnings & Analytics).
class TailorHomeScreen extends ConsumerStatefulWidget {
  const TailorHomeScreen({super.key});

  @override
  ConsumerState<TailorHomeScreen> createState() => _TailorHomeScreenState();
}

class _TailorHomeScreenState extends ConsumerState<TailorHomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(appUserProvider).valueOrNull;

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _tab,
          children: [
            _DashboardTab(name: user?.fullName ?? ''),
            const _ComingSoon(
                icon: Icons.inventory_2_outlined,
                title: 'Orders',
                body: 'Incoming and active orders land here in Module 5.'),
            const _ComingSoon(
                icon: Icons.chat_bubble_outline,
                title: 'Messages',
                body: 'Customer chat arrives in Module 6.'),
            const _ComingSoon(
                icon: Icons.storefront_outlined,
                title: 'My shop',
                body:
                    'Business profile, portfolio, and hours arrive in Module 2.'),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        indicatorColor: AppColors.threadGoldLight.withOpacity(0.35),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard'),
          NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2),
              label: 'Orders'),
          NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline),
              selectedIcon: Icon(Icons.chat_bubble),
              label: 'Chat'),
          NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              selectedIcon: Icon(Icons.storefront),
              label: 'Shop'),
        ],
      ),
    );
  }
}

class _DashboardTab extends ConsumerWidget {
  const _DashboardTab({required this.name});

  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSizes.md),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Good day, $name',
                      style: theme.textTheme.headlineMedium),
                  Text('Here’s how your shop is doing',
                      style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Log out',
              icon: const Icon(Icons.logout),
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).signOut(),
            ),
          ],
        ).animate().fadeIn().moveY(begin: 8),
        const SizedBox(height: AppSizes.lg),

        // Stat grid — values stream from Firestore aggregations in Module 5/8.
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSizes.md,
          crossAxisSpacing: AppSizes.md,
          childAspectRatio: 1.5,
          children: const [
            _StatCard(
                label: "Today's orders",
                value: '—',
                icon: Icons.today_outlined,
                color: AppColors.info),
            _StatCard(
                label: 'Pending',
                value: '—',
                icon: Icons.hourglass_top_outlined,
                color: AppColors.warning),
            _StatCard(
                label: 'Completed',
                value: '—',
                icon: Icons.check_circle_outline,
                color: AppColors.success),
            _StatCard(
                label: 'Revenue (month)',
                value: '—',
                icon: Icons.payments_outlined,
                color: AppColors.threadGold),
          ],
        ).animate().fadeIn(delay: 100.ms).moveY(begin: 16),
        const SizedBox(height: AppSizes.lg),

        Text('Quick actions', style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSizes.md),
        const Wrap(
          spacing: AppSizes.md,
          runSpacing: AppSizes.md,
          children: [
            _QuickAction(icon: Icons.add_a_photo_outlined, label: 'Add portfolio'),
            _QuickAction(icon: Icons.schedule_outlined, label: 'Set hours'),
            _QuickAction(icon: Icons.request_quote_outlined, label: 'Send quote'),
            _QuickAction(icon: Icons.reviews_outlined, label: 'Reviews'),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        border: Border.all(color: AppColors.stitch),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const Spacer(),
          Text(value, style: theme.textTheme.headlineMedium),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: AppColors.indigo),
      label: Text(label),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusField),
        side: const BorderSide(color: AppColors.stitch),
      ),
      backgroundColor: Colors.white,
      onPressed: () {},
    );
  }
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon(
      {required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.inkSoft),
            const SizedBox(height: AppSizes.md),
            Text(title, style: theme.textTheme.headlineMedium),
            const SizedBox(height: AppSizes.sm),
            Text(body,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
