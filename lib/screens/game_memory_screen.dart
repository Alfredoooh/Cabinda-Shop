import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:audioplayers/audioplayers.dart';
import '../main.dart' show AppColors;

final AudioPlayer _soundPlayer = AudioPlayer();
final AudioPlayer _musicPlayer = AudioPlayer();

class GameMemoryScreen extends StatefulWidget {
  final AppColors colors;

  const GameMemoryScreen({
    super.key,
    required this.colors,
  });

  @override
  State<GameMemoryScreen> createState() => _GameMemoryScreenState();
}

class _GameMemoryScreenState extends State<GameMemoryScreen>
    with TickerProviderStateMixin {
  // ────────────────────────────────────────────────────────────
  // ESTADO
  // ────────────────────────────────────────────────────────────

  bool _showLevelSelect = true;

  int _levelPairs = 6;

  bool _timerEnabled = false;
  int _timerDuration = 60;
  int _remainingSeconds = 60;

  Timer? _timer;

  bool _soundOn = true;
  bool _musicOn = true;
  bool _musicStarted = false;

  static const List<String> _allLetters = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
  ];

  late List<String> _cartas;
  late List<bool> _virada;
  late List<bool> _encontrada;

  int? _primeira;
  bool _bloqueado = false;

  int _tentativas = 0;
  int _streak = 0;

  int? _erroA;
  int? _erroB;

  String? _mensagem;
  Timer? _mensagemTimer;

  final List<_ConfettiParticle> _confetti = [];

  late AnimationController _confettiController;

  final Random _random = Random();

  static const List<String> _mensagensAcerto = [
    'Boa! 🌟',
    'Excelente! ✨',
    'Continua! 🚀',
    'Muito bem! 🎯',
    'Incrível! 💫',
  ];

  static const List<String> _mensagensStreak = [
    'Sequência! 🔥',
    'Em fogo! 🔥🔥',
    'Imparável! 🔥🔥🔥',
  ];

  // ────────────────────────────────────────────────────────────
  // CICLO DE VIDA
  // ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mensagemTimer?.cancel();

    _confettiController.dispose();

    _soundPlayer.stop();
    _musicPlayer.stop();

    super.dispose();
  }

  // ────────────────────────────────────────────────────────────
  // ÁUDIO
  // ────────────────────────────────────────────────────────────

  Future<void> _playSound(String asset) async {
    if (!_soundOn) return;

    try {
      await _soundPlayer.stop();
      await _soundPlayer.play(
        AssetSource(asset),
      );
    } catch (_) {}
  }

  Future<void> _startMusic() async {
    if (_musicStarted) {
      if (_musicOn) {
        try {
          await _musicPlayer.resume();
        } catch (_) {}
      }
      return;
    }

    _musicStarted = true;

    try {
      await _musicPlayer.setReleaseMode(
        ReleaseMode.loop,
      );

      await _musicPlayer.setVolume(0.35);

      if (_musicOn) {
        await _musicPlayer.play(
          AssetSource('songs/playing_song.mp3'),
        );
      }
    } catch (_) {}
  }

  Future<void> _toggleSound() async {
    setState(() {
      _soundOn = !_soundOn;
    });

    if (_soundOn) {
      await _playSound('audio/pressing.wav');
    }
  }

  Future<void> _toggleMusic() async {
    setState(() {
      _musicOn = !_musicOn;
    });

    try {
      if (_musicOn) {
        if (!_musicStarted) {
          await _startMusic();
        } else {
          await _musicPlayer.resume();
        }
      } else {
        await _musicPlayer.pause();
      }
    } catch (_) {}

    if (_soundOn) {
      await _playSound('audio/pressing.wav');
    }
  }

  // ────────────────────────────────────────────────────────────
  // INICIAR JOGO
  // ────────────────────────────────────────────────────────────

  void _iniciarJogo(
    int pares,
    bool timerOn,
    int duracao,
  ) {
    _timer?.cancel();
    _mensagemTimer?.cancel();

    final letras = _allLetters.take(pares).toList();

    final cartas = [
      ...letras,
      ...letras,
    ]..shuffle(_random);

    setState(() {
      _levelPairs = pares;

      _timerEnabled = timerOn;
      _timerDuration = duracao;
      _remainingSeconds = duracao;

      _cartas = cartas;

      _virada = List<bool>.filled(
        cartas.length,
        false,
      );

      _encontrada = List<bool>.filled(
        cartas.length,
        false,
      );

      _primeira = null;
      _bloqueado = false;

      _tentativas = 0;
      _streak = 0;

      _erroA = null;
      _erroB = null;

      _mensagem = null;

      _showLevelSelect = false;
    });

    _startMusic();

    if (timerOn) {
      _startTimer();
    }
  }

  // ────────────────────────────────────────────────────────────
  // TIMER
  // ────────────────────────────────────────────────────────────

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_remainingSeconds <= 1) {
          timer.cancel();

          setState(() {
            _remainingSeconds = 0;
          });

          _tempoEsgotado();
          return;
        }

        setState(() {
          _remainingSeconds--;
        });
      },
    );
  }

  void _tempoEsgotado() {
    _playSound('audio/wrong.wav');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final colors = widget.colors;

        return AlertDialog(
          backgroundColor: colors.bgCardNeutral,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            '⏰ Tempo esgotado!',
            style: TextStyle(
              fontFamily: 'ComicSansMS',
              fontWeight: FontWeight.w700,
              color: colors.textMain,
            ),
          ),
          content: Text(
            'Não conseguiste completar o jogo a tempo.',
            style: TextStyle(
              color: colors.textMain,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);

                setState(() {
                  _showLevelSelect = true;
                });

                _timer?.cancel();
              },
              child: Text(
                'Voltar aos níveis',
                style: TextStyle(
                  color: colors.textMain,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _voltarParaNiveis() {
    _timer?.cancel();
    _mensagemTimer?.cancel();

    setState(() {
      _showLevelSelect = true;

      _primeira = null;
      _bloqueado = false;

      _erroA = null;
      _erroB = null;

      _mensagem = null;
    });
  }

  // ────────────────────────────────────────────────────────────
  // CONFETE
  // ────────────────────────────────────────────────────────────

  void _dispararConfete() {
    _confetti.clear();

    for (int i = 0; i < 70; i++) {
      _confetti.add(
        _ConfettiParticle(_random),
      );
    }

    _confettiController.forward(
      from: 0,
    );
  }

  // ────────────────────────────────────────────────────────────
  // MENSAGEM
  // ────────────────────────────────────────────────────────────

  void _mostrarMensagem(String texto) {
    _mensagemTimer?.cancel();

    setState(() {
      _mensagem = texto;
    });

    _mensagemTimer = Timer(
      const Duration(milliseconds: 1200),
      () {
        if (!mounted) return;

        setState(() {
          _mensagem = null;
        });
      },
    );
  }

  // ────────────────────────────────────────────────────────────
  // JOGAR CARTA
  // ────────────────────────────────────────────────────────────

  void _tocar(int index) {
    if (_bloqueado) return;

    if (index < 0 || index >= _cartas.length) {
      return;
    }

    if (_virada[index] || _encontrada[index]) {
      return;
    }

    _playSound('audio/pressing.wav');

    // PRIMEIRA CARTA
    if (_primeira == null) {
      setState(() {
        _virada[index] = true;
        _primeira = index;
      });

      return;
    }

    final int a = _primeira!;

    if (a == index) {
      return;
    }

    setState(() {
      _virada[index] = true;

      _bloqueado = true;

      _primeira = null;

      _tentativas++;
    });

    // ───────────────── PAR ─────────────────

    if (_cartas[a] == _cartas[index]) {
      _playSound('audio/correct.wav');

      _streak++;

      setState(() {
        _encontrada[a] = true;
        _encontrada[index] = true;

        _bloqueado = false;
      });

      _mostrarMensagem(
        _streak >= 3
            ? _mensagensStreak[
                min(
                  _streak - 3,
                  _mensagensStreak.length - 1,
                )
              ]
            : _mensagensAcerto[
                _random.nextInt(
                  _mensagensAcerto.length,
                )
              ],
      );

      if (_ganhou) {
        _playSound('audio/win.wav');

        _timer?.cancel();

        _dispararConfete();
      }

      return;
    }

    // ───────────────── ERRO ─────────────────

    _playSound('audio/wrong.wav');

    _streak = 0;

    setState(() {
      _erroA = a;
      _erroB = index;
    });

    Future.delayed(
      const Duration(milliseconds: 900),
      () {
        if (!mounted) return;

        setState(() {
          _virada[a] = false;
          _virada[index] = false;

          _bloqueado = false;

          _erroA = null;
          _erroB = null;
        });
      },
    );
  }

  bool get _ganhou {
    if (_encontrada.isEmpty) {
      return false;
    }

    return _encontrada.every(
      (e) => e,
    );
  }

  // ────────────────────────────────────────────────────────────
  // BUILD PRINCIPAL
  // ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.colors.bg,
      body: SafeArea(
        child: _showLevelSelect
            ? _buildLevelSelect()
            : _buildGame(),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // BOTÃO DE ÁUDIO
  // ────────────────────────────────────────────────────────────

  Widget _audioBtn({
    required bool ativo,
    required String iconOn,
    required String iconOff,
    required VoidCallback onTap,
  }) {
    final colors = widget.colors;

    return _Bounce(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        margin: const EdgeInsets.symmetric(
          horizontal: 3,
        ),
        decoration: BoxDecoration(
          color: colors.bgCardNeutral,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colors.divider,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: SvgPicture.asset(
            ativo ? iconOn : iconOff,
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(
              ativo
                  ? colors.textMain
                  : colors.textMuted,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // SELEÇÃO DE NÍVEL
  // ────────────────────────────────────────────────────────────

  Widget _buildLevelSelect() {
    final colors = widget.colors;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Bounce(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colors.bgCardNeutral,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: colors.divider,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/back.svg',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        colors.textMain,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  _audioBtn(
                    ativo: _soundOn,
                    iconOn:
                        'assets/icons/speaker-icon.svg',
                    iconOff:
                        'assets/icons/speaker-off-icon.svg',
                    onTap: _toggleSound,
                  ),
                  _audioBtn(
                    ativo: _musicOn,
                    iconOn:
                        'assets/icons/music_on.svg',
                    iconOff:
                        'assets/icons/music_off.svg',
                    onTap: _toggleMusic,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            'Escolhe o nível',
            style: TextStyle(
              fontFamily: 'ComicSansMS',
              fontWeight: FontWeight.w700,
              fontSize: 24,
              color: colors.textMain,
            ),
          ),

          const SizedBox(height: 20),

          // NÍVEIS
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.1,
              children: [
                _buildLevelButton(
                  icon: 'assets/icons/easy.png',
                  label: 'Fácil',
                  pairs: 4,
                  onTap: () => _iniciarJogo(
                    4,
                    _timerEnabled,
                    _timerDuration,
                  ),
                ),
                _buildLevelButton(
                  icon: 'assets/icons/normal.png',
                  label: 'Normal',
                  pairs: 6,
                  onTap: () => _iniciarJogo(
                    6,
                    _timerEnabled,
                    _timerDuration,
                  ),
                ),
                _buildLevelButton(
                  icon: 'assets/icons/hard.png',
                  label: 'Difícil',
                  pairs: 8,
                  onTap: () => _iniciarJogo(
                    8,
                    _timerEnabled,
                    _timerDuration,
                  ),
                ),
                _buildLevelButton(
                  icon: 'assets/icons/extreme.png',
                  label: 'Extremo',
                  pairs: 10,
                  onTap: () => _iniciarJogo(
                    10,
                    _timerEnabled,
                    _timerDuration,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // TEMPORIZADOR
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.bgCardNeutral,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/clock.svg',
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        colors.textMain,
                        BlendMode.srcIn,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Text(
                      'Temporizador',
                      style: TextStyle(
                        fontFamily: 'ComicSansMS',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: colors.textMain,
                      ),
                    ),

                    const Spacer(),

                    _DuoSwitch(
                      colors: colors,
                      value: _timerEnabled,
                      onChanged: (value) {
                        _playSound(
                          'audio/pressing.wav',
                        );

                        setState(() {
                          _timerEnabled = value;
                        });
                      },
                    ),
                  ],
                ),

                if (_timerEnabled) ...[
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Text(
                        'Tempo:',
                        style: TextStyle(
                          color: colors.textMain,
                        ),
                      ),

                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor:
                                AppColors.green,
                            inactiveTrackColor:
                                colors.divider,
                            thumbColor:
                                AppColors.green,
                            overlayColor:
                                AppColors.green.withOpacity(
                              0.15,
                            ),
                            valueIndicatorColor:
                                AppColors.green,
                          ),
                          child: Slider(
                            value: _timerDuration.toDouble(),
                            min: 15,
                            max: 120,
                            divisions: 7,
                            label:
                                '$_timerDuration s',
                            onChanged: (value) {
                              setState(() {
                                _timerDuration =
                                    value.round();
                              });
                            },
                          ),
                        ),
                      ),

                      Text(
                        '$_timerDuration s',
                        style: TextStyle(
                          color: colors.textMain,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // BOTÃO DE NÍVEL
  // ────────────────────────────────────────────────────────────

  Widget _buildLevelButton({
    required String icon,
    required String label,
    required int pairs,
    required VoidCallback onTap,
  }) {
    final colors = widget.colors;

    return _Bounce(
      onTap: () {
        _playSound(
          'audio/pressing.wav',
        );

        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: colors.c2Bg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors.divider,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Image.asset(
              icon,
              width: 50,
              height: 50,
              errorBuilder: (_, __, ___) {
                return const SizedBox(width: 50, height: 50);
              },
            ),

            const SizedBox(height: 10),

            Text(
              label,
              style: TextStyle(
                fontFamily: 'ComicSansMS',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: colors.textMain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // TELA PRINCIPAL DO JOGO
  // ────────────────────────────────────────────────────────────

  Widget _buildGame() {
    final colors = widget.colors;

    return Column(
      children: [
        // ───────────────── HEADER ─────────────────

        SizedBox(
          height: 58,
          child: Row(
            children: [
              const SizedBox(width: 10),

              _Bounce(
                onTap: _voltarParaNiveis,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colors.bgCardNeutral,
                    borderRadius:
                        BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: colors.divider,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/back.svg',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        colors.textMain,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  'Jogo da Memória',
                  style: TextStyle(
                    fontFamily: 'ComicSansMS',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: colors.textMain,
                  ),
                ),
              ),

              _audioBtn(
                ativo: _soundOn,
                iconOn:
                    'assets/icons/speaker-icon.svg',
                iconOff:
                    'assets/icons/speaker-off-icon.svg',
                onTap: _toggleSound,
              ),

              _audioBtn(
                ativo: _musicOn,
                iconOn:
                    'assets/icons/music_on.svg',
                iconOff:
                    'assets/icons/music_off.svg',
                onTap: _toggleMusic,
              ),

              const SizedBox(width: 4),

              Padding(
                padding: const EdgeInsets.only(
                  right: 10,
                ),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  crossAxisAlignment:
                      CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$_tentativas tentativas',
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.textMuted,
                      ),
                    ),

                    if (_timerEnabled)
                      Text(
                        '⏳ $_remainingSeconds s',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              FontWeight.w700,
                          color:
                              _remainingSeconds <= 10
                                  ? Colors.red
                                  : colors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ───────────────── CONTEÚDO ─────────────────

        Expanded(
          child: Stack(
            children: [
              Column(
                children: [
                  // BANNER
                  AnimatedSwitcher(
                    duration:
                        const Duration(milliseconds: 280),
                    child: _ganhou
                        ? _buildBannerVitoria()
                        : _streak >= 2
                            ? _buildBannerStreak()
                            : const SizedBox(
                                key: ValueKey(
                                  'vazio',
                                ),
                                height: 0,
                              ),
                  ),

                  // ───────────────── GRID ─────────────────

                  Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(
                        12,
                        12,
                        12,
                        12,
                      ),
                      child: LayoutBuilder(
                        builder:
                            (context, constraints) {
                          if (_cartas.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return GridView.builder(
                            itemCount:
                                _cartas.length,
                            physics:
                                const BouncingScrollPhysics(),
                            padding: EdgeInsets.zero,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.95,
                            ),
                            itemBuilder:
                                (context, index) {
                              return _Carta(
                                key: ValueKey(
                                  index,
                                ),
                                colors: colors,
                                letra:
                                    _cartas[index],
                                virada:
                                    _virada[index],
                                encontrada:
                                    _encontrada[
                                        index],
                                errou: index ==
                                        _erroA ||
                                    index ==
                                        _erroB,
                                onTap: () =>
                                    _tocar(index),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),

              // ───────────────── MENSAGEM ─────────────────

              if (_mensagem != null)
                IgnorePointer(
                  child: Center(
                    child:
                        TweenAnimationBuilder<double>(
                      key: ValueKey(_mensagem),
                      tween: Tween<double>(
                        begin: 0,
                        end: 1,
                      ),
                      duration:
                          const Duration(milliseconds: 260),
                      curve: Curves.elasticOut,
                      builder:
                          (_, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Opacity(
                            opacity:
                                value.clamp(0, 1),
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color:
                              colors.bgCardNeutral,
                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  colors.divider,
                              blurRadius: 16,
                              offset:
                                  const Offset(
                                0,
                                6,
                              ),
                            ),
                          ],
                        ),
                        child: Text(
                          _mensagem!,
                          style: TextStyle(
                            fontFamily:
                                'ComicSansMS',
                            fontWeight:
                                FontWeight.w700,
                            fontSize: 22,
                            color:
                                colors.textMain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // ───────────────── CONFETE ─────────────────

              if (_confettiController.isAnimating)
                IgnorePointer(
                  child: CustomPaint(
                    size: Size.infinite,
                    painter:
                        _ConfettiPainter(
                      particles: _confetti,
                      progress:
                          _confettiController.value,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────
  // BANNER VITÓRIA
  // ────────────────────────────────────────────────────────────

  Widget _buildBannerVitoria() {
    return Container(
      key: const ValueKey('venceu'),
      margin: const EdgeInsets.fromLTRB(
        16,
        10,
        16,
        0,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 13,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: AppColors.greenShadow,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '🎉 Parabéns! $_tentativas tent.',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'ComicSansMS',
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(width: 10),

          _Bounce(
            onTap: () {
              _playSound(
                'audio/pressing.wav',
              );

              _iniciarJogo(
                _levelPairs,
                _timerEnabled,
                _timerDuration,
              );
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color:
                    Colors.white.withOpacity(0.25),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: const Text(
                'Jogar de novo',
                style: TextStyle(
                  fontFamily: 'ComicSansMS',
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // BANNER STREAK
  // ────────────────────────────────────────────────────────────

  Widget _buildBannerStreak() {
    return Container(
      key: ValueKey(
        'streak$_streak',
      ),
      margin: const EdgeInsets.fromLTRB(
        16,
        10,
        16,
        0,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 9,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: AppColors.orange,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          '🔥 Sequência: $_streak em linha!',
          style: const TextStyle(
            fontFamily: 'ComicSansMS',
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// BOUNCE
// ──────────────────────────────────────────────────────────────

class _Bounce extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _Bounce({
    required this.child,
    required this.onTap,
  });

  @override
  State<_Bounce> createState() => _BounceState();
}

class _BounceState extends State<_Bounce> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) {
        setState(() {
          _down = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _down = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _down = false;
        });
      },
      child: AnimatedScale(
        scale: _down ? 0.88 : 1.0,
        duration:
            const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// CARTA
// ──────────────────────────────────────────────────────────────

class _Carta extends StatefulWidget {
  final AppColors colors;
  final String letra;
  final bool virada;
  final bool encontrada;
  final bool errou;
  final VoidCallback onTap;

  const _Carta({
    super.key,
    required this.colors,
    required this.letra,
    required this.virada,
    required this.encontrada,
    required this.errou,
    required this.onTap,
  });

  @override
  State<_Carta> createState() => _CartaState();
}

class _CartaState extends State<_Carta>
    with TickerProviderStateMixin {
  late final AnimationController _flip;
  late final AnimationController _shake;
  late final AnimationController _pop;

  bool get _revealed =>
      widget.virada || widget.encontrada;

  @override
  void initState() {
    super.initState();

    _flip = AnimationController(
      vsync: this,
      duration:
          const Duration(milliseconds: 360),
      value: _revealed ? 1.0 : 0.0,
    );

    _shake = AnimationController(
      vsync: this,
      duration:
          const Duration(milliseconds: 420),
    );

    _pop = AnimationController(
      vsync: this,
      duration:
          const Duration(milliseconds: 300),
      value: widget.encontrada ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(
    covariant _Carta oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    final oldRevealed =
        oldWidget.virada ||
        oldWidget.encontrada;

    if (_revealed != oldRevealed) {
      if (_revealed) {
        _flip.forward();
      } else {
        _flip.reverse();
      }
    }

    if (widget.errou &&
        !oldWidget.errou) {
      _shake.forward(
        from: 0,
      );
    }

    if (widget.encontrada &&
        !oldWidget.encontrada) {
      _pop.forward(
        from: 0.8,
      );
    }
  }

  @override
  void dispose() {
    _flip.dispose();
    _shake.dispose();
    _pop.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;

    // ─────────────────────────────────────────────
    // TRASEIRA DA CARTA
    // ─────────────────────────────────────────────

    final verso = Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: colors.c2Bg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: colors.divider,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '?',
          style: TextStyle(
            fontFamily: 'ComicSansMS',
            fontWeight: FontWeight.w700,
            fontSize: 30,
            color: colors.textMuted,
          ),
        ),
      ),
    );

    // ─────────────────────────────────────────────
    // FRENTE DA CARTA
    // ─────────────────────────────────────────────

    final face = Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: widget.encontrada
            ? AppColors.green
            : colors.bgCardNeutral,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: widget.encontrada
                ? AppColors.greenShadow
                : colors.divider,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          widget.letra,
          style: TextStyle(
            fontFamily: 'ComicSansMS',
            fontWeight: FontWeight.w700,
            fontSize: 30,
            color: widget.encontrada
                ? Colors.white
                : colors.textMain,
          ),
        ),
      ),
    );

    // ─────────────────────────────────────────────
    // ANIMAÇÃO DA CARTA
    // ─────────────────────────────────────────────

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _flip,
          _shake,
          _pop,
        ]),
        builder: (context, child) {
          final t = Curves.easeInOutCubic.transform(
            _flip.value,
          );

          final rotation = pi * t;

          final showingFace = t >= 0.5;

          Widget card;

          // ───────────────────────────────────────
          // TRASEIRA
          // ───────────────────────────────────────

          if (!showingFace) {
            card = verso;
          }

          // ───────────────────────────────────────
          // FRENTE
          // ───────────────────────────────────────

          else {
            card = Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..rotateY(pi),
              child: face,
            );
          }

          // Rotação principal.
          //
          // 0°   = traseira totalmente visível
          // 90°  = carta de lado
          // 180° = frente
          //
          card = Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(
                3,
                2,
                0.0015,
              )
              ..rotateY(rotation),
            child: card,
          );

          // ───────────────────────────────────────
          // SHAKE NO ERRO
          // ───────────────────────────────────────

          if (_shake.value > 0 &&
              _shake.value < 1) {
            final shake =
                sin(
                      _shake.value *
                          pi *
                          6,
                    ) *
                    (1 - _shake.value) *
                    7;

            card = Transform.translate(
              offset: Offset(
                shake,
                0,
              ),
              child: card,
            );
          }

          // ───────────────────────────────────────
          // POP AO ENCONTRAR PAR
          // ───────────────────────────────────────

          if (widget.encontrada) {
            final scale =
                0.8 +
                    (0.2 *
                        _pop.value);

            card = Transform.scale(
              scale: scale,
              child: card,
            );
          }

          return card;
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// SWITCH
// ──────────────────────────────────────────────────────────────

class _DuoSwitch extends StatelessWidget {
  final AppColors colors;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _DuoSwitch({
    required this.colors,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged(!value);
      },
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 200),
        width: 52,
        height: 30,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value
              ? AppColors.green
              : colors.bgCardNeutral,
          borderRadius:
              BorderRadius.circular(20),
        ),
        child: AnimatedAlign(
          duration:
              const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          alignment: value
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: colors.switchThumb,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color:
                      colors.switchThumbShadow,
                  offset:
                      const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// PARTÍCULA DE CONFETE
// ──────────────────────────────────────────────────────────────

class _ConfettiParticle {
  final double startX;
  final double angle;
  final double size;
  final Color color;
  final double spin;
  final bool isCircle;

  _ConfettiParticle(Random random)
      : startX = random.nextDouble(),
        angle =
            (random.nextDouble() - 0.5) *
                pi *
                0.9,
        size =
            5 +
                random.nextDouble() *
                    8,
        spin =
            (random.nextDouble() - 0.5) *
                14,
        isCircle =
            random.nextBool(),
        color = [
          AppColors.green,
          AppColors.orange,
          const Color(0xFF1CB0F6),
          const Color(0xFFFF4B8C),
          const Color(0xFFCE82FF),
          const Color(0xFFFFC800),
        ][
            random.nextInt(6)
        ];
}

// ──────────────────────────────────────────────────────────────
// PAINTER DO CONFETE
// ──────────────────────────────────────────────────────────────

class _ConfettiPainter
    extends CustomPainter {
  final List<_ConfettiParticle> particles;
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
    final paint = Paint();

    for (final particle in particles) {
      final fade =
          (1 - progress)
              .clamp(0.0, 1.0);

      final dx =
          size.width *
              particle.startX +
          sin(
                particle.angle,
              ) *
              160 *
              progress;

      final dy =
          -30 +
          size.height *
              progress *
              progress *
              0.95;

      paint.color =
          particle.color.withOpacity(
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
          particle.size * 0.5,
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
    covariant _ConfettiPainter oldDelegate,
  ) {
    return true;
  }
}