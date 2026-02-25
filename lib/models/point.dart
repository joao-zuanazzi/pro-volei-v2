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

  /// Serializa para JSON
  Map<String, dynamic> toJson() => {
    'teamIndex': teamIndex,
    'type': type.name,
    'detail': detail.name,
    'playerId': playerId,
    'timestamp': timestamp.toIso8601String(),
  };

  /// Desserializa de JSON
  factory Point.fromJson(Map<String, dynamic> json) => Point(
    teamIndex: json['teamIndex'] as int,
    type: PointType.values.byName(json['type'] as String),
    detail: PointDetail.values.byName(json['detail'] as String),
    playerId: json['playerId'] as String?,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}
