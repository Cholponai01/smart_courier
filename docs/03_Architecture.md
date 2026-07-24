# Smart Courier — Volume 3: System Architecture

Version 1.0 | Status: Draft
Scope: Clean Architecture, Feature-First Structure & Key Design Decisions

## 1. Purpose

Describes how Smart Courier is structured internally: layering, folder organization, state management, and the key architectural decisions that keep the codebase testable and extensible into Phase 2 (native background tracking).

## 2. Architectural Style: Clean Architecture + Feature-First

Each feature (auth, orders, tracking, profile, admin) is a self-contained vertical slice with its own data/domain/presentation layers, rather than one global data layer and one global UI layer. This keeps features independently testable and lets a reviewer understand one feature without reading the whole codebase.

### 2.1 Layer Responsibilities

| Layer | Responsibility | Depends on |
|---|---|---|
| Presentation | Widgets, screens, Bloc/Cubit (UI state). | Domain only |
| Domain | Entities, use cases, repository interfaces (abstract). Pure Dart, no Flutter/Firebase imports. | Nothing (innermost layer) |
| Data | Repository implementations, Firebase/Stripe data sources, DTOs/mappers. | Domain (implements its interfaces) |

The dependency rule: outer layers depend inward, never the reverse. Domain never imports Firebase — this is what allows Cloud Firestore to be swapped or supplemented (e.g., a native location service in Phase 2) without touching business logic or tests.

### 2.2 Folder Structure

```
lib/
  core/                     // shared utilities, theming, DI setup, error types
  features/
    auth/
      data/                 // FirebaseAuthDataSource, UserRepositoryImpl
      domain/               // User entity, AuthRepository (abstract), use cases
      presentation/         // LoginScreen, AuthBloc
    orders/
      data/  domain/  presentation/
    tracking/
      data/  domain/  presentation/
    admin/
      data/  domain/  presentation/
  app.dart                  // role-based router
  main.dart
```

## 3. State Management: Bloc

- Each feature exposes one or more Bloc/Cubit classes consuming use cases from the domain layer — never talking to Firebase directly.
- Bloc events map 1:1 to user intents (e.g., `OrderSubmitted`, `OrderAcceptRequested`); states are explicit and exhaustive (Initial, Loading, Success, Failure) so widget tests can assert on state directly.
- `bloc_test` is used to unit-test Bloc logic without spinning up widgets or Firebase.

## 4. Dependency Injection

`get_it` (service locator) registers repository implementations against their domain-layer abstract interfaces at app startup. This is what allows tests to register fake/mock repositories instead of real Firebase-backed ones.

```dart
getIt.registerLazySingleton<OrderRepository>(() => OrderRepositoryImpl(firestore: getIt()));
```

## 5. Repository Pattern

Every external dependency (Firestore, Stripe, device GPS) is hidden behind a domain-defined interface. Example:

```dart
abstract class OrderRepository {
  Future<Order> createOrder(Order order);
  Stream<Order> watchOrder(String orderId);
  Future<void> acceptOrder(String orderId, String courierId);
}
```

`OrderRepositoryImpl` in the data layer implements this against Firestore. In Phase 2, `LocationRepository` gains a second implementation backed by a native Platform Channel for background tracking, without any change to the tracking feature's domain or presentation code — this is the concrete payoff of the pattern, and a good interview talking point.

## 6. Key Sequence: Live Location Tracking

1. Courier accepts order → `TrackingBloc` starts a periodic location stream (`geolocator`).
2. Each position update is pushed through `LocationRepository.publish()` → writes to `orders/{id}/location_updates` in Firestore.
3. Customer's `TrackingBloc` subscribes via `LocationRepository.watch(orderId)` → Firestore snapshot stream → map marker updates.
4. On status change to `delivered`, the courier stops publishing; the stream is closed on both ends.

## 7. Cross-Cutting Concerns

### 7.1 Error Handling
Data-layer exceptions are caught and mapped to a small sealed `Failure` type (`NetworkFailure`, `AuthFailure`, `ValidationFailure`, `UnknownFailure`) before reaching the Bloc, so presentation code never handles raw Firebase exceptions directly.

### 7.2 Role-Based Routing
A single top-level router reads the authenticated user's role (cached after login) and mounts the corresponding home shell (`CustomerShell` / `CourierShell` / `AdminShell`), each with its own bottom navigation and allowed routes.

## 8. Phase 2 Extension Point: Native Background Tracking

The Phase 2 native module (Android foreground service for background GPS) integrates as a second `LocationRepository` implementation, communicating with Dart via a Platform Channel/EventChannel, and is swapped in behind the same domain interface described in §5 — no change to Bloc or UI code is required.

## 9. Architecture Decision Records (ADR) — Index

Individual ADRs (one-page each: context, decision, consequences) are maintained as the project evolves. Initial set:

- **ADR-001**: Single Flutter codebase with role-based routing, instead of separate customer/courier apps.
- **ADR-002**: Firebase Cloud Functions instead of a custom backend server.
- **ADR-003**: Repository pattern chosen specifically to support a later native tracking implementation.
- **ADR-004**: Bloc over Provider/Riverpod, for explicit state modeling and mature testing tools.
