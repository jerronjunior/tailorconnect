import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../models/order_model.dart';
import '../../providers/order_providers.dart';
import '../../widgets/luxury_button.dart';
import '../../widgets/premium_text_field.dart';

/// Lets a tailor pick one of their orders and send (or revise) its price
/// quote to the customer.
class SendQuoteScreen extends ConsumerWidget {
  const SendQuoteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(tailorOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: const Text('Send quote', style: TextStyle(color: Colors.white)),
      ),
      body: ordersAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.goldAccent)),
        error: (e, _) => Center(
          child: Text('Could not load orders: $e',
              style: const TextStyle(color: Colors.white70)),
        ),
        data: (orders) {
          final quotable = orders
              .where((o) =>
                  o.status != OrderStatus.cancelled && o.status != OrderStatus.rejected)
              .toList();

          if (quotable.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSizes.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.inbox, size: 56, color: Colors.white24),
                    SizedBox(height: AppSizes.md),
                    Text('No orders available to quote yet.',
                        style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.md),
            itemCount: quotable.length,
            itemBuilder: (context, i) {
              final order = quotable[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.sm),
                child: _QuotableOrderTile(order: order),
              );
            },
          );
        },
      ),
    );
  }
}

class _QuotableOrderTile extends ConsumerWidget {
  const _QuotableOrderTile({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerName = ref.watch(customerNameProvider(order.customerId));

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceHighlight,
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.clothingType.isEmpty ? order.category : order.clothingType,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  customerName.when(
                    data: (name) => name,
                    loading: () => '…',
                    error: (_, __) => 'Customer',
                  ),
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                if (order.price != null) ...[
                  const SizedBox(height: 4),
                  Text('Current quote: \$${order.price!.toStringAsFixed(2)}',
                      style: const TextStyle(color: AppColors.goldAccent, fontSize: 12)),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          LuxuryButtonSmall(
            label: order.price == null ? 'Quote' : 'Revise',
            onPressed: () => _openQuoteSheet(context, ref),
          ),
        ],
      ),
    );
  }

  void _openQuoteSheet(BuildContext context, WidgetRef ref) {
    final priceController =
        TextEditingController(text: order.price?.toStringAsFixed(2) ?? '');
    final noteController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool sending = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusCard)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                AppSizes.lg,
                AppSizes.lg,
                AppSizes.lg,
                MediaQuery.of(sheetContext).viewInsets.bottom + AppSizes.lg,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      order.price == null ? 'Send a quote' : 'Revise the quote',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: AppSizes.md),
                    PremiumTextField(
                      hintText: 'Price (e.g. 45.00)',
                      controller: priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: LucideIcons.dollarSign,
                      validator: (v) {
                        final value = double.tryParse((v ?? '').trim());
                        if (value == null || value <= 0) return 'Enter a valid price';
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.md),
                    PremiumTextField(
                      hintText: 'Note to customer (optional)',
                      controller: noteController,
                      prefixIcon: LucideIcons.fileText,
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppSizes.lg),
                    LuxuryButton(
                      text: 'Send',
                      icon: LucideIcons.send,
                      isLoading: sending,
                      onPressed: () async {
                        if (!(formKey.currentState?.validate() ?? false)) return;
                        setSheetState(() => sending = true);
                        try {
                          await ref.read(orderServiceProvider).sendQuote(
                                order.id,
                                double.parse(priceController.text.trim()),
                                note: noteController.text,
                              );
                          if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Quote sent to customer.')),
                            );
                          }
                        } catch (e) {
                          setSheetState(() => sending = false);
                          if (sheetContext.mounted) {
                            ScaffoldMessenger.of(sheetContext).showSnackBar(
                              SnackBar(content: Text('Could not send quote: $e')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Compact pill-style button used inline on list tiles.
class LuxuryButtonSmall extends StatelessWidget {
  const LuxuryButtonSmall({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.goldAccent,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusField),
        ),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
