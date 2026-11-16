/// Stable identity of a player within a session. Names may change between
/// games; the id is what roles, acknowledgements and votes refer to.
extension type const PlayerId(String value) {}

/// A participant. The name is an opaque display label here: the name rules
/// (length, duplicates) are a setup concern pending Q-01.
final class Player {
  const Player({required this.id, required this.name});

  final PlayerId id;
  final String name;

  @override
  bool operator ==(Object other) =>
      other is Player && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);

  @override
  String toString() => 'Player(${id.value})';
}
