import 'package:flutter/material.dart';
import '../models/point_type.dart';
import '../models/player.dart';
import '../theme/app_theme.dart';

/// Painel de controle de uma equipe
class TeamPanel extends StatelessWidget {
  final int teamIndex;
  final String teamName;
  final Color teamColor;
  final int score;
  final List<Player> players;
  final List<Player> opponentPlayers;
  final PointType? selectedType;
  final PointDetail? selectedDetail;
  final String? selectedPlayerId;
  final ValueChanged<PointType?> onTypeChanged;
  final ValueChanged<PointDetail?> onDetailChanged;
  final ValueChanged<String?> onPlayerChanged;
  final VoidCallback onSave;
  final VoidCallback onDelete;
  final VoidCallback? onEditName;

  final bool isExpanded;

  const TeamPanel({
    super.key,
    required this.teamIndex,
    required this.teamName,
    required this.teamColor,
    required this.score,
    this.players = const [],
    this.opponentPlayers = const [],
    this.selectedType,
    this.selectedDetail,
    this.selectedPlayerId,
    required this.onTypeChanged,
    required this.onDetailChanged,
    required this.onPlayerChanged,
    required this.onSave,
    required this.onDelete,
    this.onEditName,
    this.isExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    Widget content = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: isExpanded ? null : const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTypeSelector(colors),
          if (selectedType != null) ...[
            const SizedBox(height: 16),
            _buildDetailSelector(colors),
          ],
          if (selectedType != null &&
              selectedType != PointType.opponentError) ...[
            const SizedBox(height: 16),
            _buildPlayerSelector(colors),
          ],
          const SizedBox(height: 24),
          _buildActions(context),
        ],
      ),
    );

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: teamColor.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: teamColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isExpanded
          ? Column(children: [Expanded(child: content)])
          : content,
    );
  }

  Widget _buildTypeSelector(AppThemeColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Tipo de Ponto', colors),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: PointType.values.map((type) {
              final isSelected = selectedType == type;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => onTypeChanged(isSelected ? null : type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? teamColor : colors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? teamColor : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(type.icon, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          type.label,
                          style: TextStyle(
                            color: isSelected ? Colors.white : colors.textSecondary,
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailSelector(AppThemeColors colors) {
    if (selectedType == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Detalhe', colors),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: selectedType!.availableDetails.map((detail) {
            final isSelected = selectedDetail == detail;
            return GestureDetector(
              onTap: () => onDetailChanged(isSelected ? null : detail),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? teamColor : colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? teamColor : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Text(
                  detail.label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : colors.textSecondary,
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPlayerSelector(AppThemeColors colors) {
    final targetPlayers = selectedType == PointType.opponentError
        ? opponentPlayers
        : players;

    if (targetPlayers.isEmpty) return const SizedBox();

    // Ordena por número da camisa
    final sortedPlayers = List.of(targetPlayers)
      ..sort((a, b) => a.number.compareTo(b.number));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(
          selectedType == PointType.opponentError
              ? 'Quem errou (Equipe Adversária)?'
              : 'Quem marcou?',
          colors,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: sortedPlayers.map((player) {
            final isSelected = selectedPlayerId == player.id;
            return GestureDetector(
              onTap: () => onPlayerChanged(isSelected ? null : player.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? teamColor : colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? teamColor : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white24
                            : teamColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${player.number}',
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected ? Colors.white : colors.text,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      player.name.split(' ').first,
                      style: TextStyle(
                        color: isSelected ? Colors.white : colors.textSecondary,
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    // Só habilita salvar se tipo e detalhe estiverem selecionados
    // Se houver jogadores target, um jogador deve ser selecionado
    final targetPlayers = selectedType == PointType.opponentError
        ? opponentPlayers
        : players;

    final isOpponentError = selectedType == PointType.opponentError;
    final canSave =
        selectedType != null &&
        selectedDetail != null &&
        (isOpponentError || targetPlayers.isEmpty || selectedPlayerId != null);

    return Row(
      children: [
        Expanded(
          child: Opacity(
            opacity: canSave ? 1.0 : 0.5,
            child: ElevatedButton.icon(
              onPressed: canSave ? onSave : null,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('SALVAR'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.remove, size: 20),
            label: const Text('EXCLUIR'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text, AppThemeColors colors) {
    return Text(
      text,
      style: TextStyle(
        color: colors.textTertiary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }
}
