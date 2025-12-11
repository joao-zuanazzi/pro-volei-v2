import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Barra visual de pontos com animação
class ScoreBar extends StatelessWidget {
  final int score;
  final int maxScore;
  final Color activeColor;
  final Color inactiveColor;
  final bool isReversed;

  const ScoreBar({
    super.key,
    required this.score,
    this.maxScore = 25,
    required this.activeColor,
    this.inactiveColor = const Color(0xFF2D3748),
    this.isReversed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 12,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth =
              (constraints.maxWidth - (maxScore - 1) * 3) / maxScore;

          List<Widget> items = List.generate(maxScore, (index) {
            final isActive = index < score;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: itemWidth,
              decoration: BoxDecoration(
                color: isActive ? activeColor : inactiveColor,
                borderRadius: BorderRadius.circular(2),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: activeColor.withValues(alpha: 0.4),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            );
          });

          if (isReversed) {
            items = items.reversed.toList();
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: items,
          );
        },
      ),
    );
  }
}

/// Placar grande animado
class ScoreDisplay extends StatelessWidget {
  final int score1;
  final int score2;
  final String team1Name;
  final String team2Name;

  const ScoreDisplay({
    super.key,
    required this.score1,
    required this.score2,
    required this.team1Name,
    required this.team2Name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        gradient: AppTheme.darkGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTeamScore(team1Name, score1, AppTheme.team1Color),
          _buildVs(),
          _buildTeamScore(team2Name, score2, AppTheme.team2Color),
        ],
      ),
    );
  }

  Widget _buildTeamScore(String name, int score, Color color) {
    return Column(
      children: [
        Text(
          name,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<int>(
          tween: IntTween(begin: 0, end: score),
          duration: const Duration(milliseconds: 500),
          builder: (context, value, child) {
            return Text(
              '$value',
              style: TextStyle(
                color: Colors.white,
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

  Widget _buildVs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'VS',
        style: TextStyle(
          color: Colors.white54,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
