class CliHelper {
  /// Show usage information
  static void showUsage() {
    print('''
📦 Quicklit CLI Tool v1.0.0

Usage:
  dart run quicklit:model_gen <json_file> --class <ClassName>
  dart run quicklit:model_gen --get-login [--firebase|--api]

Options:
  --help, -h      Show this help message
  --version       Show version information
  --install-deps  Force install/reinstall base dependencies
  --get-login     Generate complete auth boilerplate with BLoC
  --firebase      Use Firebase Authentication (with --get-login)
  --api           Use API/REST Authentication (with --get-login) [default]

Examples:
  # JSON Model Generation
  dart run quicklit:model_gen user.json --class UserModel
  dart run quicklit:model_gen data.json --class DataModel
  
  # Auth Boilerplate Generation
  dart run quicklit:model_gen --get-login --firebase
  dart run quicklit:model_gen --get-login --api
  dart run quicklit:model_gen --get-login  # Prompts for choice
  
  # Dependency Management
  dart run quicklit:model_gen --install-deps

Features:
  ✅ Auto-installs required dependencies on first run
  ✅ Generates JSON serializable models
  ✅ Creates complete auth boilerplate with BLoC
  ✅ Supports both Firebase and API authentication
  ✅ Creates proper directory structure
  ✅ Includes build_runner setup

Auth Providers:
  🔥 Firebase Authentication:
    • Firebase Auth SDK integration
    • Email/password authentication
    • Built-in error handling
    • Secure token management
    
  🌐 API Authentication:
    • RESTful API integration
    • JWT token handling
    • Customizable endpoints
    • HTTP client with interceptors

Generated Structure:
  lib/
  ├── pages/auth/
  │   ├── login.dart
  │   └── register.dart
  ├── bloc/auth/
  │   ├── auth_bloc.dart
  │   ├── auth_event.dart
  │   └── auth_state.dart
  ├── services/              # API only
  │   └── auth_service.dart
  └── models/                # API only
      └── user_model.dart

Dependencies:
  Base: connectivity_plus, shared_preferences, provider, json_annotation,
        build_runner, json_serializable, flutter_bloc, equatable, http
  Firebase: firebase_auth, firebase_core
  API: dio, pretty_dio_logger
''');
  }

  /// Show version information
  static void showVersion() {
    print('📦 Quicklit CLI Tool v1.0.0');
    print('🚀 A blazing-fast Flutter toolkit with flexible auth');
    print('🔗 https://github.com/shreyasgajbhiye/quicklit');
    print('');
    print('Features:');
    print('  • JSON model generation');
    print('  • Firebase authentication boilerplate');
    print('  • API authentication boilerplate');
    print('  • BLoC state management');
    print('  • Auto dependency management');
  }
}