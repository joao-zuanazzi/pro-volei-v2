import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Placar grande animado
class ScoreDisplay extends StatelessWidget {
  final int score1;
  final int score2;
  final String team1Name;
  final String team2Name;
  final Color team1Color;
  final Color team2Color;
  final VoidCallback? onSwapTeams;

  const ScoreDisplay({
    super.key,
    required this.score1,
    required this.score2,
    required this.team1Name,
    required this.team2Name,
    required this.team1Color,
    required this.team2Color,
    this.onSwapTeams,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: colors.isDark ? 0.3 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _buildTeamScore(team1Name, score1, team1Color, colors),
          ),
          _buildVs(colors),
          Expanded(
            child: _buildTeamScore(team2Name, score2, team2Color, colors),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamScore(String name, int score, Color color, AppThemeColors colors) {
    return Column(
      children: [
        Text(
          name,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<int>(
          tween: IntTween(begin: 0, end: score),
          duration: const Duration(milliseconds: 500),
          builder: (context, value, child) {
            return Text(
              '$value',
              style: TextStyle(
                color: colors.text,
                fontSize: 56,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(color: color.withValues(alpha: 0.5), blurRadius: 20),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildVs(AppThemeColors colors) {
    return GestureDetector(
      onTap: onSwapTeams,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'VS',
              style: TextStyle(
                color: colors.textTertiary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (onSwapTeams != null)
              Icon(Icons.swap_horiz, color: colors.textHint, size: 14),
          ],
        ),
      ),
    );
  }
}
