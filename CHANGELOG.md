## [1.1.0] - 2025-07-13

### Added
- CLI support for generating full **auth boilerplate** using `--get-login`
- Support for both **Firebase** and **API-based** authentication
- BLoC setup for auth: `auth_bloc.dart`, `auth_event.dart`, `auth_state.dart`
- Auth UI: `QuicklitLoginPage` and `QuicklitRegisterPage`
- Firebase Auth integration with email/password
- API Auth integration using Dio with JWT-ready setup
- CLI prompts for auth provider selection
- `--install-deps` CLI flag to auto-install core packages

### Changed
- CLI executable renamed to `quicklit:model_gen` for consistent namespace
- Improved CLI error handling and usage instructions

---

## [0.0.1] - 2025-07-04

### Added
- Prebuilt Firebase-ready Login & Register UIs
- Dark/Light mode toggle
- Internet connectivity checker
- Snackbar, dialog, toast utilities
- SharedPreferences local storage helper
- Stopwatch/timer utilities
- `isDebug()` and `isRelease()` environment helpers
- CLI tool to generate models from JSON (with @JsonSerializable support)

### Fixed
- Removed unused imports
- Fixed pubspec `executables:` validation
