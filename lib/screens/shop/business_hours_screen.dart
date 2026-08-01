import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../providers/auth_providers.dart';
import '../../providers/tailor_providers.dart';
import '../../widgets/luxury_button.dart';

const _weekdays = [
  ('monday', 'Monday'),
  ('tuesday', 'Tuesday'),
  ('wednesday', 'Wednesday'),
  ('thursday', 'Thursday'),
  ('friday', 'Friday'),
  ('saturday', 'Saturday'),
  ('sunday', 'Sunday'),
];

class _DayHours {
  _DayHours({
    this.isOpen = true,
    this.open = const TimeOfDay(hour: 9, minute: 0),
    this.close = const TimeOfDay(hour: 18, minute: 0),
  });

  bool isOpen;
  TimeOfDay open;
  TimeOfDay close;
}

/// Lets a tailor set the weekly opening hours shown on their shop profile.
class BusinessHoursScreen extends ConsumerStatefulWidget {
  const BusinessHoursScreen({super.key});

  @override
  ConsumerState<BusinessHoursScreen> createState() => _BusinessHoursScreenState();
}

class _BusinessHoursScreenState extends ConsumerState<BusinessHoursScreen> {
  final Map<String, _DayHours> _hours = {
    for (final (key, _) in _weekdays) key: _DayHours(),
  };
  bool _hydrated = false;
  bool _saving = false;

  void _hydrate(Map<String, dynamic> stored) {
    if (_hydrated) return;
    _hydrated = true;
    for (final (key, _) in _weekdays) {
      final raw = stored[key] as Map?;
      if (raw == null) continue;
      _hours[key] = _DayHours(
        isOpen: raw['isOpen'] as bool? ?? true,
        open: _parseTime(raw['open'] as String?) ?? const TimeOfDay(hour: 9, minute: 0),
        close: _parseTime(raw['close'] as String?) ?? const TimeOfDay(hour: 18, minute: 0),
      );
    }
  }

  static TimeOfDay? _parseTime(String? raw) {
    if (raw == null) return null;
    final parts = raw.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  static String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime(String dayKey, {required bool isOpenField}) async {
    final day = _hours[dayKey]!;
    final picked = await showTimePicker(
      context: context,
      initialTime: isOpenField ? day.open : day.close,
    );
    if (picked == null) return;
    setState(() {
      if (isOpenField) {
        day.open = picked;
      } else {
        day.close = picked;
      }
    });
  }

  Future<void> _save() async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;

    setState(() => _saving = true);
    try {
      final map = {
        for (final entry in _hours.entries)
          entry.key: {
            'isOpen': entry.value.isOpen,
            'open': _formatTime(entry.value.open),
            'close': _formatTime(entry.value.close),
          },
      };
      await ref
          .read(tailorServiceProvider)
          .updateProfile(uid, {'businessHours': map});
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Business hours saved.')));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not save: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(tailorProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: const Text('Set hours', style: TextStyle(color: Colors.white)),
      ),
      body: profileAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.goldAccent)),
        error: (e, _) => Center(
          child: Text('Could not load: $e', style: const TextStyle(color: Colors.white70)),
        ),
        data: (profile) {
          if (profile != null) _hydrate(profile.businessHours);
          return ListView(
            padding: const EdgeInsets.all(AppSizes.md),
            children: [
              const Text(
                'Customers see these hours on your shop profile.',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: AppSizes.lg),
              for (final (key, label) in _weekdays)
                _DayRow(
                  label: label,
                  day: _hours[key]!,
                  onToggle: (v) => setState(() => _hours[key]!.isOpen = v),
                  onTapOpen: () => _pickTime(key, isOpenField: true),
                  onTapClose: () => _pickTime(key, isOpenField: false),
                ),
              const SizedBox(height: AppSizes.lg),
              LuxuryButton(text: 'Save hours', isLoading: _saving, onPressed: _save),
            ],
          );
        },
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.label,
    required this.day,
    required this.onToggle,
    required this.onTapOpen,
    required this.onTapClose,
  });

  final String label;
  final _DayHours day;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTapOpen;
  final VoidCallback onTapClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceHighlight,
        borderRadius: BorderRadius.circular(AppSizes.radiusField),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(label, style: const TextStyle(color: Colors.white)),
          ),
          Switch(value: day.isOpen, onChanged: onToggle, activeColor: AppColors.goldAccent),
          const SizedBox(width: AppSizes.sm),
          if (day.isOpen)
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _TimeChip(time: day.open, onTap: onTapOpen)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Text('–', style: TextStyle(color: Colors.white38)),
                  ),
                  Expanded(child: _TimeChip(time: day.close, onTap: onTapClose)),
                ],
              ),
            )
          else
            const Expanded(
              child: Text('Closed',
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.white38)),
            ),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.time, required this.onTap});

  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(LucideIcons.clock, size: 14, color: AppColors.goldAccent),
      label: Text(time.format(context), style: const TextStyle(color: Colors.white)),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.white24),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusField),
        ),
      ),
    );
  }
}
