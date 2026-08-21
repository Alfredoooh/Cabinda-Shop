import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:audioplayers/audioplayers.dart';

import '../main.dart'
    show AppColors, SoundManager, kConsonants, kVowels, buildSyllable;

enum _QuizMode {
  letters,
  syllables,
}

class GameQuizScreen extends StatefulWidget {
  final AppColors colors;

  const GameQuizScreen({
    super.key,
    required this.colors,
  });

  @override
  State<GameQuizScreen> createState() => _GameQuizScreenState();
}

class _GameQuizScreenState extends State<GameQuizScreen>
    with TickerProviderStateMixin {
  // ════════════════════════════════════════════════════════════
  // DADOS
  // ════════════════════════════════════════════════════════════

  static const List<String> _alfabeto = [
    'a',
    'b',
    'c',
    'd',
    'e',
    'f',
    'g',
    'h',
    'i',
    'j',
    'k',
    'l',
    'm',
    'n',
    'o',
    'p',
    'q',
    'r',
    's',
    't',
    'u',
    'v',
    'w',
    'x',
    'y',
    'z',
  ];

  late List<String> _allSyllables;

  _QuizMode _mode = _QuizMode.letters;

  // Pergunta
  late String _perguntaSound;
  late List<String> _opcoes;

  int? _selecionada;

  // Estatísticas
  int _corretas = 0;
  int _total = 0;

  int _streak = 0;
  int _melhorStreak = 0;

  int _xp = 0;

  // Vidas estilo Duolingo
  int _vidas = 3;
  static const int _maxVidas = 3;

  // Sessão
  int _perguntasDaSessao = 0;
  static const int _metaPerguntas = 10;

  // Timer
  Timer? _questionTimer;

  int _questionTime = 10;
  static const int _maxQuestionTime = 10;

  bool _timerEnabled = false;

  // Estado
  bool _processando = false;
  bool _sessaoTerminada = false;

  // Áudio
  final AudioPlayer _feedbackPlayer = AudioPlayer();

  final Random _random = Random();

  // ════════════════════════════════════════════════════════════
  // ANIMAÇÕES
  // ════════════════════════════════════════════════════════════

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  late AnimationController _speakerController;

  late AnimationController _questionController;

  late AnimationController _xpController;

  late AnimationController _heartController;

  late AnimationController _successController;

  // Confete
  final List<_ConfettiParticle> _confetti = [];

  late AnimationController _confettiController;

  // ════════════════════════════════════════════════════════════
  // INIT
  // ════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();

    _allSyllables = _buildAllSyllables();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.elasticIn,
      ),
    );

    _speakerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      lowerBound: 0,
      upperBound: 0.12,
    );

    _questionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _xpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });

    _novaRonda();
  }

  @override
  void dispose() {
    _questionTimer?.cancel();

    _feedbackPlayer.dispose();

    _shakeController.dispose();
    _speakerController.dispose();
    _questionController.dispose();
    _xpController.dispose();
    _heartController.dispose();
    _successController.dispose();
    _confettiController.dispose();

    super.dispose();
  }

  // ════════════════════════════════════════════════════════════
  // SÍLABAS
  // ════════════════════════════════════════════════════════════

  List<String> _buildAllSyllables() {
    final syllables = <String>[];

    for (final consoante in kConsonants) {
      for (final vogal in kVowels) {
        syllables.add(
          buildSyllable(
            consoante,
            vogal,
            false,
          ).toLowerCase(),
        );
      }
    }

    return syllables;
  }

  // ════════════════════════════════════════════════════════════
  // SONS
  // ════════════════════════════════════════════════════════════

  Future<void> _playPressSound() async {
    try {
      await _feedbackPlayer.stop();

      await _feedbackPlayer.play(
        AssetSource(
          'audio/pressing.wav',
        ),
      );
    } catch (_) {}
  }

  Future<void> _playFeedback(
    String asset,
  ) async {
    try {
      await _feedbackPlayer.stop();

      await _feedbackPlayer.play(
        AssetSource(asset),
      );
    } catch (_) {}
  }

  Future<void> _playQuestionSound() async {
    _speakerController.forward(
      from: 0,
    ).then((_) {
      if (mounted) {
        _speakerController.reverse();
      }
    });

    try {
      await SoundManager.instance.play(
        _perguntaSound,
      );
    } catch (_) {}
  }

  // ════════════════════════════════════════════════════════════
  // TIMER
  // ════════════════════════════════════════════════════════════

  void _startQuestionTimer() {
    _questionTimer?.cancel();

    if (!_timerEnabled) {
      return;
    }

    _questionTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted || _processando || _sessaoTerminada) {
          timer.cancel();
          return;
        }

        if (_questionTime <= 1) {
          timer.cancel();

          setState(() {
            _questionTime = 0;
          });

          _responder(-1);
          return;
        }

        setState(() {
          _questionTime--;
        });
      },
    );
  }

  // ════════════════════════════════════════════════════════════
  // NOVA PERGUNTA
  // ════════════════════════════════════════════════════════════

  void _novaRonda() {
    _questionTimer?.cancel();

    if (!mounted) {
      return;
    }

    List<String> pool;

    if (_mode == _QuizMode.letters) {
      pool = _alfabeto;
    } else {
      pool = _allSyllables;
    }

    final correct =
        pool[_random.nextInt(pool.length)];

    final erradas = pool
        .where(
          (item) => item != correct,
        )
        .toList()
      ..shuffle(_random);

    final opcoes = [
      correct,
      erradas[0],
      erradas[1],
      erradas[2],
    ]..shuffle(_random);

    setState(() {
      _perguntaSound = correct;
      _opcoes = opcoes;

      _selecionada = null;

      _questionTime = _maxQuestionTime;

      _processando = false;
    });

    _questionController.forward(
      from: 0,
    );

    _startQuestionTimer();

    Future.delayed(
      const Duration(milliseconds: 220),
      () {
        if (mounted && !_sessaoTerminada) {
          _playQuestionSound();
        }
      },
    );
  }

  // ════════════════════════════════════════════════════════════
  // CONFETE
  // ════════════════════════════════════════════════════════════

  void _dispararConfete() {
    _confetti.clear();

    for (int i = 0; i < 42; i++) {
      _confetti.add(
        _ConfettiParticle(
          _random,
        ),
      );
    }

    _confettiController.forward(
      from: 0,
    );
  }

  // ════════════════════════════════════════════════════════════
  // RESPOSTA
  // ════════════════════════════════════════════════════════════

  void _responder(
    int index,
  ) {
    if (_processando ||
        _selecionada != null ||
        _sessaoTerminada) {
      return;
    }

    _questionTimer?.cancel();

    final bool acertou =
        index >= 0 &&
            index < _opcoes.length &&
            _opcoes[index] ==
                _perguntaSound;

    setState(() {
      _processando = true;
      _selecionada = index;

      _total++;
      _perguntasDaSessao++;

      if (acertou) {
        _corretas++;

        _streak++;

        if (_streak > _melhorStreak) {
          _melhorStreak = _streak;
        }

        // XP base + bônus por sequência + bônus de velocidade.
        int ganhoXp = 10;

        if (_streak >= 3) {
          ganhoXp += 5;
        }

        if (_timerEnabled &&
            _questionTime >= 7) {
          ganhoXp += 3;
        }

        _xp += ganhoXp;
      } else {
        _streak = 0;

        if (_vidas > 0) {
          _vidas--;
        }
      }
    });

    if (acertou) {
      _playFeedback(
        'audio/correct.wav',
      );

      _dispararConfete();

      _successController.forward(
        from: 0,
      );

      _xpController.forward(
        from: 0,
      );
    } else {
      _playFeedback(
        'audio/wrong.wav',
      );

      _shakeController.forward(
        from: 0,
      );

      _heartController.forward(
        from: 0,
      );

      // Se perder todas as vidas, termina a sessão.
      if (_vidas <= 0) {
        Future.delayed(
          const Duration(milliseconds: 950),
          _mostrarFimSemVidas,
        );

        return;
      }
    }

    // Depois da resposta, avança automaticamente.
    Future.delayed(
      const Duration(milliseconds: 1000),
      () {
        if (!mounted) {
          return;
        }

        if (_perguntasDaSessao >=
            _metaPerguntas) {
          _mostrarFimDaSessao();
        } else {
          _novaRonda();
        }
      },
    );
  }

  // ════════════════════════════════════════════════════════════
  // FIM POR VIDAS
  // ════════════════════════════════════════════════════════════

  void _mostrarFimSemVidas() {
    if (!mounted) {
      return;
    }

    _sessaoTerminada = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final colors = widget.colors;

        return AlertDialog(
          backgroundColor:
              colors.bgCardNeutral,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(22),
          ),
          title: Text(
            '❤️ Sem vidas',
            style: TextStyle(
              fontFamily:
                  'ComicSansMS',
              fontWeight:
                  FontWeight.w700,
              color:
                  colors.textMain,
            ),
          ),
          content: Text(
            'Não faz mal. Vamos tentar novamente?',
            style: TextStyle(
              color:
                  colors.textMain,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pop();

                _reiniciarSessao();
              },
              child: Text(
                'Tentar novamente',
                style: TextStyle(
                  color:
                      AppColors.green,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════
  // FIM DA SESSÃO
  // ════════════════════════════════════════════════════════════

  void _mostrarFimDaSessao() {
    if (!mounted) {
      return;
    }

    _sessaoTerminada = true;
    _questionTimer?.cancel();

    final percentagem =
        _total == 0
            ? 0
            : ((_corretas /
                            _total) *
                        100)
                    .round();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final colors = widget.colors;

        return AlertDialog(
          backgroundColor:
              colors.bgCardNeutral,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(22),
          ),
          title: Text(
            '🎉 Lição concluída!',
            style: TextStyle(
              fontFamily:
                  'ComicSansMS',
              fontWeight:
                  FontWeight.w700,
              color:
                  colors.textMain,
            ),
          ),
          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              _ResultRow(
                colors: colors,
                label: 'Acertos',
                value:
                    '$_corretas / $_total',
              ),
              const SizedBox(
                height: 8,
              ),
              _ResultRow(
                colors: colors,
                label: 'Precisão',
                value:
                    '$percentagem%',
              ),
              const SizedBox(
                height: 8,
              ),
              _ResultRow(
                colors: colors,
                label: 'XP ganho',
                value:
                    '+$_xp XP',
              ),
              const SizedBox(
                height: 8,
              ),
              _ResultRow(
                colors: colors,
                label: 'Melhor sequência',
                value:
                    '🔥 $_melhorStreak',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pop();

                _reiniciarSessao();
              },
              child: Text(
                'Nova lição',
                style: TextStyle(
                  color:
                      AppColors.green,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════
  // REINICIAR
  // ════════════════════════════════════════════════════════════

  void _reiniciarSessao() {
    _questionTimer?.cancel();

    setState(() {
      _corretas = 0;
      _total = 0;

      _streak = 0;
      _melhorStreak = 0;

      _xp = 0;

      _vidas = _maxVidas;

      _perguntasDaSessao = 0;

      _selecionada = null;

      _processando = false;

      _sessaoTerminada = false;
    });

    _novaRonda();
  }

  // ════════════════════════════════════════════════════════════
  // TROCAR MODO
  // ════════════════════════════════════════════════════════════

  void _trocarModo(
    _QuizMode mode,
  ) {
    if (_mode == mode) {
      return;
    }

    _playPressSound();

    _questionTimer?.cancel();

    setState(() {
      _mode = mode;

      _selecionada = null;

      _processando = false;
    });

    _novaRonda();
  }

  // ════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════

  @override
  Widget build(
    BuildContext context,
  ) {
    final colors =
        widget.colors;

    return Scaffold(
      backgroundColor:
          colors.bg,
      appBar: AppBar(
        backgroundColor:
            colors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,

        leading: GestureDetector(
          onTap: () =>
              Navigator.of(
                context,
              ).pop(),
          child: Center(
            child:
                SvgPicture.asset(
              'assets/icons/back.svg',
              width: 22,
              height: 22,
              colorFilter:
                  ColorFilter.mode(
                colors.textMain,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),

        title: Text(
          _mode ==
                  _QuizMode.letters
              ? 'Quiz do Alfabeto'
              : 'Quiz de Sílabas',
          style: TextStyle(
            fontFamily:
                'ComicSansMS',
            fontWeight:
                FontWeight.w700,
            fontSize: 18,
            color:
                colors.textMain,
          ),
        ),

        actions: [
          // XP
          Padding(
            padding:
                const EdgeInsets.only(
              right: 8,
            ),
            child: Center(
              child:
                  AnimatedBuilder(
                animation:
                    _xpController,
                builder:
                    (
                  context,
                  child,
                ) {
                  return Transform.scale(
                    scale:
                        1 +
                        (_xpController.value *
                            0.08),
                    child:
                        child,
                  );
                },
                child:
                    Text(
                  '⚡ $_xp',
                  style:
                      TextStyle(
                    fontFamily:
                        'ComicSansMS',
                    fontWeight:
                        FontWeight.w700,
                    fontSize:
                        14,
                    color:
                        AppColors.orange,
                  ),
                ),
              ),
            ),
          ),

          // Vidas
          Padding(
            padding:
                const EdgeInsets.only(
              right: 14,
            ),
            child: Center(
              child:
                  AnimatedBuilder(
                animation:
                    _heartController,
                builder:
                    (
                  context,
                  child,
                ) {
                  final scale =
                      1 +
                      (_heartController
                              .value *
                          0.12);

                  return Transform.scale(
                    scale:
                        scale,
                    child:
                        child,
                  );
                },
                child:
                    Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children:
                      List.generate(
                    _maxVidas,
                    (index) {
                      return Padding(
                        padding:
                            const EdgeInsets
                                .only(
                          left: 2,
                        ),
                        child:
                            Icon(
                          index <
                                  _vidas
                              ? Icons
                                  .favorite
                              : Icons
                                  .favorite_border,
                          size:
                              18,
                          color: index <
                                  _vidas
                              ? Colors
                                  .red
                              : colors
                                  .textMuted,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      body:
          Stack(
        children: [
          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              20,
              10,
              20,
              20,
            ),
            child:
                Column(
              children: [
                // ═══════════════════════════════════
                // PROGRESSO DA LIÇÃO
                // ═══════════════════════════════════

                _LessonProgress(
                  colors:
                      colors,
                  current:
                      _perguntasDaSessao,
                  total:
                      _metaPerguntas,
                ),

                const SizedBox(
                  height: 14,
                ),

                // ═══════════════════════════════════
                // SELETOR DE MODO
                // ═══════════════════════════════════

                Container(
                  padding:
                      const EdgeInsets.all(
                    4,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        colors.bgCardNeutral,
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),
                  child:
                      Row(
                    children: [
                      _ModeButton(
                        colors:
                            colors,
                        label:
                            'Letras',
                        active:
                            _mode ==
                                _QuizMode
                                    .letters,
                        onTap:
                            () {
                          _trocarModo(
                            _QuizMode
                                .letters,
                          );
                        },
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      _ModeButton(
                        colors:
                            colors,
                        label:
                            'Sílabas',
                        active:
                            _mode ==
                                _QuizMode
                                    .syllables,
                        onTap:
                            () {
                          _trocarModo(
                            _QuizMode
                                .syllables,
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                // ═══════════════════════════════════
                // STREAK
                // ═══════════════════════════════════

                AnimatedSwitcher(
                  duration:
                      const Duration(
                    milliseconds: 250,
                  ),
                  child:
                      _streak > 1
                          ? Container(
                              key: ValueKey(
                                _streak,
                              ),
                              width:
                                  double.infinity,
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal:
                                    14,
                                vertical:
                                    9,
                              ),
                              decoration:
                                  BoxDecoration(
                                color:
                                    AppColors.orange
                                        .withOpacity(
                                  0.12,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  12,
                                ),
                              ),
                              child:
                                  Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .center,
                                children: [
                                  const Text(
                                    '🔥',
                                    style:
                                        TextStyle(
                                      fontSize:
                                          17,
                                    ),
                                  ),
                                  const SizedBox(
                                    width:
                                        6,
                                  ),
                                  Text(
                                    '$_streak seguidas!',
                                    style:
                                        TextStyle(
                                      fontFamily:
                                          'ComicSansMS',
                                      fontWeight:
                                          FontWeight
                                              .w700,
                                      fontSize:
                                          14,
                                      color:
                                          AppColors
                                              .orange,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox(
                              key: ValueKey(
                                'no_streak',
                              ),
                              height:
                                  0,
                            ),
                ),

                const SizedBox(
                  height: 12,
                ),

                // ═══════════════════════════════════
                // TEMPORIZADOR
                // ═══════════════════════════════════

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.end,
                  children: [
                    Text(
                      'Temporizador',
                      style:
                          TextStyle(
                        fontSize:
                            13,
                        color:
                            colors.textMuted,
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    _DuoSwitch(
                      colors:
                          colors,
                      value:
                          _timerEnabled,
                      onChanged:
                          (value) {
                        _playPressSound();

                        setState(() {
                          _timerEnabled =
                              value;
                        });

                        if (value) {
                          _questionTime =
                              _maxQuestionTime;
                          _startQuestionTimer();
                        } else {
                          _questionTimer
                              ?.cancel();
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(
                  height: 14,
                ),

                // ═══════════════════════════════════
                // PERGUNTA / ÁUDIO
                // ═══════════════════════════════════

                Expanded(
                  child:
                      SingleChildScrollView(
                    physics:
                        const BouncingScrollPhysics(),
                    child:
                        Column(
                      children: [
                        AnimatedBuilder(
                          animation:
                              Listenable.merge([
                            _questionController,
                            _shakeAnimation,
                            _speakerController,
                          ]),
                          builder:
                              (
                            context,
                            child,
                          ) {
                            final entry =
                                Curves.easeOutBack
                                    .transform(
                              _questionController.value,
                            );

                            final shake =
                                sin(
                                      _shakeAnimation
                                              .value *
                                          pi *
                                          6,
                                    ) *
                                    (1 -
                                        _shakeAnimation
                                            .value) *
                                    7;

                            final speakerScale =
                                1 +
                                    _speakerController
                                            .value *
                                        1.2;

                            return Transform.translate(
                              offset:
                                  Offset(
                                shake,
                                0,
                              ),
                              child:
                                  Transform.scale(
                                scale:
                                    0.92 +
                                        (entry *
                                            0.08),
                                child:
                                    child,
                              ),
                            );
                          },
                          child:
                              Container(
                            width:
                                double.infinity,
                            padding:
                                const EdgeInsets
                                    .fromLTRB(
                              18,
                              18,
                              18,
                              20,
                            ),
                            decoration:
                                BoxDecoration(
                              color:
                                  colors.c1Bg,
                              borderRadius:
                                  BorderRadius.circular(
                                22,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      colors.c1Fg.withOpacity(
                                    0.12,
                                  ),
                                  offset:
                                      const Offset(
                                    0,
                                    5,
                                  ),
                                  blurRadius:
                                      3,
                                ),
                              ],
                            ),
                            child:
                                Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                  children: [
                                    Text(
                                      _mode ==
                                              _QuizMode
                                                  .letters
                                          ? 'Ouve a letra'
                                          : 'Ouve a sílaba',
                                      style:
                                          TextStyle(
                                        fontFamily:
                                            'ComicSansMS',
                                        fontWeight:
                                            FontWeight
                                                .w700,
                                        fontSize:
                                            15,
                                        color:
                                            colors.c1Fg,
                                      ),
                                    ),

                                    if (_timerEnabled)
                                      _TimerBadge(
                                        colors:
                                            colors,
                                        seconds:
                                            _questionTime,
                                      ),
                                  ],
                                ),

                                const SizedBox(
                                  height: 18,
                                ),

                                Transform.scale(
                                  scale:
                                      1.0 + (_speakerController.value * 1.2),
                                  child:
                                      Material(
                                    color:
                                        Colors.transparent,
                                    child:
                                        InkWell(
                                      customBorder:
                                          const CircleBorder(),
                                      onTap:
                                          () {
                                        _playPressSound();
                                        _playQuestionSound();
                                      },
                                      child:
                                          Container(
                                        width:
                                            88,
                                        height:
                                            88,
                                        decoration:
                                            BoxDecoration(
                                          color:
                                              colors.bgCardNeutral,
                                          shape:
                                              BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  colors.divider,
                                              offset:
                                                  const Offset(
                                                0,
                                                4,
                                              ),
                                            ),
                                          ],
                                        ),
                                        child:
                                            Center(
                                          child:
                                              SvgPicture.asset(
                                            'assets/icons/speaker-icon.svg',
                                            width:
                                                42,
                                            height:
                                                42,
                                            colorFilter:
                                                ColorFilter.mode(
                                              colors.textMain,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  height: 10,
                                ),

                                Text(
                                  'Toca para ouvir novamente',
                                  textAlign:
                                      TextAlign.center,
                                  style:
                                      TextStyle(
                                    fontSize:
                                        13,
                                    color:
                                        colors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 14,
                        ),

                        // ═══════════════════════════════════
                        // INSTRUÇÃO
                        // ═══════════════════════════════════

                        Text(
                          _mode ==
                                  _QuizMode
                                      .letters
                              ? 'Qual é a letra que ouviste?'
                              : 'Qual é a sílaba que ouviste?',
                          textAlign:
                              TextAlign.center,
                          style:
                              TextStyle(
                            fontFamily:
                                'ComicSansMS',
                            fontWeight:
                                FontWeight
                                    .w700,
                            fontSize:
                                17,
                            color:
                                colors.textMain,
                          ),
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        // ═══════════════════════════════════
                        // OPÇÕES
                        // ═══════════════════════════════════

                        GridView.builder(
                          shrinkWrap:
                              true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          itemCount:
                              _opcoes.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                2,
                            crossAxisSpacing:
                                10,
                            mainAxisSpacing:
                                10,
                            childAspectRatio:
                                1.8,
                          ),
                          itemBuilder:
                              (
                            context,
                            index,
                          ) {
                            return _AnswerButton(
                              colors:
                                  colors,
                              text:
                                  _opcoes[index],
                              selected:
                                  _selecionada ==
                                      index,
                              correct:
                                  _opcoes[index] ==
                                      _perguntaSound,
                              error:
                                  _selecionada ==
                                      index &&
                                      _selecionada !=
                                          -1 &&
                                      _opcoes[index] !=
                                          _perguntaSound,
                              disabled:
                                  _processando,
                              shakeAnimation:
                                  _shakeAnimation,
                              onTap:
                                  () {
                                _playPressSound();
                                _responder(
                                  index,
                                );
                              },
                            );
                          },
                        ),

                        const SizedBox(
                          height: 18,
                        ),

                        // ═══════════════════════════════════
                        // MELHOR STREAK
                        // ═══════════════════════════════════

                        if (_melhorStreak >
                            1)
                          Text(
                            'Melhor sequência: 🔥 $_melhorStreak',
                            style:
                                TextStyle(
                              fontSize:
                                  13,
                              fontWeight:
                                  FontWeight
                                      .w700,
                              color:
                                  colors.textMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ════════════════════════════════════════════════════
          // CONFETE
          // ════════════════════════════════════════════════════

          if (_confettiController
              .isAnimating)
            IgnorePointer(
              child:
                  CustomPaint(
                size:
                    Size.infinite,
                painter:
                    _ConfettiPainter(
                  particles:
                      _confetti,
                  progress:
                      _confettiController
                          .value,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// BOTÃO DE MODO
// ══════════════════════════════════════════════════════════════

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
  Widget build(
    BuildContext context,
  ) {
    return Expanded(
      child:
          GestureDetector(
        onTap:
            onTap,
        child:
            AnimatedContainer(
          duration:
              const Duration(
            milliseconds: 200,
          ),
          padding:
              const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 4,
          ),
          decoration:
              BoxDecoration(
            color: active
                ? AppColors.green
                : Colors.transparent,
            borderRadius:
                BorderRadius.circular(
              10,
            ),
            boxShadow:
                active
                    ? const [
                        BoxShadow(
                          color:
                              AppColors.greenShadow,
                          offset:
                              Offset(
                            0,
                            3,
                          ),
                        ),
                      ]
                    : [],
          ),
          child:
              Text(
            label,
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              fontFamily:
                  'ComicSansMS',
              fontWeight:
                  FontWeight.w700,
              fontSize:
                  15,
              color: active
                  ? Colors.white
                  : colors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// BOTÃO DE RESPOSTA
// ══════════════════════════════════════════════════════════════

class _AnswerButton extends StatelessWidget {
  final AppColors colors;
  final String text;
  final bool selected;
  final bool correct;
  final bool error;
  final bool disabled;
  final Animation<double> shakeAnimation;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.colors,
    required this.text,
    required this.selected,
    required this.correct,
    required this.error,
    required this.disabled,
    required this.shakeAnimation,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    Color background =
        colors.bgCardNeutral;

    Color foreground =
        colors.textMain;

    Color shadow =
        colors.divider;

    if (selected &&
        correct) {
      background =
          AppColors.green;

      foreground =
          Colors.white;

      shadow =
          AppColors.greenShadow;
    } else if (selected &&
        error) {
      background =
          const Color(
        0xFFFF4B4B,
      );

      foreground =
          Colors.white;

      shadow =
          const Color(
        0xFFCC0000,
      );
    }

    Widget button =
        AnimatedContainer(
      duration:
          const Duration(
        milliseconds: 180,
      ),
      width:
          double.infinity,
      height:
          double.infinity,
      decoration:
          BoxDecoration(
        color:
            background,
        borderRadius:
            BorderRadius.circular(
          17,
        ),
        boxShadow: [
          BoxShadow(
            color:
                shadow,
            offset:
                const Offset(
              0,
              4,
            ),
          ),
        ],
      ),
      child:
          Center(
        child:
            AnimatedDefaultTextStyle(
          duration:
              const Duration(
            milliseconds: 180,
          ),
          style:
              TextStyle(
            fontFamily:
                'ComicSansMS',
            fontWeight:
                FontWeight.w700,
            fontSize:
                25,
            color:
                foreground,
          ),
          child:
              Text(
            text.toUpperCase(),
          ),
        ),
      ),
    );

    if (error) {
      button =
          AnimatedBuilder(
        animation:
            shakeAnimation,
        builder:
            (
          context,
          child,
        ) {
          final value =
              sin(
                    shakeAnimation
                            .value *
                        pi *
                        6,
                  ) *
                  (1 -
                      shakeAnimation
                          .value) *
                  7;

          return Transform.translate(
            offset:
                Offset(
              value,
              0,
            ),
            child:
                child,
          );
        },
        child:
            button,
      );
    }

    if (selected &&
        correct) {
      button =
          TweenAnimationBuilder<
              double>(
        tween:
            Tween<double>(
          begin:
              0.84,
          end:
              1,
        ),
        duration:
            const Duration(
          milliseconds: 300,
        ),
        curve:
            Curves.elasticOut,
        builder:
            (
          context,
          scale,
          child,
        ) {
          return Transform.scale(
            scale:
                scale,
            child:
                child,
          );
        },
        child:
            button,
      );
    }

    return GestureDetector(
      onTap:
          disabled
              ? null
              : onTap,
      child:
          button,
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SWITCH
// ══════════════════════════════════════════════════════════════

class _DuoSwitch
    extends StatelessWidget {
  final AppColors colors;
  final bool value;
  final ValueChanged<bool>
      onChanged;

  const _DuoSwitch({
    required this.colors,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () =>
          onChanged(
        !value,
      ),
      child:
          AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 200,
        ),
        width:
            52,
        height:
            30,
        padding:
            const EdgeInsets.all(
          3,
        ),
        decoration:
            BoxDecoration(
          color: value
              ? AppColors.green
              : colors.bgCardNeutral,
          borderRadius:
              BorderRadius.circular(
            20,
          ),
        ),
        child:
            AnimatedAlign(
          duration:
              const Duration(
            milliseconds: 220,
          ),
          curve:
              Curves.easeOut,
          alignment:
              value
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
          child:
              Container(
            width:
                24,
            height:
                24,
            decoration:
                BoxDecoration(
              color:
                  colors.switchThumb,
              shape:
                  BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color:
                      colors.switchThumbShadow,
                  offset:
                      const Offset(
                    0,
                    2,
                  ),
                  blurRadius:
                      4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// PROGRESSO DA LIÇÃO
// ══════════════════════════════════════════════════════════════

class _LessonProgress
    extends StatelessWidget {
  final AppColors colors;
  final int current;
  final int total;

  const _LessonProgress({
    required this.colors,
    required this.current,
    required this.total,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final progress =
        (current / total)
            .clamp(
      0.0,
      1.0,
    );

    return Row(
      children: [
        Expanded(
          child:
              ClipRRect(
            borderRadius:
                BorderRadius.circular(
              8,
            ),
            child:
                TweenAnimationBuilder<
                    double>(
              tween:
                  Tween<double>(
                begin:
                    0,
                end:
                    progress,
              ),
              duration:
                  const Duration(
                milliseconds: 350,
              ),
              curve:
                  Curves.easeOut,
              builder:
                  (
                context,
                value,
                child,
              ) {
                return LinearProgressIndicator(
                  value:
                      value,
                  minHeight:
                      9,
                  backgroundColor:
                      colors.bgCardNeutral,
                  valueColor:
                      const AlwaysStoppedAnimation<
                          Color>(
                    AppColors.green,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(
          width:
              10,
        ),
        Text(
          '$current/$total',
          style:
              TextStyle(
            fontFamily:
                'ComicSansMS',
            fontWeight:
                FontWeight.w700,
            fontSize:
                12,
            color:
                colors.textMuted,
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// TIMER BADGE
// ══════════════════════════════════════════════════════════════

class _TimerBadge
    extends StatelessWidget {
  final AppColors colors;
  final int seconds;

  const _TimerBadge({
    required this.colors,
    required this.seconds,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final danger =
        seconds <= 3;

    return AnimatedContainer(
      duration:
          const Duration(
        milliseconds: 180,
      ),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration:
          BoxDecoration(
        color: danger
            ? Colors.red
                .withOpacity(
              0.12,
            )
            : colors.bgCardNeutral,
        borderRadius:
            BorderRadius.circular(
          10,
        ),
      ),
      child:
          Text(
        '⏱ $seconds s',
        style:
            TextStyle(
          fontFamily:
              'ComicSansMS',
          fontWeight:
              FontWeight.w700,
          fontSize:
              12,
          color: danger
              ? Colors.red
              : colors.textMuted,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// RESULTADO
// ══════════════════════════════════════════════════════════════

class _ResultRow
    extends StatelessWidget {
  final AppColors colors;
  final String label;
  final String value;

  const _ResultRow({
    required this.colors,
    required this.label,
    required this.value,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style:
              TextStyle(
            color:
                colors.textMuted,
            fontSize:
                14,
          ),
        ),
        Text(
          value,
          style:
              TextStyle(
            fontFamily:
                'ComicSansMS',
            fontWeight:
                FontWeight.w700,
            color:
                colors.textMain,
            fontSize:
                14,
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// CONFETE
// ══════════════════════════════════════════════════════════════

class _ConfettiParticle {
  final double startX;
  final double angle;
  final double size;
  final Color color;
  final double spin;
  final bool isCircle;

  _ConfettiParticle(
    Random random,
  )   : startX =
            random.nextDouble(),
        angle =
            (random.nextDouble() -
                    0.5) *
                pi *
                0.9,
        size =
            5 +
                random.nextDouble() *
                    8,
        spin =
            (random.nextDouble() -
                    0.5) *
                14,
        isCircle =
            random.nextBool(),
        color = [
          AppColors.green,
          AppColors.orange,
          const Color(
            0xFF1CB0F6,
          ),
          const Color(
            0xFFFF4B8C,
          ),
          const Color(
            0xFFCE82FF,
          ),
          const Color(
            0xFFFFC800,
          ),
        ][
            random.nextInt(
          6,
        )];
}

// ══════════════════════════════════════════════════════════════
// PAINTER
// ══════════════════════════════════════════════════════════════

class _ConfettiPainter
    extends CustomPainter {
  final List<
      _ConfettiParticle> particles;

  final double progress;

  _ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint =
        Paint();

    for (final particle
        in particles) {
      final fade =
          (1 - progress)
              .clamp(
        0.0,
        1.0,
      );

      final dx =
          size.width *
              particle.startX +
          sin(
                particle.angle,
              ) *
              150 *
              progress;

      final dy =
          size.height *
              0.25 +
          480 *
              progress *
              progress;

      paint.color =
          particle.color
              .withOpacity(
        fade,
      );

      canvas.save();

      canvas.translate(
        dx,
        dy,
      );

      canvas.rotate(
        particle.spin *
            progress,
      );

      if (particle.isCircle) {
        canvas.drawCircle(
          Offset.zero,
          particle.size *
              0.5,
          paint,
        );
      } else {
        canvas.drawRect(
          Rect.fromCenter(
            center:
                Offset.zero,
            width:
                particle.size,
            height:
                particle.size *
                    0.5,
          ),
          paint,
        );
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(
    covariant _ConfettiPainter
        oldDelegate,
  ) {
    return true;
  }
}