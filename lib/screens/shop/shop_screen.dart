import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/validators.dart';
import '../../models/tailor_profile.dart';
import '../../providers/auth_providers.dart';
import '../../providers/tailor_providers.dart';
import '../../widgets/luxury_button.dart';
import '../../widgets/premium_text_field.dart';

/// "My shop" tab — displays and edits the tailor's public business profile
/// (`tailors/{uid}`): branding, description, services, availability, and
/// portfolio photos.
class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _cityController = TextEditingController();
  final _experienceController = TextEditingController();
  final _serviceController = TextEditingController();
  List<String> _services = [];

  bool _hydrated = false;
  bool _saving = false;
  bool _uploadingLogo = false;
  bool _uploadingCover = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _cityController.dispose();
    _experienceController.dispose();
    _serviceController.dispose();
    super.dispose();
  }

  // Controllers are only ever pre-filled once, so in-progress edits survive
  // the live Firestore stream re-emitting the doc after every save.
  void _hydrate(TailorProfile p) {
    if (_hydrated) return;
    _hydrated = true;
    _nameController.text = p.businessName;
    _descController.text = p.description;
    _cityController.text = p.city ?? '';
    _experienceController.text =
        p.experienceYears == 0 ? '' : '${p.experienceYears}';
    _services = List.of(p.services);
  }

  String? get _uid => ref.read(authStateProvider).valueOrNull?.uid;

  Future<void> _pickAndUpload({required bool isLogo}) async {
    final uid = _uid;
    if (uid == null) return;
    final xfile =
        await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (xfile == null) return;

    setState(() => isLogo ? _uploadingLogo = true : _uploadingCover = true);
    try {
      final service = ref.read(tailorServiceProvider);
      final url = await service.uploadImage(
        uid,
        File(xfile.path),
        isLogo ? 'logo.jpg' : 'cover.jpg',
      );
      await service.updateProfile(uid, {
        isLogo ? 'logoUrl' : 'coverUrl': url,
      });
    } catch (e) {
      _showError('Upload failed: $e');
    } finally {
      if (mounted) {
        setState(() => isLogo ? _uploadingLogo = false : _uploadingCover = false);
      }
    }
  }

  Future<void> _toggleAvailability(bool value) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await ref.read(tailorServiceProvider).updateProfile(uid, {'isAvailable': value});
    } catch (e) {
      _showError('Could not update availability: $e');
    }
  }

  void _addService() {
    final v = _serviceController.text.trim();
    if (v.isEmpty || _services.contains(v)) return;
    setState(() {
      _services.add(v);
      _serviceController.clear();
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final uid = _uid;
    if (uid == null) return;

    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      final city = _cityController.text.trim();
      await ref.read(tailorServiceProvider).updateProfile(uid, {
        'businessName': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'city': city.isEmpty ? null : city,
        'experienceYears': int.tryParse(_experienceController.text.trim()) ?? 0,
        'services': _services,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Shop details saved.')));
    } catch (e) {
      _showError('Could not save: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(tailorProfileProvider);

    return profileAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: AppColors.goldAccent)),
      error: (e, _) => Center(
        child: Text('Could not load shop: $e',
            style: const TextStyle(color: Colors.white70)),
      ),
      data: (profile) {
        if (profile == null) {
          return const Center(
            child: Text('Shop profile not found.',
                style: TextStyle(color: Colors.white70)),
          );
        }
        _hydrate(profile);

        return Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppSizes.xl),
            children: [
              _CoverAndLogo(
                coverUrl: profile.coverUrl,
                logoUrl: profile.logoUrl,
                uploadingCover: _uploadingCover,
                uploadingLogo: _uploadingLogo,
                onEditCover: () => _pickAndUpload(isLogo: false),
                onEditLogo: () => _pickAndUpload(isLogo: true),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSizes.lg, AppSizes.md, AppSizes.lg, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            profile.businessName.isEmpty
                                ? 'Your shop'
                                : profile.businessName,
                            style: theme.textTheme.headlineSmall
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
                        if (profile.isVerified)
                          const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Icon(LucideIcons.badgeCheck,
                                color: AppColors.goldAccent, size: 22),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(LucideIcons.star,
                            color: AppColors.goldAccent, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          profile.ratingCount == 0
                              ? 'No reviews yet'
                              : '${profile.ratingAvg.toStringAsFixed(1)} · ${profile.ratingCount} reviews',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.md),
                    _AvailabilityToggle(
                        value: profile.isAvailable, onChanged: _toggleAvailability),
                    const SizedBox(height: AppSizes.lg),
                    const _SectionTitle('Business details'),
                    const SizedBox(height: AppSizes.sm),
                    PremiumTextField(
                      hintText: 'Business name',
                      controller: _nameController,
                      prefixIcon: LucideIcons.store,
                      validator: (v) =>
                          Validators.required(v, label: 'Business name'),
                    ),
                    const SizedBox(height: AppSizes.md),
                    PremiumTextField(
                      hintText: 'City',
                      controller: _cityController,
                      prefixIcon: LucideIcons.mapPin,
                    ),
                    const SizedBox(height: AppSizes.md),
                    PremiumTextField(
                      hintText: 'Years of experience',
                      controller: _experienceController,
                      keyboardType: TextInputType.number,
                      prefixIcon: LucideIcons.award,
                    ),
                    const SizedBox(height: AppSizes.md),
                    PremiumTextField(
                      hintText: 'Describe your shop, specialties, and process',
                      controller: _descController,
                      prefixIcon: LucideIcons.fileText,
                      maxLines: 4,
                    ),
                    const SizedBox(height: AppSizes.lg),
                    const _SectionTitle('Services offered'),
                    const SizedBox(height: AppSizes.sm),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final s in _services)
                          InputChip(
                            label:
                                Text(s, style: const TextStyle(color: Colors.white)),
                            backgroundColor: AppColors.darkSurfaceHighlight,
                            side: const BorderSide(color: Colors.white12),
                            deleteIconColor: Colors.white70,
                            onDeleted: () => setState(() => _services.remove(s)),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Row(
                      children: [
                        Expanded(
                          child: PremiumTextField(
                            hintText: 'Add a service (e.g. Suits)',
                            controller: _serviceController,
                            prefixIcon: LucideIcons.scissors,
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        IconButton.filled(
                          onPressed: _addService,
                          icon: const Icon(LucideIcons.plus),
                          style: IconButton.styleFrom(
                              backgroundColor: AppColors.goldAccent),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.xl),
                    const _SectionTitle('Portfolio'),
                    const SizedBox(height: AppSizes.sm),
                    _PortfolioGrid(profile: profile, onError: _showError),
                    const SizedBox(height: AppSizes.xl),
                    LuxuryButton(
                        text: 'Save changes', isLoading: _saving, onPressed: _save),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(color: Colors.white),
      );
}

class _CoverAndLogo extends StatelessWidget {
  const _CoverAndLogo({
    required this.coverUrl,
    required this.logoUrl,
    required this.uploadingCover,
    required this.uploadingLogo,
    required this.onEditCover,
    required this.onEditLogo,
  });

  final String? coverUrl;
  final String? logoUrl;
  final bool uploadingCover;
  final bool uploadingLogo;
  final VoidCallback onEditCover;
  final VoidCallback onEditLogo;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 226,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 190,
            child: Container(
              color: AppColors.darkSurfaceHighlight,
              child: coverUrl == null
                  ? const Center(
                      child: Icon(LucideIcons.image, color: Colors.white24, size: 48))
                  : CachedNetworkImage(
                      imageUrl: coverUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
            ),
          ),
          Positioned(
            right: AppSizes.md,
            top: AppSizes.md,
            child: _EditBadge(loading: uploadingCover, onTap: onEditCover),
          ),
          Positioned(
            left: AppSizes.lg,
            bottom: 0,
            child: Stack(
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.darkBackground, width: 3),
                    color: AppColors.darkSurfaceHighlight,
                  ),
                  child: ClipOval(
                    child: logoUrl == null
                        ? const Icon(LucideIcons.store, color: Colors.white38, size: 32)
                        : CachedNetworkImage(imageUrl: logoUrl!, fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: _EditBadge(
                      small: true, loading: uploadingLogo, onTap: onEditLogo),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditBadge extends StatelessWidget {
  const _EditBadge({required this.loading, required this.onTap, this.small = false});

  final bool loading;
  final VoidCallback onTap;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final size = small ? 28.0 : 36.0;
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.goldAccent,
          border: small
              ? Border.all(color: AppColors.darkBackground, width: 2)
              : null,
        ),
        child: loading
            ? const Padding(
                padding: EdgeInsets.all(7),
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Icon(LucideIcons.camera, color: Colors.white, size: small ? 14 : 18),
      ),
    );
  }
}

class _AvailabilityToggle extends StatelessWidget {
  const _AvailabilityToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceHighlight,
        borderRadius: BorderRadius.circular(AppSizes.radiusField),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(
            value ? LucideIcons.checkCircle : LucideIcons.pauseCircle,
            color: value ? AppColors.success : AppColors.warning,
            size: 20,
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              value ? 'Open for new orders' : 'Not accepting orders',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: AppColors.goldAccent),
        ],
      ),
    );
  }
}

class _PortfolioGrid extends ConsumerStatefulWidget {
  const _PortfolioGrid({required this.profile, required this.onError});

  final TailorProfile profile;
  final void Function(String message) onError;

  @override
  ConsumerState<_PortfolioGrid> createState() => _PortfolioGridState();
}

class _PortfolioGridState extends ConsumerState<_PortfolioGrid> {
  bool _uploading = false;

  Future<void> _addPhoto() async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;
    final xfile =
        await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (xfile == null) return;

    setState(() => _uploading = true);
    try {
      final service = ref.read(tailorServiceProvider);
      final url = await service.uploadImage(
          uid, File(xfile.path), 'portfolio_${const Uuid().v4()}.jpg');
      await service.addPortfolioUrl(uid, url);
    } catch (e) {
      widget.onError('Upload failed: $e');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _removePhoto(String url) async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;
    try {
      await ref.read(tailorServiceProvider).removePortfolioUrl(uid, url);
    } catch (e) {
      widget.onError('Could not remove photo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.profile.portfolioUrls;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: urls.length + 1,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (context, i) {
        if (i == urls.length) {
          return GestureDetector(
            onTap: _uploading ? null : _addPhoto,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceHighlight,
                borderRadius: BorderRadius.circular(AppSizes.radiusField),
                border: Border.all(color: Colors.white12),
              ),
              child: Center(
                child: _uploading
                    ? const CircularProgressIndicator(
                        color: AppColors.goldAccent, strokeWidth: 2)
                    : const Icon(LucideIcons.plus, color: Colors.white54),
              ),
            ),
          );
        }
        final url = urls[i];
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusField),
              child: CachedNetworkImage(imageUrl: url, fit: BoxFit.cover),
            ),
            Positioned(
              right: 4,
              top: 4,
              child: GestureDetector(
                onTap: () => _removePhoto(url),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration:
                      const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                  child: const Icon(LucideIcons.x, color: Colors.white, size: 14),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
