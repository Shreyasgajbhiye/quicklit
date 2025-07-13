// import 'dart:convert';
// import 'dart:io';
// import 'package:quicklit/src/utils/model_generator.dart';

// /// Enhanced Quicklit Model Generator with Auto-Install
// /// Automatically installs required dependencies on first run

// void main(List<String> args) async {
//   // Handle help and version flags
//   if (args.contains('--help') || args.contains('-h')) {
//     _showUsage();
//     return;
//   }

//   if (args.contains('--version')) {
//     _showVersion();
//     return;
//   }

//   if (args.contains('--install-deps')) {
//     await _autoInstallDependencies();
//     return;
//   }

//   // Check if this is first run (dependencies not installed)
//   final depsInstalled = await _checkDependencies();
//   if (!depsInstalled) {
//     print('🚀 Quicklit: First-time setup detected!');
//     print('📦 Installing required dependencies...\n');
//     await _autoInstallDependencies();
//     print('🔄 Please run your model generation command again.\n');
//     return;
//   }

//   // Proceed with model generation
//   await _generateModel(args);
// }

// /// Check if all required dependencies are installed
// Future<bool> _checkDependencies() async {
//   final pubspecFile = File('pubspec.yaml');
//   if (!await pubspecFile.exists()) {
//     return false;
//   }

//   final content = await pubspecFile.readAsString();
  
//   final requiredPackages = [
//     'connectivity_plus',
//     'shared_preferences',
//     'firebase_auth',
//     'firebase_core',
//     'provider',
//     'json_annotation',
//     'build_runner',
//     'json_serializable',
//   ];

//   // Check if all required packages are present
//   for (final package in requiredPackages) {
//     if (!content.contains('$package:')) {
//       return false;
//     }
//   }

//   return true;
// }

// /// Auto-install required dependencies by modifying pubspec.yaml
// Future<void> _autoInstallDependencies() async {
//   final packages = {
//     'connectivity_plus': '^6.0.3',
//     'shared_preferences': '^2.2.3',
//     'firebase_auth': '^5.1.0',
//     'firebase_core': '^3.15.1',
//     'provider': '^6.1.2',
//     'json_annotation': '^4.9.0',
//   };
  
//   final devPackages = {
//     'build_runner': '^2.4.9',
//     'json_serializable': '^6.8.0',
//   };

//   try {
//     // Check if pubspec.yaml exists
//     final pubspecFile = File('pubspec.yaml');
//     if (!await pubspecFile.exists()) {
//       throw Exception('pubspec.yaml not found. Please run this in your Flutter project root.');
//     }

//     print('📝 Updating pubspec.yaml...');
//     final content = await pubspecFile.readAsString();
//     String updatedContent = content;

//     // Add dependencies
//     for (final package in packages.entries) {
//       if (!content.contains(package.key)) {
//         print('📦 Adding ${package.key}: ${package.value}');
//         updatedContent = _addDependency(updatedContent, package.key, package.value, false);
//       } else {
//         print('   ✅ ${package.key} already exists');
//       }
//     }

//     // Add dev dependencies
//     for (final package in devPackages.entries) {
//       if (!content.contains(package.key)) {
//         print('🔧 Adding dev dependency ${package.key}: ${package.value}');
//         updatedContent = _addDependency(updatedContent, package.key, package.value, true);
//       } else {
//         print('   ✅ ${package.key} already exists');
//       }
//     }

//     // Write updated content
//     await pubspecFile.writeAsString(updatedContent);

//     print('\n🎉 Quicklit setup completed!');
//     print('📋 Dependencies have been added to pubspec.yaml');
//     print('⚙️  Please run: flutter pub get');

//   } catch (e) {
//     print('❌ Auto-installation failed: $e');
//     print('\n📝 Please manually add these dependencies to your pubspec.yaml:');
//     print('\ndependencies:');
//     packages.forEach((package, version) {
//       print('  $package: $version');
//     });
//     print('\ndev_dependencies:');
//     devPackages.forEach((package, version) {
//       print('  $package: $version');
//     });
//     print('\nThen run: flutter pub get');
//   }
// }

// /// Add a dependency to pubspec.yaml content
// String _addDependency(String content, String packageName, String version, bool isDev) {
//   final sectionName = isDev ? 'dev_dependencies:' : 'dependencies:';
//   final dependency = '  $packageName: $version';
  
//   if (content.contains(sectionName)) {
//     // Find the section and add the dependency
//     final lines = content.split('\n');
//     final sectionIndex = lines.indexWhere((line) => line.trim() == sectionName);
    
//     if (sectionIndex != -1) {
//       // Find the end of the section
//       int insertIndex = sectionIndex + 1;
//       while (insertIndex < lines.length && 
//              (lines[insertIndex].startsWith('  ') || lines[insertIndex].trim().isEmpty)) {
//         insertIndex++;
//       }
      
//       lines.insert(insertIndex, dependency);
//       return lines.join('\n');
//     }
//   } else {
//     // Add the section if it doesn't exist
//     final lines = content.split('\n');
//     lines.add('');
//     lines.add(sectionName);
//     lines.add(dependency);
//     return lines.join('\n');
//   }
  
//   return content;
// }

// /// Generate model from JSON (your existing functionality)
// Future<void> _generateModel(List<String> args) async {
//   if (args.isEmpty) {
//     print('❌ Error: No JSON file specified');
//     _showUsage();
//     exit(1);
//   }

//   final file = File(args[0]);
//   if (!file.existsSync()) {
//     print('❌ Error: File not found: ${args[0]}');
//     exit(1);
//   }

