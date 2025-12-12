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
    Widget content = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: isExpanded ? null : const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTypeSelector(),
          if (selectedType != null) ...[
            const SizedBox(height: 16),
            _buildDetailSelector(),
          ],
          if (selectedType != null) ...[
            const SizedBox(height: 16),
            _buildPlayerSelector(),
          ],
          const SizedBox(height: 24),
          _buildActions(context),
        ],
      ),
    );

    if (isExpanded) {
      content = Expanded(child: content);
    }

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [_buildHeader(), content],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            teamColor.withValues(alpha: 0.8),
            teamColor.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onEditName,
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      teamName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onEditName != null) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.edit,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 16,
                    ),
                  ],
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$score pts',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Tipo de Ponto'),
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
                      color: isSelected ? teamColor : AppTheme.surfaceLight,
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
                            color: isSelected ? Colors.white : Colors.white70,
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

  Widget _buildDetailSelector() {
    if (selectedType == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Detalhe'),
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
                  color: isSelected ? teamColor : AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? teamColor : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Text(
                  detail.label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
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

  Widget _buildPlayerSelector() {
    final targetPlayers = selectedType == PointType.opponentError
        ? opponentPlayers
        : players;

    if (targetPlayers.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(
          selectedType == PointType.opponentError
              ? 'Quem errou (Equipe Adversária)?'
              : 'Quem marcou?',
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: targetPlayers.map((player) {
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
                  color: isSelected ? teamColor : AppTheme.surfaceLight,
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
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${player.number}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      player.name.split(' ').first,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
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

    final canSave =
        selectedType != null &&
        selectedDetail != null &&
        (targetPlayers.isEmpty || selectedPlayerId != null);

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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white54,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }
}
