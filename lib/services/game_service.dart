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
  PointType? _selectedType1;
  PointType? _selectedType2;
  PointDetail? _selectedDetail1;
  PointDetail? _selectedDetail2;
  String? _selectedPlayer1;
  String? _selectedPlayer2;

  // Nome da partida (para organização de relatórios)
  String _matchName = '';

  /// Inicializa nome padrão da partida baseado na data
  String get matchName {
    if (_matchName.isEmpty) {
      final now = DateTime.now();
      _matchName =
          'Partida ${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
    }
    return _matchName;
  }

  /// Define nome customizado da partida
  void setMatchName(String name) {
    _matchName = name.trim().isNotEmpty ? name.trim() : matchName;
    notifyListeners();
  }

  // Getters
  Team get team1 => _team1;
  Team get team2 => _team2;
  List<SetData> get sets => _sets;
  int get currentSetIndex => _currentSetIndex;
  SetData get currentSet => _sets[_currentSetIndex];

  PointType? get selectedType1 => _selectedType1;
  PointType? get selectedType2 => _selectedType2;
  PointDetail? get selectedDetail1 => _selectedDetail1;
  PointDetail? get selectedDetail2 => _selectedDetail2;
  String? get selectedPlayer1 => _selectedPlayer1;
  String? get selectedPlayer2 => _selectedPlayer2;

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
  void setPointType(int teamIndex, PointType? value) {
    if (teamIndex == 0) {
      _selectedType1 = value;
      // Limpa detalhe se mudar tipo
      _selectedDetail1 = null;
      // Não limpa jogador propositalmente para manter seleção rápida se for o mesmo
    } else {
      _selectedType2 = value;
      _selectedDetail2 = null;
    }
    notifyListeners();
  }

  void setPointDetail(int teamIndex, PointDetail? value) {
    if (teamIndex == 0) {
      _selectedDetail1 = value;
    } else {
      _selectedDetail2 = value;
    }
    notifyListeners();
  }

  void setPlayer(int teamIndex, String? playerId) {
    if (teamIndex == 0) {
      _selectedPlayer1 = playerId;
    } else {
      _selectedPlayer2 = playerId;
    }
    notifyListeners();
  }

  /// Define uma equipe completa (para usar do Storage)
  void setTeam(int teamIndex, Team team) {
    if (teamIndex == 0) {
      _team1 = team;
    } else {
      _team2 = team;
    }
    notifyListeners();
  }

  /// Atualiza nome da equipe (uso manual/rápido)
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
  /// Retorna false se tipo/detalhe não selecionado ou limite atingido
  bool addPoint(int teamIndex) {
    // Verificar limite de pontos
    if (getScore(teamIndex) >= maxPointsPerSet) {
      return false;
    }

    final type = teamIndex == 0 ? _selectedType1 : _selectedType2;
    final detail = teamIndex == 0 ? _selectedDetail1 : _selectedDetail2;
    final playerId = teamIndex == 0 ? _selectedPlayer1 : _selectedPlayer2;

    // Validação: tipo e detalhe são obrigatórios
    if (type == null || detail == null) return false;

    // Se a equipe tem jogadores cadastrados, validar se jogador foi selecionado
    final team = teamIndex == 0 ? _team1 : _team2;
    if (team.players.isNotEmpty && playerId == null) {
      // Opcional: retornar false ou permitir ponto sem jogador?
      // O requisito diz "permitindo que seja indicado", vou assumir que é obrigatório para manter consistência
      return false;
    }

    final point = Point(
      teamIndex: teamIndex,
      type: type,
      detail: detail,
      playerId: playerId,
    );

    _sets[_currentSetIndex] = currentSet.addPoint(point);

    // Limpar seleções após marcar
    _clearSelections(teamIndex);

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
    _clearAllSelections();
    notifyListeners();
  }

  void _clearSelections(int teamIndex) {
    if (teamIndex == 0) {
      _selectedType1 = null;
      _selectedDetail1 = null;
      _selectedPlayer1 = null;
    } else {
      _selectedType2 = null;
      _selectedDetail2 = null;
      _selectedPlayer2 = null;
    }
  }

  void _clearAllSelections() {
    _selectedType1 = null;
    _selectedDetail1 = null;
    _selectedPlayer1 = null;
    _selectedType2 = null;
    _selectedDetail2 = null;
    _selectedPlayer2 = null;
  }
}
