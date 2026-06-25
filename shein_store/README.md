# StyleHub

StyleHub is an original Flutter mobile fashion marketplace demo with a guest-first browsing flow, mock commerce actions, and a full MVC + Provider structure.

## Project Overview

The app includes:

- Guest browsing for home, categories, trends, search, and product discovery
- Mock sign in, registration, and password reset flows
- Role-based interfaces for Guest, Customer, Seller, and Admin
- Wishlist, cart, checkout, orders, notifications, profile, wallet, coupons, and settings screens
- Seller dashboards for products, orders, finance, and store management
- Admin dashboards for user, product, order, banner, coupon, and report oversight
- Dense shopping UI built for mobile-first browsing on iOS and Android

## Architecture

This project uses:

- `Models`: plain app data such as `ProductModel`, `UserModel`, `OrderModel`, and `CouponModel`
- `Views`: Flutter screens and widgets only
- `Controllers`: `ChangeNotifier` classes for business logic and UI state
- `Provider`: app-wide state wiring through `MultiProvider`

Business logic stays out of widgets and is handled by controllers such as:

- `AuthController`
- `ProductController`
- `CartController`
- `WishlistController`
- `CheckoutController`
- `OrderController`
- `SearchController`
- `SettingsController`
- `SellerProductController`
- `SellerOrderController`
- `AdminDashboardController`
- `AdminProductApprovalController`

The project now also includes repository scaffolding for the admin module:

- `MarketplaceRepository`
- `LocalMarketplaceRepository`
- `AdminRepository`
- `LocalAdminRepository`

## Folder Structure

```text
lib/
  app.dart
  main.dart
  core/
  controllers/
  models/
  services/
  views/
```

## How To Run

```bash
flutter pub get
flutter run
```

## Guest Mode

Guest users can:

- Open the app
- Complete or skip onboarding
- Browse home, categories, trends, listings, search, and product details
- View generic notifications and help topics

Guest users cannot complete restricted actions like add to cart, wishlist, checkout, address management, payment setup, or order history. Restricted actions trigger the auth-required bottom sheet.

## Role-Based Access

The app routes users by role after initialization or login:

- `Guest` -> customer marketplace in restricted browsing mode
- `Customer` -> `MainTabScreen`
- `Seller` -> seller dashboard workspace
- `Admin` -> admin dashboard workspace

Seller and admin routes are protected with role guards, and customer-only commerce actions are also checked inside controllers.

## Local Persistence

- `shared_preferences` is used for temporary local demo persistence
- Local storage currently keeps login session, registered users, cart, wishlist, orders, addresses, payment methods, wallet data, notifications, seller data, admin-managed mock state, theme, and app settings
- Registered accounts remain available after restarting the app
- Logout clears only the active session and keeps saved local account data
- This local storage layer is for demo use only and should be replaced by API/backend services for production

## Demo Accounts

Customer:

- Email: `customer@stylehub.com`
- Password: `123456`

Seller:

- Email: `seller@stylehub.com`
- Password: `123456`

Admin:

- Email: `admin@stylehub.com`
- Password: `123456`

Additional admin demo accounts:

- `superadmin@stylehub.com` / `123456`
- `manager@stylehub.com` / `123456`
- `catalog@stylehub.com` / `123456`
- `finance@stylehub.com` / `123456`
- `support@stylehub.com` / `123456`
- `compliance@stylehub.com` / `123456`
- `risk@stylehub.com` / `123456`

## Admin Foundation

The admin module is being expanded toward a full marketplace operations system.

Implemented foundation pieces currently include:

- seeded admin sub-role demo accounts
- admin role metadata on users
- admin active/inactive account support
- permission list support on admin users
- `AuthController.hasPermission(...)`
- admin repository abstractions backed by local demo persistence
- admin architecture and workflow docs in `docs/`

Current admin docs:

- `docs/admin_architecture.md`
- `docs/admin_permissions.md`
- `docs/admin_workflows.md`
- `docs/admin_implementation_checklist.md`

## Mock Data Location

Primary mock data is defined in:

- `lib/services/mock_data_service.dart`

This service provides products, categories, coupons, notifications, orders, addresses, payment methods, reviews, user roles, seller listings, approval state, and preferences used across the app.

## Connecting A Real Backend Later

To integrate production services later, replace or extend the mock service layer:

- `AuthService` for authentication and session persistence
- `ProductService` for catalog APIs
- `CartService` for remote cart sync
- `OrderService` for checkout and order history

Controllers are already separated from the widget layer, which makes swapping mock services for real repositories much easier.

## Payment Note

Payment handling is mock-only in this demo. The app does not process real cards, wallet funding, PayPal authorization, or gift card transactions.
