# Admin Permissions

The admin foundation now supports:

- admin role name on the signed-in user
- admin active/inactive state
- admin permission id lists
- wildcard permission support through `*`

## Seeded Roles

- Super Admin
- Marketplace Manager
- Catalog Moderator
- Finance Officer
- Customer Support Agent
- Compliance Officer
- Risk Analyst
- Read Only

## Permission Examples Seeded

- `dashboard.view`
- `sellers.view`
- `sellers.approve`
- `products.view`
- `products.approve`
- `products.reject`
- `orders.view`
- `orders.update`
- `refunds.approve`
- `support.manage`
- `compliance.manage`
- `risk.manage`
- `reports.view`
- `audit.view`
- `*`

## Current Enforcement

Currently enforced in the auth/routing layer:

- admin role check
- admin active account check
- permission helper via `AuthController.hasPermission(...)`

## Next Step

The next migration step is to move sensitive admin controller actions to explicit repository + permission-guarded methods and to add audit logging for those actions.
