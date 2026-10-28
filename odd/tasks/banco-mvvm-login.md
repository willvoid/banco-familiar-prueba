# banco-mvvm-login

## Objective
Flutter app with MVVM architecture to test a bank login endpoint. Step 1: the ecosystem. Step 2 (later): point it at the real endpoint.

## Scope
- Scaffold project (android, windows, web), `provider` + `http`.
- MVVM, feature-first: View -> ViewModel -> Repository -> Service (Flutter's recommended app architecture).
- Login feature with configurable base URL / path via `--dart-define`.

## Route
Inline (all files small, understood, no research needed; no subagent spawned).

## Tasks
- [x] T1 Scaffold project (`flutter create`)
- [x] T2 core: config, ApiClient, Result/Failure
- [x] T3 auth feature: service, repository, ViewModel, View
- [x] T4 composition root (app.dart/main.dart) + tests
- [x] T5 `flutter analyze` (clean after removing one unused import) + `flutter test` (6/6 passed)

- [x] T6 GET /auth/me with Bearer token (ApiClient.getJson, AuthRepository.fetchMe, MeViewModel/MeView); response shape unknown so raw JSON is shown. analyze clean, 12/12 tests passed. Not yet tried against the real server.

- [x] T7 Typed /auth/me: UserProfile + BankAccount (domain/user_profile.dart), fetchMe returns Result<UserProfile>, MeView shows name/document/account cards. analyze clean, 17/17 tests passed. Not yet run against the real server.

## Exceptions
- Test-first not followed: tests were written after the code (scaffold, no endpoint to drive RED). Tests cover repository parsing and ViewModel states.
- Not run on a device/emulator: only analyze + unit tests.

## Notes
- Directory is not a git repository: work-unit commits not possible until `git init`.
- Endpoint contract is an assumption: POST `{username, password}`, token in `token` | `access_token` | `accessToken`.
