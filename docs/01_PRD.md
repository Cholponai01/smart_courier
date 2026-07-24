# Smart Courier — Volume 1: Product Requirements Document (PRD)

Version 1.0 | Status: Draft
Platform: Flutter (single codebase, role-based access) · Firebase · Stripe

## 1. Executive Summary

Smart Courier is a delivery-logistics product consisting of a single Flutter application with role-based access for three actor types — Customer, Courier, and Admin — backed by Firebase and Stripe. The product allows a customer to place a delivery order, a courier to accept and fulfil it, and an admin to oversee operations, with live GPS tracking as the central technical differentiator.

This document defines the product's purpose, scope, user roles, core flows, and technical direction for the MVP (Minimum Viable Product) phase. It is intentionally scoped to be achievable by a single developer working part-time (3-5 hours/week), while remaining architecturally sound enough to extend into a production-grade system in later phases.

This is a personal portfolio product built to industry standards, not a throwaway prototype: architecture, testing, and code quality decisions follow the same discipline expected on a professional team.

## 2. Problem Statement & Vision

Local and regional delivery services (food, parcels, documents) require real-time visibility into where an order is and when it will arrive. Many small-scale delivery operations rely on manual coordination (phone calls, messaging apps) with no live tracking, which creates uncertainty for the customer and inefficiency for the courier and dispatcher.

**Vision:** build a lightweight, technically solid delivery platform where a customer can request a delivery, an available courier can accept it, and both the customer and an admin can track the courier's live location until delivery is confirmed — a compact but faithful version of the workflow used by production courier platforms.

## 3. Goals & Success Criteria

- Ship a working, installable MVP (Android first) within Phase 1, deployable end-to-end: order creation → courier assignment → live tracking → delivery confirmation → payment.
- Demonstrate Clean Architecture + feature-first structure in a way that is inspectable by a reviewer within minutes.
- Reach meaningful automated test coverage (unit, widget, and at least one integration test per core flow) — an explicit differentiator versus typical junior-level portfolio projects.
- Produce a project that can be discussed in technical depth in an interview: architectural trade-offs, not just feature lists.
- Keep scope realistic for 3-5 hours/week of part-time development without stalling.

## 4. User Roles

The application uses a single Flutter codebase with role-based routing and permissions determined at login. There is no separate customer app and courier app — one entry point, one login screen, role-aware navigation and UI after authentication.

| Role | Primary Goal | Key Capabilities |
|---|---|---|
| Customer | Get a package delivered with visibility into progress. | Create order, view live courier location on map, receive status notifications, pay, rate delivery. |
| Courier | Find and fulfil delivery jobs efficiently. | View available orders, accept/reject, update status, share live location, view earnings history. |
| Admin | Oversee platform operations. | View all active orders on a map, view courier list & status, resolve stuck orders, view basic metrics. |

## 5. MVP Scope

### 5.1 In Scope (Phase 1)

| Area | Included in MVP |
|---|---|
| Authentication | Email/phone + Firebase Auth, single login screen, role assigned per account. |
| Order Management | Create order (pickup/drop-off address, package note), order status lifecycle (created → accepted → picked up → delivered → completed). |
| Courier Matching | Manual accept from an open-orders list (no auto-dispatch algorithm in MVP). |
| Live Tracking | Courier's live GPS position shown on customer's and admin's map while an order is active. |
| Notifications | Push notifications for key status changes (order accepted, courier arriving, delivered). |
| Payments | Stripe integration for order payment (test mode acceptable for portfolio purposes). |
| Admin Panel | Same Flutter codebase (Web build), admin role: order list + map overview, courier status list. |

### 5.2 Out of Scope (Phase 1 — candidates for later phases)

- Automatic courier-order matching / dispatch algorithm.
- Background GPS tracking via native foreground service (Phase 2 — the dedicated native module).
- In-app chat between customer and courier.
- Multi-currency / multi-region pricing logic.
- iOS-specific background location handling (Phase 2).

## 6. Core User Flows

### 6.1 Order Creation (Customer)
Customer logs in → selects "New Order" → enters pickup and drop-off address (map picker) → confirms package details → order is created with status `created` and becomes visible to couriers.

### 6.2 Order Acceptance (Courier)
Courier logs in → sees list of open orders near them → accepts one → order status becomes `accepted` → customer is notified → courier's live location becomes visible to the customer.

### 6.3 Live Tracking (Customer + Admin)
While status is `accepted` or `picked_up`, the courier's device streams location updates to Firestore at a fixed interval; customer and admin views subscribe to this stream and render the courier's marker on a live map.

### 6.4 Delivery Completion & Payment
Courier marks order as `delivered` at drop-off → triggers payment capture via Stripe → order status becomes `completed` → customer is prompted to rate the delivery.

## 7. Technology Stack & Architecture Direction

| Layer | Choice | Notes |
|---|---|---|
| Client | Flutter (single app, role-based) | Android first; iOS as stretch goal; Web for Admin. |
| Architecture | Clean Architecture + Feature-First | data / domain / presentation per feature; Bloc for state management; repository pattern to abstract Firebase. |
| Backend | Firebase (Auth, Firestore, Cloud Functions, Cloud Messaging) | Cloud Functions handle sensitive logic (payment capture, status transitions) instead of a custom backend server. |
| Payments | Stripe (via Cloud Functions) | Client never talks to Stripe secret keys directly. |
| Location | geolocator + Firestore live updates (Phase 1); native foreground service (Phase 2) | Phase 1 keeps tracking app-foreground only, to bound scope. |
| Testing | flutter_test, bloc_test, integration_test | Domain/use-case unit tests, widget tests for key screens, one integration test per core flow. |

Architectural rationale (expanded in Volume 3): Clean Architecture and the repository pattern are used specifically so that Firebase can later be partially replaced or supplemented (e.g., a native background-tracking service in Phase 2) without rewriting business logic.

## 8. Non-Functional Requirements (Summary)

- Live location updates should reach subscribers within ~5 seconds under normal network conditions.
- The app must degrade gracefully with no network (queued actions, clear offline indicator) rather than crash.
- Firestore Security Rules must enforce role-based access at the data layer, not only in the UI.
- Crash-free session rate and basic analytics/logging are tracked from Phase 1 (Firebase Crashlytics).

Full detail for each item belongs in Volume 2 (SRS).

## 9. Roadmap

| Phase | Focus | Approx. Effort (at 3-5 h/week) |
|---|---|---|
| Phase 1 — MVP | Full flow above, Flutter + Firebase + Stripe, core tests, published to GitHub. | ~4-6 weeks |
| Phase 2 — Native Module | Android foreground-service background GPS tracking via Platform Channel. | ~3-4 weeks |
| Phase 3 — Hardening | Expanded test coverage, CI/CD (GitHub Actions), polished README, ADRs. | ~2-3 weeks |

## 10. Open Questions

- Exact Stripe flow: direct charge vs. Stripe Connect (relevant if courier payouts are modeled later).
- Whether Phase 2's native module targets Android only or also iOS background location.
- Final naming/branding for the public GitHub repository.

## 11. Related Documents

- Volume 2 — Software Requirements Specification (SRS)
- Volume 3 — System Architecture & Clean Architecture layout
- Volume 4 — Firebase Backend & Firestore Data Design
- Volume 5 — Testing Strategy
- Volume 6 — CI/CD & Deployment
