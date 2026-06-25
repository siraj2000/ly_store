# Admin Workflows

## Seeded Demo Admin Accounts

- `admin@stylehub.com` / `123456`
- `superadmin@stylehub.com` / `123456`
- `manager@stylehub.com` / `123456`
- `catalog@stylehub.com` / `123456`
- `finance@stylehub.com` / `123456`
- `support@stylehub.com` / `123456`
- `compliance@stylehub.com` / `123456`
- `risk@stylehub.com` / `123456`

## Current Auth Workflow

1. User signs in from the shared login screen.
2. `AuthService` resolves the user from canonical mock marketplace data.
3. `AuthController` exposes:
   - role
   - admin active state
   - permission checks
4. `AppRoutes` blocks inactive admin accounts from protected admin routes.

## Planned Workflow Expansions

- maker-checker approval requests
- audit log creation for sensitive actions
- permission-aware admin shell navigation
- controller-level authorization across all admin mutations
