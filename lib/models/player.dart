import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

/// Modelo de atleta
class Player {
  final String id;
  final String name;
  final int number;

  Player({required this.id, required this.name, required this.number});

  factory Player.create({required String name, required int number}) {
    return Player(id: const Uuid().v4(), name: name, number: number);
  }

  Player copyWith({String? name, int? number}) {
    return Player(
      id: id,
      name: name ?? this.name,
      number: number ?? this.number,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'number': number};
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'] as String,
      name: map['name'] as String,
      number: map['number'] as int,
    );
  }
}

/// Adaptador Hive para Player
class PlayerAdapter extends TypeAdapter<Player> {
  @override
  final int typeId = 1;

  @override
  Player read(BinaryReader reader) {
    return Player(
      id: reader.readString(),
      name: reader.readString(),
      number: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, Player obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeInt(obj.number);
  }
}
