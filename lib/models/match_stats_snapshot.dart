import 'point.dart';
import 'point_type.dart';
import 'set_data.dart';
import 'team.dart';

/// Snapshot estatístico de um jogador ao final de uma partida.
///
/// Pontos do próprio jogador (saque, ataque, bloqueio) entram em
/// [serves]/[attacks]/[blocks]. Erros próprios (atribuídos via pontos do tipo
/// [PointType.opponentError] do adversário, identificando o jogador que
/// errou) entram em [errosCometidos].
class PlayerStatsSnapshot {
  final String playerId;
  final String playerName;
  final int playerNumber;
  final int serves;
  final int blocks;
  final int attacks;
  final int errosCometidos;

  const PlayerStatsSnapshot({
    required this.playerId,
    required this.playerName,
    required this.playerNumber,
    required this.serves,
    required this.blocks,
    required this.attacks,
    this.errosCometidos = 0,
  });

  int get totalPontos => serves + blocks + attacks;

  Map<String, dynamic> toJson() => {
    'playerId': playerId,
    'playerName': playerName,
    'playerNumber': playerNumber,
    'serves': serves,
    'blocks': blocks,
    'attacks': attacks,
    'errosCometidos': errosCometidos,
  };

  factory PlayerStatsSnapshot.fromJson(Map<String, dynamic> json) {
    return PlayerStatsSnapshot(
      playerId: json['playerId'] as String,
      playerName: json['playerName'] as String,
      playerNumber: json['playerNumber'] as int,
      serves: json['serves'] as int,
      blocks: json['blocks'] as int,
      attacks: json['attacks'] as int,
      errosCometidos: json['errosCometidos'] as int? ?? 0,
    );
  }
}

/// Snapshot estatístico de uma equipe ao final de uma partida.
///
/// Armazena valores absolutos (pontos por tipo). Métricas relativas
/// (aproveitamento de saque, taxa de erro) são calculadas via getters
/// para que o dashboard possa exibi-las sem recomputar nada.
class MatchTeamStatsSnapshot {
  final String teamName;
  final int score;
  final int setsWon;
  final int serves;
  final int blocks;
  final int attacks;
  final int opponentErrors;
  final int ownErrors;
  final List<PlayerStatsSnapshot> jogadores;

  const MatchTeamStatsSnapshot({
    required this.teamName,
    required this.score,
    required this.setsWon,
    required this.serves,
    required this.blocks,
    required this.attacks,
    required this.opponentErrors,
    required this.ownErrors,
    this.jogadores = const [],
  });

  /// Total de jogadas em que esta equipe esteve envolvida (pontos seus + erros próprios).
  int get totalEnvolvido => score + ownErrors;

  /// % dos pontos da equipe que vieram de saque.
  double get aproveitamentoSaque =>
      score == 0 ? 0 : (serves / score) * 100;

  /// % dos pontos da equipe que vieram de ataque.
  double get aproveitamentoAtaque =>
      score == 0 ? 0 : (attacks / score) * 100;

  /// % dos pontos da equipe que vieram de bloqueio.
  double get aproveitamentoBloqueio =>
      score == 0 ? 0 : (blocks / score) * 100;

  /// % dos pontos da equipe que vieram de erro do adversário.
  double get pontosPorErroAdversario =>
      score == 0 ? 0 : (opponentErrors / score) * 100;

  /// Taxa de erro: erros próprios em relação ao total de jogadas onde a equipe esteve envolvida.
  double get taxaErro =>
      totalEnvolvido == 0 ? 0 : (ownErrors / totalEnvolvido) * 100;

  Map<String, dynamic> toJson() => {
    'teamName': teamName,
    'score': score,
    'setsWon': setsWon,
    'serves': serves,
    'blocks': blocks,
    'attacks': attacks,
    'opponentErrors': opponentErrors,
    'ownErrors': ownErrors,
    'jogadores': jogadores.map((j) => j.toJson()).toList(),
  };

