# LY STORE API Contract

This document describes the backend contract required to replace the current local demo data layer. The mobile app keeps Customer and Seller roles only. Admin belongs to a future separate app.

## Common Rules

- Base URL: `API_BASE_URL`
- Auth: Bearer access token unless marked public.
- Pagination: `page`, `limit`
- Sorting: `sort=recommended|newest|price_asc|price_desc|top_rated|popular|discount`
- Localization: clients send `Accept-Language: en|ar`; IDs stay stable and names are display-only.
- Standard success envelope: `{ "data": ..., "meta": ... }`
- Standard error envelope: `{ "code": "stock_unavailable", "message": "...", "details": {} }`

## Auth

| Method | Path | Auth | Request | Response | Errors |
| --- | --- | --- | --- | --- | --- |
| POST | `/auth/login` | Public | `email`, `password` | user, roles, tokens | `invalid_credentials`, `account_disabled` |
| POST | `/auth/register` | Public | name, email, phone, password, role | user, tokens | `email_exists`, `invalid_phone` |
| POST | `/auth/logout` | Required | refreshToken | success | `invalid_token` |
| POST | `/auth/refresh` | Public | refreshToken | tokens | `invalid_token`, `expired_token` |
| POST | `/auth/forgot-password` | Public | email or phone | success | `not_found` |
| GET | `/me` | Required | none | current user profile | `unauthorized` |
| PATCH | `/me` | Required | name, phone, email, avatarUrl | updated user | `email_exists`, `invalid_phone` |

## Customer Endpoints

| Method | Path | Auth | Request / Query | Response | Notes |
| --- | --- | --- | --- | --- | --- |
| GET | `/products` | Public | filters, sort, pagination | products | Only public, active, orderable products. |
| GET | `/products/{id}` | Public | none | product details, variants, reviews summary | Include stable category IDs. |
| GET | `/categories` | Public | departmentId optional | departments, categories, subcategories | IDs never depend on translated labels. |
| GET | `/search` | Public | `q`, filters, sort, pagination | products, stores | Search names, SKU, tags, store city/address. |
| GET | `/cart` | Customer | none | cart items | Include selected variant snapshot. |
| POST | `/cart/items` | Customer | productId, variantId, quantity | cart | Validate stock immediately. |
| PATCH | `/cart/items/{id}` | Customer | quantity, selected | cart | Reject quantity above stock. |
| DELETE | `/cart/items/{id}` | Customer | none | cart | Remove one item. |
| GET | `/wishlist` | Customer | pagination | products | Customer only. |
| POST | `/wishlist/{productId}` | Customer | none | wishlist state | Idempotent. |
| DELETE | `/wishlist/{productId}` | Customer | none | wishlist state | Idempotent. |
| POST | `/checkout/validate` | Customer | selectedCartItemIds, couponCode, walletAmount, points | quote | No state mutation. |
| POST | `/checkout/place-order` | Customer | selectedCartItemIds, addressId/body, paymentMethod, couponCode, walletAmount, points | master order, seller orders | Must be transaction-safe. |
| GET | `/orders` | Customer | status, pagination | master orders | Supports unpaid, processing, shipped, delivered, review, returns. |
| GET | `/orders/{id}` | Customer | none | order details, seller orders, tracking | Customer owns order. |
| POST | `/orders/{id}/cancel` | Customer | reason | order | Only eligible statuses. |
| POST | `/orders/{id}/returns` | Customer | sellerOrderId, reason, note, imageUrls | return request | Delivered/eligible only. |
| GET | `/returns` | Customer | status, pagination | return requests | Track status. |
| GET | `/reviews/product/{productId}` | Public | pagination | verified reviews | Visible to guests. |
| POST | `/reviews` | Customer | productId, orderId, rating, text, imageUrls | review | Purchased product only. |
| PATCH | `/reviews/{id}` | Customer | rating, text, imageUrls | review | Owner only. |
| GET | `/wallet` | Customer | none | balance, transactions | No card/CVV storage. |
| POST | `/wallet/use` | Customer | orderQuoteId, amount | quote | Final deduction only in checkout. |
| GET | `/points` | Customer | none | balance, transactions | Earn/redeem history. |
| POST | `/gift-cards/redeem` | Customer | code | wallet transaction | Reject reused/expired codes. |
| GET | `/coupons` | Customer | storeId optional | eligible coupons | Include expiry and limits. |
| POST | `/coupons/validate` | Customer | code, cartItemIds | discount quote | No consumption. |
| GET | `/notifications` | Required | role, unread, pagination | notifications | Include entityType/entityId/route. |
| PATCH | `/notifications/{id}/read` | Required | none | notification | Mark single read. |
| PATCH | `/notifications/read-all` | Required | role | success | Mark all read. |

## Seller Endpoints

