# 🔥 Quicklit

[![pub package](https://img.shields.io/pub/v/quicklit.svg)](https://pub.dev/packages/quicklit)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**Quicklit** is a blazing-fast Flutter toolkit built for hackathon-ready apps.  
It bundles essential UI components, utility helpers, and a CLI-powered model generator — all in one package.

---

## ✨ Features

- ✅ Prebuilt **Login & Register** UI (Firebase-ready)
- ✅ Dark/Light mode toggle widget
- ✅ Internet connectivity checker
- ✅ Snackbar, dialog, and toast utilities
- ✅ Local storage helper using `SharedPreferences`
- ✅ Stopwatch & timer utilities
- ✅ `isDebug()` and `isRelease()` environment helpers
- ✅ CLI-powered **JSON → Dart model generator** (with `.g.dart` support)

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
    

---

## 📦 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  quicklit: ^1.0.0
```

Then run:

```bash
flutter pub get
```

---

## 🚀 Usage

### ✅ 1. Use Prebuilt Auth Screens

```dart
import 'package:quicklit/quicklit.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: QuicklitLoginPage(), // or QuicklitRegisterPage()
  ));
}
```

### ✅ 2. Toggle Theme

```dart
QuicklitThemeToggle() // Widget
```

### ✅ 3. Use Local Storage

```dart
await QuicklitStorage.saveString('username', 'shreyash');
String? name = await QuicklitStorage.getString('username');
```

### ✅ 4. Check Internet Connection

```dart
QuicklitConnectionChecker(
  onOnline: () => print('Connected'),
  onOffline: () => print('Disconnected'),
)
```

### ✅ 5. Utility Functions

```dart
// Environment helpers
if (QuicklitUtils.isDebug()) {
  print('Running in debug mode');
}

if (QuicklitUtils.isRelease()) {
  print('Running in release mode');
}

// Snackbar utilities
QuicklitSnackbar.show(context, 'Success message');
QuicklitSnackbar.error(context, 'Error message');

// Dialog utilities
QuicklitDialog.show(
  context,
  title: 'Confirmation',
  content: 'Are you sure?',
  onConfirm: () => print('Confirmed'),
);

