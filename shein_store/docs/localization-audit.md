# Localization Audit

## Scope started
- Flutter `gen_l10n` infrastructure
- Runtime language switching with `Provider`
- English and Arabic ARB files
- `MaterialApp` locale/delegates wiring
- Settings language UI
- Onboarding language selection
- Bottom navigation labels
- Seller orders screens

## Files audited in this pass
- `pubspec.yaml`
- `l10n.yaml`
- `lib/app.dart`
- `lib/controllers/settings_controller.dart`
- `lib/controllers/language_controller.dart`
- `lib/views/screens/settings/settings_screen.dart`
- `lib/views/screens/onboarding/onboarding_screen.dart`
- `lib/views/widgets/common/bottom_nav_bar.dart`
- `lib/views/screens/seller/seller_orders_screen.dart`
- `lib/views/screens/seller/seller_order_details_screen.dart`
- `lib/core/extensions/localization_extension.dart`
- `lib/core/helpers/localized_status_helper.dart`
- `lib/core/helpers/locale_formatters.dart`

## Intentionally not localized in this pass
- Brand name `StyleHub`
- Currency codes such as `USD`, `EUR`, `GBP`
- Route names and storage keys
- SKU / order ids / technical identifiers

## Remaining dynamic content limitations
- A full app-wide hardcoded-string audit is still required.
- Product, store, notification, coupon, and admin/customer/seller copy is not fully migrated yet.
- Some reusable widgets still receive hardcoded English labels from callers outside this pass.

## Bilingual content migration
- Runtime localization infrastructure is active.
- Full bilingual product/store content model migration is still pending.

## ARB completeness
- `app_en.arb` and `app_ar.arb` are currently validated by `test/localization/arb_keys_test.dart`.
- This pass keeps key parity for the keys added so far.
