import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:audioplayers/audioplayers.dart';
import '../main.dart'
    show AppColors, SoundManager, kConsonants, kVowels, buildSyllable;

enum _QuizMode { letters, syllables }

class GameQuizScreen extends StatefulWidget {
  final AppColors colors;
  const GameQuizScreen({super.key, required this.colors});

  @override
  State<GameQuizScreen> createState() => _GameQuizScreenState();
}

class _GameQuizScreenState extends State<GameQuizScreen> {
  static const List<String> _alfabeto = [
    'a','b','c','d','e','f','g','h','i','j','k','l','m',
    'n','o','p','q','r','s','t','u','v','w','x','y','z',
  ];

  late List<String> _allSyllables;
  _QuizMode _mode = _QuizMode.letters;

  late String _perguntaSound;
  late List<String> _opcoes;
  int? _selecionada;
  int _corretas = 0;
  int _total = 0;
  int _streak = 0;

  Timer? _questionTimer;
  int _questionTime = 10;
  bool _timerEnabled = false;

  final AudioPlayer _feedbackPlayer = AudioPlayer();
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _allSyllables = _buildAllSyllables();
    _novaRonda();
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
    _feedbackPlayer.dispose();
    super.dispose();
  }

  List<String> _buildAllSyllables() {
    final syllables = <String>[];
    for (final consoante in kConsonants) {
      for (final vogal in kVowels) {
        syllables.add(buildSyllable(consoante, vogal, false).toLowerCase());
      }
    }
    return syllables;
  }

  Future<void> _playPressSound() async {
    try {
      await _feedbackPlayer.play(AssetSource('audio/pressing.wav'));
    } catch (e) {}
  }

  Future<void> _playFeedback(String asset) async {
    try {
      await _feedbackPlayer.play(AssetSource(asset));
    } catch (e) {}
  }

  Future<void> _playQuestionSound() async {
    try {
      await SoundManager.instance.play(_perguntaSound);
    } catch (e) {}
  }

  void _startQuestionTimer() {
    _questionTimer?.cancel();
    if (!_timerEnabled) return;
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _questionTime--);
      if (_questionTime <= 0) {
        _questionTimer?.cancel();
        if (_selecionada == null) {
          _responder(-1); // tempo esgotado
        }
      }
    });
  }

  void _novaRonda() {
    _questionTimer?.cancel();

    List<String> pool;
    String correct;

    if (_mode == _QuizMode.letters) {
      pool = _alfabeto;
      correct = pool[_random.nextInt(pool.length)];
    } else {
      pool = _allSyllables;
      correct = pool[_random.nextInt(pool.length)];
    }

    final erradas = (pool.toList()..remove(correct))..shuffle();
    final opcoes = [correct, erradas[0], erradas[1], erradas[2]]..shuffle();

    setState(() {
      _perguntaSound = correct;
      _opcoes = opcoes;
      _selecionada = null;
      _questionTime = 10;
    });

    _startQuestionTimer();
    _playQuestionSound();
  }

  void _responder(int index) {
    if (_selecionada != null) return;

    bool acertou;
    if (index == -1) {
      // Tempo esgotado
      acertou = false;
      setState(() {
        _selecionada = -1;
        _total++;
        _streak = 0;
      });
    } else {
      acertou = _opcoes[index] == _perguntaSound;
      setState(() {
        _selecionada = index;
        _total++;
        if (acertou) {
          _corretas++;
          _streak++;
        } else {
          _streak = 0;
        }
      });
    }

    if (acertou) {
      _playFeedback('audio/correct.wav');
    } else {
      _playFeedback('audio/wrong.wav');
    }

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _novaRonda();
    });
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
          _mode == _QuizMode.letters
              ? 'Quiz do Alfabeto'
              : 'Quiz de Sílabas',
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$_corretas / $_total',
                    style: TextStyle(
                      fontFamily: 'ComicSansMS',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.green,
                    ),
                  ),
                  if (_streak > 1)
                    Text(
                      '🔥 $_streak',
                      style: const TextStyle(
                        fontFamily: 'ComicSansMS',
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Colors.orange,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          children: [
            // Seletor de modo
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colors.bgCardNeutral,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _ModeButton(
                    colors: colors,
                    label: 'Letras',
                    active: _mode == _QuizMode.letters,
                    onTap: () {
                      _playPressSound();
                      setState(() => _mode = _QuizMode.letters);
                      _novaRonda();
                    },
                  ),
                  const SizedBox(width: 4),
                  _ModeButton(
                    colors: colors,
                    label: 'Sílabas',
                    active: _mode == _QuizMode.syllables,
                    onTap: () {
                      _playPressSound();
                      setState(() => _mode = _QuizMode.syllables);
                      _novaRonda();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Interruptor do temporizador
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Temporizador',
                  style: TextStyle(fontSize: 14, color: colors.textMuted),
                ),
                Switch(
                  value: _timerEnabled,
                  onChanged: (val) {
                    _playPressSound();
                    setState(() => _timerEnabled = val);
                    if (val) {
                      _startQuestionTimer();
                    } else {
                      _questionTimer?.cancel();
                    }
                  },
                  activeColor: AppColors.green,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Área do som (altifalante)
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: colors.c1Bg,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: colors.c1Fg.withOpacity(0.20),
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(32),
                  onTap: () {
                    _playPressSound();
                    _playQuestionSound();
                  },
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/speaker-icon.svg',
                          width: 48,
                          height: 48,
                          colorFilter: ColorFilter.mode(
                            colors.c1Fg,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ouvir',
                          style: TextStyle(
                            fontFamily: 'ComicSansMS',
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: colors.c1Fg,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ouve e escolhe a opção correta',
              style: TextStyle(
                fontFamily: 'ComicSansMS',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: colors.textMuted,
              ),
            ),
            if (_timerEnabled) ...[
              const SizedBox(height: 8),
              Text(
                'Tempo: $_questionTime s',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _questionTime <= 3 ? Colors.red : colors.textMuted,
                ),
              ),
            ],
            const SizedBox(height: 24),
            // Opções
            ...List.generate(_opcoes.length, (index) {
              final opcao = _opcoes[index];
              final acertou = _selecionada != null && opcao == _perguntaSound;
              final errou = _selecionada == index && opcao != _perguntaSound;

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
                  onTapDown: (_) => _playPressSound(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: shadow, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Text(
                      opcao,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'ComicSansMS',
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
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

class _ModeButton extends StatelessWidget {
  final AppColors colors;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ModeButton({
    required this.colors,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: active ? AppColors.green : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: active
                ? [
                    const BoxShadow(
                      color: AppColors.greenShadow,
                      offset: Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'ComicSansMS',
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: active ? Colors.white : colors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}