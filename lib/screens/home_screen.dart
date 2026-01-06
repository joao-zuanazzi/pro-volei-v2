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
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  _buildLogo(),
                  const SizedBox(height: 16),
                  _buildTitle(),
                  const SizedBox(height: 8),
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppTheme.goldGradient,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGold.withValues(alpha: 0.4),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Center(child: Text('🏐', style: TextStyle(fontSize: 70))),
    );
  }

  Widget _buildTitle() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [AppTheme.primaryGold, Color(0xFFE8C468)],
      ).createShader(bounds),
      child: const Text(
        'PRO VOLEI',
        style: TextStyle(
          fontSize: 42,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 4,
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
      'Versão 2.1',
      style: TextStyle(
        fontSize: 12,
        color: Colors.white.withValues(alpha: 0.3),
      ),
    );
  }

  void _showMatchSetup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const MatchSetupDialog(),
    );
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
      content: Column(
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
