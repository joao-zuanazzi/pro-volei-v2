import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';
import '../services/pdf_service.dart';
import '../services/report_storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/action_button.dart';
import '../widgets/score_bar.dart';
import '../widgets/set_selector.dart';
import '../widgets/team_panel.dart';

/// Tela principal da partida
class MatchScreen extends StatelessWidget {
  const MatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Se a altura for suficiente, usa layout com Expanded
              if (constraints.maxHeight >= 650) {
                return Column(
                  children: [
                    _buildHeader(context),
                    _buildScoreBars(context),
                    _buildScoreDisplay(context),
                    Expanded(child: _buildTeamPanels(context)),
                    _buildSetSelector(context),
                    _buildActionButtons(context),
                  ],
                );
              }
              // Se a altura for pequena, usa scroll
              return SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(context),
                    _buildScoreBars(context),
                    _buildScoreDisplay(context),
                    SizedBox(height: 400, child: _buildTeamPanels(context)),
                    _buildSetSelector(context),
                    _buildActionButtons(context),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
            onPressed: () => _showExitDialog(context),
          ),
          GestureDetector(
            onTap: () => _showEditMatchNameDialog(context),
            child: Consumer<GameService>(
              builder: (context, game, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🏐', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              AppTheme.goldGradient.createShader(bounds),
                          child: const Text(
                            'PRO VOLEI',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              game.matchName,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.edit,
                              color: Colors.white38,
                              size: 12,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          Consumer<GameService>(
            builder: (context, game, _) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'SET ${game.currentSetIndex + 1}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBars(BuildContext context) {
    return Consumer<GameService>(
      builder: (context, game, _) {
        return Column(
          children: [
            ScoreBar(score: game.getScore(0), activeColor: AppTheme.team1Color),
            const SizedBox(height: 4),
            ScoreBar(
              score: game.getScore(1),
              activeColor: AppTheme.team2Color,
              isReversed: true,
            ),
          ],
        );
      },
    );
  }

  Widget _buildScoreDisplay(BuildContext context) {
    return Consumer<GameService>(
      builder: (context, game, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ScoreDisplay(
            score1: game.getScore(0),
            score2: game.getScore(1),
            team1Name: game.team1.name,
            team2Name: game.team2.name,
          ),
        );
      },
    );
  }

  Widget _buildTeamPanels(BuildContext context) {
    return Consumer<GameService>(
      builder: (context, game, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // Se tela larga, mostra lado a lado
            if (constraints.maxWidth > 800) {
              return Row(
                children: [
                  Expanded(child: _buildTeamPanel(context, game, 0)),
                  Expanded(child: _buildTeamPanel(context, game, 1)),
                ],
              );
            }
            // Se tela estreita, usa tabs
            return DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      indicatorColor: AppTheme.primaryGold,
                      indicatorWeight: 3,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white54,
                      tabs: [
                        Tab(text: game.team1.name),
                        Tab(text: game.team2.name),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildTeamPanel(context, game, 0),
                        _buildTeamPanel(context, game, 1),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTeamPanel(
    BuildContext context,
    GameService game,
    int teamIndex,
  ) {
    final team = teamIndex == 0 ? game.team1 : game.team2;
    // Passa a lista de jogadores do oponente para o painel
    final opponentTeam = teamIndex == 0 ? game.team2 : game.team1;

    return TeamPanel(
      teamIndex: teamIndex,
      teamName: team.name,
      teamColor: team.primaryColor,
      score: game.getScore(teamIndex),
      players: team.players,
      opponentPlayers: opponentTeam.players,
      selectedType: teamIndex == 0 ? game.selectedType1 : game.selectedType2,
      selectedDetail: teamIndex == 0
          ? game.selectedDetail1
          : game.selectedDetail2,
      selectedPlayerId: teamIndex == 0
          ? game.selectedPlayer1
          : game.selectedPlayer2,
      onTypeChanged: (val) => game.setPointType(teamIndex, val),
      onDetailChanged: (val) => game.setPointDetail(teamIndex, val),
      onPlayerChanged: (val) => game.setPlayer(teamIndex, val),
      onSave: () => _savePoint(context, teamIndex),
      onDelete: () => game.removeLastPoint(teamIndex),
      onEditName: () => _showEditTeamNameDialog(context, teamIndex),
    );
  }

  Widget _buildSetSelector(BuildContext context) {
    return Consumer<GameService>(
      builder: (context, game, _) {
        final setWinners = game.sets.map((s) => s.winnerTeamIndex).toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SetSelector(
            currentSet: game.currentSetIndex + 1,
            setWinners: setWinners,
            onSetSelected: (set) => game.selectSet(set - 1),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: GradientButton(
              text: 'SAIR',
              icon: Icons.exit_to_app,
              backgroundColor: AppTheme.error,
              gradient: null,
              onPressed: () => _showExitDialog(context),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GradientButton(
              text: 'FINALIZAR SET',
              icon: Icons.flag,
              gradient: AppTheme.primaryGradient,
              onPressed: () => _finishSet(context),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GradientButton(
              text: 'FINALIZAR JOGO',
              icon: Icons.emoji_events,
              gradient: AppTheme.goldGradient,
              onPressed: () => _finishMatch(context),
            ),
          ),
        ],
      ),
    );
  }

  void _savePoint(BuildContext context, int teamIndex) {
    final game = context.read<GameService>();
    final type = teamIndex == 0 ? game.selectedType1 : game.selectedType2;
    final score = game.getScore(teamIndex);

    if (type == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selecione o tipo de ponto'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    if (score >= GameService.maxPointsPerSet) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Limite de 25 pontos atingido! Finalize o set.'),
          backgroundColor: AppTheme.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    game.addPoint(teamIndex);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ponto registrado: ${type.label}'),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showEditTeamNameDialog(BuildContext context, int teamIndex) {
    final game = context.read<GameService>();
    final currentName = teamIndex == 0 ? game.team1.name : game.team2.name;
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Editar ${teamIndex == 0 ? "Equipe 1" : "Equipe 2"}',
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Nome da equipe',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: AppTheme.surfaceLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                game.setTeamName(teamIndex, controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('SALVAR'),
          ),
        ],
      ),
    );
  }

  void _showEditMatchNameDialog(BuildContext context) {
    final game = context.read<GameService>();
    final controller = TextEditingController(text: game.matchName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Nome da Partida',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Ex: Campeonato Regional',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: AppTheme.surfaceLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              game.setMatchName(controller.text);
              Navigator.pop(context);
            },
            child: const Text('SALVAR'),
          ),
        ],
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Sair da Partida?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Os dados da partida atual serão perdidos.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('SAIR'),
          ),
        ],
      ),
    );
  }

  Future<void> _finishSet(BuildContext context) async {
    final game = context.read<GameService>();
    final setData = game.finishCurrentSet();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryGold),
      ),
    );

    final file = await PdfService.generateSetPdf(
      setData: setData,
      team1: game.team1,
      team2: game.team2,
      matchName: game.matchName,
    );

    Navigator.pop(context);

    if (file != null) {
      // Salva no storage de relatórios
      await ReportStorageService.addSetReport(game.matchName, file.path);
      // Mostra diálogo de confirmação
      final shouldOpen = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.success, size: 28),
              const SizedBox(width: 12),
              const Text('PDF Gerado!', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Text(
            'Relatório do Set ${setData.setNumber} salvo com sucesso.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('FECHAR'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('ABRIR PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
              ),
            ),
          ],
        ),
      );

      if (shouldOpen == true) {
        await PdfService.openPdf(file);
      }
    }
  }

  Future<void> _finishMatch(BuildContext context) async {
    final game = context.read<GameService>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryGold),
      ),
    );

    final file = await PdfService.generateMatchPdf(
      sets: game.sets,
      team1: game.team1,
      team2: game.team2,
      totalStats1: game.getTotalStats(0),
      totalStats2: game.getTotalStats(1),
      setsWon1: game.getSetsWon(0),
      setsWon2: game.getSetsWon(1),
      matchName: game.matchName,
    );

    Navigator.pop(context);

    if (file != null) {
      // Salva no storage de relatórios (e finaliza a partida)
      await ReportStorageService.addFinalReport(game.matchName, file.path);
      // Mostra diálogo de confirmação
      final shouldOpen = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.emoji_events, color: AppTheme.primaryGold, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Partida Finalizada!',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: const Text(
            'Relatório completo da partida salvo com sucesso.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('FECHAR'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('ABRIR PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGold,
              ),
            ),
          ],
        ),
      );

      if (shouldOpen == true) {
        await PdfService.openPdf(file);
      }
    }
  }
}