// Toast utilities
QuicklitToast.show('Quick toast message');
```

---

## ⚙️ Model Generator (CLI)

Quicklit includes a powerful CLI tool to generate Dart model classes from any JSON response.

### 🛠️ Command

```bash
dart run quicklit:model_gen path/to/input.json --class YourModelName
```

### 📂 What It Does

✅ Outputs model in `lib/models/your_model_name.dart`

✅ Adds `@JsonSerializable()` annotations

✅ Generates factory constructors

✅ Compatible with `json_serializable`

### 📁 Example

**input.json**
```json
{
  "id": 1,
  "name": "Shreyash",
  "isVerified": true
}
```

**Run:**
```bash
dart run quicklit:model_gen input.json --class UserModel
```

**Generated Output:** `lib/models/user_model.dart`
```dart
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final int id;
  final String name;
  final bool isVerified;

  UserModel({
    required this.id,
    required this.name,
    required this.isVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
```

### 🔧 Advanced CLI Options

```bash
# Generate model with custom output directory
dart run quicklit:model_gen input.json --class UserModel --output custom/path/

# Generate model with nullable fields support
dart run quicklit:model_gen input.json --class UserModel --nullable

# Generate model with custom file name
dart run quicklit:model_gen input.json --class UserModel --filename custom_user
```

---

## 🎨 Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:quicklit/quicklit.dart';

void main() {
  runApp(const QuicklitApp());
}

class QuicklitApp extends StatelessWidget {
  const QuicklitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quicklit Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quicklit Demo'),
        actions: [
          QuicklitThemeToggle(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            QuicklitConnectionChecker(
              onOnline: () => QuicklitToast.show('Connected to internet'),
              onOffline: () => QuicklitToast.show('No internet connection'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _saveUserData(),
              child: const Text('Save User Data'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _loadUserData(context),
              child: const Text('Load User Data'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _showConfirmDialog(context),
              child: const Text('Show Dialog'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveUserData() async {
    await QuicklitStorage.saveString('username', 'shreyash');
    await QuicklitStorage.saveBool('isVerified', true);
    QuicklitToast.show('User data saved!');
  }

  Future<void> _loadUserData(BuildContext context) async {
    final username = await QuicklitStorage.getString('username');
    final isVerified = await QuicklitStorage.getBool('isVerified');
    
    if (username != null) {
      QuicklitSnackbar.show(
        context,
        'Welcome back, $username! ${isVerified == true ? '✅' : '❌'}',
      );
    } else {
      QuicklitSnackbar.error(context, 'No user data found');
    }
  }

  void _showConfirmDialog(BuildContext context) {
    QuicklitDialog.show(
      context,
      title: 'Confirmation',
      content: 'Do you want to clear all data?',
      onConfirm: () async {
        await QuicklitStorage.clear();
        QuicklitToast.show('All data cleared!');
      },
    );
  }
}
```

---

## 🛠️ Available Utilities

### Storage Helper
```dart
// Save data
await QuicklitStorage.saveString('key', 'value');
await QuicklitStorage.saveInt('key', 42);
await QuicklitStorage.saveBool('key', true);
await QuicklitStorage.saveDouble('key', 3.14);

// Load data
String? value = await QuicklitStorage.getString('key');
int? number = await QuicklitStorage.getInt('key');
bool? flag = await QuicklitStorage.getBool('key');
double? decimal = await QuicklitStorage.getDouble('key');

// Remove data
await QuicklitStorage.remove('key');
await QuicklitStorage.clear(); // Clear all data
```

### Timer & Stopwatch
```dart
// Stopwatch
final stopwatch = QuicklitStopwatch();
stopwatch.start();
Duration elapsed = stopwatch.elapsed;
stopwatch.stop();
stopwatch.reset();

// Timer utilities
QuicklitTimer.delay(Duration(seconds: 2), () {
  print('Executed after 2 seconds');
});
```

### Environment Helpers
```dart
if (QuicklitUtils.isDebug()) {
  print('Debug mode - show detailed logs');
}

if (QuicklitUtils.isRelease()) {
  print('Release mode - hide debug info');
}
```

---

## 📚 Dependencies

Quicklit internally uses these Flutter packages:
- `shared_preferences` - For local storage
- `connectivity_plus` - For internet connection checking
- `json_annotation` - For JSON serialization

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📞 Support

If you find any issues or have suggestions, please file an issue on the [GitHub repository](https://github.com/shreyasgajbhiye/quicklit).

---

# 🔥 Quicklit

[![pub package](https://img.shields.io/pub/v/quicklit.svg)](https://pub.dev/packages/quicklit)  
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**Quicklit** is a blazing-fast Flutter toolkit built for hackathon-ready apps.  
It bundles essential UI components, utility helpers, a CLI-powered model generator, and a complete auth boilerplate generator — all in one package.

---

## ✨ Features

- ✅ Prebuilt **Login & Register** UI (Firebase & API-ready)
- ✅ Dark/Light mode toggle widget
- ✅ Internet connectivity checker
- ✅ Snackbar, dialog, and toast utilities
- ✅ Local storage helper using `SharedPreferences`
- ✅ Stopwatch & timer utilities
- ✅ `isDebug()` and `isRelease()` environment helpers
- ✅ CLI-powered **JSON → Dart model generator**
- ✅ 🔐 **Auth boilerplate generator (BLoC)** via CLI
- ✅ Supports **Firebase** and **REST API** authentication

---

## 📦 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  quicklit: ^0.0.1
```

Then run:

```bash
flutter pub get
```

---

## 🚀 CLI Usage (v1.0.0)

The `Quicklit CLI Tool v1.0.0` supports model generation, auth boilerplate scaffolding, and dependency setup.

### 🔧 Commands

```bash
dart run quicklit:model_gen <json_file> --class <ClassName>
dart run quicklit:model_gen --get-login [--firebase | --api]
dart run quicklit:model_gen --install-deps
```

### 🧪 Examples

#### 📄 JSON Model Generation

```bash
dart run quicklit:model_gen user.json --class UserModel
```

#### 🔐 Auth Boilerplate (BLoC-based)

```bash
dart run quicklit:model_gen --get-login --firebase
dart run quicklit:model_gen --get-login --api
dart run quicklit:model_gen --get-login   # Prompts to choose
```

#### ⚙️ Install Dependencies

```bash
dart run quicklit:model_gen --install-deps
```

---

## 🔐 Auth Providers

### 🌐 API Auth

- RESTful API login/register
- JWT token support
- Customizable endpoints
- Dio client with interceptors

### 🔥 Firebase Auth

- Firebase Auth SDK integration
- Email/password login/register
- Built-in error handling
- Works with `google-services.json` / `GoogleService-Info.plist`

---

## 📁 Auth Boilerplate Structure

```
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
```

---

## 🎨 Flutter Usage

### ✅ Auth Screens

```dart
import 'package:quicklit/quicklit.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: QuicklitLoginPage(), // or QuicklitRegisterPage()
  ));
}
```

### 🎨 Theme Toggle

```dart
QuicklitThemeToggle()
```

### 🌐 Internet Connection Checker

```dart
QuicklitConnectionChecker(
  onOnline: () => print('Connected'),
  onOffline: () => print('Disconnected'),
)
```

---

## 🛠 Utility Functions

### 🗃 Local Storage

```dart
await QuicklitStorage.saveString('username', 'shreyash');
String? name = await QuicklitStorage.getString('username');
```

### 🕒 Timer & Stopwatch

```dart
final stopwatch = QuicklitStopwatch();
stopwatch.start();
await Future.delayed(Duration(seconds: 2));
stopwatch.stop();
print(stopwatch.elapsed);
```

```dart
QuicklitTimer.delay(Duration(seconds: 3), () {
  print('Executed after 3 seconds');
});
```

### 🧪 Environment Helpers

```dart
if (QuicklitUtils.isDebug()) {
  print('Debug mode');
}
```

---

## 📚 Dependencies

### Base
- `connectivity_plus`
- `shared_preferences`
- `provider`
- `flutter_bloc`
- `equatable`
- `http`
- `json_annotation`
- `build_runner`
- `json_serializable`

### Firebase
- `firebase_auth`
- `firebase_core`

### API
- `dio`
- `pretty_dio_logger`

---

## 🎯 Full Example App

See `/example/` directory for complete usage.

---

## 🤝 Contributing

We welcome contributions:

1. Fork the repo  
2. Create your branch (`git checkout -b feature/new-feature`)  
3. Commit your changes (`git commit -m 'Add something'`)  
4. Push (`git push origin feature/new-feature`)  
5. Open a Pull Request  

---

## 📄 License

MIT License – see [LICENSE](LICENSE)

---

## 🔗 Links

- GitHub: [shreyasgajbhiye/quicklit](https://github.com/shreyasgajbhiye/quicklit)
- Pub.dev: [Quicklit Package](https://pub.dev/packages/quicklit)

---
