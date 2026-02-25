import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';
import '../models/team.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'match_screen.dart';
import 'reports_screen.dart';
import 'team_list_screen.dart';

/// Tela inicial do aplicativo
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape = constraints.maxWidth > constraints.maxHeight;
              final isDesktop = constraints.maxHeight > 600;

              // PC: 280px, Celular portrait: 300px, Celular landscape: 140px
              final logoHeight = isDesktop
                  ? 280.0
                  : (isLandscape ? 140.0 : 300.0);

              // Em landscape usa scroll centrado, em portrait usa layout fixo
              if (isLandscape) {
                return Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLogo(logoHeight),
                          const SizedBox(height: 12),
                          _buildSubtitle(),
                          const SizedBox(height: 20),
                          _buildStartButton(context),
                          const SizedBox(height: 12),
                          _buildManageTeamsButton(context),
                          const SizedBox(height: 8),
                          _buildReportsButton(context),
                          const SizedBox(height: 16),
                          _buildVersion(),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // Portrait: layout original com Spacers
              return Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    _buildLogo(logoHeight),
                    const SizedBox(height: 16),
                    _buildSubtitle(),
                    const Spacer(),
                    const Spacer(),
                    _buildStartButton(context),
                    const SizedBox(height: 24),
                    _buildManageTeamsButton(context),
                    const SizedBox(height: 12),
                    _buildReportsButton(context),
                    const SizedBox(height: 32),
                    _buildVersion(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(double height) {
    // Mantém proporção da logo (largura ≈ 1.45x altura)
    final width = height * 1.45;
    return SizedBox(
      width: width,
      height: height,
      child: Image.asset('assets/logo.png', fit: BoxFit.contain),
    );
  }

  Widget _buildTitle() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [AppTheme.primaryGold, Color(0xFFE8C468)],
      ).createShader(bounds),
      child: const Text(
        'PRÓ-VÔLEI SPY',
        style: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Gerenciador Profissional de Partidas',
      style: TextStyle(
        fontSize: 14,
        color: Colors.white.withValues(alpha: 0.6),
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _showMatchSetup(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Text(
                'INICIAR PARTIDA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManageTeamsButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TeamListScreen()),
        );
      },
      icon: const Icon(Icons.people, color: Colors.white70),
      label: const Text(
        'GERENCIAR EQUIPES',
        style: TextStyle(color: Colors.white70, fontSize: 16),
      ),
    );
  }

  Widget _buildReportsButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ReportsScreen()),
        );
      },
      icon: const Icon(Icons.folder_open, color: Colors.white54),
      label: const Text(
        'VER RELATÓRIOS',
        style: TextStyle(color: Colors.white54, fontSize: 14),
      ),
    );
  }

  Widget _buildVersion() {
    return Text(
      'Versão 2.2',
      style: TextStyle(
        fontSize: 12,
        color: Colors.white.withValues(alpha: 0.3),
      ),
    );
  }

  void _showMatchSetup(BuildContext context) async {
    final hasSaved = await GameService.hasSavedMatch();

    if (hasSaved && context.mounted) {
      // Há partida salva — perguntar se quer retomar
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppTheme.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Partida em Andamento',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Existe uma partida salva que não foi finalizada. Deseja retomar ou iniciar uma nova?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('CANCELAR'),
            ),
            TextButton(
              onPressed: () async {
                await GameService.clearSavedMatch();
                if (context.mounted) {
                  Navigator.pop(dialogContext);
                  showDialog(
                    context: context,
                    builder: (context) => const MatchSetupDialog(),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.amber),
              child: const Text('NOVA PARTIDA'),
            ),
            ElevatedButton(
              onPressed: () async {
                final game = context.read<GameService>();
                await game.loadMatchState();
                if (context.mounted) {
                  Navigator.pop(dialogContext);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const MatchScreen(),
                    ),
                  );
                }
              },
              child: const Text('RETOMAR PARTIDA'),
            ),
          ],
        ),
      );
    } else if (context.mounted) {
      // Sem partida salva — abrir configuração normal
      showDialog(
        context: context,
        builder: (context) => const MatchSetupDialog(),
      );
    }
  }
}

class MatchSetupDialog extends StatefulWidget {
  const MatchSetupDialog({super.key});

  @override
  State<MatchSetupDialog> createState() => _MatchSetupDialogState();
}

class _MatchSetupDialogState extends State<MatchSetupDialog> {
  String? _team1Id;
  String? _team2Id;

  @override
  Widget build(BuildContext context) {
    final teams = context.watch<StorageService>().teams;

    return AlertDialog(
      backgroundColor: AppTheme.cardBackground,
      title: const Text(
        'Configurar Partida',
        style: TextStyle(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTeamSelector(
              'Equipe 1',
              teams,
              _team1Id,
              (val) => setState(() => _team1Id = val),
            ),
            const SizedBox(height: 16),
            _buildTeamSelector(
              'Equipe 2',
              teams,
              _team2Id,
              (val) => setState(() => _team2Id = val),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('CANCELAR'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: const Text('INICIAR'),
          onPressed: () {
            final game = context.read<GameService>();
            game.resetGame();

            final storage = context.read<StorageService>();

            if (_team1Id != null) {
              final t1 = storage.getTeam(_team1Id!);
              if (t1 != null) game.setTeam(0, t1);
            }

            if (_team2Id != null) {
              final t2 = storage.getTeam(_team2Id!);
              if (t2 != null) game.setTeam(1, t2);
            }

            Navigator.pop(context); // Close dialog
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const MatchScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTeamSelector(
    String label,
    List<Team> teams,
    String? value,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            hint: const Text('Padrão', style: TextStyle(color: Colors.white38)),
            dropdownColor: AppTheme.surfaceLight,
            style: const TextStyle(color: Colors.white),
            underline: const SizedBox(),
            items: [
              const DropdownMenuItem(value: null, child: Text('Padrão')),
              ...teams.map(
                (t) => DropdownMenuItem(value: t.id, child: Text(t.name)),
              ),
            ],
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
