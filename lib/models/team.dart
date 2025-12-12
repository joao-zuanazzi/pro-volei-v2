import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'player.dart';

/// Representa uma equipe na partida
class Team {
  final String id;
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final List<Player> players;

  const Team({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    this.players = const [],
  });

  /// Equipe padrão 1 (Azul)
  static final team1Default = Team(
    id: const Uuid().v4(),
    name: 'Equipe 1',
    primaryColor: const Color(0xFF1E3A5F),
    secondaryColor: const Color(0xFF3D5A80),
  );

  /// Equipe padrão 2 (Dourado/Laranja)
  static final team2Default = Team(
    id: const Uuid().v4(),
    name: 'Equipe 2',
    primaryColor: const Color(0xFFD4A03C),
    secondaryColor: const Color(0xFFE8C468),
  );

  Team copyWith({
    String? id,
    String? name,
    Color? primaryColor,
    Color? secondaryColor,
    List<Player>? players,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      players: players ?? this.players,
    );
  }
}

/// Adaptador Hive para Team
class TeamAdapter extends TypeAdapter<Team> {
  @override
  final int typeId = 0;

  @override
  Team read(BinaryReader reader) {
    return Team(
      id: reader.readString(),
      name: reader.readString(),
      primaryColor: Color(reader.readInt()),
      secondaryColor: Color(reader.readInt()),
      players: reader.readList().cast<Player>(),
    );
  }

  @override
  void write(BinaryWriter writer, Team obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeInt(obj.primaryColor.value);
    writer.writeInt(obj.secondaryColor.value);
    writer.writeList(obj.players);
  }
}
