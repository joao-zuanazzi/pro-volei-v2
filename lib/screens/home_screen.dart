import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';
import '../models/team.dart';
import '../services/storage_service.dart';
import '../services/theme_provider.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'match_screen.dart';
import 'reports_screen.dart';
import 'team_list_screen.dart';

Route<void> _fadeRoute(Widget page) => PageRouteBuilder(
  pageBuilder: (_, __, ___) => page,
  transitionsBuilder: (_, anim, __, child) =>
      FadeTransition(opacity: anim, child: child),
  transitionDuration: const Duration(milliseconds: 300),
);

/// Tela inicial do aplicativo
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: colors.backgroundGradient),
        child: SafeArea(
          child: Stack(
            children: [
              LayoutBuilder(
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
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 480),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildLogo(context, logoHeight),
                                const SizedBox(height: 12),
                                _buildSubtitle(context),
                                const SizedBox(height: 20),
                                _buildStartButton(context),
                                const SizedBox(height: 12),
                                _buildManageTeamsButton(context),
                                const SizedBox(height: 8),
                                _buildReportsButton(context),
                                const SizedBox(height: 8),
                                _buildDashboardButton(context),
                                const SizedBox(height: 16),
                                _buildVersion(context),
                              ],
                            ),
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
                        _buildLogo(context, logoHeight),
                        const SizedBox(height: 16),
                        _buildSubtitle(context),
                        const Spacer(),
                        const Spacer(),
                        _buildStartButton(context),
                        const SizedBox(height: 24),
                        _buildManageTeamsButton(context),
                        const SizedBox(height: 12),
                        _buildReportsButton(context),
                        const SizedBox(height: 12),
                        _buildDashboardButton(context),
                        const SizedBox(height: 32),
                        _buildVersion(context),
                      ],
                    ),
                  );
                },
              ),
              // Botão de toggle de tema
              Positioned(
                top: 8,
                right: 8,
                child: _buildThemeToggle(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    // EXCEÇÃO INTENCIONAL à regra "não usar context.watch<ThemeProvider>".
    // Em main.dart, a HomeScreen é `home: const HomeScreen()`. O Consumer no
    // MaterialApp reconstrói só o MaterialApp; por ser const, a HomeScreen
    // não é reconstruída automaticamente. Esse `watch` (recebendo o context
    // da HomeScreen via parâmetro) inscreve a tela inteira no ThemeProvider,
    // garantindo que cores, logo e o próprio ícone do toggle se atualizem
    // ao trocar de tema. NÃO TROCAR para context.read.
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return IconButton(
      onPressed: () => themeProvider.toggleTheme(),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) => RotationTransition(
          turns: Tween(begin: 0.75, end: 1.0).animate(anim),
          child: FadeTransition(opacity: anim, child: child),
        ),
        child: Icon(
          isDark ? Icons.light_mode : Icons.dark_mode,
          key: ValueKey(isDark),
          color: isDark ? AppTheme.primaryGold : const Color(0xFF5A5A7A),
          size: 28,
        ),
      ),
      tooltip: isDark ? 'Tema Claro' : 'Tema Escuro',
    );
  }

  Widget _buildLogo(BuildContext context, double height) {
    final colors = AppTheme.of(context);
    final width = height * 1.45;
    return SizedBox(
      width: width,
      height: height,
      child: Image.asset(colors.logoAsset, fit: BoxFit.contain),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    final colors = AppTheme.of(context);
    return Text(
      'Gerenciador Profissional de Partidas',
      style: TextStyle(
        fontSize: 14,
        color: colors.textSecondary,
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
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
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

  Widget _buildNavCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String description,
    required VoidCallback onTap,
  }) {
    final colors = AppTheme.of(context);
    return Material(
      color: colors.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: colors.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        color: colors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colors.textHint, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManageTeamsButton(BuildContext context) {
    return _buildNavCard(
      context,
      icon: Icons.people,
      iconColor: AppTheme.team1Color,
      label: 'Gerenciar Equipes',
      description: 'Criar, editar e organizar equipes',
      onTap: () => Navigator.push(context, _fadeRoute(const TeamListScreen())),
    );
  }

  Widget _buildReportsButton(BuildContext context) {
    return _buildNavCard(
      context,
      icon: Icons.folder_open,
      iconColor: AppTheme.primaryGold,
      label: 'Relatórios',
      description: 'Histórico e PDF das partidas',
      onTap: () => Navigator.push(context, _fadeRoute(const ReportsScreen())),
    );
  }

  Widget _buildDashboardButton(BuildContext context) {
    return _buildNavCard(
      context,
      icon: Icons.bar_chart,
      iconColor: AppTheme.success,
      label: 'Dashboard',
      description: 'Estatísticas e evolução das equipes',
      onTap: () => Navigator.push(context, _fadeRoute(const DashboardScreen())),
    );
  }

  Widget _buildVersion(BuildContext context) {
    final colors = AppTheme.of(context);
    return Text(
      'Versão 2.3',
      style: TextStyle(
        fontSize: 12,
        color: colors.textHint,
      ),
    );
  }

  void _showMatchSetup(BuildContext context) async {
    final colors = AppTheme.read(context);
    final hasSaved = await GameService.hasSavedMatch();

    if (hasSaved && context.mounted) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: colors.dialogBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Partida em Andamento',
            style: TextStyle(color: colors.text),
          ),
          content: Text(
            'Existe uma partida salva que não foi finalizada. Deseja retomar ou iniciar uma nova?',
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
                  Navigator.of(context).push(_fadeRoute(const MatchScreen()));
                }
              },
              child: const Text('RETOMAR PARTIDA'),
            ),
          ],
        ),
      );
    } else if (context.mounted) {
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
    final colors = AppTheme.of(context);
    final teams = context.watch<StorageService>().teams;

    return AlertDialog(
      backgroundColor: colors.dialogBackground,
      title: Text(
        'Configurar Partida',
        style: TextStyle(color: colors.text),
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
          child: Text('CANCELAR', style: TextStyle(color: colors.cancelButton)),
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
              if (t2 != null) {
                if (t2.primaryColor == game.team1.primaryColor) {
                  game.setTeam(1, t2.copyWith(
                    primaryColor: Team.team2Default.primaryColor,
                    secondaryColor: Team.team2Default.secondaryColor,
                  ));
                } else {
                  game.setTeam(1, t2);
                }
              }
            }

            Navigator.pop(context);
            Navigator.of(context).push(_fadeRoute(const MatchScreen()));
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
    final colors = AppTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: colors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            hint: Text('Padrão', style: TextStyle(color: colors.textHint)),
            dropdownColor: colors.dropdownColor,
            style: TextStyle(color: colors.text),
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
