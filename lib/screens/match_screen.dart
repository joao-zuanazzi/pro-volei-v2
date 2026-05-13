import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/match_stats_snapshot.dart';
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
    final colors = AppTheme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _showExitDialog(context);
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: colors.backgroundGradient),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Se a altura for suficiente, usa layout com Expanded
                if (constraints.maxHeight >= 650) {
                  return Column(
                    children: [
                      _buildHeader(context),
                      _buildScoreDisplay(context),
                      Expanded(child: _buildTeamPanels(context)),
                      _buildSetSelector(context),
                      _buildActionButtons(context),
                    ],
                  );
                }
                // Se a altura for pequena (paisagem), usa scroll compacto
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(context),
                      _buildScoreDisplay(context, compact: true),
                      SizedBox(
                        height: constraints.maxHeight * 0.55,
                        child: _buildTeamPanels(context),
                      ),
                      _buildSetSelector(context),
                      _buildActionButtons(context),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = AppTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Botão de sair (fecha a partida) — usa ícone de fechar (X) em vez
          // de seta de voltar porque o tap abre um diálogo modal, não navega.
          SizedBox(
            width: 80,
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: Icon(Icons.close, color: colors.textSecondary),
                tooltip: 'Sair da partida',
                onPressed: () => _showExitDialog(context),
              ),
            ),
          ),
          // Centro: Título + nome da partida (expansível)
          Expanded(
            child: Tooltip(
              message: 'Editar nome da partida',
              child: GestureDetector(
                onTap: () => _showEditMatchNameDialog(context),
                child: Consumer<GameService>(
                  builder: (context, game, _) {
                    return Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              AppTheme.goldGradient.createShader(bounds),
                          child: const Text(
                            'PRÓ-VÔLEI SPY',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              game.matchName,
                              style: TextStyle(
                                color: colors.textTertiary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.edit,
                              color: colors.textHint,
                              size: 16,
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          // Timer à direita - Toque para iniciar/pausar.
          GestureDetector(
            onTap: () => context.read<GameService>().toggleTimer(),
            child: Consumer<GameService>(
              builder: (context, game, _) {
                // Stream periódico só ativo quando o cronômetro está rodando.
                // Quando pausado, o tempo não muda, então não precisamos rebuild a cada segundo.
                return StreamBuilder<void>(
                  stream: game.isTimerRunning
                      ? Stream.periodic(const Duration(seconds: 1))
                      : null,
                  builder: (context, _) {
                    final matchTime = game.matchDuration;
                    final isRunning = game.isTimerRunning;
                    final m = matchTime.inMinutes.toString().padLeft(2, '0');
                    final s = (matchTime.inSeconds % 60).toString().padLeft(
                      2,
                      '0',
                    );
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isRunning
                            ? AppTheme.success.withValues(alpha: 0.18)
                            : colors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isRunning
                              ? AppTheme.success.withValues(alpha: 0.5)
                              : AppTheme.warning.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isRunning ? Icons.pause : Icons.play_arrow,
                            color: isRunning
                                ? AppTheme.success
                                : AppTheme.warning,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$m:$s',
                            style: TextStyle(
                              color: isRunning
                                  ? AppTheme.success
                                  : AppTheme.warning,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDisplay(BuildContext context, {bool compact = false}) {
    return Consumer<GameService>(
      builder: (context, game, _) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: compact ? 4 : 12,
          ),
          child: ScoreDisplay(
            score1: game.getScore(0),
            score2: game.getScore(1),
            team1Name: game.team1.name,
            team2Name: game.team2.name,
            team1Color: game.team1.primaryColor,
            team2Color: game.team2.primaryColor,
            onSwapTeams: () => game.swapTeams(),
          ),
        );
      },
    );
  }

  Widget _buildTeamPanels(BuildContext context) {
    final colors = AppTheme.of(context);

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
            // Se tela estreita, usa tabs com cores das equipes
            return DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorWeight: 3,
                      dividerHeight: 0,
                      labelColor: colors.text,
                      unselectedLabelColor: colors.textHint,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: colors.isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.05),
                      ),
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: game.team1.primaryColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: game.team1.primaryColor.withValues(alpha: 0.5),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('Equipe 1', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: game.team2.primaryColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: game.team2.primaryColor.withValues(alpha: 0.5),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('Equipe 2', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
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
        // Mostra sets finalizados + set atual + 1 próximo, no máximo 5
        final visibleSets = (game.currentSetIndex + 2).clamp(2, 5);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SetSelector(
            currentSet: game.currentSetIndex + 1,
            totalSets: visibleSets,
            setWinners: setWinners,
            onSetSelected: (set) => game.selectSet(set - 1),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    // Hierarquia visual:
    // - "Finalizar set": ação frequente (a cada 25 pts), peso secundário (azul).
    // - "Finalizar jogo": ação terminal de maior consequência, peso primário (gold,
    //   maior, com destaque). Sair virou ícone de fechar no header.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: GradientButton(
              text: 'FINALIZAR SET',
              icon: Icons.flag,
              gradient: AppTheme.primaryGradient,
              onPressed: () => _finishSet(context),
            ),
          ),
          const SizedBox(width: 10),
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

    if (game.isSetFinished()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Set finalizado! Clique em "Finalizar Set".'),
          backgroundColor: AppTheme.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    final success = game.addPoint(teamIndex);
    if (success) HapticFeedback.lightImpact();

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
    final colors = AppTheme.read(context);
    final game = context.read<GameService>();
    final currentName = teamIndex == 0 ? game.team1.name : game.team2.name;
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.dialogBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Editar ${teamIndex == 0 ? "Equipe 1" : "Equipe 2"}',
          style: TextStyle(color: colors.text),
        ),
        content: TextField(
          controller: controller,
          style: TextStyle(color: colors.text),
          decoration: InputDecoration(
            hintText: 'Nome da equipe',
            hintStyle: TextStyle(color: colors.textHint),
            filled: true,
            fillColor: colors.surface,
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
            child: Text('CANCELAR', style: TextStyle(color: colors.cancelButton)),
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
    final colors = AppTheme.read(context);
    final game = context.read<GameService>();
    final controller = TextEditingController(text: game.matchName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.dialogBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Nome da Partida',
          style: TextStyle(color: colors.text),
        ),
        content: TextField(
          controller: controller,
          style: TextStyle(color: colors.text),
          decoration: InputDecoration(
            hintText: 'Ex: Campeonato Regional',
            hintStyle: TextStyle(color: colors.textHint),
            filled: true,
            fillColor: colors.surface,
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
            child: Text('CANCELAR', style: TextStyle(color: colors.cancelButton)),
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
    final colors = AppTheme.read(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.dialogBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Sair da Partida?',
          style: TextStyle(color: colors.text),
        ),
        content: Text(
          'Você pode salvar o progresso e voltar depois.',
          style: TextStyle(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('CANCELAR', style: TextStyle(color: colors.cancelButton)),
          ),
          TextButton(
            onPressed: () async {
              await GameService.clearSavedMatch();
              if (context.mounted) {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('SAIR SEM SALVAR'),
          ),
          ElevatedButton(
            onPressed: () async {
              final game = context.read<GameService>();
              await game.saveMatchState();
              if (context.mounted) {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
            child: const Text('VOLTAR DEPOIS'),
          ),
        ],
      ),
    );
  }

  Future<void> _finishSet(BuildContext context) async {
    final colors = AppTheme.read(context);
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

    if (!context.mounted) return;
    Navigator.pop(context);

    if (file != null) {
      // Salva no storage de relatórios
      await ReportStorageService.addSetReport(game.matchName, file.path);
      if (!context.mounted) return;
      // Mostra diálogo de confirmação
      final shouldOpen = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: colors.dialogBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.success, size: 28),
              const SizedBox(width: 12),
              Text('PDF Gerado!', style: TextStyle(color: colors.text)),
            ],
          ),
          content: Text(
            'Relatório do Set ${setData.setNumber} salvo com sucesso.',
            style: TextStyle(color: colors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('FECHAR', style: TextStyle(color: colors.cancelButton)),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context, false);
                await Share.shareXFiles(
                  [XFile(file.path)],
                  subject: 'Relatório Set ${setData.setNumber}',
                );
              },
              icon: const Icon(Icons.share, size: 18),
              label: const Text('COMPARTILHAR'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.success,
              ),
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
    final colors = AppTheme.read(context);
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

    if (!context.mounted) return;
    Navigator.pop(context);

    if (file != null) {
      final snapshot = MatchStatsSnapshot.fromMatch(
        sets: game.sets,
        team1: game.team1,
        team2: game.team2,
        matchDuration: game.matchDuration,
      );
      await ReportStorageService.addFinalReport(
        game.matchName,
        file.path,
        stats: snapshot,
      );
      await GameService.clearSavedMatch();

      if (!context.mounted) return;
      final shouldOpen = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: colors.dialogBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.emoji_events, color: AppTheme.primaryGold, size: 28),
              const SizedBox(width: 12),
              Text(
                'Partida Finalizada!',
                style: TextStyle(color: colors.text),
              ),
            ],
          ),
          content: Text(
            'Relatório completo da partida salvo com sucesso.',
            style: TextStyle(color: colors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('FECHAR', style: TextStyle(color: colors.cancelButton)),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context, false);
                await Share.shareXFiles(
                  [XFile(file.path)],
                  subject: 'Relatório Final - ${game.matchName}',
                );
              },
              icon: const Icon(Icons.share, size: 18),
              label: const Text('COMPARTILHAR'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.success,
              ),
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
