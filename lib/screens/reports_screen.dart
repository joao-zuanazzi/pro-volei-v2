import 'dart:io';
import 'package:flutter/material.dart';
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
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
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: _loadReports,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
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
            Icon(Icons.folder_open, size: 80, color: Colors.white24),
            const SizedBox(height: 16),
            const Text(
              'Nenhum relatório salvo',
              style: TextStyle(color: Colors.white54, fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'Finalize uma partida para ver aqui',
              style: TextStyle(color: Colors.white38, fontSize: 14),
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
          return _buildReportCard(report);
        },
      ),
    );
  }

  Widget _buildReportCard(MatchReport report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        report.formattedDate,
                        style: const TextStyle(
                          color: Colors.white54,
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
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${report.totalReports} PDF${report.totalReports != 1 ? 's' : ''}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.white38),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showReportDetails(MatchReport report) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _buildReportDetailsSheet(report),
    );
  }

  Widget _buildReportDetailsSheet(MatchReport report) {
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _confirmDelete(report),
              ),
            ],
          ),
          Text(
            report.formattedDate,
            style: const TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 24),
          const Text(
            'Relatórios disponíveis:',
            style: TextStyle(
              color: Colors.white70,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppTheme.primaryGold.withValues(alpha: 0.1)
            : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: isHighlighted
            ? Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.3))
            : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isHighlighted ? AppTheme.primaryGold : Colors.white70,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isHighlighted ? AppTheme.primaryGold : Colors.white,
            fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        trailing: const Icon(
          Icons.open_in_new,
          color: Colors.white38,
          size: 20,
        ),
        onTap: () => _openPdf(path),
      ),
    );
  }

  Future<void> _openPdf(String path) async {
    final exists = await ReportStorageService.fileExists(path);
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

  void _confirmDelete(MatchReport report) {
    Navigator.pop(context); // Fecha o bottom sheet
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Excluir Partida?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Deseja remover "${report.name}" da lista?\n\nOs arquivos PDF não serão apagados.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
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
