import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Seletor visual de sets
class SetSelector extends StatelessWidget {
  final int currentSet;
  final int totalSets;
  final List<int?>
  setWinners; // null = não finalizado, 0 ou 1 = índice do time vencedor
  final ValueChanged<int> onSetSelected;

  const SetSelector({
    super.key,
    required this.currentSet,
    this.totalSets = 5,
    this.setWinners = const [],
    required this.onSetSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalSets, (index) {
          final setNumber = index + 1;
          final isSelected = currentSet == setNumber;
          final winner = index < setWinners.length ? setWinners[index] : null;
          final isFinished = winner != null;

          return GestureDetector(
            onTap: () => onSetSelected(setNumber),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: isSelected ? AppTheme.primaryGradient : null,
                color: isSelected
                    ? null
                    : (isFinished
                          ? (winner == 0
                                ? AppTheme.team1Color.withValues(alpha: 0.3)
                                : AppTheme.team2Color.withValues(alpha: 0.3))
                          : AppTheme.surfaceLight),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryGold : Colors.transparent,
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'SET',
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : Colors.white38,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$setNumber',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isFinished)
                    Icon(
                      Icons.check_circle,
                      size: 10,
                      color: winner == 0
                          ? AppTheme.team1Color
                          : AppTheme.team2Color,
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
