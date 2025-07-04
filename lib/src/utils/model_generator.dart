// lib/src/utils/model_generator.dart

String generateModelTemplate(String className, Map<String, dynamic> json) {
  String getDartType(dynamic value) {
    if (value == null) return 'dynamic';
    if (value is String) return 'String';
    if (value is int) return 'int';
    if (value is double) return 'double';
    if (value is bool) return 'bool';
    if (value is List) {
      if (value.isEmpty) return 'List<dynamic>';
      return 'List<${getDartType(value.first)}>';
    }
    if (value is Map) return 'Map<String, dynamic>';
    return 'dynamic';
  }

  final fields = json.entries
      .map((e) => '  final ${getDartType(e.value)} ${e.key};')
      .join('\n');

  final constructorParams =
      json.keys.map((k) => 'required this.$k').join(', ');

  return '''
import 'package:json_annotation/json_annotation.dart';

part '${className.toLowerCase()}.g.dart';

@JsonSerializable()
class $className {
$fields

  $className({$constructorParams});

  factory $className.fromJson(Map<String, dynamic> json) =>
      _\$${className}FromJson(json);

  Map<String, dynamic> toJson() => _\$${className}ToJson(this);
}
''';
}