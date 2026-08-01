import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../models/tailor_profile.dart';
import '../../providers/auth_providers.dart';
import '../../providers/tailor_providers.dart';
import '../orders/send_quote_screen.dart';
import '../orders/tailor_orders_screen.dart';
import '../reviews/tailor_reviews_screen.dart';
import '../shop/business_hours_screen.dart';
import '../shop/shop_screen.dart';

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
            _DashboardTab(
                name: user?.fullName ?? '', onOpenShop: () => setState(() => _tab = 3)),
            const TailorOrdersScreen(),
            const _ComingSoon(
                icon: LucideIcons.messageSquare,
                title: 'Messages',
                body: 'Customer chat arrives in Module 6.'),
            const ShopScreen(),
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
  const _DashboardTab({required this.name, required this.onOpenShop});

  final String name;
  final VoidCallback onOpenShop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(tailorProfileProvider);

    return ListView(
      padding: const EdgeInsets.all(AppSizes.md),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Good day, $name',
                style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white)),
            Text('Here’s how your shop is doing',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
          ],
        ).animate().fadeIn().moveY(begin: 8),
        const SizedBox(height: AppSizes.lg),

        if (profileAsync.valueOrNull != null) ...[
          _ShopPreviewCard(profile: profileAsync.valueOrNull!, onTap: onOpenShop)
              .animate()
              .fadeIn(delay: 60.ms)
              .moveY(begin: 12),
          const SizedBox(height: AppSizes.lg),
        ],

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
        Wrap(
          spacing: AppSizes.md,
          runSpacing: AppSizes.md,
          children: [
            _QuickAction(
                icon: LucideIcons.camera, label: 'Add portfolio', onTap: onOpenShop),
            _QuickAction(
              icon: LucideIcons.clock,
              label: 'Set hours',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BusinessHoursScreen()),
              ),
            ),
            _QuickAction(
              icon: LucideIcons.fileText,
              label: 'Send quote',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SendQuoteScreen()),
              ),
            ),
            _QuickAction(
              icon: LucideIcons.star,
              label: 'Reviews',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TailorReviewsScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.lg),

        Row(
          children: [
            Expanded(
              child: Text('Portfolio',
                  style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
            ),
            TextButton(
              onPressed: onOpenShop,
              child: const Text('Manage', style: TextStyle(color: AppColors.goldAccent)),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.sm),
        _PortfolioPreviewRow(
          urls: profileAsync.valueOrNull?.portfolioUrls ?? const [],
          onTap: onOpenShop,
        ),
      ],
    );
  }
}

class _ShopPreviewCard extends StatelessWidget {
  const _ShopPreviewCard({required this.profile, required this.onTap});

  final TailorProfile profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 128,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
          border: Border.all(color: Colors.white12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(60),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            profile.coverUrl == null
                ? Container(color: AppColors.darkSurfaceHighlight)
                : CachedNetworkImage(imageUrl: profile.coverUrl!, fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withAlpha(10), Colors.black.withAlpha(190)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.darkSurfaceHighlight,
                      border: Border.all(color: Colors.white24, width: 1.5),
                    ),
                    child: ClipOval(
                      child: profile.logoUrl == null
                          ? const Icon(LucideIcons.store, color: Colors.white38, size: 22)
                          : CachedNetworkImage(
                              imageUrl: profile.logoUrl!, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          profile.businessName.isEmpty ? 'Your shop' : profile.businessName,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Icon(
                              profile.isAvailable
                                  ? LucideIcons.checkCircle
                                  : LucideIcons.pauseCircle,
                              color: profile.isAvailable
                                  ? AppColors.success
                                  : AppColors.warning,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              profile.isAvailable ? 'Open for orders' : 'Not accepting orders',
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(LucideIcons.chevronRight, color: Colors.white54),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PortfolioPreviewRow extends StatelessWidget {
  const _PortfolioPreviewRow({required this.urls, required this.onTap});

  final List<String> urls;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: 96,
          decoration: BoxDecoration(
            color: AppColors.darkSurfaceHighlight,
            borderRadius: BorderRadius.circular(AppSizes.radiusCard),
            border: Border.all(color: Colors.white12),
          ),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.image, color: Colors.white24, size: 28),
                SizedBox(height: 4),
                Text('Add photos of your work',
                    style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSizes.sm),
        itemBuilder: (context, i) => GestureDetector(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusField),
            child: CachedNetworkImage(
              imageUrl: urls[i],
              width: 96,
              height: 96,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 120.ms);
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
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

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
      onPressed: onTap,
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
