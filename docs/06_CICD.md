# Smart Courier — Volume 6: CI/CD & Deployment

Version 1.0 | Status: Draft
Scope: Branching, Commit Convention, GitHub Actions Pipeline & Release Process

## 1. Purpose

Defines the CI/CD pipeline, branching strategy, and release process for Smart Courier — sized appropriately for a solo, part-time contributor while still reflecting real team practice.

## 2. Branching Strategy

| Branch | Purpose | Rule |
|---|---|---|
| `main` | Always deployable; represents the latest stable state. | No direct commits; only merged via reviewed PRs. |
| `feature/*` | One branch per feature/use case (e.g., `feature/order-creation`). | Branched from main, merged back via PR. |
| `fix/*` | Bug fixes. | Same as feature/* flow. |

As a solo project, PR review is self-review — but the discipline of small, focused PRs with a description and a passing CI run is kept, both for good habits and because it is visible on GitHub to anyone reviewing the repository.

## 3. Commit Convention

Conventional Commits format is used for a clean, meaningful history:

```
feat(orders): add order creation form with map picker
fix(tracking): correct marker jump on first location update
test(auth): add unit tests for AuthBloc login flow
docs: update Volume 4 with location_updates retention decision
```

## 4. CI Pipeline (GitHub Actions)

Runs on every push and pull request:

1. Setup: checkout, install Flutter SDK (pinned version), `flutter pub get`.
2. Static analysis: `flutter analyze` must pass with zero issues.
3. Formatting check: `dart format --set-exit-if-changed .`
4. Unit + widget tests: `flutter test --coverage`.
5. Integration tests (on PRs to main only): Firebase Emulator Suite spun up as a service container, then `flutter test integration_test/`.
6. Coverage report uploaded as a CI artifact (and optionally to Codecov) for visibility in the PR.

Example workflow skeleton (full YAML lives in `.github/workflows/ci.yml`):

```yaml
name: CI
on: [push, pull_request]
jobs:
  analyze_and_test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { flutter-version: '3.x', channel: 'stable' }
      - run: flutter pub get
      - run: flutter analyze
      - run: dart format --set-exit-if-changed .
      - run: flutter test --coverage
```

## 5. Release Process

- Version follows semantic versioning (MAJOR.MINOR.PATCH) tracked in `pubspec.yaml` and `CHANGELOG.md`.
- A merge to main that represents a meaningful milestone (e.g., "Phase 1 MVP complete") is tagged (`v0.1.0`, `v0.2.0`, ...) and noted in `CHANGELOG.md`.
- Android release build produced via `flutter build appbundle --release`; signed with a release keystore kept out of the repository (documented, not committed).
- For portfolio purposes, a debug/demo APK can also be attached to a GitHub Release for reviewers to install directly without building from source.

## 6. Firebase Environments

| Environment | Purpose |
|---|---|
| dev (Firebase project) | Used during local development and by CI's emulator config as a schema reference. |
| prod (Firebase project) | The single "live" project used for the deployed demo build; Stripe kept in test mode throughout, since this is a portfolio project. |

## 7. Fastlane (Optional, Phase 3)

If time allows, Fastlane can automate versioned builds and (optionally) upload to a closed testing track — treated as a nice-to-have polish item, not a Phase 1 requirement, to protect the realistic 3-5 hour/week budget.