| Method | Path | Auth | Request / Query | Response | Notes |
| --- | --- | --- | --- | --- | --- |
| GET | `/seller/dashboard` | Seller | dateRange | totals, alerts, quick actions | Derived from seller-owned data only. |
| GET | `/seller/store` | Seller | none | store profile | Own store only. |
| PATCH | `/seller/store` | Seller | name, logoUrl, address, categoryIds | store | Approval fields controlled by backend/admin. |
| PATCH | `/seller/store/vacation` | Seller | enabled, reason | store | Affects orderability. |
| GET | `/seller/products` | Seller | status, categoryId, search, pagination | products | Own products only. |
| POST | `/seller/products` | Seller | product draft | product | Save draft. |
| PATCH | `/seller/products/{id}` | Seller | product fields | product | Own product only. |
| POST | `/seller/products/{id}/publish` | Seller | none | product status | Respect approval policy. |
| POST | `/seller/products/{id}/resubmit` | Seller | changes | product pendingApproval | Requires rejection reason history. |
| PATCH | `/seller/products/{id}/variants/{variantId}` | Seller | sku, priceAdjustment, stock, active | variant | Stock managed per variant. |
| POST | `/seller/products/{id}/duplicate` | Seller | none | draft product | Duplicate as draft. |
| POST | `/seller/products/{id}/archive` | Seller | reason | product | Confirmation required in UI. |
| GET | `/seller/orders` | Seller | status, pagination | seller orders | Seller sees only own orders. |
| GET | `/seller/orders/{id}` | Seller | none | seller order details | Include delivery info for own order. |
| POST | `/seller/orders/{id}/confirm` | Seller | none | seller order | Confirmation required. |
| POST | `/seller/orders/{id}/cancel` | Seller | reason | seller order | Reason required. |
| POST | `/seller/orders/{id}/ship` | Seller | carrierName, trackingNumber, trackingUrl, notes | seller order | Save `shippedAt`, notify customer. |
| POST | `/seller/orders/{id}/deliver` | Seller | deliveredAt optional | seller order | Recompute master order. |
| GET | `/seller/returns` | Seller | status, pagination | return requests | Own seller orders only. |
| POST | `/seller/returns/{id}/approve` | Seller | reason optional | return request | Notify customer. |
| POST | `/seller/returns/{id}/reject` | Seller | reason | return request | Reason required. |
| POST | `/seller/returns/{id}/received` | Seller | notes | return request | Optional local/API-ready stage. |
| GET | `/seller/finance` | Seller | dateRange, status | earnings, commissions, payouts | Derived from seller orders only. |
| POST | `/seller/finance/payout-request` | Seller | amount, payoutMethodId | payout request | API-ready if payment provider absent. |
| GET | `/seller/reviews` | Seller | productId, pagination | reviews | Seller cannot delete customer reviews. |
| GET | `/seller/notifications` | Seller | unread, pagination | notifications | New order, returns, approvals, finance. |

## Future Admin App Endpoints

These are documented for backend planning only and must not be exposed in this app.

| Method | Path | Purpose |
| --- | --- | --- |
| GET/PATCH | `/admin/sellers` | Seller approval, suspension, risk flags |
| GET/PATCH | `/admin/stores` | Store moderation and vacation/suspension policy |
| GET/POST/PATCH | `/admin/product-approvals` | Product approve/reject/resubmit moderation |
| GET/POST/PATCH | `/admin/categories` | Stable department/category/subcategory IDs |
| GET/PATCH | `/admin/products` | Product moderation and takedown |
| GET/PATCH | `/admin/orders` | Marketplace order oversight |
| GET/PATCH | `/admin/returns` | Return/refund dispute handling |
| GET | `/admin/finance` | Commission, payout, refund reporting |
| GET | `/admin/reports` | Operational reports |
| GET/PATCH | `/admin/risk` | Risk/compliance review |
| GET | `/admin/audit-logs` | Immutable admin action logs |

## Checkout Transaction Requirements

`POST /checkout/place-order` must perform one atomic transaction:

1. Validate customer session, selected cart items, active products, active sellers, active stores, store vacation/suspension state, variants, stock, coupon, wallet, points, gift cards, and non-negative final total.
2. Deduct product/variant stock.
3. Consume coupon only after successful validation.
4. Deduct wallet and points only after successful validation.
5. Create master order and seller orders grouped by seller/store.
6. Create customer and seller notifications.
7. Award points according to policy.
8. Clear purchased cart items only.
9. Roll back all changes on failure.

## Required Error Codes

- `unauthorized`
- `forbidden_role`
- `cart_empty`
- `product_not_found`
- `product_not_orderable`
- `seller_inactive`
- `store_inactive`
- `store_suspended`
- `store_on_vacation`
- `variant_invalid`
- `stock_unavailable`
- `coupon_invalid`
- `coupon_expired`
- `coupon_limit_reached`
- `wallet_insufficient`
- `points_insufficient`
- `gift_card_invalid`
- `negative_total`
- `return_not_eligible`
- `review_not_eligible`
- `tracking_required`
- `validation_error`
