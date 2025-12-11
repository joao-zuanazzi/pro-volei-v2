import 'package:flutter/foundation.dart';
import '../models/point.dart';
import '../models/point_type.dart';
import '../models/set_data.dart';
import '../models/team.dart';
import '../models/team_stats.dart';

/// Serviço de gerenciamento do jogo
/// Usa ChangeNotifier para notificar mudanças na UI
class GameService extends ChangeNotifier {
  // Equipes
  Team _team1 = Team.team1Default;
  Team _team2 = Team.team2Default;

  // Sets (máximo 5)
  List<SetData> _sets = [const SetData(setNumber: 1)];
  int _currentSetIndex = 0;

  // Seleções temporárias para adicionar ponto
  int? _selectedPosition1;
  int? _selectedPosition2;
  PointType? _selectedType1;
  PointType? _selectedType2;
  PointOrigin? _selectedOrigin1;
  PointOrigin? _selectedOrigin2;
  int? _selectedSetter1;
  int? _selectedSetter2;

  // Getters
  Team get team1 => _team1;
  Team get team2 => _team2;
  List<SetData> get sets => _sets;
  int get currentSetIndex => _currentSetIndex;
  SetData get currentSet => _sets[_currentSetIndex];

  int? get selectedPosition1 => _selectedPosition1;
  int? get selectedPosition2 => _selectedPosition2;
  PointType? get selectedType1 => _selectedType1;
  PointType? get selectedType2 => _selectedType2;
  PointOrigin? get selectedOrigin1 => _selectedOrigin1;
  PointOrigin? get selectedOrigin2 => _selectedOrigin2;
  int? get selectedSetter1 => _selectedSetter1;
  int? get selectedSetter2 => _selectedSetter2;

  /// Placar atual da equipe no set atual
  int getScore(int teamIndex) => currentSet.getScore(teamIndex);

  /// Estatísticas da equipe no set atual
  TeamStats getStats(int teamIndex) => currentSet.getStats(teamIndex);

  /// Estatísticas totais do jogo
  TeamStats getTotalStats(int teamIndex) {
    return _sets.fold<TeamStats>(
      TeamStats.empty,
      (acc, set) => acc + set.getStats(teamIndex),
    );
  }

  /// Sets vencidos por cada equipe
  int getSetsWon(int teamIndex) {
    return _sets.where((s) => s.winnerTeamIndex == teamIndex).length;
  }

  /// Placar total do jogo
  int getTotalScore(int teamIndex) {
    return _sets.fold<int>(0, (acc, set) => acc + set.getScore(teamIndex));
  }

  // Setters para seleções
  void setPosition(int teamIndex, int? value) {
    if (teamIndex == 0) {
      _selectedPosition1 = value;
    } else {
      _selectedPosition2 = value;
    }
    notifyListeners();
  }

  void setPointType(int teamIndex, PointType? value) {
    if (teamIndex == 0) {
      _selectedType1 = value;
    } else {
      _selectedType2 = value;
    }
    notifyListeners();
  }

  void setOrigin(int teamIndex, PointOrigin? value) {
    if (teamIndex == 0) {
      _selectedOrigin1 = value;
    } else {
      _selectedOrigin2 = value;
    }
    notifyListeners();
  }

  void setSetter(int teamIndex, int? value) {
    if (teamIndex == 0) {
      _selectedSetter1 = value;
    } else {
      _selectedSetter2 = value;
    }
    notifyListeners();
  }

  /// Atualiza nome da equipe
  void setTeamName(int teamIndex, String name) {
    if (teamIndex == 0) {
      _team1 = _team1.copyWith(name: name);
    } else {
      _team2 = _team2.copyWith(name: name);
    }
    notifyListeners();
  }

  /// Limite máximo de pontos por set
  static const int maxPointsPerSet = 25;

  /// Adiciona um ponto para a equipe
  /// Retorna false se tipo não selecionado ou limite atingido
  bool addPoint(int teamIndex) {
    // Verificar limite de pontos
    if (getScore(teamIndex) >= maxPointsPerSet) {
      return false;
    }

    final position = teamIndex == 0 ? _selectedPosition1 : _selectedPosition2;
    final type = teamIndex == 0 ? _selectedType1 : _selectedType2;
    final origin = teamIndex == 0 ? _selectedOrigin1 : _selectedOrigin2;
    final setter = teamIndex == 0 ? _selectedSetter1 : _selectedSetter2;

    // Validação: pelo menos tipo é obrigatório
    if (type == null) return false;

    final point = Point(
      teamIndex: teamIndex,
      position: position ?? 1,
      type: type,
      origin: origin ?? PointOrigin.sideOut,
      setterPosition: setter ?? 1,
    );

    _sets[_currentSetIndex] = currentSet.addPoint(point);
    notifyListeners();
    return true;
  }

  /// Remove o último ponto da equipe
  void removeLastPoint(int teamIndex) {
    if (currentSet.getScore(teamIndex) > 0) {
      _sets[_currentSetIndex] = currentSet.removeLastPoint(teamIndex);
      notifyListeners();
    }
  }

  /// Muda para outro set
  void selectSet(int index) {
    if (index >= 0 && index < 5) {
      // Cria sets se necessário
      while (_sets.length <= index) {
        _sets.add(SetData(setNumber: _sets.length + 1));
      }
      _currentSetIndex = index;
      notifyListeners();
    }
  }

  /// Finaliza o set atual
  SetData finishCurrentSet() {
    _sets[_currentSetIndex] = currentSet.finish();
    final finishedSet = currentSet;

    // Avança para próximo set se possível
    if (_currentSetIndex < 4) {
      selectSet(_currentSetIndex + 1);
    }

    notifyListeners();
    return finishedSet;
  }

  /// Reinicia todo o jogo
  void resetGame() {
    _sets = [const SetData(setNumber: 1)];
    _currentSetIndex = 0;
    _clearSelections();
    notifyListeners();
  }

  void _clearSelections() {
    _selectedPosition1 = null;
    _selectedPosition2 = null;
    _selectedType1 = null;
    _selectedType2 = null;
    _selectedOrigin1 = null;
    _selectedOrigin2 = null;
    _selectedSetter1 = null;
    _selectedSetter2 = null;
  }
}
