import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../main.dart' show AppColors;

class GameMemoryScreen extends StatefulWidget {
  final AppColors colors;
  const GameMemoryScreen({super.key, required this.colors});

  @override
  State<GameMemoryScreen> createState() => _GameMemoryScreenState();
}

class _GameMemoryScreenState extends State<GameMemoryScreen> {
  static const List<String> _letras = [
    'A', 'B', 'C', 'D', 'E', 'F',
  ];

  late List<String> _cartas;
  late List<bool> _virada;
  late List<bool> _encontrada;
  int? _primeira;
  bool _bloqueado = false;
  int _tentativas = 0;

  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  void _iniciar() {
    final pares = [..._letras, ..._letras]..shuffle();
    setState(() {
      _cartas = pares;
      _virada = List.filled(pares.length, false);
      _encontrada = List.filled(pares.length, false);
      _primeira = null;
      _bloqueado = false;
      _tentativas = 0;
    });
  }

  void _tocar(int index) {
    if (_bloqueado) return;
    if (_virada[index]) return;
    if (_encontrada[index]) return;

    setState(() => _virada[index] = true);

    if (_primeira == null) {
      _primeira = index;
    } else {
      final a = _primeira!;
      _primeira = null;
      _tentativas++;
      if (_cartas[a] == _cartas[index]) {
        setState(() {
          _encontrada[a] = true;
          _encontrada[index] = true;
        });
      } else {
        _bloqueado = true;
        Future.delayed(const Duration(milliseconds: 900), () {
          if (!mounted) return;
          setState(() {
            _virada[a] = false;
            _virada[index] = false;
            _bloqueado = false;
          });
        });
      }
    }
  }

  bool get _ganhou => _encontrada.every((e) => e);

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/back.svg',
              width: 20,
              height: 20,
              colorFilter:
                  ColorFilter.mode(colors.textMain, BlendMode.srcIn),
            ),
          ),
        ),
        title: Text(
          'Jogo da Memória',
          style: TextStyle(
            fontFamily: 'ComicSansMS',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: colors.textMain,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '$_tentativas tentativas',
                style:
                    TextStyle(fontSize: 13, color: colors.textMuted),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_ganhou)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.symmetric(
                  vertical: 14, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.greenShadow,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '🎉 Parabéns! $_tentativas tentativas',
                    style: const TextStyle(
                      fontFamily: 'ComicSansMS',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: _iniciar,
                    child: const Text(
                      'Jogar de novo',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _cartas.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  return _Carta(
                    colors: colors,
                    letra: _cartas[index],
                    virada: _virada[index],
                    encontrada: _encontrada[index],
                    onTap: () => _tocar(index),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Carta extends StatelessWidget {
  final AppColors colors;
  final String letra;
  final bool virada;
  final bool encontrada;
  final VoidCallback onTap;

  const _Carta({
    required this.colors,
    required this.letra,
    required this.virada,
    required this.encontrada,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final revealed = virada || encontrada;
    final bg = encontrada
        ? AppColors.green
        : revealed
            ? colors.bgCardNeutral
            : colors.c2Bg;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: encontrada
                  ? AppColors.greenShadow
                  : colors.divider,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: revealed ? 1.0 : 0.0,
            child: Text(
              letra,
              style: TextStyle(
                fontFamily: 'ComicSansMS',
                fontWeight: FontWeight.w700,
                fontSize: 28,
                color: encontrada ? Colors.white : colors.textMain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}