# PTMS - Property & Tenant Management System

Flutter / Android / GetX / SQLite (local-first, single owner).

## Run
    flutter pub get
    flutter run

## What is included
- GetX app shell: bindings, named routes, PIN middleware, translations (AR/EN, RTL), theme switch
- SQLite schema for all entities (properties, units, tenants, contracts, services, obligations, payments, documents)
- ObligationService: idempotent monthly rent catch-up on app start (UNIQUE contract+period+type)
- Dashboard with live stats, Settings (language, theme, PIN, DB backup/share)
- Properties: complete vertical slice (model -> repository -> controller (StateMixin) -> view). Copy this pattern for the other modules
- Contract PDF skeleton with blank signature / thumbprint / two-witness areas
- Placeholder pages for the remaining modules

## Next steps
1. Put Cairo-Regular.ttf and Cairo-Bold.ttf in assets/fonts/ (needed for Arabic in PDFs)
2. Build Units, Tenants, Contracts (copy the Properties slice)
3. Extend ObligationService with services (fixed / consumption / shared splits)
4. Payments: update obligations.paid_amount and status in one transaction
5. Restore-from-backup, reports, receipts

## Open decisions (from SRS section 9)
Currency, shared-service split method, contract templates, due-day per contract, proration, backup/restore.