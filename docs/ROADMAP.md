# Roadmap — ProVolei v2

## 🔧 Pendências imediatas (antes de novas features)

### Tema Claro — Ajustes finos
O tema claro foi implementado mas ainda NÃO foi testado completamente no celular Android. Possíveis ajustes:
- [ ] Verificar se a logo escura (`logo_dark.png`) fica boa no tema claro no celular
- [ ] Testar todos os diálogos no tema claro (PDF gerado, Excluir equipe, Sair da partida, etc.)
- [ ] Ajustar cores se necessário para melhor contraste
- [ ] O `action_button.dart` (GradientButton, CircleActionButton) ainda usa algumas cores fixas (`Colors.white`) — verificar se ficam boas no tema claro (provavelmente sim, pois são botões com fundo colorido)

### Layout
- [ ] **Modo paisagem** — Quando a tela é pequena (landscape), o layout tem problemas conhecidos de espaçamento entre placar e cards
- [ ] **Modo paisagem** — Ao fazer swap de times, as cores no placar de cima e nos labels "Equipe 1/2" nas tabs podem não acompanhar corretamente

### Build Android
- [ ] Configurar JAVA_HOME corretamente (Android Studio foi reinstalado)
- [ ] Testar `flutter run` no celular Android

---

## 🚀 Próximas features (Roadmap do TCC)

### Fase 3 — Tema Claro ✅ (implementado, falta polir)
- Toggle na home screen
- Todas as telas e widgets com cores dinâmicas

### Fase 4 — Dashboard de Estatísticas ✅
- [x] Tela de dashboard com gráficos (`DashboardScreen`)
- [x] Estatísticas por equipe (total de pontos por tipo)
- [x] Comparativo histórico entre partidas (evolução por equipe)
- [x] Gráficos visuais (linha + barras com `fl_chart`)
- [x] Snapshot estatístico persistido junto do `MatchReport` (`MatchStatsSnapshot`)
- [x] Top jogadores por pontos (saque + ataque + bloqueio agregados)
- [x] Desempenho por adversário (V/E/D, pontos pró/contra)
- [x] "Quem mais erra" — fluxo de seleção de jogador adversário restaurado no `TeamPanel` (estava desativado), `PlayerStatsSnapshot` ganhou `errosCometidos`
- [x] Sparklines empilhados com escala individual, linha de média, contexto "vs partida anterior" e aviso de amostra pequena (heurísticas de Nielsen)

### Fase 5 — Melhorias de UX (auditoria de design completa)

Auditoria realizada na sessão de 2026-05-09 com base nas heurísticas de Nielsen.
Itens marcados ✅ já foram implementados no commit dessa sessão. Os demais
estão pendentes e priorizados para futuras iterações.

#### Críticos — implementados ✅
- [x] **Remover long-press de pontos aleatórios no timer** (`match_screen.dart`) — feature de debug exposta para usuário final
- [x] **Resolver fonte Poppins** — referências removidas do `app_theme.dart` (fonte não estava carregada). Decisão: usar fonte do sistema. Alternativa futura: incluir Poppins em `assets/fonts/` para identidade tipográfica própria.
- [x] **Hierarquizar botões do `match_screen` rodapé** — removido "SAIR" do rodapé (passou para ícone X no header), "FINALIZAR JOGO" ganhou flex 3 + gold gradient, "FINALIZAR SET" ficou flex 2 + azul.
- [x] **Trocar ícone "voltar" do `match_screen` por X (close)** — `arrow_back_ios` sugere navegação simples; ação real é abrir diálogo modal de saída. Adicionado tooltip "Sair da partida".

