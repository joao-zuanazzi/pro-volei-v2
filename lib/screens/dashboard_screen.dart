import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/match_report.dart';
import '../models/match_stats_snapshot.dart';
import '../services/report_storage_service.dart';
import '../theme/app_theme.dart';

/// Dashboard de Histórico — gráficos com a evolução das equipes ao longo
/// de várias partidas (aproveitamento de saque, ataque, bloqueio e taxa de erro).
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<MatchReport> _reports = [];
  bool _isLoading = true;
  String? _selectedTeam;

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
      // Default: primeira equipe encontrada nas partidas com stats
      final equipes = _equipesDisponiveis();
      _selectedTeam = equipes.isNotEmpty ? equipes.first : null;
    });
  }

  /// Lista única de nomes de equipes presentes nos snapshots.
  List<String> _equipesDisponiveis() {
    final nomes = <String>{};
    for (final r in _reports) {
      if (r.stats == null) continue;
      nomes.add(r.stats!.team1.teamName);
      nomes.add(r.stats!.team2.teamName);
    }
    final lista = nomes.toList()..sort();
    return lista;
  }

  /// Retorna os snapshots da equipe selecionada, em ordem cronológica (mais antiga → mais recente).
  /// Cada item é um par (data da partida, snapshot da equipe naquele jogo).
  List<_PartidaEquipe> _historicoDaEquipe(String teamName) {
    final partidas = <_PartidaEquipe>[];
    for (final r in _reports) {
      final s = r.stats;
      if (s == null) continue;
      MatchTeamStatsSnapshot? minha;
      MatchTeamStatsSnapshot? adversaria;
      if (s.team1.teamName == teamName) {
        minha = s.team1;
        adversaria = s.team2;
      } else if (s.team2.teamName == teamName) {
        minha = s.team2;
        adversaria = s.team1;
      }
      if (minha != null && adversaria != null) {
        partidas.add(
          _PartidaEquipe(
            partida: r,
            equipe: minha,
            adversaria: adversaria,
          ),
        );
      }
    }
    partidas.sort((a, b) => a.partida.createdAt.compareTo(b.partida.createdAt));
    return partidas;
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
              Expanded(child: _buildBody()),
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
              'DASHBOARD',
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
            tooltip: 'Atualizar dashboard',
            onPressed: _loadReports,
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final colors = AppTheme.of(context);

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryGold),
      );
    }

    final equipes = _equipesDisponiveis();
    if (equipes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart, size: 80, color: colors.textHint),
              const SizedBox(height: 16),
              Text(
                'Sem dados para o dashboard',
                style: TextStyle(color: colors.textTertiary, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Finalize uma partida para começar a acompanhar a evolução das equipes.',
                style: TextStyle(color: colors.textHint, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final teamName = _selectedTeam ?? equipes.first;
    final historico = _historicoDaEquipe(teamName);

    return RefreshIndicator(
      onRefresh: _loadReports,
      color: AppTheme.primaryGold,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          _buildTeamSelector(equipes),
          const SizedBox(height: 16),
          _buildResumoCards(historico),
          const SizedBox(height: 20),
          _buildSecaoTitulo('Evolução por partida'),
          const SizedBox(height: 8),
          _buildEvolucaoChart(historico),
          const SizedBox(height: 20),
          _buildSecaoTitulo('Distribuição média de pontos'),
          const SizedBox(height: 8),
          _buildDistribuicaoChart(historico),
          const SizedBox(height: 20),
          _buildSecaoTitulo('Top jogadores (pontuação)'),
          const SizedBox(height: 8),
          _buildTopJogadores(historico),
          const SizedBox(height: 20),
          _buildSecaoTitulo('Quem mais erra'),
          const SizedBox(height: 8),
          _buildJogadoresMaisErram(historico),
          const SizedBox(height: 20),
          _buildSecaoTitulo('Desempenho por adversário'),
          const SizedBox(height: 8),
          _buildAdversarios(historico),
          const SizedBox(height: 20),
          _buildSecaoTitulo('Histórico de partidas'),
          const SizedBox(height: 8),
          ..._buildListaPartidas(historico),
        ],
      ),
    );
  }

  Widget _buildTeamSelector(List<String> equipes) {
    final colors = AppTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.groups, color: colors.textSecondary),
          const SizedBox(width: 12),
          Text(
            'Equipe:',
            style: TextStyle(color: colors.textSecondary, fontSize: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<String>(
              value: _selectedTeam ?? equipes.first,
              isExpanded: true,
              underline: const SizedBox(),
              dropdownColor: colors.dropdownColor,
              style: TextStyle(color: colors.text, fontSize: 15),
              items: equipes
                  .map(
                    (e) => DropdownMenuItem(value: e, child: Text(e)),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _selectedTeam = val),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumoCards(List<_PartidaEquipe> historico) {
    final totalPartidas = historico.length;
    final vitorias = historico.where((h) {
      return h.equipe.setsWon > h.adversaria.setsWon;
    }).length;
    final pctVitoria = totalPartidas == 0
        ? 0.0
        : (vitorias / totalPartidas) * 100;

    final mediaSaque = _media(historico, (h) => h.equipe.aproveitamentoSaque);
    final mediaErro = _media(historico, (h) => h.equipe.taxaErro);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.7,
      children: [
        _ResumoCard(
          label: 'Partidas',
          valor: totalPartidas.toString(),
          icone: Icons.sports_volleyball,
          cor: AppTheme.primaryBlue,
        ),
        _ResumoCard(
          label: '% Vitórias',
          valor: '${pctVitoria.toStringAsFixed(0)}%',
          icone: Icons.emoji_events,
          cor: AppTheme.primaryGold,
          subtitulo: '$vitorias de $totalPartidas',
        ),
        _ResumoCard(
          label: 'Saque (média)',
          valor: '${mediaSaque.toStringAsFixed(1)}%',
          icone: Icons.flash_on,
          cor: AppTheme.success,
        ),
        _ResumoCard(
          label: 'Erros (média)',
          valor: '${mediaErro.toStringAsFixed(1)}%',
          icone: Icons.warning_amber_rounded,
          cor: AppTheme.error,
        ),
      ],
    );
  }

  double _media(
    List<_PartidaEquipe> historico,
    double Function(_PartidaEquipe) extrator,
  ) {
    if (historico.isEmpty) return 0;
    final soma = historico.fold<double>(0, (acc, h) => acc + extrator(h));
    return soma / historico.length;
  }

  Widget _buildSecaoTitulo(String titulo) {
    final colors = AppTheme.of(context);
    return Text(
      titulo,
      style: TextStyle(
        color: colors.text,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  /// Sparklines empilhados — uma métrica por card, com sua própria escala.
  /// Esta abordagem evita os 3 problemas que apareciam ao plotar tudo junto:
  /// (1) saque e ataque ficavam sobrepostos por correlação natural;
  /// (2) outliers (ex.: 1 partida com 100% de erros) achatavam as outras
  /// séries no eixo Y; (3) misturar % de aproveitamento e % de taxa de
  /// erro na mesma escala confundia a leitura.
  Widget _buildEvolucaoChart(List<_PartidaEquipe> historico) {
    final colors = AppTheme.of(context);

    if (historico.isEmpty) {
      return _buildChartCard(
        height: 120,
        child: Center(
          child: Text(
            'Sem dados ainda',
            style: TextStyle(color: colors.textHint),
          ),
        ),
      );
    }

    final saques =
        historico.map((h) => h.equipe.aproveitamentoSaque).toList();
    final ataques =
        historico.map((h) => h.equipe.aproveitamentoAtaque).toList();
    final erros = historico.map((h) => h.equipe.taxaErro).toList();

    return Column(
      children: [
        if (historico.length < 4) _buildAvisoAmostraPequena(historico.length),
        _Sparkline(
          titulo: 'Aproveitamento de saque',
          subtitulo: '% dos pontos da equipe que vieram do saque',
          icone: Icons.flash_on,
          cor: AppTheme.success,
          valores: saques,
        ),
        const SizedBox(height: 10),
        _Sparkline(
          titulo: 'Aproveitamento de ataque',
          subtitulo: '% dos pontos da equipe que vieram do ataque',
          icone: Icons.sports_volleyball,
          cor: AppTheme.primaryGold,
          valores: ataques,
        ),
        const SizedBox(height: 10),
        _Sparkline(
          titulo: 'Erros cometidos',
          subtitulo: '% das jogadas em que a equipe errou',
          icone: Icons.warning_amber_rounded,
          cor: AppTheme.error,
          valores: erros,
          tendenciaInvertida: true,
        ),
      ],
    );
  }

  Widget _buildAvisoAmostraPequena(int n) {
    final colors = AppTheme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppTheme.warning, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              n == 1
                  ? 'Apenas 1 partida registrada. Tendências aparecem a partir da 2ª.'
                  : 'Amostra pequena ($n partidas). Quanto mais partidas, mais confiável a tendência.',
              style: TextStyle(color: colors.textSecondary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistribuicaoChart(List<_PartidaEquipe> historico) {
    final colors = AppTheme.of(context);

    if (historico.isEmpty) {
      return _buildChartCard(
        height: 120,
        child: Center(
          child: Text(
            'Sem dados ainda',
            style: TextStyle(color: colors.textHint),
          ),
        ),
      );
    }

    final mediaSaque = _media(historico, (h) => h.equipe.serves.toDouble());
    final mediaAtaque = _media(historico, (h) => h.equipe.attacks.toDouble());
    final mediaBloqueio = _media(historico, (h) => h.equipe.blocks.toDouble());
    final mediaErroAdv =
        _media(historico, (h) => h.equipe.opponentErrors.toDouble());

    final barras = [
      _BarraDist(
        label: 'Saque',
        valor: mediaSaque,
        cor: AppTheme.success,
      ),
      _BarraDist(
        label: 'Ataque',
        valor: mediaAtaque,
        cor: AppTheme.primaryGold,
      ),
      _BarraDist(
        label: 'Bloqueio',
        valor: mediaBloqueio,
        cor: AppTheme.primaryBlue,
      ),
      _BarraDist(
        label: 'Erro Adv.',
        valor: mediaErroAdv,
        cor: AppTheme.warning,
      ),
    ];

    final maxValor = barras
        .map((b) => b.valor)
        .fold<double>(0, (a, b) => a > b ? a : b);
    final teto = (maxValor < 5 ? 5.0 : (maxValor * 1.2));

    return _buildChartCard(
      height: 240,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 24, 16, 8),
        child: BarChart(
          BarChartData(
            maxY: teto,
            alignment: BarChartAlignment.spaceAround,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => FlLine(
                color: colors.border.withValues(alpha: 0.3),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  getTitlesWidget: (val, _) => Text(
                    val.toStringAsFixed(0),
                    style: TextStyle(color: colors.textHint, fontSize: 11),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (val, _) {
                    final i = val.toInt();
                    if (i < 0 || i >= barras.length) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        barras[i].label,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) =>
                    colors.dialogBackground.withValues(alpha: 0.95),
                getTooltipItem: (group, _, rod, __) {
                  return BarTooltipItem(
                    '${rod.toY.toStringAsFixed(1)} pts',
                    TextStyle(
                      color: rod.color ?? Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
            ),
            barGroups: List.generate(barras.length, (i) {
              final b = barras[i];
              return BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: b.valor,
                    color: b.cor,
                    width: 22,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildChartCard({required double height, required Widget child}) {
    final colors = AppTheme.of(context);
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
      ),
      child: child,
    );
  }

  /// Agrega pontos por jogador (por playerId) ao longo de todas as partidas filtradas
  /// e mostra os 5 maiores pontuadores em uma lista com barras proporcionais.
  Widget _buildTopJogadores(List<_PartidaEquipe> historico) {
    final colors = AppTheme.of(context);

    final agg = <String, _AggJogador>{};
    for (final h in historico) {
      for (final j in h.equipe.jogadores) {
        final acc = agg.putIfAbsent(
          j.playerId,
          () => _AggJogador(
            nome: j.playerName,
            numero: j.playerNumber,
          ),
        );
        acc.serves += j.serves;
        acc.blocks += j.blocks;
        acc.attacks += j.attacks;
        acc.erros += j.errosCometidos;
        acc.partidas++;
        // Mantém o nome/número mais recente caso tenha sido alterado.
        acc.nome = j.playerName;
        acc.numero = j.playerNumber;
      }
    }

    if (agg.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: colors.textHint, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Sem jogadores cadastrados nessas partidas.',
                style: TextStyle(color: colors.textHint, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    final ordenado = agg.values.toList()
      ..sort((a, b) => b.totalPontos.compareTo(a.totalPontos));
    final topN = ordenado.take(5).toList();
    final maxPontos = topN.first.totalPontos.toDouble();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: List.generate(topN.length, (i) {
          final j = topN[i];
          final fracao = maxPontos == 0 ? 0.0 : j.totalPontos / maxPontos;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: i == 0
                            ? AppTheme.primaryGold.withValues(alpha: 0.18)
                            : colors.surface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: i == 0
                              ? AppTheme.primaryGold
                              : colors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '#${j.numero} ${j.nome}',
                        style: TextStyle(
                          color: colors.text,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${j.totalPontos} pts',
                      style: TextStyle(
                        color: colors.text,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: fracao,
                    minHeight: 6,
                    backgroundColor: colors.surface,
                    valueColor: AlwaysStoppedAnimation(
                      i == 0 ? AppTheme.primaryGold : AppTheme.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Saque ${j.serves} · Ataque ${j.attacks} · Bloqueio ${j.blocks} · Erros ${j.erros} · ${j.partidas} ${j.partidas == 1 ? "partida" : "partidas"}',
                  style: TextStyle(
                    color: colors.textHint,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  /// Lista os 5 jogadores que mais cometeram erros, agregando os erros marcados
  /// pelo time adversário ao longo das partidas filtradas.
  Widget _buildJogadoresMaisErram(List<_PartidaEquipe> historico) {
    final colors = AppTheme.of(context);

    final agg = <String, _AggJogador>{};
    for (final h in historico) {
      for (final j in h.equipe.jogadores) {
        if (j.errosCometidos == 0) continue;
        final acc = agg.putIfAbsent(
          j.playerId,
          () => _AggJogador(nome: j.playerName, numero: j.playerNumber),
        );
        acc.erros += j.errosCometidos;
        acc.partidas++;
        acc.nome = j.playerName;
        acc.numero = j.playerNumber;
      }
    }

    if (agg.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline,
                color: AppTheme.success.withValues(alpha: 0.7), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Nenhum erro registrado por jogador nessas partidas.',
                style: TextStyle(color: colors.textHint, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    final ordenado = agg.values.toList()
      ..sort((a, b) => b.erros.compareTo(a.erros));
    final topN = ordenado.take(5).toList();
    final maxErros = topN.first.erros.toDouble();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: List.generate(topN.length, (i) {
          final j = topN[i];
          final fracao = maxErros == 0 ? 0.0 : j.erros / maxErros;
          final mediaPorPartida = j.partidas == 0
              ? 0.0
              : j.erros / j.partidas;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: i == 0
                            ? AppTheme.error.withValues(alpha: 0.18)
                            : colors.surface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: i == 0
                              ? AppTheme.error
                              : colors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '#${j.numero} ${j.nome}',
                        style: TextStyle(
                          color: colors.text,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${j.erros} ${j.erros == 1 ? "erro" : "erros"}',
                      style: TextStyle(
                        color: colors.text,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: fracao,
                    minHeight: 6,
                    backgroundColor: colors.surface,
                    valueColor: AlwaysStoppedAnimation(AppTheme.error),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Média de ${mediaPorPartida.toStringAsFixed(1)} por partida · ${j.partidas} ${j.partidas == 1 ? "partida" : "partidas"}',
                  style: TextStyle(color: colors.textHint, fontSize: 11),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  /// Agrega resultados da equipe selecionada contra cada adversário enfrentado.
  Widget _buildAdversarios(List<_PartidaEquipe> historico) {
    final colors = AppTheme.of(context);

    final agg = <String, _AggAdversario>{};
    for (final h in historico) {
      final acc = agg.putIfAbsent(
        h.adversaria.teamName,
        () => _AggAdversario(nome: h.adversaria.teamName),
      );
      acc.partidas++;
      acc.pontosPro += h.equipe.score;
      acc.pontosContra += h.adversaria.score;
      if (h.equipe.setsWon > h.adversaria.setsWon) {
        acc.vitorias++;
      } else if (h.equipe.setsWon < h.adversaria.setsWon) {
        acc.derrotas++;
      } else {
        acc.empates++;
      }
    }

    if (agg.isEmpty) {
      return const SizedBox.shrink();
    }

    final ordenado = agg.values.toList()
      ..sort((a, b) => b.partidas.compareTo(a.partidas));

    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: List.generate(ordenado.length, (i) {
          final a = ordenado[i];
          final isLast = i == ordenado.length - 1;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(
                      bottom: BorderSide(
                        color: colors.border.withValues(alpha: 0.4),
                      ),
                    ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.nome,
                        style: TextStyle(
                          color: colors.text,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${a.partidas} ${a.partidas == 1 ? "partida" : "partidas"} · ${a.pontosPro} - ${a.pontosContra} pts',
                        style: TextStyle(
                          color: colors.textHint,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _PillResultado(
                  letra: 'V',
                  valor: a.vitorias,
                  cor: AppTheme.success,
                ),
                const SizedBox(width: 6),
                _PillResultado(
                  letra: 'E',
                  valor: a.empates,
                  cor: AppTheme.warning,
                ),
                const SizedBox(width: 6),
                _PillResultado(
                  letra: 'D',
                  valor: a.derrotas,
                  cor: AppTheme.error,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  List<Widget> _buildListaPartidas(List<_PartidaEquipe> historico) {
    final colors = AppTheme.of(context);
    if (historico.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border.withValues(alpha: 0.5)),
          ),
          child: Center(
            child: Text(
              'Sem partidas para esta equipe',
              style: TextStyle(color: colors.textHint),
            ),
          ),
        ),
      ];
    }

    // Ordem reversa: mais recentes primeiro na lista textual
    final ordenadas = historico.reversed.toList();
    return ordenadas.asMap().entries.map((entry) {
      final h = entry.value;
      final venceu = h.equipe.setsWon > h.adversaria.setsWon;
      final empate = h.equipe.setsWon == h.adversaria.setsWon;
      final corResultado = empate
          ? AppTheme.warning
          : (venceu ? AppTheme.success : AppTheme.error);
      final letraResultado = empate ? 'E' : (venceu ? 'V' : 'D');
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: corResultado.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: corResultado),
              ),
              child: Text(
                letraResultado,
                style: TextStyle(
                  color: corResultado,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    h.partida.name,
                    style: TextStyle(
                      color: colors.text,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${h.partida.formattedDate} · vs ${h.adversaria.teamName}',
                    style: TextStyle(
                      color: colors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${h.equipe.setsWon} x ${h.adversaria.setsWon}',
                  style: TextStyle(
                    color: colors.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${h.equipe.score} - ${h.adversaria.score} pts',
                  style: TextStyle(
                    color: colors.textHint,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }
}

class _PartidaEquipe {
  final MatchReport partida;
  final MatchTeamStatsSnapshot equipe;
  final MatchTeamStatsSnapshot adversaria;

  const _PartidaEquipe({
    required this.partida,
    required this.equipe,
    required this.adversaria,
  });
}

class _BarraDist {
  final String label;
  final double valor;
  final Color cor;
  const _BarraDist({
    required this.label,
    required this.valor,
    required this.cor,
  });
}

class _AggJogador {
  String nome;
  int numero;
  int serves = 0;
  int blocks = 0;
  int attacks = 0;
  int erros = 0;
  int partidas = 0;

  _AggJogador({required this.nome, required this.numero});

  int get totalPontos => serves + blocks + attacks;
}

class _AggAdversario {
  final String nome;
  int partidas = 0;
  int vitorias = 0;
  int derrotas = 0;
  int empates = 0;
  int pontosPro = 0;
  int pontosContra = 0;

  _AggAdversario({required this.nome});
}

class _PillResultado extends StatelessWidget {
  final String letra;
  final int valor;
  final Color cor;

  const _PillResultado({
    required this.letra,
    required this.valor,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      padding: const EdgeInsets.symmetric(vertical: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cor.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$valor',
            style: TextStyle(
              color: cor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            letra,
            style: TextStyle(
              color: cor,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Mini-gráfico (sparkline) com cabeçalho informativo, pensado para
/// usuários leigos (professores de Ed. Física): linguagem clara, contexto
/// explícito sobre a tendência ("vs partida anterior"), linha de média
/// como referência e estatísticas resumidas embaixo (média/mín/máx).
class _Sparkline extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final IconData icone;
  final Color cor;
  final List<double> valores;
  final bool tendenciaInvertida;

  const _Sparkline({
    required this.titulo,
    required this.subtitulo,
    required this.icone,
    required this.cor,
    required this.valores,
    this.tendenciaInvertida = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
    if (valores.isEmpty) return const SizedBox.shrink();

    final ultimo = valores.last;
    final anterior = valores.length >= 2 ? valores[valores.length - 2] : null;
    final delta = anterior == null ? null : ultimo - anterior;
    final media = valores.reduce((a, b) => a + b) / valores.length;
    final minVal = valores.reduce((a, b) => a < b ? a : b);
    final maxVal = valores.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: ícone + título + subtítulo explicativo
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icone, color: cor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        color: colors.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitulo,
                      style: TextStyle(
                        color: colors.textHint,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Body: valor atual à esquerda, mini-gráfico à direita
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 110,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'última partida',
                        style: TextStyle(
                          color: colors.textHint,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        '${ultimo.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: colors.text,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (delta != null)
                        _badgeTendencia(delta, colors)
                      else
                        Text(
                          'partida única',
                          style: TextStyle(
                            color: colors.textHint,
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 70,
                    child: valores.length == 1
                        ? const SizedBox.shrink()
                        : _miniLineChart(media),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Footer: média / mín / máx / nº partidas
          _buildEstatisticas(media, minVal, maxVal, colors),
        ],
      ),
    );
  }

  Widget _buildEstatisticas(
    double media,
    double minVal,
    double maxVal,
    AppThemeColors colors,
  ) {
    Widget item(String label, String valor) => Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(color: colors.textHint, fontSize: 10),
          ),
          const SizedBox(height: 2),
          Text(
            valor,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          item('média', '${media.toStringAsFixed(1)}%'),
          item('mín', '${minVal.toStringAsFixed(1)}%'),
          item('máx', '${maxVal.toStringAsFixed(1)}%'),
          item('partidas', '${valores.length}'),
        ],
      ),
    );
  }

  Widget _badgeTendencia(double delta, AppThemeColors colors) {
    // tendenciaInvertida: subir = ruim (vermelho), descer = bom (verde).
    final ehBom = tendenciaInvertida ? delta < -0.5 : delta > 0.5;
    final ehRuim = tendenciaInvertida ? delta > 0.5 : delta < -0.5;
    final Color corBadge;
    if (ehBom) {
      corBadge = AppTheme.success;
    } else if (ehRuim) {
      corBadge = AppTheme.error;
    } else {
      corBadge = colors.textHint;
    }
    // A seta sempre segue o sinal do delta, para casar visualmente com o gráfico.
    final IconData seta = delta > 0.5
        ? Icons.arrow_upward_rounded
        : (delta < -0.5 ? Icons.arrow_downward_rounded : Icons.remove_rounded);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: corBadge.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(seta, size: 12, color: corBadge),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              '${delta.abs().toStringAsFixed(1)} pp vs anterior',
              style: TextStyle(
                color: corBadge,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniLineChart(double media) {
    final spots = <FlSpot>[
      for (var i = 0; i < valores.length; i++)
        FlSpot(i.toDouble(), valores[i]),
    ];

    // Janela Y respira 15% acima/abaixo do range, com mínimo de 4 pp.
    var minVal = valores.reduce((a, b) => a < b ? a : b);
    var maxVal = valores.reduce((a, b) => a > b ? a : b);
    // Garante que a linha de média caiba dentro da janela.
    if (media < minVal) minVal = media;
    if (media > maxVal) maxVal = media;
    final spread = maxVal - minVal;
    final pad = spread < 8 ? 4.0 : spread * 0.15;
    var lo = (minVal - pad).clamp(0, 100).toDouble();
    var hi = (maxVal + pad).clamp(0, 100).toDouble();
    if (hi - lo < 4) {
      hi = (lo + 4).clamp(0, 100).toDouble();
    }

    return LineChart(
      LineChartData(
        minY: lo,
        maxY: hi,
        minX: -0.15,
        maxX: (valores.length - 1) + 0.15,
        clipData: const FlClipData.all(),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        // Linha pontilhada horizontal mostrando a média da série.
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: media,
              color: cor.withValues(alpha: 0.45),
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ],
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.2,
            preventCurveOverShooting: true,
            color: cor,
            barWidth: 2.5,
            dotData: FlDotData(
              show: true,
              checkToShowDot: (spot, _) => spot.x == spots.last.x,
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                radius: 3.5,
                color: cor,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  cor.withValues(alpha: 0.25),
                  cor.withValues(alpha: 0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumoCard extends StatelessWidget {
  final String label;
  final String valor;
  final IconData icone;
  final Color cor;
  final String? subtitulo;

  const _ResumoCard({
    required this.label,
    required this.valor,
    required this.icone,
    required this.cor,
    this.subtitulo,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icone, color: cor, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                valor,
                style: TextStyle(
                  color: colors.text,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitulo != null) ...[
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    subtitulo!,
                    style: TextStyle(
                      color: colors.textHint,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
