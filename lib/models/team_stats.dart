import 'point.dart';
import 'point_type.dart';

/// Estatísticas de uma equipe
class TeamStats {
  final int score;
  final int serves;
  final int blocks;
  final int attacks;
  final int opponentErrors;

  const TeamStats({
    this.score = 0,
    this.serves = 0,
    this.blocks = 0,
    this.attacks = 0,
    this.opponentErrors = 0,
  });

  /// Cria estatísticas a partir de uma lista de pontos
  factory TeamStats.fromPoints(List<Point> points, int teamIndex) {
    final teamPoints = points.where((p) => p.teamIndex == teamIndex).toList();

    return TeamStats(
      score: teamPoints.length,
      serves: teamPoints.where((p) => p.type == PointType.serve).length,
      blocks: teamPoints.where((p) => p.type == PointType.block).length,
      attacks: teamPoints.where((p) => p.type == PointType.attack).length,
      opponentErrors: teamPoints
          .where((p) => p.type == PointType.opponentError)
          .length,
    );
  }

  /// Soma duas estatísticas
  TeamStats operator +(TeamStats other) {
    return TeamStats(
      score: score + other.score,
      serves: serves + other.serves,
      blocks: blocks + other.blocks,
      attacks: attacks + other.attacks,
      opponentErrors: opponentErrors + other.opponentErrors,
    );
  }

  /// Estatísticas zeradas
  static const empty = TeamStats();
}
