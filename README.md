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

