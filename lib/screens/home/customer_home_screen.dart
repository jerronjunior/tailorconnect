import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/glass_card.dart';

class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(appUserProvider).valueOrNull;
    final firstName = (user?.fullName ?? '').split(' ').firstOrNull ?? 'there';

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: IndexedStack(
          index: _tab,
          children: [
            _HomeTab(firstName: firstName),
            const _PlaceholderTab(
                icon: LucideIcons.receipt,
                title: 'Orders',
                body: 'Your orders will appear here (Module 4).'),
            const _PlaceholderTab(
                icon: LucideIcons.messageSquare,
                title: 'Messages',
                body: 'Chats with tailors arrive in Module 6.'),
            _ProfileTab(onSignOut: () => ref.read(authControllerProvider.notifier).signOut()),
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
              icon: Icon(LucideIcons.home, color: Colors.white70),
              selectedIcon: Icon(LucideIcons.home, color: AppColors.goldAccent),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(LucideIcons.receipt, color: Colors.white70),
              selectedIcon: Icon(LucideIcons.receipt, color: AppColors.goldAccent),
              label: 'Orders'),
          NavigationDestination(
              icon: Icon(LucideIcons.messageSquare, color: Colors.white70),
              selectedIcon: Icon(LucideIcons.messageSquare, color: AppColors.goldAccent),
              label: 'Chat'),
          NavigationDestination(
              icon: Icon(LucideIcons.user, color: Colors.white70),
              selectedIcon: Icon(LucideIcons.user, color: AppColors.goldAccent),
              label: 'Profile'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.firstName});

  final String firstName;

  static const _categories = [
    ('Men', LucideIcons.user),
    ('Women', LucideIcons.userCircle),
    ('Kids', LucideIcons.baby),
    ('Wedding', LucideIcons.heart),
    ('Office', LucideIcons.briefcase),
    ('Traditional', LucideIcons.sparkles),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        await Future<void>.delayed(const Duration(milliseconds: 600));
      },
      child: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          Text('Hello, $firstName 👋', style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white))
              .animate()
              .fadeIn()
              .moveY(begin: 8),
          Text('Find the perfect tailor for your next outfit',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
          const SizedBox(height: AppSizes.md),

          // Search
          TextField(
            readOnly: true,
            style: const TextStyle(color: Colors.white),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Tailor search arrives in Module 2.')));
            },
            decoration: InputDecoration(
              hintText: 'Search tailors, styles, fabrics…',
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(LucideIcons.search, color: Colors.white54),
              filled: true,
              fillColor: AppColors.darkSurfaceHighlight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusField),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.lg),

          // Promotional banner
          Container(
            height: 150,
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              gradient: AppColors.luxuryGradient,
              borderRadius: BorderRadius.circular(AppSizes.radiusCard),
              boxShadow: [
                BoxShadow(
                  color: AppColors.goldAccent.withAlpha(100),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ]
            ),
            child: Stack(
              children: [
                const Positioned(
                  right: 0,
                  bottom: 0,
                  child: Icon(LucideIcons.scissors,
                      size: 96, color: Colors.black12),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const GlassCard(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.sm, vertical: AppSizes.xs),
                      borderRadius: AppSizes.sm,
                      child: Text('NEW HERE?',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w700)),
                    ),
                    const Spacer(),
                    Text('20% off your first order',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSizes.xs),
                    const Text('Use code WELCOME20 at checkout',
                        style:
                            TextStyle(color: Colors.white, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms).moveY(begin: 16),
          const SizedBox(height: AppSizes.lg),

          // Categories
          Text('Categories', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
          const SizedBox(height: AppSizes.md),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppSizes.md),
              itemBuilder: (context, i) {
                final (label, icon) = _categories[i];
                return Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.darkSurfaceHighlight,
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusField),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Icon(icon, color: AppColors.goldAccent),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(label, style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
                  ],
                ).animate(delay: (60 * i).ms).fadeIn().moveX(begin: 12);
              },
            ),
          ),
          const SizedBox(height: AppSizes.lg),

          _SectionHeader(
              title: 'Nearby tailors', onSeeAll: () {}),
          const SizedBox(height: AppSizes.md),
          const _TailorListSkeleton(),
          const SizedBox(height: AppSizes.lg),
          _SectionHeader(title: 'Top rated', onSeeAll: () {}),
          const SizedBox(height: AppSizes.md),
          const _TailorListSkeleton(),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onSeeAll});

  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child:
                Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white))),
        TextButton(onPressed: onSeeAll, child: const Text('See all', style: TextStyle(color: AppColors.goldAccent))),
      ],
    );
  }
}

class _TailorListSkeleton extends StatelessWidget {
  const _TailorListSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: AppSizes.md),
        itemBuilder: (_, i) => Container(
          width: 220,
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(AppSizes.radiusCard),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 110,
                decoration: const BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppSizes.radiusCard)),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).fade(
                  begin: 0.5, end: 1, duration: 900.ms),
              Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        width: 130,
                        height: 12,
                        color: Colors.white24),
                    const SizedBox(height: AppSizes.sm),
                    Container(
                        width: 80,
                        height: 10,
                        color: Colors.white12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab(
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

class _ProfileTab extends ConsumerWidget {
  const _ProfileTab({required this.onSignOut});

  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(appUserProvider).valueOrNull;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSizes.lg),
      children: [
        Center(
          child: CircleAvatar(
            radius: 44,
            backgroundColor: AppColors.goldAccent,
            backgroundImage: user?.photoUrl != null
                ? NetworkImage(user!.photoUrl!)
                : null,
            child: user?.photoUrl == null
                ? Text(
                    (user?.fullName.isNotEmpty ?? false)
                        ? user!.fullName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  )
                : null,
          ),
        ),
        const SizedBox(height: AppSizes.md),
        Center(
            child: Text(user?.fullName ?? '',
                style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white))),
        Center(
            child:
                Text(user?.email ?? '', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70))),
        const SizedBox(height: AppSizes.xl),
        ListTile(
          leading: const Icon(LucideIcons.ruler, color: Colors.white),
          title: const Text('My measurements', style: TextStyle(color: Colors.white)),
          trailing: const Icon(LucideIcons.chevronRight, color: Colors.white54),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(LucideIcons.mapPin, color: Colors.white),
          title: const Text('Addresses', style: TextStyle(color: Colors.white)),
          trailing: const Icon(LucideIcons.chevronRight, color: Colors.white54),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(LucideIcons.settings, color: Colors.white),
          title: const Text('Settings', style: TextStyle(color: Colors.white)),
          trailing: const Icon(LucideIcons.chevronRight, color: Colors.white54),
          onTap: () {},
        ),
        const Divider(color: Colors.white12),
        ListTile(
          leading: const Icon(LucideIcons.logOut, color: AppColors.error),
          title:
              const Text('Log out', style: TextStyle(color: AppColors.error)),
          onTap: onSignOut,
        ),
      ],
    );
  }
}
