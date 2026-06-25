# Backend Migration Requirements

StyleHub currently uses SharedPreferences-backed local demo persistence. That means data is local to one app installation and is not synchronized between devices, users, or sellers.

Production requires:

- Central API services for auth, marketplace catalog, orders, inventory, notifications, reviews, finance, and admin policy.
- Database-backed canonical records for users, stores, products, categories, orders, seller orders, inventory, reviews, coupons, gift cards, wallet balances, points, and notification events.
- Authentication tokens, refresh tokens, role claims, server-side permission checks, and password reset tokens.
- Server-side stock locking and transactional order placement so two customers cannot buy the same unavailable stock.
- File storage and signed upload/download URLs for product, store, review, and profile images.
- Payment gateway integration for card wallets, local payment providers, refunds, settlement, disputes, and audit trails.
- Push notification infrastructure for customer, seller, and admin event delivery across devices.
- API repositories such as ApiMarketplaceRepository, ApiOrderRepository, ApiInventoryRepository, ApiNotificationRepository, and ApiAuthRepository that can replace the local demo repositories.
- Server-side localization data or stable notification/event payloads so clients can localize display text without storing permanent English sentences as canonical data.
- Operational monitoring, migration scripts, backup/restore, fraud controls, privacy controls, and audit logging.

Until those services exist, the demo must not claim real multi-device synchronization, real push delivery across devices, or globally synchronized seller/admin changes.
