import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/glass_card.dart';

/// Customer dashboard shell (Module 1).
///
/// Layout, navigation, and section scaffolding are final; the tailor lists
/// are wired to live Firestore queries in Module 2 (Tailor Discovery).
class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() =>
      _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(appUserProvider).valueOrNull;
    final firstName =
        (user?.fullName ?? '').split(' ').firstOrNull ?? 'there';

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _tab,
          children: [
            _HomeTab(firstName: firstName),
            const _PlaceholderTab(
                icon: Icons.receipt_long_outlined,
                title: 'Orders',
                body: 'Your orders will appear here (Module 4).'),
            const _PlaceholderTab(
                icon: Icons.chat_bubble_outline,
                title: 'Messages',
                body: 'Chats with tailors arrive in Module 6.'),
            _ProfileTab(onSignOut: () =>
                ref.read(authControllerProvider.notifier).signOut()),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        indicatorColor: AppColors.threadGoldLight.withOpacity(0.35),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Orders'),
          NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline),
              selectedIcon: Icon(Icons.chat_bubble),
              label: 'Chat'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
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
    ('Men', Icons.man_outlined),
    ('Women', Icons.woman_outlined),
    ('Kids', Icons.child_care_outlined),
    ('Wedding', Icons.favorite_outline),
    ('Office', Icons.work_outline),
    ('Traditional', Icons.auto_awesome_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        // Module 2: re-run nearby/popular tailor queries.
        await Future<void>.delayed(const Duration(milliseconds: 600));
      },
      child: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          Text('Hello, $firstName 👋', style: theme.textTheme.headlineMedium)
              .animate()
              .fadeIn()
              .moveY(begin: 8),
          Text('Find the perfect tailor for your next outfit',
              style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSizes.md),

          // Search
          TextField(
            readOnly: true,
            onTap: () {
              // Module 2: push tailor search screen.
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Tailor search arrives in Module 2.')));
            },
            decoration: const InputDecoration(
              hintText: 'Search tailors, styles, fabrics…',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: AppSizes.lg),

          // Promotional banner
          Container(
            height: 150,
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(AppSizes.radiusCard),
            ),
            child: Stack(
              children: [
                const Positioned(
                  right: 0,
                  bottom: 0,
                  child: Icon(Icons.content_cut,
                      size: 96, color: Colors.white12),
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
                              color: AppColors.threadGoldLight,
                              fontSize: 11,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w700)),
                    ),
                    const Spacer(),
                    Text('20% off your first order',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(color: Colors.white)),
                    const SizedBox(height: AppSizes.xs),
                    const Text('Use code WELCOME20 at checkout',
                        style:
                            TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms).moveY(begin: 16),
          const SizedBox(height: AppSizes.lg),

          // Categories
          Text('Categories', style: theme.textTheme.titleLarge),
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
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusField),
                        border: Border.all(color: AppColors.stitch),
                      ),
                      child: Icon(icon, color: AppColors.indigo),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(label, style: theme.textTheme.bodySmall),
                  ],
                ).animate(delay: (60 * i).ms).fadeIn().moveX(begin: 12);
              },
            ),
          ),
          const SizedBox(height: AppSizes.lg),

          // Nearby tailors — skeleton until Module 2 wires Firestore.
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
                Text(title, style: Theme.of(context).textTheme.titleLarge)),
        TextButton(onPressed: onSeeAll, child: const Text('See all')),
      ],
    );
  }
}

/// Horizontal skeleton cards shown while tailor data loads (and until the
/// Module 2 Firestore queries land).
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusCard),
            border: Border.all(color: AppColors.stitch),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 110,
                decoration: BoxDecoration(
                  color: AppColors.stitch.withOpacity(0.6),
                  borderRadius: const BorderRadius.vertical(
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
                        color: AppColors.stitch.withOpacity(0.8)),
                    const SizedBox(height: AppSizes.sm),
                    Container(
                        width: 80,
                        height: 10,
                        color: AppColors.stitch.withOpacity(0.5)),
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
            backgroundColor: AppColors.indigo,
            backgroundImage: user?.photoUrl != null
                ? NetworkImage(user!.photoUrl!)
                : null,
            child: user?.photoUrl == null
                ? Text(
                    (user?.fullName.isNotEmpty ?? false)
                        ? user!.fullName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 32),
                  )
                : null,
          ),
        ),
        const SizedBox(height: AppSizes.md),
        Center(
            child: Text(user?.fullName ?? '',
                style: theme.textTheme.headlineMedium)),
        Center(
            child:
                Text(user?.email ?? '', style: theme.textTheme.bodySmall)),
        const SizedBox(height: AppSizes.xl),
        // Full profile management (addresses, measurements, payment methods)
        // ships in Modules 3 and 7.
        ListTile(
          leading: const Icon(Icons.straighten_outlined),
          title: const Text('My measurements'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.location_on_outlined),
          title: const Text('Addresses'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.settings_outlined),
          title: const Text('Settings'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: AppColors.error),
          title:
              const Text('Log out', style: TextStyle(color: AppColors.error)),
          onTap: onSignOut,
        ),
      ],
    );
  }
}
