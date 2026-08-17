import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:audioplayers/audioplayers.dart';
import '../main.dart' show AppColors;

final AudioPlayer _soundPlayer = AudioPlayer();

class GameMemoryScreen extends StatefulWidget {
  final AppColors colors;
  const GameMemoryScreen({super.key, required this.colors});

  @override
  State<GameMemoryScreen> createState() => _GameMemoryScreenState();
}

class _GameMemoryScreenState extends State<GameMemoryScreen>
    with TickerProviderStateMixin {
  // Estado de seleção de nível
  bool _showLevelSelect = true;
  int _levelPairs = 6; // número de pares (4,6,8,10)
  bool _timerEnabled = false;
  int _timerDuration = 60; // segundos
  int _remainingSeconds = 60;
  Timer? _timer;

  // Estado do jogo
  static const List<String> _allLetters = [
    'A','B','C','D','E','F','G','H','I','J','K','L','M'
  ];
  late List<String> _cartas;
  late List<bool> _virada;
  late List<bool> _encontrada;
  int? _primeira;
  bool _bloqueado = false;
  int _tentativas = 0;

  // Índices do par errado atual (para animar o "wiggle" de erro)
  int? _erroA;
  int? _erroB;

  // Confete quando ganha o jogo
  final List<_ConfettiParticle> _confetti = [];
  late AnimationController _confettiController;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..addListener(() {
        if (mounted) setState(() {});
      });
    // Não inicia o jogo automaticamente; aguarda seleção de nível
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  // Inicia o jogo com a configuração escolhida
  void _iniciarJogo(int pares, bool timerOn, int duracao) {
    final letrasSelecionadas = _allLetters.sublist(0, pares);
    final cartas = [...letrasSelecionadas, ...letrasSelecionadas]..shuffle();
    setState(() {
      _levelPairs = pares;
      _timerEnabled = timerOn;
      _timerDuration = duracao;
      _remainingSeconds = duracao;
      _cartas = cartas;
      _virada = List.filled(cartas.length, false);
      _encontrada = List.filled(cartas.length, false);
      _primeira = null;
      _bloqueado = false;
      _tentativas = 0;
      _erroA = null;
      _erroB = null;
      _showLevelSelect = false;
    });
    if (_timerEnabled) {
      _startTimer();
    } else {
      _timer?.cancel();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _remainingSeconds--;
      });
      if (_remainingSeconds <= 0) {
        _timer?.cancel();
        _tempoEsgotado();
      }
    });
  }

  void _tempoEsgotado() {
    _playSound('audio/wrong.wav'); // ou um som específico de derrota
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.colors.bgCardNeutral,
        title: const Text('⏰ Tempo esgotado!'),
        content: const Text('Não conseguiste completar o jogo a tempo.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _showLevelSelect = true);
              _timer?.cancel();
            },
            child: const Text('Voltar aos níveis'),
          ),
        ],
      ),
    );
  }

  void _voltarParaNiveis() {
    _timer?.cancel();
    setState(() => _showLevelSelect = true);
  }

  Future<void> _playSound(String asset) async {
    try {
      await _soundPlayer.play(AssetSource(asset));
    } catch (e) {
      // ignora erros
    }
  }

  void _dispararConfete() {
    _confetti.clear();
    for (int i = 0; i < 40; i++) {
      _confetti.add(_ConfettiParticle(_random));
    }
    _confettiController.forward(from: 0);
  }

  void _tocar(int index) {
    if (_bloqueado || _virada[index] || _encontrada[index]) return;

    _playSound('audio/pressing.wav');
    setState(() => _virada[index] = true);

    if (_primeira == null) {
      _primeira = index;
    } else {
      final a = _primeira!;
      _primeira = null;
      _tentativas++;
      if (_cartas[a] == _cartas[index]) {
        // Acertou
        _playSound('audio/correct.wav');
        setState(() {
          _encontrada[a] = true;
          _encontrada[index] = true;
        });
        if (_ganhou) {
          _playSound('audio/win.wav');
          _timer?.cancel();
          _dispararConfete();
        }
      } else {
        // Errou
        _playSound('audio/wrong.wav');
        _bloqueado = true;
        setState(() {
          _erroA = a;
          _erroB = index;
        });
        Future.delayed(const Duration(milliseconds: 900), () {
          if (!mounted) return;
          setState(() {
            _virada[a] = false;
            _virada[index] = false;
            _bloqueado = false;
            _erroA = null;
            _erroB = null;
          });
        });
      }
    }
  }

  bool get _ganhou => _encontrada.every((e) => e);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.colors.bg,
      body: _showLevelSelect ? _buildLevelSelect() : _buildGame(),
    );
  }

  // Tela de seleção de nível
  Widget _buildLevelSelect() {
    final colors = widget.colors;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Botão voltar (se veio de outro lugar)
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: SvgPicture.asset(
                'assets/icons/back.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(colors.textMain, BlendMode.srcIn),
              ),
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
            // Grid de níveis
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
                    onTap: () {
                      _playSound('audio/pressing.wav');
                      _iniciarJogo(4, _timerEnabled, _timerDuration);
                    },
                  ),
                  _buildLevelButton(
                    icon: 'assets/icons/normal.png',
                    label: 'Normal',
                    pairs: 6,
                    onTap: () {
                      _playSound('audio/pressing.wav');
                      _iniciarJogo(6, _timerEnabled, _timerDuration);
                    },
                  ),
                  _buildLevelButton(
                    icon: 'assets/icons/hard.png',
                    label: 'Difícil',
                    pairs: 8,
                    onTap: () {
                      _playSound('audio/pressing.wav');
                      _iniciarJogo(8, _timerEnabled, _timerDuration);
                    },
                  ),
                  _buildLevelButton(
                    icon: 'assets/icons/extreme.png',
                    label: 'Extremo',
                    pairs: 10,
                    onTap: () {
                      _playSound('audio/pressing.wav');
                      _iniciarJogo(10, _timerEnabled, _timerDuration);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Secção do temporizador
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
                        colorFilter: ColorFilter.mode(colors.textMain, BlendMode.srcIn),
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
                        onChanged: (val) {
                          _playSound('audio/pressing.wav');
                          setState(() => _timerEnabled = val);
                        },
                      ),
                    ],
                  ),
                  if (_timerEnabled) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('Tempo:',
                            style: TextStyle(color: colors.textMain)),
                        Expanded(
                          child: SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: AppColors.green,
                              inactiveTrackColor: colors.divider,
                              thumbColor: AppColors.green,
                              overlayColor:
                                  AppColors.green.withOpacity(0.15),
                              valueIndicatorColor: AppColors.green,
                            ),
                            child: Slider(
                              value: _timerDuration.toDouble(),
                              min: 15,
                              max: 120,
                              divisions: 7,
                              label: '$_timerDuration s',
                              onChanged: (val) {
                                setState(() {
                                  _timerDuration = val.round();
                                });
                              },
                            ),
                          ),
                        ),
                        Text('$_timerDuration s',
                            style: TextStyle(color: colors.textMain)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelButton({
    required String icon,
    required String label,
    required int pairs,
    required VoidCallback onTap,
  }) {
    final colors = widget.colors;
    return _BounceOnTap(
      onTap: onTap,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              icon,
              width: 50,
              height: 50,
              errorBuilder: (_, __, ___) => Icon(
                Icons.star,
                size: 50,
                color: colors.textMain,
              ),
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

  // Tela do jogo
  Widget _buildGame() {
    final colors = widget.colors;
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: _voltarParaNiveis,
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/back.svg',
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(colors.textMain, BlendMode.srcIn),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$_tentativas tentativas',
                    style: TextStyle(fontSize: 13, color: colors.textMuted),
                  ),
                  if (_timerEnabled)
                    Text(
                      '⏳ $_remainingSeconds s',
                      style: TextStyle(
                        fontSize: 13,
                        color: _remainingSeconds <= 10 ? Colors.red : colors.textMuted,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.5),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                      parent: animation, curve: Curves.easeOutBack)),
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: _ganhou
                    ? Container(
                        key: const ValueKey('venceu'),
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
                              onTap: () {
                                _playSound('audio/pressing.wav');
                                _iniciarJogo(
                                    _levelPairs, _timerEnabled, _timerDuration);
                              },
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
                      )
                    : const SizedBox.shrink(key: ValueKey('vazio')),
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
                        errou: index == _erroA || index == _erroB,
                        onTap: () => _tocar(index),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          if (_confettiController.isAnimating)
            IgnorePointer(
              child: CustomPaint(
                size: Size.infinite,
                painter: _ConfettiPainter(
                  particles: _confetti,
                  progress: _confettiController.value,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Card com "bounce" ao premir, usado nos botões de nível.
class _BounceOnTap extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _BounceOnTap({required this.child, required this.onTap});

  @override
  State<_BounceOnTap> createState() => _BounceOnTapState();
}

class _BounceOnTapState extends State<_BounceOnTap> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Carta do jogo da memória com "flip" 3D e wiggle ao errar o par.
class _Carta extends StatelessWidget {
  final AppColors colors;
  final String letra;
  final bool virada;
  final bool encontrada;
  final bool errou;
  final VoidCallback onTap;

  const _Carta({
    required this.colors,
    required this.letra,
    required this.virada,
    required this.encontrada,
    required this.errou,
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

    Widget carta = TweenAnimationBuilder<double>(
      tween: Tween(begin: revealed ? 0 : 1, end: revealed ? 1 : 0),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutBack,
      builder: (context, t, child) {
        final angle = (1 - t) * pi / 2;
        final mostraFrente = t > 0.5;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..rotateY(angle),
          child: mostraFrente
              ? child
              : Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(pi),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.c2Bg,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(color: colors.divider, offset: const Offset(0, 3)),
                      ],
                    ),
                  ),
                ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: encontrada ? AppColors.greenShadow : colors.divider,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
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
    );

    // Wiggle (sacudidela) quando o par está errado
    if (errou) {
      carta = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 400),
        curve: Curves.elasticIn,
        builder: (context, value, child) {
          final shake = sin(value * pi * 6) * (1 - value) * 6;
          return Transform.translate(offset: Offset(shake, 0), child: child);
        },
        child: carta,
      );
    }

    // Pop de vitória quando encontra o par
    if (encontrada) {
      carta = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.85, end: 1.0),
        duration: const Duration(milliseconds: 280),
        curve: Curves.elasticOut,
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: carta,
      );
    }

    return GestureDetector(onTap: onTap, child: carta);
  }
}

