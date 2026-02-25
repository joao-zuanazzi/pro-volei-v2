/// Tipos de ponto no vôlei
enum PointType {
  serve('Saque', '🏐'),
  block('Bloqueio', '🛡️'),
  attack('Ataque', '⚡'),
  opponentError('Erro do Adversário', '❌');

  const PointType(this.label, this.icon);

  final String label;
  final String icon;

  /// Detalhes disponíveis para este tipo de ponto
  List<PointDetail> get availableDetails {
    switch (this) {
      case PointType.serve:
        return [PointDetail.standing, PointDetail.jump];
      case PointType.block:
        return [PointDetail.p2, PointDetail.p3, PointDetail.p4];
      case PointType.attack:
        return [PointDetail.sideOut, PointDetail.counterAttack];
      case PointType.opponentError:
        return [PointDetail.serveError, PointDetail.otherError];
    }
  }
}

/// Detalhes específicos do ponto (complementos)
enum PointDetail {
  // Saque
  standing('Do solo'),
  jump('Em suspensão'),

  // Bloqueio
  p2('Na P2'),
  p3('Na P3'),
  p4('Na P4'),

  // Ataque
  sideOut('Side-out'),
  counterAttack('Contra-ataque'),

  // Erro do adversário
  serveError('Saque'),
  receptionError('Recepção'),
  settingError('Levantamento'),
  attackError('Ataque'),
  blockNetTouch('Bloqueio (rede)'),
  defenseError('Defesa'),
  otherError('Outros');

  const PointDetail(this.label);

  final String label;
}
