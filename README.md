# 🏐 ProVolei

Aplicativo **Flutter** para **professores de educação física e técnicos** registrarem e
analisarem partidas de vôlei **em tempo real**, durante a aula ou o jogo.

Projeto de **TCC** (Ciência da Computação, UFMS) com origem no **PET Computação**.
O app é avaliado por professores reais em aulas práticas, com um estudo de usabilidade
baseado nas **heurísticas de Nielsen** — por isso clareza e prevenção de erros vêm antes
de qualquer sofisticação técnica.


---

## O que o app faz

- **Registra pontos** por equipe, classificados por **tipo** (saque, ataque, bloqueio,
  erro do adversário), **detalhe** e **jogador**.
- **Gerencia equipes e atletas** (nome, número, cores).
- **Placar e cronômetro** ao vivo, por set e por partida.
- **Gera relatórios em PDF** (por set e da partida completa) e permite
  **compartilhá-los** (WhatsApp, e-mail, etc.).
- **Dashboard** com estatísticas históricas: evolução por partida, ranking de jogadores,
  desempenho por adversário (gráficos com `fl_chart`).
- **Salva e retoma** partidas interrompidas.
- **Tema claro e escuro** com alternância persistida.
- **Onboarding** no primeiro uso (tela de boas-vindas + tutorial contextual na partida).

---

## Stack

| Camada | Tecnologia |
|--------|-----------|
| Linguagem / UI | Dart + Flutter (Material 3) |
| Estado | Provider (`ChangeNotifier`) |
| Persistência | Hive (equipes), SharedPreferences (tema/onboarding/partida salva), JSON em arquivo (relatórios) |
| PDF | `pdf` + `printing` |
| Gráficos | `fl_chart` |
| Compartilhamento | `share_plus` |

Ambiente: **Flutter 3.38.4** / **Dart 3.10.3** (SDK `^3.9.2`). Plataforma-alvo principal:
**Android** (compila para Windows para testes rápidos).

---

## Rodando o projeto

```bash
flutter pub get          # instala dependências

flutter run -d windows   # teste rápido no desktop (itera UI sem celular)
flutter run              # no celular Android conectado (debug)
flutter run --release    # mais próximo do app final
```

> O tutorial de onboarding só aparece no 1º uso (flags em SharedPreferences). Para revê-lo,
> desinstale/reinstale o app ou limpe os dados nas configurações do Android.

### Build do APK (distribuição)

```bash
# Build otimizado: por arquitetura + ofuscado
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/debug-info
```

Saída em `build/app/outputs/flutter-apk/`. Para Androids modernos, distribua o
**`app-arm64-v8a-release.apk`**.

> ⚠️ O release atual usa a **chave de debug** para assinar — serve para instalação manual
> do APK, **não** para a Play Store. Para publicar, configure uma keystore própria e troque
> o `applicationId` (`com.example.pro_volei`) em `android/app/build.gradle.kts`.

### Ícones

```bash
flutter pub run flutter_launcher_icons   # regenera a partir de assets/app_icon_padded.png
```

---

## Estrutura

```
lib/
├── main.dart        # entry point: MultiProvider + MaterialApp + tema
├── models/          # dados puros (Team, Player, Point, SetData, MatchReport, snapshots…)
├── services/        # lógica + persistência (GameService, StorageService, PdfService…)
├── screens/         # telas (home, match, dashboard, reports, team_*, onboarding, startup)
├── widgets/         # componentes (team_panel, score_bar, set_selector, action_button, coach_mark)
└── theme/           # app_theme.dart (cores, ThemeData, AppThemeColors)

docs/
├── ROADMAP.md       # backlog priorizado (o que falta)
└── HISTORICO.md     # decisões de design e armadilhas já resolvidas
CLAUDE.md            # convenções de contribuição
```

### Arquitetura em uma frase

UI (`screens/` + `widgets/`) observa **serviços** (`services/`) via **Provider**, que
manipulam **modelos** (`models/`) imutáveis. Três providers globais: `GameService`
(estado da partida), `StorageService` (equipes/Hive), `ThemeProvider` (tema).

---

## Convenções (resumo — detalhes em `CLAUDE.md`)

- **Idioma:** todo código, comentários e UI em **português brasileiro**.
- **Tema:** cores sempre via `AppTheme.of(context)`. **Nunca** `Colors.white`/`black87`
  hardcoded para texto/superfície; **nunca** `context.watch<ThemeProvider>()` direto.
- **Provider:** `context.read<X>()` em handlers, `context.watch<X>()` só em `build()`.
- **Diálogos:** `AlertDialog` com `colors.dialogBackground` e bordas arredondadas (20);
  botões CANCELAR/NÃO em `colors.cancelButton`, destrutivos em `AppTheme.error`.
- **Commits:** Conventional Commits em PT-BR (`feat`, `fix`, `refactor`, `polish`, `chore`).
- Antes de commitar: `flutter analyze` e `dart format lib/`.

---

## Estado e roadmap

Funcionalidades principais implementadas (registro de partida, equipes, PDFs, dashboard,
tema claro/escuro, onboarding e uma rodada extensa de melhorias de UX por Nielsen).

Pendências em [`docs/ROADMAP.md`](docs/ROADMAP.md) — destaques: ajustes de **modo paisagem**
no `MatchScreen`, polimentos de tipografia/escala, faxina de warnings em `pdf_service.dart`
e a futura Fase 6 (exportar CSV/Excel, busca no histórico, backup/restore).

---

Desenvolvido por **João Victor Zuanazzi Lourenço** — TCC, Ciência da Computação (UFMS) ·
PET Computação UFMS (também: Caio Kwiatkoski Mendes).
Repositório: https://github.com/joao-zuanazzi/pro-volei-v2
```