#### Importantes — pendentes 🟡
- [ ] **Home: cards clicáveis em vez de TextButton planos** para "Equipes / Relatórios / Dashboard". Hoje os 3 secundários parecem irrelevantes no menu.
- [ ] **Renomear "EXCLUIR" → "DESFAZER ÚLTIMO"** com ícone `undo` no `team_panel.dart`. Texto atual é ambíguo (sugere apagar a seleção atual, na prática remove o último ponto).
- [ ] **Tornar o "VS" (swap teams) descobrível** — hoje é um ícone `swap_horiz` size 14 dentro do placar. Trocar por botão dedicado com label "Trocar lados" ou aumentar bem a área de toque + tooltip.
- [ ] **Aumentar áreas de toque** (edit nome da partida no header com 12px, ícones 12-14px no placar). Material recomenda mínimo 48×48.
- [ ] **Modo claro: trocar branco-puro por off-white nos cards** (`#FFFFFF` → `#FAFBFC`) e suavizar borders (`#D0D5DD` → `#E1E5EA`). Hoje os cards "flutuam" sem definição.
- [ ] **Contraste WCAG AA no modo claro**: `textTertiary` `#7A7A94` sobre branco dá ratio ~4:1 (abaixo de 4.5:1 para texto < 18px). Escurecer para `#5C5C75`.
- [ ] **Padronizar AppBar real em todas as telas**. Hoje `team_list` e `team_editor` usam `AppBar`; `home`, `match`, `reports`, `dashboard` montam header manualmente em Stack/Column.
- [ ] **Escala de espaçamento múltiplos de 4** (4 / 8 / 12 / 16 / 24 / 32). Hoje há padding/margin ad-hoc com 4, 6, 8, 10, 12, 16, 20, 24, 32.
- [ ] **Haptic feedback ao registrar ponto** (`HapticFeedback.lightImpact()` em `addPoint`). Para anotação rápida ao vivo, vibração curta confirma o tap sem precisar olhar a tela.
- [ ] **Animação correta do score**: hoje o `TweenAnimationBuilder` do `score_bar.dart` reanima de 0 → N a cada rebuild. Animar só do valor anterior → novo valor.
- [ ] **SetSelector progressivo**: mostrar set atual + 1 próximo, com botão "+ adicionar" se chegar no 5º. Hoje sempre mostra 5 sets e confunde.
- [ ] **Tooltips em todos os ícone-only buttons** (toggle de tema, edit, delete, share, refresh, etc.) — usuário novo não sabe o que cada um faz.
- [ ] **Onboarding/tutorial primeiro uso** — overlay simples na primeira partida explicando o fluxo Tipo → Detalhe → Jogador → Salvar.

#### Polimentos — pendentes 🟢
- [ ] **Suavizar `error` no modo claro**: `#E53935` → `#D32F2F` (Material 600, mais maduro em fundos claros).
- [ ] **Escala tipográfica fixa**: hoje o app usa 16+ tamanhos diferentes (8, 10, 11, 12, 13, 14, 15, 16, 18, 20, 22, 24, 26, 28, 36, 48, 56). Definir caption(11), body(13), body-strong(14), title(16), heading(20), display(28).
- [ ] **`letterSpacing` consistente**: hoje varia entre 0.3, 0.5, 1, 2 sem padrão.
- [ ] **Transições fade entre rotas** em vez do slide padrão do Material — `PageRouteBuilder` com `FadeTransition`.
- [ ] **Substituir snackbar "Ponto registrado"** por animação curta no placar (flash do número). Em uma partida com 50+ pontos por set, o snackbar a cada ponto vira ruído.
- [ ] **Suporte a text scaling do sistema** — hoje `fontSize` é hardcoded; usuários com fonte ampliada no Android não veem mudança.

#### Sugeridos no roadmap original mas cobertos pelos itens acima
- ~~Animações mais suaves nas transições de tela~~ (item de polimento)
- ~~Feedback tátil ao registrar pontos~~ (item importante: haptic feedback)
- ~~Onboarding/tutorial primeiro uso~~ (item importante)
- ~~Undo mais visível~~ (item importante: renomear EXCLUIR → DESFAZER ÚLTIMO)

### Fase 6 — Exportação e Compartilhamento avançado
- [ ] Exportar dados em CSV/Excel
- [ ] Histórico de partidas com busca/filtro
- [ ] Backup/restore de dados

---

## 📋 Backlog de bugs/melhorias conhecidos

| Prioridade | Item | Arquivo |
|------------|------|---------|
| Média | `_buildPlayerErrorsTable` não utilizado no pdf_service | pdf_service.dart:374 |
| Média | `_buildChartSection` não utilizado no pdf_service | pdf_service.dart:1052 |
| Baixa | `invalid_null_aware_operator` warnings no pdf_service | pdf_service.dart:412,685 |
| Baixa | `avoid_print` em pdf_service e report_storage_service | Vários |
| Info | `use_build_context_synchronously` em reports_screen | reports_screen.dart:403 |
