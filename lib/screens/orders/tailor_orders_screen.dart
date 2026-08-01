import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../models/order_model.dart';
import '../../providers/order_providers.dart';

/// "Orders" tab — every order assigned to the signed-in tailor, filterable
/// by status, with controls to advance or set the order's status.
class TailorOrdersScreen extends ConsumerStatefulWidget {
  const TailorOrdersScreen({super.key});

  @override
  ConsumerState<TailorOrdersScreen> createState() => _TailorOrdersScreenState();
}

enum _Filter { all, placed, active, ready, delivered, cancelled }

extension on _Filter {
  String get label => switch (this) {
        _Filter.all => 'All',
        _Filter.placed => 'New',
        _Filter.active => 'In progress',
        _Filter.ready => 'Ready',
        _Filter.delivered => 'Delivered',
        _Filter.cancelled => 'Cancelled',
      };

  bool matches(OrderStatus s) => switch (this) {
        _Filter.all => true,
        _Filter.placed => s == OrderStatus.placed,
        _Filter.active => {
            OrderStatus.accepted,
            OrderStatus.measurementConfirmed,
            OrderStatus.cutting,
            OrderStatus.stitching,
            OrderStatus.qualityCheck,
          }.contains(s),
        _Filter.ready =>
          {OrderStatus.ready, OrderStatus.outForDelivery}.contains(s),
        _Filter.delivered => s == OrderStatus.delivered,
        _Filter.cancelled =>
          {OrderStatus.cancelled, OrderStatus.rejected}.contains(s),
      };
}

/// Linear happy-path sequence used to compute the "advance" action.
const _statusSequence = [
  OrderStatus.placed,
  OrderStatus.accepted,
  OrderStatus.measurementConfirmed,
  OrderStatus.cutting,
  OrderStatus.stitching,
  OrderStatus.qualityCheck,
  OrderStatus.ready,
  OrderStatus.outForDelivery,
  OrderStatus.delivered,
];

OrderStatus? _nextStatus(OrderStatus s) {
  final i = _statusSequence.indexOf(s);
  if (i == -1 || i == _statusSequence.length - 1) return null;
  return _statusSequence[i + 1];
}

Color _statusColor(OrderStatus s) => switch (s) {
      OrderStatus.placed => AppColors.warning,
      OrderStatus.accepted ||
      OrderStatus.measurementConfirmed ||
      OrderStatus.cutting ||
      OrderStatus.stitching ||
      OrderStatus.qualityCheck =>
        AppColors.info,
      OrderStatus.ready || OrderStatus.outForDelivery => AppColors.goldAccent,
      OrderStatus.delivered => AppColors.success,
      OrderStatus.cancelled || OrderStatus.rejected => AppColors.error,
    };

class _TailorOrdersScreenState extends ConsumerState<TailorOrdersScreen> {
  _Filter _filter = _Filter.all;

  Future<void> _setStatus(OrderModel order, OrderStatus status) async {
    try {
      await ref.read(orderServiceProvider).updateStatus(order.id, status);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order marked "${status.label}".')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not update status: $e')));
    }
  }

  void _openStatusPicker(OrderModel order) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusCard)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(AppSizes.lg, AppSizes.lg, AppSizes.lg, AppSizes.sm),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Set order status',
                      style: TextStyle(
                          color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                ),
              ),
              for (final status in OrderStatus.values)
                ListTile(
                  leading: Icon(
                    status == order.status ? LucideIcons.circleDot : LucideIcons.circle,
                    color: _statusColor(status),
                    size: 20,
                  ),
                  title: Text(status.label,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight:
                            status == order.status ? FontWeight.w600 : FontWeight.normal,
                      )),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    if (status != order.status) _setStatus(order, status);
                  },
                ),
              const SizedBox(height: AppSizes.sm),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(tailorOrdersProvider);

    return ordersAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: AppColors.goldAccent)),
      error: (e, _) => Center(
        child: Text('Could not load orders: $e',
            style: const TextStyle(color: Colors.white70)),
      ),
      data: (orders) {
        final filtered = orders.where((o) => _filter.matches(o.status)).toList();

        return Column(
          children: [
            SizedBox(
              height: 48,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                scrollDirection: Axis.horizontal,
                itemCount: _Filter.values.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSizes.sm),
                itemBuilder: (context, i) {
                  final f = _Filter.values[i];
                  final selected = f == _filter;
                  return ChoiceChip(
                    label: Text(f.label),
                    selected: selected,
                    onSelected: (_) => setState(() => _filter = f),
                    selectedColor: AppColors.goldAccent.withAlpha(60),
                    backgroundColor: AppColors.darkSurfaceHighlight,
                    labelStyle: TextStyle(
                        color: selected ? AppColors.goldAccent : Colors.white70),
                    side: BorderSide(
                        color: selected ? AppColors.goldAccent : Colors.white12),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.xl),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.package, size: 56, color: Colors.white24),
                            const SizedBox(height: AppSizes.md),
                            Text(
                              orders.isEmpty
                                  ? 'No orders yet'
                                  : 'No orders in "${_filter.label}"',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                          AppSizes.md, 0, AppSizes.md, AppSizes.xl),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSizes.md),
                        child: _OrderCard(
                          order: filtered[i],
                          onAdvance: () {
                            final next = _nextStatus(filtered[i].status);
                            if (next != null) _setStatus(filtered[i], next);
                          },
                          onPickStatus: () => _openStatusPicker(filtered[i]),
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _OrderCard extends ConsumerWidget {
  const _OrderCard({
    required this.order,
    required this.onAdvance,
    required this.onPickStatus,
  });

  final OrderModel order;
  final VoidCallback onAdvance;
  final VoidCallback onPickStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final customerName = ref.watch(customerNameProvider(order.customerId));
    final next = _nextStatus(order.status);
    final isTerminal = order.status == OrderStatus.delivered ||
        order.status == OrderStatus.cancelled ||
        order.status == OrderStatus.rejected;

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceHighlight,
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.clothingType.isEmpty ? order.category : order.clothingType,
                      style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      customerName.when(
                        data: (name) => name,
                        loading: () => '…',
                        error: (_, __) => 'Customer',
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.moreVertical, color: Colors.white54, size: 20),
                onPressed: onPickStatus,
                tooltip: 'Set status',
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _StatusPill(status: order.status),
              if (order.price != null)
                Text('\$${order.price!.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
              if (order.createdAt != null)
                Text(DateFormat('MMM d, h:mm a').format(order.createdAt!),
                    style: const TextStyle(color: Colors.white38, fontSize: 12)),
            ],
          ),
          if (!isTerminal) ...[
            const SizedBox(height: AppSizes.md),
            Row(
              children: [
                if (next != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onAdvance,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.goldAccent,
                        side: const BorderSide(color: AppColors.goldAccent),
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusField),
                        ),
                      ),
                      child: Text('Mark as ${next.label}'),
                    ),
                  ),
                if (order.status == OrderStatus.placed) ...[
                  const SizedBox(width: AppSizes.sm),
                  OutlinedButton(
                    onPressed: () => _confirmReject(context, ref),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.md, vertical: AppSizes.sm),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusField),
                      ),
                    ),
                    child: const Text('Reject'),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmReject(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text('Reject this order?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'The customer will be notified that you cannot take this order.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Reject', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(orderServiceProvider).updateStatus(order.id, OrderStatus.rejected);
    }
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(AppSizes.radiusField),
        border: Border.all(color: color.withAlpha(120)),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
