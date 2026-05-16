import 'package:flutter/material.dart';
import '../services/onboarding_service.dart';
import '../theme/app_theme.dart';
import '../widgets/action_button.dart';
import 'home_screen.dart';

class _OnboardingPage {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;

  const _OnboardingPage({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPage(
      icon: Icons.sports_volleyball,
      iconColor: AppTheme.primaryGold,
      title: 'Bem-vindo ao ProVolei',
      body:
          'Seu assistente de estatísticas de vôlei em tempo real. Este guia rápido vai te apresentar todas as funcionalidades do aplicativo.',
    ),
    _OnboardingPage(
      icon: Icons.home_rounded,
      iconColor: Color(0xFF4FC3F7),
      title: 'Tela Inicial',
      body:
          'A home possui 4 acessos principais:\n\n'
          '• Iniciar Partida — registre pontos ao vivo\n'
          '• Equipes — gerencie times e jogadores\n'
          '• Relatórios — acesse PDFs das partidas\n'
          '• Estatísticas — gráficos e rankings',
    ),
    _OnboardingPage(
      icon: Icons.people_rounded,
      iconColor: Color(0xFF81C784),
      title: 'Cadastrando Equipes',
      body:
          'Antes da primeira partida, crie suas equipes. Defina o nome, adicione os jogadores e o número de cada um. Os times ficam salvos e podem ser reutilizados em qualquer partida.',
    ),
    _OnboardingPage(
      icon: Icons.play_circle_rounded,
      iconColor: AppTheme.primaryGold,
      title: 'Iniciando uma Partida',
      body:
          'Em "Iniciar Partida", selecione as duas equipes e toque em Iniciar — o placar ao vivo, o cronômetro e os painéis de registro aparecem em tempo real.',
    ),
    _OnboardingPage(
      icon: Icons.touch_app_rounded,
      iconColor: Color(0xFFFFB74D),
      title: 'Registrando Pontos',
      body:
          'Para cada ação em quadra, siga o fluxo no painel da equipe:\n\n'
          '1. Tipo — Saque, Ataque, Bloqueio ou Erro\n'
          '2. Detalhe — informações da jogada\n'
          '3. Jogador — quem realizou a ação\n'
          '4. Confirme tocando em Salvar',
    ),
    _OnboardingPage(
      icon: Icons.bar_chart_rounded,
      iconColor: Color(0xFFCE93D8),
      title: 'Relatórios e Estatísticas',
      body:
          'Ao finalizar a partida, PDFs são gerados por set e como relatório final. No Dashboard você acessa gráficos de desempenho e o ranking dos jogadores.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    await OnboardingService.markWelcomeDone();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _complete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          decoration:
              BoxDecoration(gradient: AppTheme.of(context).backgroundGradient),
          child: SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (_, i) => _buildSlide(_pages[i]),
                  ),
                ),
                _buildDots(),
                const SizedBox(height: 16),
                _buildButton(),
                SizedBox(height: isLandscape ? 8 : 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final colors = AppTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 64),
          if (_currentPage > 0)
            TextButton(
              onPressed: _complete,
              child: Text(
                'Pular',
                style: TextStyle(color: colors.textTertiary),
              ),
            )
          else
            const SizedBox(width: 64),
        ],
      ),
    );
  }

  Widget _buildSlide(_OnboardingPage page) {
    final colors = AppTheme.of(context);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (isLandscape) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: page.iconColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(page.icon, size: 48, color: page.iconColor),
                ),
                const SizedBox(width: 28),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              AppTheme.goldGradient.createShader(bounds),
                          child: Text(
                            page.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          page.body,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 13,
                            height: 1.55,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Layout portrait
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(page.icon, size: 60, color: page.iconColor),
          ),
          const SizedBox(height: 36),
          ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.goldGradient.createShader(bounds),
            child: Text(
              page.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            page.body,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 15,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDots() {
    final colors = AppTheme.of(context);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isLandscape ? 8 : 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_pages.length, (i) {
          final isActive = i == _currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? AppTheme.primaryGold : colors.textHint,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildButton() {
    final isLast = _currentPage == _pages.length - 1;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SizedBox(
            width: double.infinity,
            child: GradientButton(
              text: isLast ? 'COMEÇAR!' : 'PRÓXIMO',
              icon: isLast ? Icons.check : Icons.arrow_forward,
              gradient: AppTheme.primaryGradient,
              onPressed: _next,
            ),
          ),
        ),
      ),
    );
  }
}
