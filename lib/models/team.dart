import 'package:flutter/material.dart';

/// Representa uma equipe na partida
class Team {
  final String name;
  final Color primaryColor;
  final Color secondaryColor;

  const Team({
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
  });

  /// Equipe padrão 1 (Azul)
  static const team1Default = Team(
    name: 'Equipe 1',
    primaryColor: Color(0xFF1E3A5F),
    secondaryColor: Color(0xFF3D5A80),
  );

  /// Equipe padrão 2 (Dourado/Laranja)
  static const team2Default = Team(
    name: 'Equipe 2',
    primaryColor: Color(0xFFD4A03C),
    secondaryColor: Color(0xFFE8C468),
  );

  Team copyWith({String? name, Color? primaryColor, Color? secondaryColor}) {
    return Team(
      name: name ?? this.name,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
    );
  }
}
