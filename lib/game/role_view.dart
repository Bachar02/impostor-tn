/// What one player is allowed to see during the private reveal (PRD §5).
///
/// The Impostor's view has no field that could carry the word, an alias or a
/// hint: the type itself enforces "category only".
sealed class RoleView {
  const RoleView({required this.playerName, required this.category});

  final String playerName;
  final String category;

  @override
  String toString() => 'RoleView(<redacted>)';
}

final class CivilianView extends RoleView {
  const CivilianView({
    required super.playerName,
    required super.category,
    required this.word,
  });

  final String word;
}

final class ImpostorView extends RoleView {
  const ImpostorView({required super.playerName, required super.category});
}
