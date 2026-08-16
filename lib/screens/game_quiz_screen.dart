import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../main.dart' show AppColors;

class GameQuizScreen extends StatefulWidget {
  final AppColors colors;
  const GameQuizScreen({super.key, required this.colors});

  @override
  State<GameQuizScreen> createState() => _GameQuizScreenState();
}

class _GameQuizScreenState extends State<GameQuizScreen> {
  static const List<String> _alfabeto = [
    'A','B','C','D','E','F','G','H','I','J','K','L','M',
    'N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
  ];

  late String _pergunta;
  late List<String> _opcoes;
  int? _selecionada;
  int _corretas = 0;
  int _total = 0;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _novaRonda();
  }

  void _novaRonda() {
    final correctIndex = _random.nextInt(_alfabeto.length);
    final correct = _alfabeto[correctIndex];
    final erradas = (_alfabeto.toList()..remove(correct))..shuffle();
    final opcoes = [correct, erradas[0], erradas[1], erradas[2]]..shuffle();
    setState(() {
      _pergunta = correct;
      _opcoes = opcoes;
      _selecionada = null;
    });
  }

  void _responder(int index) {
    if (_selecionada != null) return;
    final acertou = _opcoes[index] == _pergunta;
    setState(() {
      _selecionada = index;
      _total++;
      if (acertou) _corretas++;
    });
    Future.delayed(const Duration(milliseconds: 900), _novaRonda);
  }

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
          'Quiz do Alfabeto',
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
                '$_corretas / $_total',
                style: TextStyle(
                  fontFamily: 'ComicSansMS',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.green,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          children: [
            // Letra a adivinhar
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: colors.c1Bg,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(color: colors.c1Fg.withOpacity(0.20),
                      offset: const Offset(0, 6)),
                ],
              ),
              child: Center(
                child: Text(
                  _pergunta,
                  style: TextStyle(
                    fontFamily: 'ComicSansMS',
                    fontWeight: FontWeight.w700,
                    fontSize: 72,
                    color: colors.c1Fg,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Qual é esta letra?',
              style: TextStyle(
                fontFamily: 'ComicSansMS',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: colors.textMuted,
              ),
            ),
            const SizedBox(height: 32),
            // Opções
            ...List.generate(_opcoes.length, (index) {
              final opcao = _opcoes[index];
              final acertou = _selecionada != null &&
                  opcao == _pergunta;
              final errou = _selecionada == index &&
                  opcao != _pergunta;

              Color bg = colors.bgCardNeutral;
              Color textColor = colors.textMain;
              Color shadow = colors.divider;

              if (acertou) {
                bg = AppColors.green;
                textColor = Colors.white;
                shadow = AppColors.greenShadow;
              } else if (errou) {
                bg = const Color(0xFFFF4B4B);
                textColor = Colors.white;
                shadow = const Color(0xFFCC0000);
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => _responder(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: shadow,
                            offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Text(
                      opcao,
                      style: TextStyle(
                        fontFamily: 'ComicSansMS',
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}