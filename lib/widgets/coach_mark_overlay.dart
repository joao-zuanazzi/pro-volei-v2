import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CoachMarkStep {
  final GlobalKey targetKey;
  final String title;
  final String body;

  const CoachMarkStep({
    required this.targetKey,
    required this.title,
    required this.body,
  });
}

class CoachMarkOverlay extends StatefulWidget {
  final List<CoachMarkStep> steps;
  final VoidCallback onComplete;

  const CoachMarkOverlay({
    super.key,
    required this.steps,
    required this.onComplete,
  });

  /// Insere o overlay na pilha e retorna o entry para controle externo.
  static OverlayEntry show({
    required BuildContext context,
    required List<CoachMarkStep> steps,
    required VoidCallback onComplete,
  }) {
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => CoachMarkOverlay(
        steps: steps,
        onComplete: () {
          entry.remove();
          onComplete();
        },
      ),
    );
    Overlay.of(context).insert(entry);
    return entry;
  }

  @override
  State<CoachMarkOverlay> createState() => _CoachMarkOverlayState();
}

class _CoachMarkOverlayState extends State<CoachMarkOverlay> {
  int _step = 0;
  Rect? _targetRect;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _computeRect());
  }

  void _computeRect() {
    if (!mounted) return;
    final key = widget.steps[_step].targetKey;
    final ctx = key.currentContext;
    if (ctx == null) {
      setState(() => _targetRect = null);
      return;
    }
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      setState(() => _targetRect = null);
      return;
    }
    final pos = box.localToGlobal(Offset.zero);
    setState(() => _targetRect = pos & box.size);
  }

  void _next() {
    if (_step < widget.steps.length - 1) {
      setState(() {
        _step++;
        _targetRect = null;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _computeRect());
    } else {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final rect = _targetRect;
    final isLast = _step == widget.steps.length - 1;
    final step = widget.steps[_step];

    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _HolePainter(rect: rect),
            size: size,
          ),
          if (rect != null)
            _buildPositionedCard(step, rect, size, isLast)
          else
            Center(child: _buildCard(step, size, isLast)),
        ],
      ),
    );
  }

  Widget _buildPositionedCard(
    CoachMarkStep step,
    Rect rect,
    Size size,
    bool isLast,
  ) {
    const gap = 12.0;
    const safeMargin = 8.0;

    final cardWidth = (size.width - 32).clamp(0.0, 480.0);
    final left = (size.width - cardWidth) / 2;

    final spaceBelow = size.height - rect.bottom - gap - safeMargin;
    final spaceAbove = rect.top - gap - safeMargin;
    final showBelow = spaceBelow >= spaceAbove;

    final maxHeight =
        (showBelow ? spaceBelow : spaceAbove).clamp(120.0, double.infinity);

    return Positioned(
      left: left,
      width: cardWidth,
      top: showBelow ? rect.bottom + gap : null,
      bottom: showBelow ? null : size.height - rect.top + gap,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(child: _buildCard(step, size, isLast)),
      ),
    );
  }

  Widget _buildCard(CoachMarkStep step, Size size, bool isLast) {
    final colors = AppTheme.of(context);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Container(
      padding: EdgeInsets.all(isLandscape ? 12 : 20),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryGold.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${_step + 1} de ${widget.steps.length}',
            style: TextStyle(
              color: colors.textHint,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.goldGradient.createShader(bounds),
            child: Text(
              step.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            step.body,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: widget.onComplete,
                child: Text(
                  'Pular tutorial',
                  style: TextStyle(color: colors.textHint, fontSize: 13),
                ),
              ),
              ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGold,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                child: Text(
                  isLast ? 'Entendi!' : 'Próximo',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HolePainter extends CustomPainter {
  final Rect? rect;

  const _HolePainter({this.rect});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, Paint());

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Colors.black.withValues(alpha: 0.78),
    );

    if (rect != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect!.inflate(6), const Radius.circular(12)),
        Paint()..blendMode = BlendMode.clear,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_HolePainter old) => old.rect != rect;
}
