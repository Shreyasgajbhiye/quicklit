import 'dart:io';

class DependencyManager {
  /// Check if base dependencies are installed
  static Future<bool> checkBaseDependencies() async {
    final pubspecFile = File('pubspec.yaml');
    if (!await pubspecFile.exists()) {
      return false;
    }

    final content = await pubspecFile.readAsString();
    
    final requiredPackages = [
      'connectivity_plus',
      'shared_preferences',
      'provider',
      'json_annotation',
      'build_runner',
      'json_serializable',
    ];

    for (final package in requiredPackages) {
      if (!content.contains('$package:')) {
        return false;
      }
    }

    return true;
  }

  /// Install base dependencies
  static Future<void> installBaseDependencies() async {
    final packages = {
      'connectivity_plus': '^6.0.3',
      'shared_preferences': '^2.2.3',
      'provider': '^6.1.2',
      'json_annotation': '^4.9.0',
      'flutter_bloc': '^8.1.6',
      'equatable': '^2.0.5',
      'http': '^1.2.0',
    };
    
    final devPackages = {
      'build_runner': '^2.4.9',
      'json_serializable': '^6.8.0',
    };

    await _installPackages(packages, devPackages, 'base');
  }

  /// Install Firebase-specific dependencies
  static Future<void> installFirebaseDependencies() async {
    final packages = {
      'firebase_auth': '^5.1.0',
      'firebase_core': '^3.15.1',
    };
    
    final devPackages = <String, String>{};

    await _installPackages(packages, devPackages, 'Firebase');
  }

  /// Install API-specific dependencies
  static Future<void> installApiDependencies() async {
    final packages = {
      'dio': '^5.4.0',
      'pretty_dio_logger': '^1.3.1',
    };
    
    final devPackages = <String, String>{};

    await _installPackages(packages, devPackages, 'API');
  }

  /// Generic package installation method
  static Future<void> _installPackages(
    Map<String, String> packages,
    Map<String, String> devPackages,
    String type,
  ) async {
    try {
      final pubspecFile = File('pubspec.yaml');
      if (!await pubspecFile.exists()) {
        throw Exception('pubspec.yaml not found. Please run this in your Flutter project root.');
      }

      print('📝 Updating pubspec.yaml with $type dependencies...');
      final content = await pubspecFile.readAsString();
      String updatedContent = content;

      // Add dependencies
      for (final package in packages.entries) {
        if (!content.contains(package.key)) {
          print('📦 Adding ${package.key}: ${package.value}');
          updatedContent = _addDependency(updatedContent, package.key, package.value, false);
        } else {
          print('   ✅ ${package.key} already exists');
        }
      }

      // Add dev dependencies
      for (final package in devPackages.entries) {
        if (!content.contains(package.key)) {
          print('🔧 Adding dev dependency ${package.key}: ${package.value}');
          updatedContent = _addDependency(updatedContent, package.key, package.value, true);
        } else {
          print('   ✅ ${package.key} already exists');
        }
      }

      await pubspecFile.writeAsString(updatedContent);

      if (type == 'base') {
        print('\n🎉 Quicklit setup completed!');
        print('📋 Dependencies have been added to pubspec.yaml');
        print('⚙️  Please run: flutter pub get');
      } else {
        print('✅ $type dependencies added to pubspec.yaml');
      }

    } catch (e) {
      print('❌ $type dependency installation failed: $e');
      print('\n📝 Please manually add these dependencies to your pubspec.yaml:');
      print('\ndependencies:');
      packages.forEach((package, version) {
        print('  $package: $version');
      });
      if (devPackages.isNotEmpty) {
        print('\ndev_dependencies:');
        devPackages.forEach((package, version) {
          print('  $package: $version');
        });
      }
      print('\nThen run: flutter pub get');
      rethrow;
    }
  }

  /// Add a dependency to pubspec.yaml content
  static String _addDependency(String content, String packageName, String version, bool isDev) {
    final sectionName = isDev ? 'dev_dependencies:' : 'dependencies:';
    final dependency = '  $packageName: $version';
    
    if (content.contains(sectionName)) {
      // Find the section and add the dependency
      final lines = content.split('\n');
      final sectionIndex = lines.indexWhere((line) => line.trim() == sectionName);
      
      if (sectionIndex != -1) {
        // Find the end of the section
        int insertIndex = sectionIndex + 1;
        while (insertIndex < lines.length && 
               (lines[insertIndex].startsWith('  ') || lines[insertIndex].trim().isEmpty)) {
          insertIndex++;
        }
        
        lines.insert(insertIndex, dependency);
        return lines.join('\n');
      }
    } else {
      // Add the section if it doesn't exist
      final lines = content.split('\n');
      lines.add('');
      lines.add(sectionName);
      lines.add(dependency);
      return lines.join('\n');
    }
    
    return content;
  }
}