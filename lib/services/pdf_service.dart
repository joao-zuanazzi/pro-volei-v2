import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../models/set_data.dart';
import '../models/team.dart';
import '../models/team_stats.dart';

/// Serviço para geração de PDFs
class PdfService {
  /// Gera PDF de um set específico
  static Future<File?> generateSetPdf({
    required SetData setData,
    required Team team1,
    required Team team2,
  }) async {
    final pdf = pw.Document();
    final stats1 = setData.getStats(0);
    final stats2 = setData.getStats(1);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          _buildHeader('RELATÓRIO DO SET ${setData.setNumber}'),
          pw.SizedBox(height: 30),
          _buildScoreSection(
            team1.name,
            team2.name,
            stats1.score,
            stats2.score,
          ),
          pw.SizedBox(height: 30),
          _buildStatsTable(team1.name, team2.name, stats1, stats2),
          pw.SizedBox(height: 40),
          _buildChart(stats1, stats2),
          pw.SizedBox(height: 20),
          _buildLegend(team1.name, team2.name),
        ],
      ),
    );

    return _saveAndOpenPdf(
      pdf,
      'set_${setData.setNumber}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  /// Gera PDF do jogo completo
  static Future<File?> generateMatchPdf({
    required List<SetData> sets,
    required Team team1,
    required Team team2,
    required TeamStats totalStats1,
    required TeamStats totalStats2,
    required int setsWon1,
    required int setsWon2,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          _buildHeader('RELATÓRIO DA PARTIDA'),
          pw.SizedBox(height: 20),
          _buildMatchResult(team1.name, team2.name, setsWon1, setsWon2),
          pw.SizedBox(height: 30),
          _buildStatsTable(
            team1.name,
            team2.name,
            totalStats1,
            totalStats2,
            showSets: true,
            sets1: setsWon1,
            sets2: setsWon2,
          ),
          pw.SizedBox(height: 40),
          _buildChart(totalStats1, totalStats2),
          pw.SizedBox(height: 20),
          _buildLegend(team1.name, team2.name),
          pw.SizedBox(height: 40),
          _buildSetsBreakdown(sets, team1.name, team2.name),
        ],
      ),
    );

    return _saveAndOpenPdf(
      pdf,
      'partida_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  // Componentes do PDF
  static pw.Widget _buildHeader(String title) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blueGrey800,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'PRO VOLEI',
            style: pw.TextStyle(
              fontSize: 14,
              color: PdfColors.amber,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 24,
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildScoreSection(
    String team1,
    String team2,
    int score1,
    int score2,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
      children: [
        _buildTeamScore(team1, score1, PdfColors.blue700),
        pw.Text(
          'VS',
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        _buildTeamScore(team2, score2, PdfColors.amber700),
      ],
    );
  }

  static pw.Widget _buildTeamScore(String name, int score, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            name,
            style: pw.TextStyle(color: PdfColors.white, fontSize: 14),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            '$score',
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 48,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildMatchResult(
    String team1,
    String team2,
    int sets1,
    int sets2,
  ) {
    final winner = sets1 > sets2 ? team1 : (sets2 > sets1 ? team2 : 'Empate');
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.amber, width: 2),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'VENCEDOR',
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            winner,
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            '$sets1 x $sets2 sets',
            style: const pw.TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildStatsTable(
    String team1Name,
    String team2Name,
    TeamStats stats1,
    TeamStats stats2, {
    bool showSets = false,
    int sets1 = 0,
    int sets2 = 0,
  }) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
      },
      children: [
        _tableRow('', team1Name, team2Name, isHeader: true),
        _tableRow('Pontos Totais', '${stats1.score}', '${stats2.score}'),
        if (showSets) _tableRow('Sets Vencidos', '$sets1', '$sets2'),
        _tableRow('Saques', '${stats1.serves}', '${stats2.serves}'),
        _tableRow('Bloqueios', '${stats1.blocks}', '${stats2.blocks}'),
        _tableRow('Ataques', '${stats1.attacks}', '${stats2.attacks}'),
        _tableRow(
          'Erros Adversários',
          '${stats1.opponentErrors}',
          '${stats2.opponentErrors}',
        ),
      ],
    );
  }

  static pw.TableRow _tableRow(
    String label,
    String val1,
    String val2, {
    bool isHeader = false,
  }) {
    final style = isHeader
        ? pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white)
        : const pw.TextStyle();
    final bgColor = isHeader ? PdfColors.blueGrey700 : PdfColors.white;

    return pw.TableRow(
      decoration: pw.BoxDecoration(color: bgColor),
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(10),
          child: pw.Text(label, style: style),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(10),
          child: pw.Text(val1, style: style, textAlign: pw.TextAlign.center),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(10),
          child: pw.Text(val2, style: style, textAlign: pw.TextAlign.center),
        ),
      ],
    );
  }

  static pw.Widget _buildChart(TeamStats stats1, TeamStats stats2) {
    return pw.Chart(
      grid: pw.CartesianGrid(
        xAxis: pw.FixedAxis.fromStrings(
          ['Saque', 'Bloqueio', 'Ataque', 'Erro Adv'],
          marginStart: 30,
          marginEnd: 30,
        ),
        yAxis: pw.FixedAxis([0, 2, 4, 6, 8, 10, 15, 20, 25]),
      ),
      datasets: [
        pw.BarDataSet(
          color: PdfColors.blue700,
          width: 18,
          data: [
            pw.PointChartValue(-0.18, stats1.serves.toDouble()),
            pw.PointChartValue(0.82, stats1.blocks.toDouble()),
            pw.PointChartValue(1.82, stats1.attacks.toDouble()),
            pw.PointChartValue(2.82, stats1.opponentErrors.toDouble()),
          ],
        ),
        pw.BarDataSet(
          color: PdfColors.amber700,
          width: 18,
          data: [
            pw.PointChartValue(0.18, stats2.serves.toDouble()),
            pw.PointChartValue(1.18, stats2.blocks.toDouble()),
            pw.PointChartValue(2.18, stats2.attacks.toDouble()),
            pw.PointChartValue(3.18, stats2.opponentErrors.toDouble()),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildLegend(String team1, String team2) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        pw.Container(width: 16, height: 16, color: PdfColors.blue700),
        pw.SizedBox(width: 8),
        pw.Text(team1),
        pw.SizedBox(width: 30),
        pw.Container(width: 16, height: 16, color: PdfColors.amber700),
        pw.SizedBox(width: 8),
        pw.Text(team2),
      ],
    );
  }

  static pw.Widget _buildSetsBreakdown(
    List<SetData> sets,
    String team1,
    String team2,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'DETALHAMENTO POR SET',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400),
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'Set',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    team1,
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    team2,
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'Vencedor',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            ...sets.where((s) => s.isFinished).map((set) {
              final score1 = set.getScore(0);
              final score2 = set.getScore(1);
              final winner = set.winnerTeamIndex == 0
                  ? team1
                  : (set.winnerTeamIndex == 1 ? team2 : '-');
              return pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Set ${set.setNumber}'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('$score1', textAlign: pw.TextAlign.center),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('$score2', textAlign: pw.TextAlign.center),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(winner),
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  static Future<File?> _saveAndOpenPdf(pw.Document pdf, String filename) async {
    try {
      final directory =
          await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsBytes(await pdf.save());
      await OpenFile.open(file.path);
      return file;
    } catch (e) {
      print('Erro ao salvar PDF: $e');
      return null;
    }
  }
}
