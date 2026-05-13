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
        _AnimatedScore(score: score, color: color, colors: colors),
      ],
    );
  }

  Widget _buildVs(AppThemeColors colors) {
    return Tooltip(
      message: 'Trocar lados',
      child: GestureDetector(
        onTap: onSwapTeams,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(10),
            border: onSwapTeams != null
                ? Border.all(color: colors.border)
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'VS',
                style: TextStyle(
                  color: colors.textTertiary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onSwapTeams != null) ...[
                const SizedBox(height: 4),
                Icon(Icons.swap_horiz, color: AppTheme.primaryGold, size: 20),
                const SizedBox(height: 2),
                Text(
                  'Trocar',
                  style: TextStyle(
                    color: colors.textHint,
                    fontSize: 9,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedScore extends StatefulWidget {
  final int score;
  final Color color;
  final AppThemeColors colors;

  const _AnimatedScore({
    required this.score,
    required this.color,
    required this.colors,
  });

  @override
  State<_AnimatedScore> createState() => _AnimatedScoreState();
}

class _AnimatedScoreState extends State<_AnimatedScore> {
  late int _prevScore;

  @override
  void initState() {
    super.initState();
    _prevScore = widget.score;
  }

  @override
  void didUpdateWidget(_AnimatedScore old) {
    super.didUpdateWidget(old);
    if (old.score != widget.score) {
      _prevScore = old.score;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: _prevScore, end: widget.score),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, _) {
        return Text(
          '$value',
          style: TextStyle(
            color: widget.colors.text,
            fontSize: 56,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: widget.color.withValues(alpha: 0.5),
                blurRadius: 20,
              ),
            ],
          ),
        );
      },
    );
  }
}
