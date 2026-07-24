# Smart Courier — Volume 4: Firebase & Database Design

Version 1.0 | Status: Draft
Scope: Firestore Schema, Security Rules & Cloud Functions

## 1. Purpose

Defines the Firestore data model, Security Rules approach, and Cloud Functions responsibilities that back the flows specified in Volume 2 (SRS).

## 2. Firestore Collections

### 2.1 users
```
users/{userId}
  name: string
  phone: string
  role: 'customer' | 'courier' | 'admin'
  createdAt: timestamp
  // courier-only fields:
  vehicleType: string | null
  isActive: boolean | null
```

### 2.2 orders
```
orders/{orderId}
  customerId: string
  courierId: string | null
  status: 'created' | 'accepted' | 'picked_up' | 'delivered' | 'completed' | 'cancelled'
  pickup: { address: string, lat: number, lng: number }
  dropoff: { address: string, lat: number, lng: number }
  note: string | null
  amount: number
  paymentStatus: 'pending' | 'captured' | 'failed'
  createdAt, acceptedAt, pickedUpAt, deliveredAt: timestamp | null
```

### 2.3 orders/{orderId}/location_updates (subcollection)
```
location_updates/{autoId}
  lat: number
  lng: number
  timestamp: timestamp
```
Written only by the assigned courier while order status is `accepted` or `picked_up`. Considered for TTL/cleanup after order completion (see Open Decisions, Volume 2 §9).

### 2.4 ratings
```
ratings/{orderId}
  customerId: string
  courierId: string
  stars: number (1-5)
  comment: string | null
  createdAt: timestamp
```

## 3. Indexes

Composite indexes required for the query patterns in Volume 2:

| Collection | Fields | Used by |
|---|---|---|
| orders | status ASC, createdAt DESC | Courier's open-orders list (UC-COUR-01) |
| orders | customerId ASC, createdAt DESC | Customer's order history (UC-CUST-02) |
| orders | courierId ASC, status ASC | Courier's active/earnings views |

## 4. Firestore Security Rules (Approach)

Rules enforce the role model from the SRS at the data layer. Illustrative excerpt (not exhaustive):

```
match /orders/{orderId} {
  allow read: if isSignedIn() && (
     resource.data.customerId == request.auth.uid ||
     resource.data.courierId == request.auth.uid ||
     isAdmin());
  allow create: if isSignedIn() && request.resource.data.customerId == request.auth.uid;
  allow update: if isCourierAccepting() || isAdmin();
}

match /orders/{orderId}/location_updates/{u} {
  allow read: if isOrderParticipant(orderId) || isAdmin();
  allow create: if isAssignedCourier(orderId);
}
```

Full rule set, plus the `isAdmin()`/`isOrderParticipant()` helper functions, is maintained directly in `firestore.rules` in the repository and kept in sync with this document.

## 5. Cloud Functions

| Function | Trigger | Responsibility |
|---|---|---|
| `onOrderAccepted` | Firestore onUpdate (status → accepted) | Send push notification to customer; stamp `acceptedAt`. |
| `onOrderDelivered` | Firestore onUpdate (status → delivered) | Trigger Stripe payment capture; on success set `paymentStatus='captured'` and `status='completed'`. |
| `acceptOrderTxn` | Callable function | Atomically assign `courierId` and set `status='accepted'` only if order is still `created` — prevents double-accept race conditions (UC-COUR-02). |
| `createStripePaymentIntent` | Callable function | Creates a Stripe PaymentIntent server-side; client never sees secret keys. |

Sensitive or consistency-critical logic (payment capture, order acceptance) intentionally lives in Cloud Functions rather than directly in client code, so it cannot be bypassed or corrupted by a malicious or buggy client.

## 6. Admin Access: Custom Claims

The Admin panel is served as a public web build (Firebase Hosting) and is reachable by anyone who knows the URL, unlike the mobile app which is distributed as an installable build. Relying only on a `role` field inside a user's own Firestore document is not sufficient on its own, since a Security Rule bug or a client-side write could let a user set their own role to `admin`. Firebase Auth Custom Claims are used as the source of truth for admin authorization instead.

### 6.1 Assigning the Claim
```js
// Callable Cloud Function, invoked manually (not from client UI) for the
// project owner's own account during setup:
exports.setAdminClaim = functions.https.onCall(async (data, context) => {
  if (!context.auth || !(await isExistingAdmin(context.auth.uid))) {
    throw new functions.https.HttpsError('permission-denied', 'Not allowed');
  }
  await admin.auth().setCustomUserClaims(data.targetUid, { admin: true });
});
```

### 6.2 Enforcing the Claim in Security Rules
```
function isAdmin() {
  return request.auth != null && request.auth.token.admin == true;
}
```
All admin-only reads (e.g., the full orders/couriers overview in UC-ADM-01/02) are gated with `isAdmin()` reading the custom claim from the auth token, not from a Firestore document — the claim is only settable server-side via the callable function above, so it cannot be forged by the client.

### 6.3 Login Flow (Admin)
- Admin uses the same `LoginScreen`/`AuthBloc` as every other role — no separate admin login UI is built.
- After sign-in, the client reads the ID token's custom claims (`idTokenResult.claims['admin']`); if true, the role-based router (Volume 3, §7.2) mounts `AdminShell`.
- The Firestore `users/{uid}.role` field is kept in sync for convenience (display purposes) but is never trusted for authorization decisions — the custom claim is.

This reuses 100% of the existing auth UI and Bloc from the auth feature; the only new work is the one callable function above and the `isAdmin()` rule helper.

## 7. Data Retention & Cost Considerations

- `location_updates` is the highest-write-volume collection; Phase 1 accepts the cost at MVP scale. A scheduled Cloud Function to prune updates older than N days post-completion is a Phase 3 hardening item.
- Composite indexes above are the minimum required set; additional indexes should only be added when a real query requires them, to avoid unnecessary write overhead.
