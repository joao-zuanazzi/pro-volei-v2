import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/team.dart';
import '../models/player.dart';

/// Serviço de armazenamento local usando Hive
class StorageService extends ChangeNotifier {
  static const String _teamsBoxName = 'teams';
  late Box<Team> _teamsBox;

  List<Team> get teams => _teamsBox.values.toList();

  /// Inicializa o serviço e abre as boxes
  Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(TeamAdapter());
    Hive.registerAdapter(PlayerAdapter());

    _teamsBox = await Hive.openBox<Team>(_teamsBoxName);
    notifyListeners();
  }

  /// Salva uma equipe (cria ou atualiza)
  Future<void> saveTeam(Team team) async {
    await _teamsBox.put(team.id, team);
    notifyListeners();
  }

  /// Remove uma equipe
  Future<void> deleteTeam(String id) async {
    await _teamsBox.delete(id);
    notifyListeners();
  }

  /// Retorna uma equipe pelo ID
  Team? getTeam(String id) {
    return _teamsBox.get(id);
  }
}
