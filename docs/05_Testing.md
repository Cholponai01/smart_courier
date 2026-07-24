# Smart Courier — Volume 5: Testing Strategy

Version 1.0 | Status: Draft
Scope: Unit, Widget & Integration Testing Approach and Coverage Targets

## 1. Purpose

Defines the testing approach, tooling, and coverage targets for Smart Courier. Given the solo/part-time context, this strategy prioritizes tests that give the most confidence per hour invested, rather than chasing a raw coverage number.

## 2. Testing Pyramid for This Project

| Layer | Tool | What it covers | Priority |
|---|---|---|---|
| Unit | flutter_test, bloc_test, mocktail | Use cases, repositories (mocked data sources), Bloc event→state logic. | Highest — fast, cheap, catches most logic bugs. |
| Widget | flutter_test (WidgetTester) | Individual screens render correctly per Bloc state (loading/error/success). | High — catches UI/state-wiring bugs. |
| Integration | integration_test package | One end-to-end flow per core use case, against a Firebase emulator. | Medium — fewer, but high-value; run against emulator, not production Firebase. |

## 3. Unit Testing Approach

- Domain use cases are pure Dart with no Flutter/Firebase dependency — tested with plain `flutter_test`, no widget pump required.
- Repository implementations are tested against a fake/mocked data source (`mocktail`) so tests do not require network or Firebase access.
- Bloc tests use `bloc_test`'s `blocTest()` to assert the exact sequence of emitted states for a given sequence of events, per feature.

Example (illustrative):
```dart
blocTest<OrderBloc, OrderState>(
  'emits [Loading, Success] when order creation succeeds',
  build: () => OrderBloc(createOrder: mockCreateOrderUseCase),
  act: (bloc) => bloc.add(OrderSubmitted(testOrder)),
  expect: () => [OrderLoading(), OrderSuccess(testOrder)],
);
```

## 4. Widget Testing Approach

- Each screen has at least one widget test per meaningful Bloc state (loading spinner shown, error message shown, success content shown).
- Screens are tested with a fake Bloc (`bloc_test`'s `MockBloc` / `whenListen`) so tests do not depend on real business logic — that is already covered at the unit level.
- Golden tests are a stretch goal for Phase 3, not required for MVP given the time budget.

## 5. Integration Testing Approach

Integration tests run against the Firebase Local Emulator Suite (Auth + Firestore emulators), never against production data. One integration test is written per core flow identified in the SRS:

- Customer creates an order → document appears in Firestore emulator with expected fields.
- Courier accepts an open order → status transitions correctly and a second courier's accept attempt is rejected (race-condition check).
- Full happy-path: create → accept → pick up → deliver → status becomes `completed`.

## 6. Coverage Targets

| Layer | Target for Phase 1 |
|---|---|
| Domain (use cases) | ≥ 85% |
| Data (repositories) | ≥ 70% (critical paths; error branches included) |
| Presentation (Bloc) | ≥ 80% of event→state transitions |
| Widgets | At least one test per screen per Bloc state |
| Integration | One test per core flow (§5), non-negotiable |

These are intentionally higher for domain/business logic (cheap, high-value tests) and more pragmatic for widget/UI layers, reflecting realistic effort allocation at 3-5 hours/week.

## 7. CI Integration

`flutter test` (unit + widget) runs on every push via GitHub Actions (see Volume 6). Integration tests against the emulator run in CI on pull requests to `main`, using the Firebase Emulator Suite in a GitHub Actions service container.

## 8. What Is Explicitly Not Tested in Phase 1

- Load/performance testing (out of scope for a portfolio-scale project).
- Real Stripe payment flows in CI (Stripe test-mode calls are mocked in automated tests; manual testing covers real Stripe test-mode integration).
- Cross-device/golden visual regression testing (deferred to Phase 3, if time allows).
