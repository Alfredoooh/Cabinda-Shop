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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_letras.length, (index) {
            // Desfasamento por letra, criando o efeito de onda sequencial
            final atraso = index * 0.2;
            final progresso = (_controller.value - atraso) % 1.0;
            final pulso = progresso < 0.5
                ? Curves.easeOut.transform(progresso * 2)
                : Curves.easeIn.transform(1 - (progresso - 0.5) * 2);

            final escala = 0.85 + (pulso * 0.35);
            final corFundo = Color.lerp(
              widget.corMuted.withOpacity(0.15),
              verde,
              pulso,
            )!;
            final corTexto = Color.lerp(
              widget.corMuted,
              Colors.white,
              pulso,
            )!;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Transform.scale(
                scale: escala,
                child: Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: corFundo,
                    shape: BoxShape.circle,
                    boxShadow: pulso > 0.3
                        ? [
                            BoxShadow(
                              color: verde.withOpacity(pulso * 0.4),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    _letras[index],
                    style: TextStyle(
                      fontFamily: 'ComicSansMS',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
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