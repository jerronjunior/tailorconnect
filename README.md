# TailorConnect

**Custom Clothing Made Easy** — a Flutter marketplace connecting customers with professional tailors. Built with Riverpod, GoRouter, Firebase, and Clean Architecture.

## Status: Module 1 complete ✅ (Foundation + Authentication)

Delivered in this module:

- Project scaffold, folder structure, lint rules
- Material 3 theme system (light + dark) with a bespoke "atelier" identity: suiting-indigo, thread-gold, Fraunces display / Inter body typography
- Riverpod dependency injection + auth state machine (`AuthController`)
- GoRouter with auth- and role-aware redirects
- `AppUser` model + `users/{uid}` and `tailors/{uid}` Firestore documents
- Screens: Splash, 3-page Onboarding, Login (glassmorphism + gradient), Role Selection, Registration (role-aware fields), Forgot Password
- Home shells: Customer dashboard (search, banner, categories, skeleton sections, bottom nav) and Tailor dashboard (stat grid, quick actions)
- Reusable widgets: `PrimaryButton`, `AppTextField`, `GlassCard`
- Firestore security rules starter (`firestore.rules`)

## Roadmap (module by module)

| # | Module | Contents |
|---|--------|----------|
| 1 | Foundation + Auth | ✅ done |
| 2 | Tailor Discovery | Search, filters, nearby (Google Maps), tailor profile page, portfolio |
| 3 | Measurements | Measurement profiles CRUD, multiple named profiles, Hive offline cache |
| 4 | Order Creation | 10-step order wizard, image upload + compression, Stripe payment |
| 5 | Order Management & Tracking | Status timeline, tailor accept/reject, progress photos |
| 6 | Chat | Real-time Firestore chat, images, typing indicator, read receipts, FCM |
| 7 | Profile, Wallet, Reviews | Addresses, payment methods, transactions, ratings |
| 8 | Tailor Analytics & Earnings | Charts, aggregations, invoices |
| 9 | Settings & Polish | Dark-mode toggle, localization, delete account, Crashlytics, empty/error states |

## Getting started

1. **Flutter**: install the latest stable SDK, then:
   ```bash
   flutter pub get
   ```
2. **Firebase**: create a Firebase project, enable **Authentication** (Email/Password + Google), **Firestore**, **Storage**, then:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   Uncomment the `firebase_options.dart` import and the `options:` line in `lib/main.dart`.
3. **Security rules**: deploy `firestore.rules`:
   ```bash
   firebase deploy --only firestore:rules
   ```
4. **Google Sign-In (Android)**: add your SHA-1/SHA-256 fingerprints in the Firebase console and re-download `google-services.json`.
5. Run: `flutter run`

## Architecture

```
lib/
  core/            # constants, theme, router, utils (no Flutter-free logic leaks upward)
  models/          # Firestore document models (Equatable, fromDoc/toMap)
  services/        # Firebase wrappers (repository layer) — screens never touch Firebase
  providers/       # Riverpod DI + state (controllers as StateNotifier)
  screens/         # feature-first UI
  widgets/         # shared design-system widgets
```

State flows one way: `Service (Firebase) → StreamProvider → UI`, and actions flow `UI → Controller → Service`. The GoRouter redirect derives navigation purely from auth + role state, so deep links are safe.