  factory MatchTeamStatsSnapshot.fromJson(Map<String, dynamic> json) {
    return MatchTeamStatsSnapshot(
      teamName: json['teamName'] as String,
      score: json['score'] as int,
      setsWon: json['setsWon'] as int,
      serves: json['serves'] as int,
      blocks: json['blocks'] as int,
      attacks: json['attacks'] as int,
      opponentErrors: json['opponentErrors'] as int,
      ownErrors: json['ownErrors'] as int,
      jogadores: (json['jogadores'] as List?)
              ?.map(
                (j) => PlayerStatsSnapshot.fromJson(j as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );
  }
}

/// Snapshot estatístico completo de uma partida.
class MatchStatsSnapshot {
  final MatchTeamStatsSnapshot team1;
  final MatchTeamStatsSnapshot team2;
  final int totalSets;
  final int durationMs;

  const MatchStatsSnapshot({
    required this.team1,
    required this.team2,
    required this.totalSets,
    required this.durationMs,
  });

  /// Constrói o snapshot a partir do estado bruto da partida.
  ///
  /// Para "ownErrors" usamos os pontos de [PointType.opponentError]
  /// marcados pelo time adversário (cada um representa um erro nosso
  /// que rendeu ponto a eles).
  factory MatchStatsSnapshot.fromMatch({
    required List<SetData> sets,
    required Team team1,
    required Team team2,
    required Duration matchDuration,
  }) {
    int score1 = 0;
    int score2 = 0;
    int serves1 = 0, blocks1 = 0, attacks1 = 0, opErr1 = 0;
    int serves2 = 0, blocks2 = 0, attacks2 = 0, opErr2 = 0;
    int setsWon1 = 0, setsWon2 = 0;

    // Acumuladores de stats por jogador (por playerId)
    final jogadores1 = <String, _PlayerAcc>{};
    final jogadores2 = <String, _PlayerAcc>{};

    for (final set in sets) {
      final s1 = set.getScore(0);
      final s2 = set.getScore(1);
      score1 += s1;
      score2 += s2;
      if (set.winnerTeamIndex == 0) setsWon1++;
      if (set.winnerTeamIndex == 1) setsWon2++;

      for (final Point p in set.points) {
        final isTeam1 = p.teamIndex == 0;
        switch (p.type) {
          case PointType.serve:
            isTeam1 ? serves1++ : serves2++;
            break;
          case PointType.block:
            isTeam1 ? blocks1++ : blocks2++;
            break;
          case PointType.attack:
            isTeam1 ? attacks1++ : attacks2++;
            break;
          case PointType.opponentError:
            isTeam1 ? opErr1++ : opErr2++;
            break;
        }

        // Atribui o ponto/erro ao jogador correto:
        // - saque/ataque/bloqueio: jogador do MESMO time que pontuou.
        // - opponentError: jogador do time ADVERSÁRIO (quem errou).
        if (p.playerId == null) continue;
        final ehErro = p.type == PointType.opponentError;
        final accAlvo = ehErro
            ? (isTeam1 ? jogadores2 : jogadores1)
            : (isTeam1 ? jogadores1 : jogadores2);
        final acumulado = accAlvo.putIfAbsent(
          p.playerId!,
          () => _PlayerAcc(),
        );
        if (ehErro) {
          acumulado.erros++;
        } else {
          acumulado.add(p.type);
        }
      }
    }

    // Os erros do time 1 são os pontos de "erro do adversário" do time 2 (e vice-versa).
    final ownErrors1 = opErr2;
    final ownErrors2 = opErr1;

    return MatchStatsSnapshot(
      team1: MatchTeamStatsSnapshot(
        teamName: team1.name,
        score: score1,
        setsWon: setsWon1,
        serves: serves1,
        blocks: blocks1,
        attacks: attacks1,
        opponentErrors: opErr1,
        ownErrors: ownErrors1,
        jogadores: _materializaJogadores(team1, jogadores1),
      ),
      team2: MatchTeamStatsSnapshot(
        teamName: team2.name,
        score: score2,
        setsWon: setsWon2,
        serves: serves2,
        blocks: blocks2,
        attacks: attacks2,
        opponentErrors: opErr2,
        ownErrors: ownErrors2,
        jogadores: _materializaJogadores(team2, jogadores2),
      ),
      totalSets: sets.where((s) => s.isFinished).length,
      durationMs: matchDuration.inMilliseconds,
    );
  }

  /// Converte os acumuladores em [PlayerStatsSnapshot] usando o cadastro
  /// da equipe para resolver nome e número da camisa.
  static List<PlayerStatsSnapshot> _materializaJogadores(
    Team team,
    Map<String, _PlayerAcc> acumuladores,
  ) {
    return acumuladores.entries.map((entry) {
      final player = team.players
          .where((p) => p.id == entry.key)
          .cast<dynamic>()
          .firstOrNull;
      return PlayerStatsSnapshot(
        playerId: entry.key,
        playerName: player?.name as String? ?? 'Jogador',
        playerNumber: player?.number as int? ?? 0,
        serves: entry.value.serves,
        blocks: entry.value.blocks,
        attacks: entry.value.attacks,
        errosCometidos: entry.value.erros,
      );
    }).toList()
      ..sort((a, b) => b.totalPontos.compareTo(a.totalPontos));
  }

  Map<String, dynamic> toJson() => {
    'team1': team1.toJson(),
    'team2': team2.toJson(),
    'totalSets': totalSets,
    'durationMs': durationMs,
  };

  factory MatchStatsSnapshot.fromJson(Map<String, dynamic> json) {
    return MatchStatsSnapshot(
      team1: MatchTeamStatsSnapshot.fromJson(
        json['team1'] as Map<String, dynamic>,
      ),
      team2: MatchTeamStatsSnapshot.fromJson(
        json['team2'] as Map<String, dynamic>,
      ),
      totalSets: json['totalSets'] as int,
      durationMs: json['durationMs'] as int,
    );
  }
}

/// Acumulador interno usado durante a construção do snapshot.
class _PlayerAcc {
  int serves = 0;
  int blocks = 0;
  int attacks = 0;
  int erros = 0;

  void add(PointType type) {
    switch (type) {
      case PointType.serve:
        serves++;
        break;
      case PointType.block:
        blocks++;
        break;
      case PointType.attack:
        attacks++;
        break;
      case PointType.opponentError:
        break;
    }
  }
}
