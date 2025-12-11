import 'point.dart';
import 'team_stats.dart';

/// Dados de um set
class SetData {
  final int setNumber;
  final List<Point> points;
  final bool isFinished;
  final int? winnerTeamIndex;

  const SetData({
    required this.setNumber,
    this.points = const [],
    this.isFinished = false,
    this.winnerTeamIndex,
  });

  /// Placar da equipe
  int getScore(int teamIndex) {
    return points.where((p) => p.teamIndex == teamIndex).length;
  }

  /// Estatísticas da equipe
  TeamStats getStats(int teamIndex) {
    return TeamStats.fromPoints(points, teamIndex);
  }

  /// Adiciona um ponto
  SetData addPoint(Point point) {
    return SetData(
      setNumber: setNumber,
      points: [...points, point],
      isFinished: isFinished,
      winnerTeamIndex: winnerTeamIndex,
    );
  }

  /// Remove o último ponto de uma equipe
  SetData removeLastPoint(int teamIndex) {
    final newPoints = List<Point>.from(points);
    for (int i = newPoints.length - 1; i >= 0; i--) {
      if (newPoints[i].teamIndex == teamIndex) {
        newPoints.removeAt(i);
        break;
      }
    }
    return SetData(
      setNumber: setNumber,
      points: newPoints,
      isFinished: isFinished,
      winnerTeamIndex: winnerTeamIndex,
    );
  }

  /// Finaliza o set
  SetData finish() {
    final score0 = getScore(0);
    final score1 = getScore(1);
    return SetData(
      setNumber: setNumber,
      points: points,
      isFinished: true,
      winnerTeamIndex: score0 > score1 ? 0 : (score1 > score0 ? 1 : null),
    );
  }
}