/// Switch custom estilo Duolingo (mesmo padrão do _ThemeSwitch do drawer),
/// substitui o Switch() do Material que estava a destoar visualmente.
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
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 30,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? AppColors.green : colors.bgCardNeutral,
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: colors.switchThumb,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colors.switchThumbShadow,
                  offset: const Offset(0, 2),
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

/// Partícula individual de confete.
class _ConfettiParticle {
  final double startX;
  final double angle;
  final double size;
  final Color color;
  final double spin;

  _ConfettiParticle(Random random)
      : startX = random.nextDouble(),
        angle = (random.nextDouble() - 0.5) * pi * 0.8,
        size = 5 + random.nextDouble() * 7,
        spin = (random.nextDouble() - 0.5) * 12,
        color = [
          AppColors.green,
          AppColors.orange,
          const Color(0xFF1CB0F6),
          const Color(0xFFFF4B8C),
          const Color(0xFFCE82FF),
          const Color(0xFFFFC800),
        ][random.nextInt(6)];
}

/// Desenha o confete a cair a partir do topo do ecrã ao vencer o jogo.
class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (final p in particles) {
      final t = progress;
      final fade = (1 - t).clamp(0.0, 1.0);
      final dx = size.width * p.startX + sin(p.angle) * 150 * t;
      final dy = -20 + size.height * 0.9 * t * t + cos(p.angle) * 30;

      paint.color = p.color.withOpacity(fade);
      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(p.spin * t);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.5),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}