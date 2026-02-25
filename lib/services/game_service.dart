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

  // Cronômetro com iniciar/pausar
  bool _isTimerRunning = false;
  DateTime? _lastResumeTime;
  Duration _accumulatedMatchTime = Duration.zero;
  Duration _accumulatedSetTime = Duration.zero;

  /// Se o cronômetro está rodando
  bool get isTimerRunning => _isTimerRunning;

  /// Tempo decorrido da partida (acumulado + tempo desde último resume)
  Duration get matchDuration {
    if (_isTimerRunning && _lastResumeTime != null) {
      return _accumulatedMatchTime +
          DateTime.now().difference(_lastResumeTime!);
    }
    return _accumulatedMatchTime;
  }

  /// Tempo decorrido do set atual
  Duration get setDuration {
    if (_isTimerRunning && _lastResumeTime != null) {
      return _accumulatedSetTime + DateTime.now().difference(_lastResumeTime!);
    }
    return _accumulatedSetTime;
  }

  /// Inicia ou retoma o cronômetro
  void startTimer() {
    if (!_isTimerRunning) {
      _isTimerRunning = true;
      _lastResumeTime = DateTime.now();
      notifyListeners();
    }
  }

  /// Pausa o cronômetro
  void pauseTimer() {
    if (_isTimerRunning && _lastResumeTime != null) {
      final elapsed = DateTime.now().difference(_lastResumeTime!);
      _accumulatedMatchTime += elapsed;
      _accumulatedSetTime += elapsed;
      _isTimerRunning = false;
      _lastResumeTime = null;
      notifyListeners();
    }
  }

  /// Alterna entre iniciar e pausar
  void toggleTimer() {
    if (_isTimerRunning) {
      pauseTimer();
    } else {
      startTimer();
    }
  }

  /// Reseta o cronômetro do set (mantém o da partida)
  void resetSetTimer() {
    if (_isTimerRunning && _lastResumeTime != null) {
      // Salva o tempo acumulado da partida antes de resetar o set
      final elapsed = DateTime.now().difference(_lastResumeTime!);
      _accumulatedMatchTime += elapsed;
      _accumulatedSetTime = Duration.zero;
      _lastResumeTime = DateTime.now();
    } else {
      _accumulatedSetTime = Duration.zero;
    }
  }

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

  /// Troca os lados das equipes (esquerda/direita)
  void swapTeams() {
    final tempTeam = _team1;
    _team1 = _team2;
    _team2 = tempTeam;

    // Troca seleções temporárias
    final tempType = _selectedType1;
    _selectedType1 = _selectedType2;
    _selectedType2 = tempType;

    final tempDetail = _selectedDetail1;
    _selectedDetail1 = _selectedDetail2;
    _selectedDetail2 = tempDetail;

    final tempPlayer = _selectedPlayer1;
    _selectedPlayer1 = _selectedPlayer2;
    _selectedPlayer2 = tempPlayer;

    // Troca os índices de equipe em todos os sets para que os pontos sigam as equipes
    _sets = _sets.map((s) => s.swapTeamIndices()).toList();

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

  /// Mínimo de pontos para vencer o set
  static const int minPointsToWin = 25;

  /// Verifica se o set já foi finalizado
  bool isSetFinished() {
    final s1 = getScore(0);
    final s2 = getScore(1);
    // Uma equipe venceu se tem >= 25 pontos E 2+ pontos de vantagem
    return (s1 >= minPointsToWin || s2 >= minPointsToWin) &&
        (s1 - s2).abs() >= 2;
  }

  /// Adiciona um ponto para a equipe
  /// Retorna false se tipo/detalhe não selecionado ou set finalizado
  bool addPoint(int teamIndex) {
    // Verificar se o set já foi finalizado
    if (isSetFinished()) {
      return false;
    }

    final type = teamIndex == 0 ? _selectedType1 : _selectedType2;
    final detail = teamIndex == 0 ? _selectedDetail1 : _selectedDetail2;
    final playerId = teamIndex == 0 ? _selectedPlayer1 : _selectedPlayer2;

    // Validação: tipo e detalhe são obrigatórios
    if (type == null || detail == null) return false;

    // Se a equipe tem jogadores cadastrados, validar se jogador foi selecionado
    // Exceto para erro do adversário, onde o jogador não é atribuído
    final team = teamIndex == 0 ? _team1 : _team2;
    if (type != PointType.opponentError &&
        team.players.isNotEmpty &&
        playerId == null) {
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
    final elapsed = setDuration;
    _sets[_currentSetIndex] = currentSet.finish(setDuration: elapsed);
    final finishedSet = currentSet;

    // Reseta o timer para o próximo set
    resetSetTimer();

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

  /// [DEBUG/TEST] Gera pontos aleatórios para teste rápido
  void generateRandomPoints({int count = 10}) {
    final random = DateTime.now().millisecondsSinceEpoch;
    final types = PointType.values;

    for (int i = 0; i < count; i++) {
      // Alterna entre time 0 e 1 com variação
      final teamIndex = (random + i) % 3 == 0 ? 1 : ((random + i) % 2);
      final type = types[(random + i) % types.length];

      // Seleciona detalhe válido para o tipo
      final details = type.availableDetails;
      final detail = details[(random + i) % details.length];

      // Jogador aleatório se a equipe tem jogadores
      final team = teamIndex == 0 ? _team1 : _team2;
      String? playerId;
      if (team.players.isNotEmpty) {
        playerId = team.players[(random + i) % team.players.length].id;
      }

      final point = Point(
        teamIndex: teamIndex,
        type: type,
        detail: detail,
        playerId: playerId,
      );

      _sets[_currentSetIndex] = currentSet.addPoint(point);
    }

    notifyListeners();
  }
}
