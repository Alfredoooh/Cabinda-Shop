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
  const GameMemoryScreen({super.key, required this.colors});

  @override
  State<GameMemoryScreen> createState() => _GameMemoryScreenState();
}

class _GameMemoryScreenState extends State<GameMemoryScreen>
    with TickerProviderStateMixin {
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
    'A','B','C','D','E','F','G','H','I','J','K','L','M'
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
  final _random = Random();

  static const List<String> _mensagensAcerto = [
    'Boa! 🌟',
    'Excelente! ✨',
    'Continua assim! 🚀',
    'Muito bem! 🎯',
    'Incrível! 💫',
  ];

  static const List<String> _mensagensStreak = [
    'Sequência incrível! 🔥',
    'Estás em fogo! 🔥🔥',
    'Imparável! 🔥🔥🔥',
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..addListener(() {
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mensagemTimer?.cancel();
    _confettiController.dispose();
    _musicPlayer.stop();
    super.dispose();
  }

  // ---------------- Áudio ----------------

  Future<void> _playSound(String asset) async {
    if (!_soundOn) return;
    try {
      await _soundPlayer.play(AssetSource(asset));
    } catch (e) {
      // ignora erros
    }
  }

  Future<void> _startMusic() async {
    if (_musicStarted) return;
    _musicStarted = true;
    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.setVolume(0.4);
      if (_musicOn) {
        await _musicPlayer.play(AssetSource('songs/playing_song.mp3'));
      }
    } catch (e) {
      // ignora erros
    }
  }

  Future<void> _toggleSound() async {
    _playSound('audio/pressing.wav');
    setState(() => _soundOn = !_soundOn);
  }

  Future<void> _toggleMusic() async {
    _playSound('audio/pressing.wav');
    setState(() => _musicOn = !_musicOn);
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
    } catch (e) {
      // ignora erros
    }
  }

  // ---------------- Fluxo do jogo ----------------

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
      _streak = 0;
      _erroA = null;
      _erroB = null;
      _mensagem = null;
      _showLevelSelect = false;
    });
    _startMusic();
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
    _playSound('audio/wrong.wav');
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
    _mensagemTimer?.cancel();
    setState(() => _showLevelSelect = true);
  }

  void _dispararConfete() {
    _confetti.clear();
    for (int i = 0; i < 60; i++) {
      _confetti.add(_ConfettiParticle(_random));
    }
    _confettiController.forward(from: 0);
  }

  void _mostrarMensagem(String texto) {
    _mensagemTimer?.cancel();
    setState(() => _mensagem = texto);
    _mensagemTimer = Timer(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      setState(() => _mensagem = null);
    });
  }

  void _tocar(int index) {
    if (_bloqueado ||
        index < 0 ||
        index >= _cartas.length ||
        _virada[index] ||
        _encontrada[index]) {
      return;
    }

    _playSound('audio/pressing.wav');

    if (_primeira == null) {
      setState(() {
        _virada[index] = true;
        _primeira = index;
      });
      return;
    }

    final a = _primeira!;
    if (a == index) return;

    setState(() {
      _virada[index] = true;
      _bloqueado = true;
      _primeira = null;
      _tentativas++;
    });

    if (_cartas[a] == _cartas[index]) {
      _playSound('audio/correct.wav');
      _streak++;

      setState(() {
        _encontrada[a] = true;
        _encontrada[index] = true;
        _bloqueado = false;
      });

      if (_streak >= 3) {
        _mostrarMensagem(
            _mensagensStreak[min(_streak - 3, _mensagensStreak.length - 1)]);
      } else {
        _mostrarMensagem(
            _mensagensAcerto[_random.nextInt(_mensagensAcerto.length)]);
      }

      if (_ganhou) {
        _playSound('audio/win.wav');
        _timer?.cancel();
        _dispararConfete();
      }
    } else {
      _playSound('audio/wrong.wav');
      _streak = 0;
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

  bool get _ganhou => _encontrada.every((e) => e);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.colors.bg,
      body: _showLevelSelect ? _buildLevelSelect() : _buildGame(),
    );
  }

  // ---------------- Botão circular de áudio estilo Duolingo ----------------

  Widget _audioButton({
    required bool ativo,
    required String iconOn,
    required String iconOff,
    required VoidCallback onTap,
  }) {
    final colors = widget.colors;
    return _BounceOnTap(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.bgCardNeutral,
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
            colorFilter: ColorFilter.mode(colors.textMain, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelSelect() {
    final colors = widget.colors;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _BounceOnTap(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.bgCardNeutral,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/back.svg',
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(
                            colors.textMain, BlendMode.srcIn),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    _audioButton(
                      ativo: _soundOn,
                      iconOn: 'assets/icons/speaker-icon.svg',
                      iconOff: 'assets/icons/speaker-off-icon.svg',
                      onTap: _toggleSound,
                    ),
                    _audioButton(
                      ativo: _musicOn,
                      iconOn: 'assets/icons/music_on.svg',
                      iconOff: 'assets/icons/music_off.svg',
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
                    onTap: () => _iniciarJogo(4, _timerEnabled, _timerDuration),
                  ),
                  _buildLevelButton(
                    icon: 'assets/icons/normal.png',
                    label: 'Normal',
                    pairs: 6,
                    onTap: () => _iniciarJogo(6, _timerEnabled, _timerDuration),
                  ),
                  _buildLevelButton(
                    icon: 'assets/icons/hard.png',
                    label: 'Difícil',
                    pairs: 8,
                    onTap: () => _iniciarJogo(8, _timerEnabled, _timerDuration),
                  ),
                  _buildLevelButton(
                    icon: 'assets/icons/extreme.png',
                    label: 'Extremo',
                    pairs: 10,
                    onTap: () => _iniciarJogo(10, _timerEnabled, _timerDuration),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
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
                        colorFilter:
                            ColorFilter.mode(colors.textMain, BlendMode.srcIn),
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
                              overlayColor: AppColors.green.withOpacity(0.15),
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
      onTap: () {
        _playSound('audio/pressing.wav');
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

  Widget _buildGame() {
    final colors = widget.colors;
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: _BounceOnTap(
            onTap: _voltarParaNiveis,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.bgCardNeutral,
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/back.svg',
                  width: 18,
                  height: 18,
                  colorFilter:
                      ColorFilter.mode(colors.textMain, BlendMode.srcIn),
                ),
              ),
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
          _audioButton(
            ativo: _soundOn,
            iconOn: 'assets/icons/speaker-icon.svg',
            iconOff: 'assets/icons/speaker-off-icon.svg',
            onTap: _toggleSound,
          ),
          _audioButton(
            ativo: _musicOn,
            iconOn: 'assets/icons/music_on.svg',
            iconOff: 'assets/icons/music_off.svg',
            onTap: _toggleMusic,
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 4),
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
                        color: _remainingSeconds <= 10
                            ? Colors.red
                            : colors.textMuted,
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
                                _iniciarJogo(_levelPairs, _timerEnabled,
                                    _timerDuration);
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
                    : (_streak >= 2
                        ? Container(
                            key: ValueKey('streak-$_streak'),
                            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.orange,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '🔥 Sequência: $_streak',
                                  style: const TextStyle(
                                    fontFamily: 'ComicSansMS',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(key: ValueKey('vazio'))),
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
                      // key por índice garante que o Flutter nunca troca o
                      // Elemento desta carta por outro durante o rebuild,
                      // o que era a causa principal do "sumiço".
                      return _Carta(
                        key: ValueKey('carta_$index'),
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
          if (_mensagem != null)
            IgnorePointer(
              child: Center(
                child: TweenAnimationBuilder<double>(
                  key: ValueKey(_mensagem),
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.elasticOut,
                  builder: (context, t, child) => Transform.scale(
                    scale: t,
                    child: Opacity(opacity: t.clamp(0, 1), child: child),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      color: colors.bgCardNeutral,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: colors.divider,
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      _mensagem!,
                      style: TextStyle(
                        fontFamily: 'ComicSansMS',
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: colors.textMain,
                      ),
                    ),
                  ),
                ),
              ),
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

/// Bounce ao premir, usado em botões de nível e círculos de áudio.
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
        scale: _pressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Carta do jogo da memória.
///
/// Reescrita como StatefulWidget com AnimationController próprio e fixo.
/// Antes, o flip era feito com TweenAnimationBuilder dentro de um build()
/// que corria de novo a cada setState do ecrã pai — isso recriava a árvore
/// de widgets da carta a meio da animação, fazendo-a "sumir" ou piscar em
/// vez de rodar suavemente. Agora o controller vive fora do build() e só
/// reage a mudanças reais de estado (didUpdateWidget), garantindo uma
/// única fonte de verdade para o ângulo do flip.
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

class _CartaState extends State<_Carta> with TickerProviderStateMixin {
  late final AnimationController _flipController;
  late final AnimationController _shakeController;
  late final AnimationController _popController;

  bool get _revealed => widget.virada || widget.encontrada;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      value: _revealed ? 1.0 : 0.0,
    );
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: widget.encontrada ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(covariant _Carta old) {
    super.didUpdateWidget(old);

    final wasRevealed = old.virada || old.encontrada;
    if (_revealed != wasRevealed) {
      if (_revealed) {
        _flipController.forward();
      } else {
        _flipController.reverse();
      }
    }

    if (widget.errou && !old.errou) {
      _shakeController.forward(from: 0);
    }

    if (widget.encontrada && !old.encontrada) {
      _popController.forward(from: 0.85);
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    _shakeController.dispose();
    _popController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final bg = widget.encontrada
        ? AppColors.green
        : _revealed
            ? colors.bgCardNeutral
            : colors.c2Bg;

    Widget face = Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: widget.encontrada ? AppColors.greenShadow : colors.divider,
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
            fontSize: 28,
            color: widget.encontrada ? Colors.white : colors.textMain,
          ),
        ),
      ),
    );

    Widget verso = Container(
      decoration: BoxDecoration(
        color: colors.c2Bg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: colors.divider, offset: const Offset(0, 3)),
        ],
      ),
    );

    Widget carta = AnimatedBuilder(
      animation: Listenable.merge(
          [_flipController, _shakeController, _popController]),
      builder: (context, _) {
        final t = _flipController.value;
        final angle = (1 - t) * pi / 2;
        final mostraFrente = t > 0.5;

        Widget conteudo = Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..rotateY(angle),
          child: mostraFrente
              ? face
              : Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(pi),
                  child: verso,
                ),
        );

        if (_shakeController.isAnimating) {
          final v = _shakeController.value;
          final shake = sin(v * pi * 6) * (1 - v) * 6;
          conteudo = Transform.translate(
              offset: Offset(shake, 0), child: conteudo);
        }

        if (widget.encontrada) {
          final scale = 0.85 + (0.15 * _popController.value);
          conteudo = Transform.scale(scale: scale, child: conteudo);
        }

        return conteudo;
      },
    );

    return GestureDetector(onTap: widget.onTap, child: carta);
  }
}

/// Switch custom estilo Duolingo.
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
        Rect.fromCenter(
            center: Offset.zero, width: p.size, height: p.size * 0.5),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}