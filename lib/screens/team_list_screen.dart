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
    return Scaffold(
      backgroundColor: AppTheme.darkGradient.colors.first,
      appBar: AppBar(
        title: const Text('Gerenciar Equipes'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: Consumer<StorageService>(
          builder: (context, storage, child) {
            final teams = storage.teams;

            if (teams.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 64,
                      color: Colors.white24,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Nenhuma equipe cadastrada',
                      style: TextStyle(color: Colors.white54, fontSize: 16),
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
                    color: AppTheme.error,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppTheme.cardBackground,
                        title: const Text(
                          'Excluir equipe?',
                          style: TextStyle(color: Colors.white),
                        ),
                        content: Text(
                          'Deseja excluir ${team.name}?',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        actions: [
                          TextButton(
                            child: const Text('CANCELAR'),
                            onPressed: () => Navigator.pop(ctx, false),
                          ),
                          TextButton(
                            child: const Text(
                              'EXCLUIR',
                              style: TextStyle(color: AppTheme.error),
                            ),
                            onPressed: () => Navigator.pop(ctx, true),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (_) {
                    storage.deleteTeam(team.id);
                  },
                  child: Card(
                    color: AppTheme.cardBackground,
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${team.players.length} atletas',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: const Icon(Icons.edit, color: Colors.white54),
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

  void _openEditor(BuildContext context, {Team? team}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TeamEditorScreen(team: team)),
    );
  }
}
