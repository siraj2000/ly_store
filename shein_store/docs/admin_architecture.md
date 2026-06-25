# Admin Architecture

StyleHub currently uses MVC with `Provider` and `ChangeNotifier` controllers.

This admin foundation adds a repository layer so the admin module can grow without tightly coupling screens to `SharedPreferences` or the current mock service.

## Repository Layer

Implemented repositories:

- `MarketplaceRepository`
- `LocalMarketplaceRepository`
- `AdminRepository`
- `LocalAdminRepository`

`MarketplaceRepository` is the canonical abstraction for shared marketplace entities:

- users
- products
- orders
- categories

`AdminRepository` is the admin-specific abstraction for:

- admin users
- roles
- permissions
- platform settings
- audit logs

## Local Persistence

The local repositories use `LocalStorageService` and `MockDataService`.

Important note:

`Local repository is used for demo only. Replace with secure backend API repository for production.`

The structure is intentionally prepared for future replacements such as:

- `ApiMarketplaceRepository`
- `ApiAdminRepository`

without redesigning the widget layer.

## Current Constraint

The app still contains legacy admin screens/controllers that read from the older mock-service based structure. The new repository layer is now in place, but full controller migration is still in progress.