//   final classNameFlagIndex = args.indexOf('--class');
//   if (classNameFlagIndex == -1 || classNameFlagIndex + 1 >= args.length) {
//     print('❌ Error: Missing --class <ClassName>');
//     _showUsage();
//     exit(1);
//   }

//   final className = args[classNameFlagIndex + 1];
  
//   try {
//     final jsonContent = json.decode(await file.readAsString());

//     if (jsonContent is! Map<String, dynamic>) {
//       print('❌ Error: JSON root must be an object.');
//       exit(1);
//     }

//     final output = generateModelTemplate(className, jsonContent);
//     final outputPath = 'lib/models/${className.toLowerCase()}.dart';

//     await Directory('lib/models').create(recursive: true);
//     await File(outputPath).writeAsString(output);

//     print('✅ Model created at: $outputPath');
//     print('⚙️  Next: flutter pub run build_runner build');
    
//   } catch (e) {
//     print('❌ Error parsing JSON: $e');
//     exit(1);
//   }
// }

// /// Show usage information
// void _showUsage() {
//   print('''
// 📦 Quicklit Model Generator v0.0.1

// Usage:
//   dart run quicklit:model_gen <json_file> --class <ClassName>

// Options:
//   --help, -h      Show this help message
//   --version       Show version information
//   --install-deps  Force install/reinstall dependencies

// Examples:
//   dart run quicklit:model_gen user.json --class UserModel
//   dart run quicklit:model_gen data.json --class DataModel
//   dart run quicklit:model_gen --install-deps

// Features:
//   ✅ Auto-installs required dependencies on first run
//   ✅ Generates JSON serializable models
//   ✅ Creates proper directory structure
//   ✅ Includes build_runner setup

// First Run:
//   The tool will automatically install these dependencies:
//   • connectivity_plus, shared_preferences, firebase_auth
//   • firebase_core, provider, json_annotation
//   • build_runner, json_serializable (dev dependencies)
// ''');
// }

// /// Show version information
// void _showVersion() {
//   print('📦 Quicklit Model Generator v0.0.1');
//   print('🚀 A blazing-fast Flutter toolkit');
//   print('🔗 https://github.com/shreyasgajbhiye/quicklit');
// }



// v1.0.0
// bin/quicklit.dart
import 'dart:convert';
import 'dart:io';
import 'package:quicklit/src/generator/auth_generator.dart';
import 'package:quicklit/src/utils/model_generator.dart';
import 'package:quicklit/src/utils/dependency_manager.dart';
import 'package:quicklit/src/utils/cli_helper.dart';
import 'package:quicklit/src/shared/auth_provider.dart' as auth_provider;

void main(List<String> args) async {
  try {
    await _handleCliCommands(args);
  } catch (e) {
    print('❌ Error: $e');
    exit(1);
  }
}

Future<void> _handleCliCommands(List<String> args) async {
  if (args.contains('--help') || args.contains('-h')) {
    CliHelper.showUsage();
    return;
  }

  if (args.contains('--version')) {
    CliHelper.showVersion();
    return;
  }

  if (args.contains('--install-deps')) {
    await DependencyManager.installBaseDependencies();
    return;
  }

  if (args.contains('--get-login')) {
    await _handleAuthGeneration(args);
    return;
  }

  await _generateModel(args);
}

Future<void> _handleAuthGeneration(List<String> args) async {
  print('🚀 Generating Quicklit Auth Boilerplate v1.0.0...');
  
  auth_provider.AuthProvider provider = auth_provider.AuthProvider.api;
  
  if (args.contains('--firebase')) {
    provider = auth_provider.AuthProvider.firebase;
  } else if (args.contains('--api')) {
    provider = auth_provider.AuthProvider.api;
  } else {
    provider = await _promptAuthProvider();
  }

  final authGenerator = AuthGenerator(
    provider: provider,
    projectPath: Directory.current.path,
  );
  await authGenerator.generateAuthBoilerplate();
}

Future<auth_provider.AuthProvider> _promptAuthProvider() async {
  print('\n🔐 Choose Authentication Provider:');
  print('1. API (REST/HTTP) - Default');
  print('2. Firebase Authentication');
  stdout.write('Enter your choice (1-2) [1]: ');
  
  final input = stdin.readLineSync()?.trim() ?? '1';
  
  return input == '2' 
      ? auth_provider.AuthProvider.firebase 
      : auth_provider.AuthProvider.api;
}

/// Generate model from JSON (existing functionality)
Future<void> _generateModel(List<String> args) async {
  if (args.isEmpty) {
    print('❌ Error: No JSON file specified');
    CliHelper.showUsage();
    exit(1);
  }

  final file = File(args[0]);
  if (!file.existsSync()) {
    print('❌ Error: File not found: ${args[0]}');
    exit(1);
  }

  final classNameFlagIndex = args.indexOf('--class');
  if (classNameFlagIndex == -1 || classNameFlagIndex + 1 >= args.length) {
    print('❌ Error: Missing --class <ClassName>');
    CliHelper.showUsage();
    exit(1);
  }

  final className = args[classNameFlagIndex + 1];
  
  try {
    final jsonContent = json.decode(await file.readAsString());

    if (jsonContent is! Map<String, dynamic>) {
      print('❌ Error: JSON root must be an object.');
      exit(1);
    }

    final output = generateModelTemplate(className, jsonContent);
    final outputPath = 'lib/models/${className.toLowerCase()}.dart';

    await Directory('lib/models').create(recursive: true);
    await File(outputPath).writeAsString(output);

    print('✅ Model created at: $outputPath');
    print('⚙️  Next: flutter pub run build_runner build');
    
  } catch (e) {
    print('❌ Error parsing JSON: $e');
    exit(1);
  }
}