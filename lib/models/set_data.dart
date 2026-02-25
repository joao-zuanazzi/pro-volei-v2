import 'point.dart';
import 'team_stats.dart';

/// Dados de um set
class SetData {
  final int setNumber;
  final List<Point> points;
  final bool isFinished;
  final int? winnerTeamIndex;
  final Duration? duration;

  const SetData({
    required this.setNumber,
    this.points = const [],
    this.isFinished = false,
    this.winnerTeamIndex,
    this.duration,
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
      duration: duration,
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
      duration: duration,
    );
  }

  /// Finaliza o set com duração
  SetData finish({Duration? setDuration}) {
    final score0 = getScore(0);
    final score1 = getScore(1);
    return SetData(
      setNumber: setNumber,
      points: points,
      isFinished: true,
      winnerTeamIndex: score0 > score1 ? 0 : (score1 > score0 ? 1 : null),
      duration: setDuration ?? duration,
    );
  }

  /// Troca os índices de equipe de todos os pontos (0↔1)
  /// Usado quando o usuário clica no VS para trocar lados
  SetData swapTeamIndices() {
    final swappedPoints = points.map((p) {
      return Point(
        teamIndex: p.teamIndex == 0 ? 1 : 0,
        type: p.type,
        detail: p.detail,
        playerId: p.playerId,
      );
    }).toList();

    return SetData(
      setNumber: setNumber,
      points: swappedPoints,
      isFinished: isFinished,
      winnerTeamIndex: winnerTeamIndex == null
          ? null
          : (winnerTeamIndex == 0 ? 1 : 0),
      duration: duration,
    );
  }

  /// Serializa para JSON
  Map<String, dynamic> toJson() => {
    'setNumber': setNumber,
    'points': points.map((p) => p.toJson()).toList(),
    'isFinished': isFinished,
    'winnerTeamIndex': winnerTeamIndex,
    'durationMs': duration?.inMilliseconds,
  };

  /// Desserializa de JSON
  factory SetData.fromJson(Map<String, dynamic> json) => SetData(
    setNumber: json['setNumber'] as int,
    points: (json['points'] as List)
        .map((p) => Point.fromJson(p as Map<String, dynamic>))
        .toList(),
    isFinished: json['isFinished'] as bool,
    winnerTeamIndex: json['winnerTeamIndex'] as int?,
    duration: json['durationMs'] != null
        ? Duration(milliseconds: json['durationMs'] as int)
        : null,
  );
}
