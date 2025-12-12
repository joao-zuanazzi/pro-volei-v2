import 'point_type.dart';

/// Representa um ponto marcado na partida
class Point {
  final int teamIndex;
  final PointType type;
  final PointDetail detail;
  final String? playerId;
  final DateTime timestamp;

  Point({
    required this.teamIndex,
    required this.type,
    required this.detail,
    this.playerId,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Copia o ponto com modificações opcionais
  Point copyWith({
    int? teamIndex,
    PointType? type,
    PointDetail? detail,
    String? playerId,
  }) {
    return Point(
      teamIndex: teamIndex ?? this.teamIndex,
      type: type ?? this.type,
      detail: detail ?? this.detail,
      playerId: playerId ?? this.playerId,
      timestamp: timestamp,
    );
  }
}
