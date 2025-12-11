import 'point_type.dart';

/// Representa um ponto marcado na partida
class Point {
  final int teamIndex; // 0 ou 1
  final int position; // Posição 1-6
  final PointType type;
  final PointOrigin origin;
  final int setterPosition; // Posição do levantador 1-6
  final DateTime timestamp;

  Point({
    required this.teamIndex,
    required this.position,
    required this.type,
    required this.origin,
    required this.setterPosition,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Copia o ponto com modificações opcionais
  Point copyWith({
    int? teamIndex,
    int? position,
    PointType? type,
    PointOrigin? origin,
    int? setterPosition,
  }) {
    return Point(
      teamIndex: teamIndex ?? this.teamIndex,
      position: position ?? this.position,
      type: type ?? this.type,
      origin: origin ?? this.origin,
      setterPosition: setterPosition ?? this.setterPosition,
      timestamp: timestamp,
    );
  }
}
