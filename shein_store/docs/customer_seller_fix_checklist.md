# Customer and Seller Fix Checklist

Status values: Not Started, In Progress, Implemented, Tested.

| Area | Issue | Status |
| --- | --- | --- |
| Project governance | Preserve MVC, Provider, ChangeNotifier controllers, repository pattern, and SharedPreferences demo persistence | In Progress |
| Project governance | Keep one canonical source for products, stores, categories, users, orders, reviews, notifications, and balances | In Progress |
| Customer UI | Home spacing, compact hero, earlier product/store content, category images, responsive cards, no overflow | In Progress |
| Customer UI | Checkout cards/padding reduced while preserving sticky order action | Not Started |
| Customer UI | Guest profile uses real feature icons with small lock badges | Not Started |
| Auth | Real local demo forgot/reset password flow with mock verification code and persisted password change | In Progress |
| Cart | Add to cart validates active product, active seller, active store, variants, and stock | In Progress |
| Cart | Update quantity blocks values below 1 and above current stock | In Progress |
| Cart | Edit variant validates current variant and stock | Not Started |
| Cart | Buy again validates availability, stock, and price changes | Not Started |
| Checkout | Final checkout reloads and validates all selected cart items | Not Started |
| Checkout | Price changes require customer confirmation before charging | Not Started |
| Inventory | Inventory model, movement model, reservation/deduction lifecycle, and persistence | Not Started |
| Finance | Points deduction and transaction after successful order only | Not Started |
| Finance | Wallet deduction and transaction after successful order only | Not Started |
| Finance | Coupon validation, usage recording, and single-use protection | Not Started |
| Finance | Gift card validation, partial usage, balances, history, and expiry support | Not Started |
| Shipping | ShippingMethodModel affects fee, delivery estimate, total, and order snapshot | Not Started |
| Buy Now | Result-based add-to-cart flow blocks navigation on validation failure | In Progress |
| Variants | Empty color/size lists do not crash and hide unneeded selectors | Not Started |
| Reviews | ProductReviewModel, eligibility, duplicate prevention, edit flow, rating recalculation, and seller notification | Not Started |
| Product Details | Recommended product quick add has auth guard, variant selector, stock validation, and feedback | Not Started |
| Customer Orders | View details, tracking, service contact, cancellation, return, refund, buy again, review, store rating, confirm received | Not Started |
| Address Book | Add, edit, delete, set default, and checkout selection | Not Started |
| Payment Options | Add/edit/delete/default/select mock payment method without storing full card or CVV | Not Started |
| Multi-seller Orders | Master order status aggregator instead of copying seller order status | Not Started |
| Notifications | Customer order lifecycle notifications with event de-duplication | Not Started |
| Notifications | Seller order/review/approval/low-stock notifications with event de-duplication | Not Started |
| Categories | Stable category IDs shared by admin, seller, customer, search, and listings | Not Started |
| Seller UI | Seller navigation, app bars, cards, headers, badges, empty/loading/error states match design system | Not Started |
| Seller Localization | Move seller hardcoded visible strings to ARB and remove mojibake | Not Started |
| Seller Store | Split large seller store screen into reusable widgets | Not Started |
| Seller Drafts | Separate draft validation from publish validation | Not Started |
| Seller Images | Multi-image picker, max 9, cover/reorder/remove/replace, local persistence | Not Started |
| Approval | Prevent seller activation bypass when admin product approval is required | Not Started |
| Persistence | Await critical product, order, inventory, notification, wallet, points, and coupon writes | Not Started |
| SKU | SKU uniqueness validation for create, edit, duplicate, and import | Not Started |
| Pricing | Centralized price/oldPrice/discount consistency validation | Not Started |
| Publish Guard | Validate seller account, store state, category permission before product publish | Not Started |
| Seller Orders | SellerOrderStatus enum, transition validator, and status history | Not Started |
| Shipping Data | Require carrier/tracking/package data before shipped status | Not Started |
| Privacy | Safe customer name masking helper | Not Started |
| Seller Finance | Real seller balance, transaction, settlement, commission, delay, and finance UI logic | Not Started |
| Store Metrics | Remove fake rating, follower, conversion, and finance fallbacks | Not Started |
| Store Source | StoreModel is the canonical store source with migration from legacy UserModel fields | Not Started |
| Seller Dashboard | Dashboard reacts to product/order/return/review changes immediately | Not Started |
| Performance | Reduce full snapshot persistence, repeated sorting, broad rebuilds, and expensive build work | Not Started |
| API Readiness | Document backend requirements and keep repository interfaces replaceable | In Progress |
| Localization | New/changed visible strings added to app_en.arb and app_ar.arb | Not Started |
| Tests | Customer unit/widget tests listed in the prompt | Not Started |
| Tests | Seller unit/widget tests listed in the prompt | Not Started |
| Tests | General localization, dark mode, persistence, migration tests | Not Started |
| Validation | flutter pub get, flutter gen-l10n, dart format ., flutter analyze, flutter test, optional web debug build | Not Started |
