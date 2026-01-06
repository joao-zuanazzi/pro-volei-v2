import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/match_report.dart';

/// Serviço para gerenciar armazenamento de relatórios
class ReportStorageService {
  static const String _reportsFileName = 'match_reports.json';
  static List<MatchReport> _cachedReports = [];
  static MatchReport? _currentMatch;

  /// Inicializa ou retorna a partida atual
  static Future<MatchReport> getCurrentMatch(String matchName) async {
    if (_currentMatch != null && _currentMatch!.name == matchName) {
      return _currentMatch!;
    }

    _currentMatch = MatchReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: matchName,
      createdAt: DateTime.now(),
    );

    return _currentMatch!;
  }

  /// Registra um relatório de set
  static Future<void> addSetReport(String matchName, String filePath) async {
    final match = await getCurrentMatch(matchName);
    _currentMatch = match.addSetReport(filePath);
  }

  /// Registra o relatório final e salva a partida
  static Future<void> addFinalReport(String matchName, String filePath) async {
    final match = await getCurrentMatch(matchName);
    _currentMatch = match.withFinalReport(filePath);

    // Salva a partida completa
    await saveMatch(_currentMatch!);
    _currentMatch = null; // Reseta para próxima partida
  }

  /// Salva uma partida na lista
  static Future<void> saveMatch(MatchReport match) async {
    final reports = await loadAllReports();

    // Remove se já existir (update)
    reports.removeWhere((r) => r.id == match.id);
    reports.insert(0, match); // Adiciona no início

    await _saveReports(reports);
    _cachedReports = reports;
  }

  /// Carrega todos os relatórios salvos
  static Future<List<MatchReport>> loadAllReports() async {
    if (_cachedReports.isNotEmpty) {
      return _cachedReports;
    }

    try {
      final file = await _getReportsFile();
      if (!await file.exists()) {
        return [];
      }

      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents);
      _cachedReports = jsonList
          .map((j) => MatchReport.fromJson(j as Map<String, dynamic>))
          .toList();

      return _cachedReports;
    } catch (e) {
      print('Erro ao carregar relatórios: $e');
      return [];
    }
  }

  /// Remove uma partida
  static Future<void> deleteMatch(String matchId) async {
    final reports = await loadAllReports();
    reports.removeWhere((r) => r.id == matchId);
    await _saveReports(reports);
    _cachedReports = reports;
  }

  /// Força recarregar do disco
  static Future<List<MatchReport>> refreshReports() async {
    _cachedReports = [];
    return loadAllReports();
  }

  /// Salva a lista de relatórios
  static Future<void> _saveReports(List<MatchReport> reports) async {
    try {
      final file = await _getReportsFile();
      final jsonList = reports.map((r) => r.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
    } catch (e) {
      print('Erro ao salvar relatórios: $e');
    }
  }

  /// Obtém o arquivo de relatórios
  static Future<File> _getReportsFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_reportsFileName');
  }

  /// Verifica se um arquivo PDF existe
  static Future<bool> fileExists(String path) async {
    return File(path).exists();
  }
}
