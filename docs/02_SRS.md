# Smart Courier — Volume 2: Software Requirements Specification (SRS)

Version 1.0 | Status: Draft
Scope: Functional & Non-Functional Requirements — Phase 1 (MVP)

## 1. Introduction

This SRS translates the goals defined in Volume 1 (PRD) into concrete, testable functional and non-functional requirements. Scoped to Phase 1 (MVP); Phase 2 (native background tracking) requirements are marked separately where relevant.

## 2. Purpose & Scope

Defines exactly what the Smart Courier application must do (functional requirements), how well it must do it (non-functional requirements), and the rules that govern data validity and error handling. This document is the reference used while writing acceptance tests.

## 3. Definitions

| Term | Definition |
|---|---|
| Order | A single delivery request created by a Customer, with a defined lifecycle. |
| Active Order | An order whose status is `accepted` or `picked_up` (courier location is being tracked). |
| Role | Customer, Courier, or Admin — assigned per user account, determines UI and permissions. |
| Use Case (UC) | A discrete, testable unit of functional behavior, numbered for traceability. |

## 4. Functional Requirements

### 4.1 Authentication (UC-AUTH)

| ID | Requirement |
|---|---|
| UC-AUTH-01 | User can register with email + password via Firebase Auth. |
| UC-AUTH-02 | User can log in; on success, the app reads the user's role from Firestore and routes to the corresponding home screen. |
| UC-AUTH-03 | User can log out; local session and cached role are cleared. |
| UC-AUTH-04 | Invalid credentials show a specific, non-technical error message (see Error Handling, §7). |
| UC-AUTH-05 | A new account defaults to role `customer`; courier/admin roles are assigned manually in Firestore for MVP (no self-serve courier signup flow in Phase 1). |

### 4.2 Customer Flows (UC-CUST)

| ID | Requirement |
|---|---|
| UC-CUST-01 | Customer can create an order: pickup address, drop-off address (map picker + manual text fallback), package note, optional photo. |
| UC-CUST-02 | Customer can view the list/status of their own orders (active and past). |
| UC-CUST-03 | While an order is active, customer sees the assigned courier's live position on a map, updated at least every 5-8 seconds. |
| UC-CUST-04 | Customer receives a push notification on: order accepted, courier arriving at pickup, order delivered. |
| UC-CUST-05 | Customer can pay for the order via Stripe after courier marks it delivered (or at creation — decision recorded in §9). |
| UC-CUST-06 | Customer can rate a completed order (1-5 stars, optional comment). |

### 4.3 Courier Flows (UC-COUR)

| ID | Requirement |
|---|---|
| UC-COUR-01 | Courier sees a list of open orders (status `created`) sorted by distance from current location. |
| UC-COUR-02 | Courier can accept an open order; order becomes unavailable to other couriers atomically (Firestore transaction to prevent double-accept). |
| UC-COUR-03 | Courier can update order status: accepted → picked_up → delivered. |
| UC-COUR-04 | While an order is active, the app streams the courier's device location to Firestore at a fixed interval (foreground only in Phase 1). |
| UC-COUR-05 | Courier can view a simple earnings history (list of completed orders with amounts). |

### 4.4 Admin Flows (UC-ADM)

| ID | Requirement |
|---|---|
| UC-ADM-01 | Admin sees all active orders plotted on a map, each with its courier's live position. |
| UC-ADM-02 | Admin sees a list of couriers with current status (idle / on a delivery) and last-seen timestamp. |
| UC-ADM-03 | Admin can view details of any single order, including its full status-change history. |

### 4.5 Notifications (UC-NOTIF)

- Delivered via Firebase Cloud Messaging; triggered server-side by a Cloud Function listening to order status changes (not triggered directly from client, to prevent spoofing).

## 5. Non-Functional Requirements

### 5.1 Performance
- Cold app start (first meaningful paint) under 3 seconds on a mid-range Android device.
- Live location marker updates rendered within 1 second of receiving new Firestore data.

### 5.2 Offline Behaviour
- Order creation form retains entered data if connectivity drops mid-entry (local state, not lost on reconnect).
- A clear, non-intrusive offline banner is shown when the device has no connectivity; write actions are disabled rather than silently failing.

### 5.3 Security
- All Firestore access is governed by Security Rules matching the role model in §4 — the client UI is not the security boundary.
- Stripe secret keys and payment-capture logic live only in Cloud Functions, never in client code.
- Location data for a given order is only readable by that order's customer, its assigned courier, and admin accounts.

### 5.4 Reliability & Monitoring
- Firebase Crashlytics integrated from Phase 1; crash-free session rate tracked as a basic quality signal.
- Key business events (order created, accepted, delivered, payment captured) are logged via Firebase Analytics for basic funnel visibility.

## 6. Firestore Data Model (Overview)

Full schema detail is in Volume 4; top-level collections this SRS assumes:

| Collection | Purpose |
|---|---|
| `users` | Profile + role (customer / courier / admin) per authenticated user. |
| `orders` | One document per order: addresses, status, customer_id, courier_id, timestamps, amount. |
| `orders/{id}/location_updates` | Time-stamped courier location pings for an active order (subcollection, short retention). |
| `ratings` | One document per completed order rating. |

## 7. Error Handling & Validation Rules

| Scenario | Required Behaviour |
|---|---|
| Invalid login credentials | Show "Incorrect email or password" — never reveal whether the email exists. |
| Order form: missing pickup/drop-off | Block submission; inline field-level error, no dialog interruption. |
| Courier tries to accept an already-accepted order | Transaction fails gracefully; UI shows "This order was just taken" and refreshes the list. |
| Network failure during payment | Payment is never assumed successful client-side; status confirmed via Cloud Function / Stripe webhook before order is marked paid. |
| Location permission denied (courier) | Courier cannot go 'active' on deliveries until permission is granted; clear explanation screen, link to system settings. |

## 8. Acceptance Criteria (Sample — Core Flow)

Full acceptance-criteria set is maintained alongside the test suite (Volume 5); this illustrates the expected format.

### Order Creation → Acceptance → Delivery

- Given a logged-in customer, when they submit a valid order form, then a Firestore document is created with status `created` within 2 seconds.
- Given an open order, when a courier accepts it, then the order status becomes `accepted`, the courier_id is set, and the customer receives a push notification within 5 seconds.
- Given an active order, when the courier's location updates, then the customer's map marker moves without requiring a manual refresh.
- Given an order marked `delivered`, when payment capture succeeds, then the order status becomes `completed` and appears in the customer's order history.

## 9. Open Decisions

- Payment timing: capture at order creation (hold) vs. capture at delivery confirmation — affects Cloud Function design in Volume 4.
- Whether courier location pings are retained after order completion for dispute resolution, or purged (storage-cost vs. auditability trade-off).
