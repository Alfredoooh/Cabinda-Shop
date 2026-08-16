import 'package:flutter/material.dart';

class AbcLoader extends StatefulWidget {
  final Color corMuted;

  const AbcLoader({super.key, this.corMuted = const Color(0xFFA08868)});

  @override
  State<AbcLoader> createState() => _AbcLoaderState();
}

class _AbcLoaderState extends State<AbcLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const List<String> _letras = ['A', 'B', 'C', 'D'];
  static const Color verde = Color(0xFF58CC02);

  static const double _janela = 0.35;
  static const double _atraso = 0.20;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _pulso(int index, double t) {
    final inicio = index * _atraso;
    final local = ((t - inicio) % 1.0 + 1.0) % 1.0;
    if (local > _janela) return 0.0;
    final norm = local / _janela;
    return norm < 0.5
        ? Curves.easeOut.transform(norm * 2)
        : Curves.easeIn.transform(1.0 - (norm - 0.5) * 2);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_letras.length, (index) {
            final p = _pulso(index, _controller.value);
            final escala = 0.80 + p * 0.40;
            final corFundo = Color.lerp(
              widget.corMuted.withOpacity(0.12),
              verde,
              p,
            )!;
            final corTexto = Color.lerp(
              widget.corMuted,
              Colors.white,
              p,
            )!;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: escala,
                child: Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: corFundo,
                    shape: BoxShape.circle,
                    boxShadow: p > 0.2
                        ? [
                            BoxShadow(
                              color: verde.withOpacity(p * 0.35),
                              blurRadius: 8,
                              spreadRadius: 0,
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    _letras[index],
                    style: TextStyle(
                      fontFamily: 'ComicSansMS',
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: corTexto,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}