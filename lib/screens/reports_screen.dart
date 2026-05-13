import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/match_report.dart';
import '../services/pdf_service.dart';
import '../services/report_storage_service.dart';
import '../theme/app_theme.dart';

/// Tela de listagem de relatórios salvos
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<MatchReport> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    final reports = await ReportStorageService.refreshReports();
    setState(() {
      _reports = reports;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: colors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final colors = AppTheme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios, color: colors.textSecondary),
            tooltip: 'Voltar',
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.goldGradient.createShader(bounds),
            child: const Text(
              'RELATÓRIOS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.refresh, color: colors.textSecondary),
            tooltip: 'Atualizar relatórios',
            onPressed: _loadReports,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final colors = AppTheme.of(context);

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryGold),
      );
    }

    if (_reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 80, color: colors.textHint),
            const SizedBox(height: 16),
            Text(
              'Nenhum relatório salvo',
              style: TextStyle(color: colors.textTertiary, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Finalize uma partida para ver aqui',
              style: TextStyle(color: colors.textHint, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReports,
      color: AppTheme.primaryGold,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _reports.length,
        itemBuilder: (context, index) {
          final report = _reports[index];
          return Dismissible(
            key: Key(report.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppTheme.error,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (_) async {
              return await _showDeleteSwipeDialog(report);
            },
            onDismissed: (_) async {
              await ReportStorageService.deleteMatch(report.id);
              _loadReports();
            },
            child: _buildReportCard(report),
          );
        },
      ),
    );
  }

  Future<bool?> _showDeleteSwipeDialog(MatchReport report) {
    final colors = AppTheme.read(context);
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.dialogBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Excluir Relatório?', style: TextStyle(color: colors.text)),
        content: Text('Deseja excluir "${report.name}"?', style: TextStyle(color: colors.textSecondary)),
        actions: [
          TextButton(child: Text('CANCELAR', style: TextStyle(color: colors.cancelButton)), onPressed: () => Navigator.pop(ctx, false)),
          TextButton(
            child: const Text('EXCLUIR', style: TextStyle(color: AppTheme.error)),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(MatchReport report) {
    final colors = AppTheme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showReportDetails(report),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.description,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.name,
                        style: TextStyle(
                          color: colors.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        report.formattedDate,
                        style: TextStyle(
                          color: colors.textTertiary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${report.totalReports} PDF${report.totalReports != 1 ? 's' : ''}',
                    style: TextStyle(color: colors.textSecondary, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: colors.textHint),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showReportDetails(MatchReport report) {
    final colors = AppTheme.read(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.dialogBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _buildReportDetailsSheet(report),
    );
  }

  Widget _buildReportDetailsSheet(MatchReport report) {
    final colors = AppTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  report.name,
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppTheme.error),
                tooltip: 'Excluir relatório',
                onPressed: () => _confirmDelete(report),
              ),
            ],
          ),
          Text(
            report.formattedDate,
            style: TextStyle(color: colors.textTertiary),
          ),
          const SizedBox(height: 24),
          Text(
            'Relatórios disponíveis:',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          ...report.setReportPaths.asMap().entries.map((entry) {
            final index = entry.key;
            final path = entry.value;
            return _buildPdfItem(
              'Set ${index + 1}',
              path,
              Icons.sports_volleyball,
            );
          }),
          if (report.finalReportPath != null)
            _buildPdfItem(
              'Relatório Final',
              report.finalReportPath!,
              Icons.emoji_events,
              isHighlighted: true,
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPdfItem(
    String title,
    String path,
    IconData icon, {
    bool isHighlighted = false,
  }) {
    final colors = AppTheme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppTheme.primaryGold.withValues(alpha: 0.1)
            : colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: isHighlighted
            ? Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.3))
            : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isHighlighted ? AppTheme.primaryGold : colors.textSecondary,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isHighlighted ? AppTheme.primaryGold : colors.text,
            fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.share, color: colors.textHint, size: 20),
              tooltip: 'Compartilhar PDF',
              onPressed: () => _sharePdf(path),
            ),
            Icon(
              Icons.open_in_new,
              color: colors.textHint,
              size: 20,
            ),
          ],
        ),
        onTap: () => _openPdf(path),
      ),
    );
  }

  Future<void> _openPdf(String path) async {
    final exists = await ReportStorageService.fileExists(path);
    if (!mounted) return;
    if (!exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Arquivo não encontrado'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    await PdfService.openPdf(File(path));
  }

  Future<void> _sharePdf(String path) async {
    final exists = await ReportStorageService.fileExists(path);
    if (!mounted) return;
    if (!exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Arquivo não encontrado'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    await Share.shareXFiles(
      [XFile(path)],
      subject: 'Relatório ProVolei',
    );
  }

  void _confirmDelete(MatchReport report) {
    final colors = AppTheme.read(context);
    Navigator.pop(context); // Fecha o bottom sheet
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.dialogBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Excluir Partida?',
          style: TextStyle(color: colors.text),
        ),
        content: Text(
          'Deseja remover "${report.name}" da lista?\n\nOs arquivos PDF não serão apagados.',
          style: TextStyle(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCELAR', style: TextStyle(color: colors.cancelButton)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ReportStorageService.deleteMatch(report.id);
              _loadReports();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('EXCLUIR'),
          ),
        ],
      ),
    );
  }
}
