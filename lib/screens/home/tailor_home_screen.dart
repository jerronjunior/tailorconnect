import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../providers/auth_providers.dart';

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
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: IndexedStack(
          index: _tab,
          children: [
            _DashboardTab(name: user?.fullName ?? ''),
            const _ComingSoon(
                icon: LucideIcons.package,
                title: 'Orders',
                body: 'Incoming and active orders land here in Module 5.'),
            const _ComingSoon(
                icon: LucideIcons.messageSquare,
                title: 'Messages',
                body: 'Customer chat arrives in Module 6.'),
            const _ComingSoon(
                icon: LucideIcons.store,
                title: 'My shop',
                body:
                    'Business profile, portfolio, and hours arrive in Module 2.'),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.goldAccent.withAlpha(50),
        destinations: const [
          NavigationDestination(
              icon: Icon(LucideIcons.layoutDashboard, color: Colors.white70),
              selectedIcon: Icon(LucideIcons.layoutDashboard, color: AppColors.goldAccent),
              label: 'Dashboard'),
          NavigationDestination(
              icon: Icon(LucideIcons.package, color: Colors.white70),
              selectedIcon: Icon(LucideIcons.package, color: AppColors.goldAccent),
              label: 'Orders'),
          NavigationDestination(
              icon: Icon(LucideIcons.messageSquare, color: Colors.white70),
              selectedIcon: Icon(LucideIcons.messageSquare, color: AppColors.goldAccent),
              label: 'Chat'),
          NavigationDestination(
              icon: Icon(LucideIcons.store, color: Colors.white70),
              selectedIcon: Icon(LucideIcons.store, color: AppColors.goldAccent),
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
                      style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white)),
                  Text('Here’s how your shop is doing',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Log out',
              icon: const Icon(LucideIcons.logOut, color: Colors.white),
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).signOut(),
            ),
          ],
        ).animate().fadeIn().moveY(begin: 8),
        const SizedBox(height: AppSizes.lg),

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
                icon: LucideIcons.calendar,
                color: AppColors.info),
            _StatCard(
                label: 'Pending',
                value: '—',
                icon: LucideIcons.hourglass,
                color: AppColors.warning),
            _StatCard(
                label: 'Completed',
                value: '—',
                icon: LucideIcons.checkCircle,
                color: AppColors.success),
            _StatCard(
                label: 'Revenue (month)',
                value: '—',
                icon: LucideIcons.banknote,
                color: AppColors.goldAccent),
          ],
        ).animate().fadeIn(delay: 100.ms).moveY(begin: 16),
        const SizedBox(height: AppSizes.lg),

        Text('Quick actions', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
        const SizedBox(height: AppSizes.md),
        const Wrap(
          spacing: AppSizes.md,
          runSpacing: AppSizes.md,
          children: [
            _QuickAction(icon: LucideIcons.camera, label: 'Add portfolio'),
            _QuickAction(icon: LucideIcons.clock, label: 'Set hours'),
            _QuickAction(icon: LucideIcons.fileText, label: 'Send quote'),
            _QuickAction(icon: LucideIcons.star, label: 'Reviews'),
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
        color: AppColors.darkSurfaceHighlight,
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const Spacer(),
          Text(value, style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white)),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
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
      avatar: Icon(icon, size: 18, color: AppColors.goldAccent),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusField),
        side: const BorderSide(color: Colors.white12),
      ),
      backgroundColor: AppColors.darkSurface,
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
            Icon(icon, size: 64, color: Colors.white38),
            const SizedBox(height: AppSizes.md),
            Text(title, style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white)),
            const SizedBox(height: AppSizes.sm),
            Text(body,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
