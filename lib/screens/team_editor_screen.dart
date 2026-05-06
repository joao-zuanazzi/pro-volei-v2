import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/team.dart';
import '../models/player.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class TeamEditorScreen extends StatefulWidget {
  final Team? team;

  const TeamEditorScreen({super.key, this.team});

  @override
  State<TeamEditorScreen> createState() => _TeamEditorScreenState();
}

class _TeamEditorScreenState extends State<TeamEditorScreen> {
  late TextEditingController _nameController;
  late Color _primaryColor;
  late Color _secondaryColor;
  late List<Player> _players;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final team = widget.team;
    _nameController = TextEditingController(text: team?.name ?? '');
    _primaryColor = team?.primaryColor ?? Team.team1Default.primaryColor;
    _secondaryColor = team?.secondaryColor ?? Team.team1Default.secondaryColor;
    _players = List.from(team?.players ?? []);
    _nameController.addListener(() => _hasChanges = true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nome da equipe é obrigatório')),
      );
      return;
    }

    final team = Team(
      id: widget.team?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      primaryColor: _primaryColor,
      secondaryColor: _secondaryColor,
      players: _players,
    );

    context.read<StorageService>().saveTeam(team);
    Navigator.pop(context);
  }

  void _addPlayer() {
    showDialog(
      context: context,
      builder: (context) => _PlayerDialog(
        onSave: (name, number) {
          if (_players.any((p) => p.number == number)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Já existe um jogador com este número'),
              ),
            );
            return;
          }
          if (_players.any((p) => p.name.toLowerCase() == name.toLowerCase())) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Já existe um jogador com este nome'),
              ),
            );
            return;
          }
          setState(() {
            _players.add(Player.create(name: name, number: number));
            _hasChanges = true;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _editPlayer(int index) {
    final player = _players[index];
    showDialog(
      context: context,
      builder: (context) => _PlayerDialog(
        initialName: player.name,
        initialNumber: player.number,
        onSave: (name, number) {
          if (_players
              .where((p) => p != player)
              .any((p) => p.number == number)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Já existe um jogador com este número'),
              ),
            );
            return;
          }
          if (_players
              .where((p) => p != player)
              .any((p) => p.name.toLowerCase() == name.toLowerCase())) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Já existe um jogador com este nome'),
              ),
            );
            return;
          }
          setState(() {
            _players[index] = player.copyWith(name: name, number: number);
            _hasChanges = true;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _removePlayer(int index) {
    setState(() {
      _players.removeAt(index);
      _hasChanges = true;
    });
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final colors = AppTheme.read(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.dialogBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Salvar alterações?',
          style: TextStyle(color: colors.text, fontSize: 16),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            child: const Text('DESCARTAR', style: TextStyle(color: AppTheme.error)),
            onPressed: () => Navigator.pop(ctx, true),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
            child: const Text('SALVAR'),
            onPressed: () {
              _save();
            },
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
      appBar: AppBar(
        title: Text(widget.team == null ? 'Nova Equipe' : 'Editar Equipe'),
        backgroundColor: colors.background,
        foregroundColor: colors.text,
        actions: [IconButton(icon: const Icon(Icons.check), onPressed: _save)],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: colors.backgroundGradient),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection('Informações Básicas'),
            Card(
              color: colors.card,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      style: TextStyle(color: colors.text),
                      decoration: InputDecoration(
                        labelText: 'Nome da Equipe',
                        labelStyle: TextStyle(color: colors.textSecondary),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: colors.border),
                        ),
                      ),
                    ),
                    // TODO: Color Pickers (Simplificado por agora)
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSection('Atletas (${_players.length})'),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppTheme.success),
                  onPressed: _addPlayer,
                ),
              ],
            ),
            if (_players.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Nenhum atleta cadastrado',
                  style: TextStyle(color: colors.textTertiary),
                  textAlign: TextAlign.center,
                ),
              ),
            ..._players.asMap().entries.map((entry) {
              final index = entry.key;
              final player = entry.value;
              return Card(
                color: colors.surface,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _primaryColor,
                    child: Text(
                      '${player.number}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    player.name,
                    style: TextStyle(color: colors.text),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: colors.textTertiary),
                        onPressed: () => _editPlayer(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppTheme.error),
                        onPressed: () => _removePlayer(index),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.primaryGold,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _PlayerDialog extends StatefulWidget {
  final String? initialName;
  final int? initialNumber;
  final Function(String, int) onSave;

  const _PlayerDialog({
    this.initialName,
    this.initialNumber,
    required this.onSave,
  });

  @override
  State<_PlayerDialog> createState() => _PlayerDialogState();
}

class _PlayerDialogState extends State<_PlayerDialog> {
  late TextEditingController _nameController;
  late TextEditingController _numberController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _numberController = TextEditingController(
      text: widget.initialNumber?.toString() ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    return AlertDialog(
      backgroundColor: colors.dialogBackground,
      title: Text(
        widget.initialName == null ? 'Novo Atleta' : 'Editar Atleta',
        style: TextStyle(color: colors.text),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            style: TextStyle(color: colors.text),
            decoration: InputDecoration(
              labelText: 'Nome',
              labelStyle: TextStyle(color: colors.textSecondary),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _numberController,
            style: TextStyle(color: colors.text),
            decoration: InputDecoration(
              labelText: 'Número',
              labelStyle: TextStyle(color: colors.textSecondary),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text('CANCELAR', style: TextStyle(color: colors.cancelButton)),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: const Text('SALVAR'),
          onPressed: () {
            final name = _nameController.text.trim();
            final number = int.tryParse(_numberController.text.trim());

            if (name.isNotEmpty && number != null) {
              widget.onSave(name, number);
            }
          },
        ),
      ],
    );
  }
}
