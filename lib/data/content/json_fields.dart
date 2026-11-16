import 'package:impostor_tn/game/content/content_issue.dart';

/// Typed access to one decoded JSON object that records an issue, located by
/// path, for every missing, misspelt or mistyped field instead of throwing.
final class JsonFields {
  JsonFields._(this._path, this._map, this._issues);

  final String _path;
  final Map<String, Object?> _map;
  final List<ContentIssue> _issues;

  /// [value] as an object, or null after recording a type issue.
  static JsonFields? object(
    Object? value,
    String path,
    List<ContentIssue> issues,
  ) {
    if (value is Map<String, Object?>) return JsonFields._(path, value, issues);
    issues.add(ContentIssue(path, ContentIssueKind.wrongType));
    return null;
  }

  /// A nested object at [relative] below this one.
  JsonFields? child(Object? value, String relative) =>
      object(value, '$_path.$relative', _issues);

  JsonFields? childObject(String key, {bool optional = false}) {
    if (!_present(key, optional)) return null;
    return child(_map[key], key);
  }

  void allowOnly(Set<String> keys) {
    for (final key in _map.keys) {
      if (!keys.contains(key)) {
        _issues.add(ContentIssue(_at(key), ContentIssueKind.unknownField));
      }
    }
  }

  void invalid(String key) =>
      _issues.add(ContentIssue(_at(key), ContentIssueKind.invalidValue));

  String? string(String key, {bool optional = false}) {
    if (!_present(key, optional)) return null;
    final value = _map[key];
    if (value is String) return value;
    _wrongType(key);
    return null;
  }

  int? integer(String key) {
    if (!_present(key, false)) return null;
    final value = _map[key];
    if (value is int) return value;
    _wrongType(key);
    return null;
  }

  /// The list at [key]; empty after recording an issue.
  List<Object?> list(String key) {
    if (!_present(key, false)) return const [];
    final value = _map[key];
    if (value is List<Object?>) return value;
    _wrongType(key);
    return const [];
  }

  List<String>? stringList(String key, {bool optional = false}) {
    if (!_present(key, optional)) return null;
    final value = _map[key];
    if (value is! List<Object?>) {
      _wrongType(key);
      return null;
    }
    final strings = <String>[];
    for (final (index, item) in value.indexed) {
      if (item is String) {
        strings.add(item);
      } else {
        _issues.add(
          ContentIssue('${_at(key)}[$index]', ContentIssueKind.wrongType),
        );
      }
    }
    return strings;
  }

  /// The enum value named by the string at [key].
  T? choice<T>(String key, Map<String, T> values, {bool optional = false}) {
    final name = string(key, optional: optional);
    if (name == null) return null;
    final value = values[name];
    if (value == null) invalid(key);
    return value;
  }

  bool _present(String key, bool optional) {
    if (_map.containsKey(key)) return true;
    if (!optional) {
      _issues.add(ContentIssue(_at(key), ContentIssueKind.missingField));
    }
    return false;
  }

  void _wrongType(String key) =>
      _issues.add(ContentIssue(_at(key), ContentIssueKind.wrongType));

  String _at(String key) => _path == r'$' ? key : '$_path.$key';
}
