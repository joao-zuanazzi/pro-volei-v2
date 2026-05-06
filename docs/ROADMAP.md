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

### Fase 4 — Dashboard de Estatísticas
- [ ] Tela de dashboard com gráficos
- [ ] Estatísticas por equipe (total de pontos por tipo)
- [ ] Estatísticas por jogador (quem mais pontua, quem mais erra)
- [ ] Comparativo entre equipes
- [ ] Gráficos visuais (barras, pizza) — considerar pacote `fl_chart`

### Fase 5 — Melhorias de UX
- [ ] Animações mais suaves nas transições de tela
- [ ] Feedback tátil (vibração) ao registrar pontos
- [ ] Onboarding/tutorial para primeiro uso
- [ ] Undo mais visível (atualmente apenas "EXCLUIR" remove último ponto)

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
