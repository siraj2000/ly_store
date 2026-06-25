# Admin Gap Audit

Verified against the current StyleHub source before this implementation pass:

- Admin controllers still depend heavily on `MockDataService` instead of repository abstractions.
- `AdminRepository` currently covers admin users, roles, permissions, platform settings, and audit logs only.
- `CheckoutController` was registered before `OrderController` in `app.dart`.
- `AdminDashboardController.todayRevenue` compared only the day number.
- `AdminReportController` used hardcoded refund and complaint counts.
- Store data was still embedded inside `UserModel`; there was no canonical `StoreModel`.
- `MarketplaceRepository` had no store APIs.
- Product records still used raw status strings such as `approved`, `pending_approval`, and `out_of_stock`.
- Seller product creation always defaulted to approval flow instead of respecting a platform rule.
- Platform settings defaulted `requiresProductApproval` to `true`.
- The mock marketplace catalog still had a single seller/store source.
- Admin account screens still used local translation helpers instead of `AppLocalizations`.
- Several admin screens remained read-only and partially localized.

Implementation focus for this pass:

- Add canonical store data and migration support.
- Add stable product status serialization and migration.
- Fix seller publishing rules to support immediate publishing by default.
- Expand repository contracts for store operations.
- Remove a few hardcoded admin metrics.
- Add tests for the new model/status foundation.
