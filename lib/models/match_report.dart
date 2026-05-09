import 'match_stats_snapshot.dart';

/// Modelo para armazenar informações de uma partida e seus relatórios
class MatchReport {
  final String id;
  final String name;
  final DateTime createdAt;
  final List<String> setReportPaths;
  final String? finalReportPath;
  final MatchStatsSnapshot? stats;

  const MatchReport({
    required this.id,
    required this.name,
    required this.createdAt,
    this.setReportPaths = const [],
    this.finalReportPath,
    this.stats,
  });

  /// Cria a partir de JSON
  factory MatchReport.fromJson(Map<String, dynamic> json) {
    return MatchReport(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      setReportPaths: List<String>.from(json['setReportPaths'] ?? []),
      finalReportPath: json['finalReportPath'] as String?,
      stats: json['stats'] != null
          ? MatchStatsSnapshot.fromJson(json['stats'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'setReportPaths': setReportPaths,
      'finalReportPath': finalReportPath,
      if (stats != null) 'stats': stats!.toJson(),
    };
  }

  /// Cria cópia com modificações
  MatchReport copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    List<String>? setReportPaths,
    String? finalReportPath,
    MatchStatsSnapshot? stats,
  }) {
    return MatchReport(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      setReportPaths: setReportPaths ?? this.setReportPaths,
      finalReportPath: finalReportPath ?? this.finalReportPath,
      stats: stats ?? this.stats,
    );
  }

  /// Adiciona um relatório de set
  MatchReport addSetReport(String path) {
    return copyWith(setReportPaths: [...setReportPaths, path]);
  }

  /// Define o relatório final
  MatchReport withFinalReport(String path) {
    return copyWith(finalReportPath: path);
  }

  /// Define o snapshot estatístico
  MatchReport withStats(MatchStatsSnapshot snapshot) {
    return copyWith(stats: snapshot);
  }

  /// Total de relatórios
  int get totalReports =>
      setReportPaths.length + (finalReportPath != null ? 1 : 0);

  /// Data formatada
  String get formattedDate {
    return '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';
  }
}
