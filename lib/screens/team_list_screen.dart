import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/team.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/action_button.dart';
import 'team_editor_screen.dart';

class TeamListScreen extends StatelessWidget {
  const TeamListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Gerenciar Equipes'),
        backgroundColor: Colors.transparent,
        foregroundColor: colors.text,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: colors.backgroundGradient),
        child: Consumer<StorageService>(
          builder: (context, storage, child) {
            final teams = storage.teams;

            if (teams.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: colors.textHint,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhuma equipe cadastrada',
                      style: TextStyle(color: colors.textTertiary, fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    GradientButton(
                      text: 'CRIAR EQUIPE',
                      icon: Icons.add,
                      gradient: AppTheme.primaryGradient,
                      onPressed: () => _openEditor(context),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: teams.length,
              itemBuilder: (context, index) {
                final team = teams[index];
                return Dismissible(
                  key: Key(team.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await _showDeleteDialog(context, team.name);
                  },
                  onDismissed: (_) {
                    storage.deleteTeam(team.id);
                  },
                  child: Card(
                    color: colors.card,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: team.primaryColor,
                        child: Text(
                          team.name.isNotEmpty
                              ? team.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        team.name,
                        style: TextStyle(
                          color: colors.text,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${team.players.length} atletas',
                        style: TextStyle(color: colors.textSecondary),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                            onPressed: () async {
                              final confirm = await _showDeleteDialog(context, team.name);
                              if (confirm == true) storage.deleteTeam(team.id);
                            },
                          ),
                          Icon(Icons.edit, color: colors.textTertiary),
                        ],
                      ),
                      onTap: () => _openEditor(context, team: team),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryGold,
        child: const Icon(Icons.add),
        onPressed: () => _openEditor(context),
      ),
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context, String teamName) {
    final colors = AppTheme.read(context);
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.dialogBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Deseja excluir a equipe $teamName?',
          style: TextStyle(color: colors.text, fontSize: 16),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            child: Text('CANCELAR', style: TextStyle(color: colors.cancelButton)),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          TextButton(
            child: const Text('EXCLUIR', style: TextStyle(color: AppTheme.error)),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );
  }

  void _openEditor(BuildContext context, {Team? team}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TeamEditorScreen(team: team)),
    );
  }
}
