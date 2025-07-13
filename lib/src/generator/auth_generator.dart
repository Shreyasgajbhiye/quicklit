// import 'dart:io';
// import '../utils/dependency_manager.dart';
// import '../templates/auth_templates.dart';

// enum Auth1Provider { firebase, api }

// class Auth1Generator {
//   final AuthProvider provider;
  
//   Auth1Generator(this.provider);

//   /// Generate complete auth boilerplate
//   Future<void> generateAuthBoilerplate() async {
//     try {
//       print('🔐 Using ${provider == AuthProvider.firebase ? 'Firebase' : 'API'} authentication');
      
//       // Install provider-specific dependencies
//       await _installProviderDependencies();
      
//       // Create directory structure
//       await _createAuthDirectories();
      
//       // Generate auth files
//       await _generateAuthFiles();
      
//       print('\n✅ Auth boilerplate generated successfully!');
//       print('📁 Created files:');
//       print('   • lib/pages/auth/login.dart');
//       print('   • lib/pages/auth/register.dart');
//       print('   • lib/bloc/auth/auth_bloc.dart');
//       print('   • lib/bloc/auth/auth_event.dart');
//       print('   • lib/bloc/auth/auth_state.dart');
//       if (provider == AuthProvider.api) {
//         print('   • lib/services/auth_service.dart');
//         print('   • lib/models/user_model.dart');
//       }
//       print('');
//       print('⚙️  Next steps:');
//       print('   1. Run: flutter pub get');
//       if (provider == AuthProvider.api) {
//         print('   2. Update BASE_URL in lib/services/auth_service.dart');
//         print('   3. Customize API endpoints if needed');
//       } else {
//         print('   2. Configure Firebase in your project');
//         print('   3. Add google-services.json (Android) / GoogleService-Info.plist (iOS)');
//       }
//       print('   4. Import: import "package:your_app/pages/auth/login.dart";');
//       print('   5. Use: QuicklitLoginPage() in your routes');
      
//     } catch (e) {
//       print('❌ Failed to generate auth boilerplate: $e');
//       rethrow;
//     }
//   }

//   /// Install provider-specific dependencies
//   Future<void> _installProviderDependencies() async {
//     print('📦 Installing ${provider.name} dependencies...');
    
//     if (provider == AuthProvider.firebase) {
//       await DependencyManager.installFirebaseDependencies();
//     } else {
//       await DependencyManager.installApiDependencies();
//     }
//   }

//   /// Create auth directory structure
//   Future<void> _createAuthDirectories() async {
//     final directories = [
//       'lib/pages/auth',
//       'lib/bloc/auth',
//       if (provider == AuthProvider.api) 'lib/services',
//       if (provider == AuthProvider.api) 'lib/models',
//     ];

//     for (final dir in directories) {
//       await Directory(dir).create(recursive: true);
//     }
//   }

//   /// Generate all auth-related files
//   Future<void> _generateAuthFiles() async {
//     final templates = AuthTemplates(provider);
    
//     // Generate BLoC files
//     await File('lib/bloc/auth/auth_event.dart').writeAsString(templates.getAuthEventCode());
//     await File('lib/bloc/auth/auth_state.dart').writeAsString(templates.getAuthStateCode());
//     await File('lib/bloc/auth/auth_bloc.dart').writeAsString(templates.getAuthBlocCode());
    
//     // Generate page files
//     await File('lib/pages/auth/login.dart').writeAsString(templates.getLoginPageCode());
//     await File('lib/pages/auth/register.dart').writeAsString(templates.getRegisterPageCode());
    
//     // Generate service files for API provider
//     if (provider == AuthProvider.api) {
//       await File('lib/services/auth_service.dart').writeAsString(templates.getAuthServiceCode());
//       await File('lib/models/user_model.dart').writeAsString(templates.getUserModelCode());
//     }
//   }
// }

// lib/src/generator/auth_generator.dart
import 'dart:io';
import '../utils/dependency_manager.dart';
import '../templates/auth_templates.dart';
import '../shared/auth_provider.dart' as auth_provider;

class AuthGenerator {
  final auth_provider.AuthProvider provider;
  final String projectPath;

  AuthGenerator({
    required this.provider,
    required this.projectPath,
  });

  Future<void> generateAuthBoilerplate() async {
    try {
      print('🔐 Using ${provider == auth_provider.AuthProvider.firebase ? 'Firebase' : 'API'} authentication');
      
      await _installProviderDependencies();
      await _createAuthDirectories();
      await _generateAuthFiles();
      
      print('\n✅ Auth boilerplate generated successfully!');
      // ... [rest of the success message]
    } catch (e) {
      print('❌ Failed to generate auth boilerplate: $e');
      rethrow;
    }
  }

  Future<void> _installProviderDependencies() async {
    if (provider == auth_provider.AuthProvider.firebase) {
      await DependencyManager.installFirebaseDependencies();
    } else {
      await DependencyManager.installApiDependencies();
    }
  }

  Future<void> _createAuthDirectories() async {
    final directories = [
      '$projectPath/lib/pages/auth',
      '$projectPath/lib/bloc/auth',
      if (provider == auth_provider.AuthProvider.api) '$projectPath/lib/services',
      if (provider == auth_provider.AuthProvider.api) '$projectPath/lib/models',
    ];

    for (final dir in directories) {
      await Directory(dir).create(recursive: true);
    }
  }

  Future<void> _generateAuthFiles() async {
    final templates = AuthTemplates(provider);
    
    await File('$projectPath/lib/bloc/auth/auth_event.dart').writeAsString(templates.getAuthEventCode());
    await File('$projectPath/lib/bloc/auth/auth_state.dart').writeAsString(templates.getAuthStateCode());
    await File('$projectPath/lib/bloc/auth/auth_bloc.dart').writeAsString(templates.getAuthBlocCode());
    await File('$projectPath/lib/pages/auth/login.dart').writeAsString(templates.getLoginPageCode());
    await File('$projectPath/lib/pages/auth/register.dart').writeAsString(templates.getRegisterPageCode());
    
    if (provider == auth_provider.AuthProvider.api) {
      await File('$projectPath/lib/services/auth_service.dart').writeAsString(templates.getAuthServiceCode());
      await File('$projectPath/lib/models/user_model.dart').writeAsString(templates.getUserModelCode());
    }
  }
}