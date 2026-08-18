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
    'Boa! 🌟', 'Excelente! ✨', 'Continua! 🚀', 'Muito bem! 🎯', 'Incrível! 💫',
  ];
  static const List<String> _mensagensStreak = [
    'Sequência! 🔥', 'Em fogo! 🔥🔥', 'Imparável! 🔥🔥🔥',
  ];

  // Configurações de nível
  static const _niveis = [
    {'label': 'Fácil',   'emoji': '😊', 'pairs': 4,  'cor': Color(0xFF58CC02)},
    {'label': 'Normal',  'emoji': '😐', 'pairs': 6,  'cor': Color(0xFF1CB0F6)},
    {'label': 'Difícil', 'emoji': '😤', 'pairs': 8,  'cor': Color(0xFFFF9600)},
    {'label': 'Extremo', 'emoji': '🔥', 'pairs': 10, 'cor': Color(0xFFFF4B8C)},
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..addListener(() { if (mounted) setState(() {}); });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mensagemTimer?.cancel();
    _confettiController.dispose();
    _musicPlayer.stop();
    super.dispose();
  }

  // ─── Áudio ────────────────────────────────────────────────

  Future<void> _playSound(String asset) async {
    if (!_soundOn) return;
    try {
      await _soundPlayer.stop();
      await _soundPlayer.play(AssetSource(asset));
    } catch (_) {}
  }

  Future<void> _startMusic() async {
    if (_musicStarted) return;
    _musicStarted = true;
    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.setVolume(0.35);
      if (_musicOn) await _musicPlayer.play(AssetSource('songs/playing_song.mp3'));
    } catch (_) {}
  }

  Future<void> _toggleSound() async {
    setState(() => _soundOn = !_soundOn);
    if (_soundOn) _playSound('audio/pressing.wav');
  }

  Future<void> _toggleMusic() async {
    setState(() => _musicOn = !_musicOn);
    try {
      if (_musicOn) {
        if (!_musicStarted) { await _startMusic(); }
        else { await _musicPlayer.resume(); }
      } else {
        await _musicPlayer.pause();
      }
    } catch (_) {}
    if (_soundOn) _playSound('audio/pressing.wav');
  }

  // ─── Fluxo do jogo ────────────────────────────────────────

  void _iniciarJogo(int pares, bool timerOn, int duracao) {
    final letras = _allLetters.sublist(0, pares);
    final cartas = [...letras, ...letras]..shuffle();
    setState(() {
      _levelPairs   = pares;
      _timerEnabled = timerOn;
      _timerDuration = duracao;
      _remainingSeconds = duracao;
      _cartas    = cartas;
      _virada    = List.filled(cartas.length, false);
      _encontrada = List.filled(cartas.length, false);
      _primeira  = null;
      _bloqueado = false;
      _tentativas = 0;
      _streak    = 0;
      _erroA = null;
      _erroB = null;
      _mensagem = null;
      _showLevelSelect = false;
    });
    _startMusic();
    _timerEnabled ? _startTimer() : _timer?.cancel();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _remainingSeconds--);
      if (_remainingSeconds <= 0) { _timer?.cancel(); _tempoEsgotado(); }
    });
  }

  void _tempoEsgotado() {
    _playSound('audio/wrong.wav');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.colors.bgCardNeutral,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('⏰ Tempo esgotado!'),
        content: const Text('Não conseguiste completar o jogo a tempo.'),
        actions: [
          TextButton(
            onPressed: () { Navigator.pop(ctx); setState(() => _showLevelSelect = true); _timer?.cancel(); },
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
    for (int i = 0; i < 70; i++) _confetti.add(_ConfettiParticle(_random));
    _confettiController.forward(from: 0);
  }

  void _mostrarMensagem(String texto) {
    _mensagemTimer?.cancel();
    setState(() => _mensagem = texto);
    _mensagemTimer = Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() => _mensagem = null);
    });
  }

  void _tocar(int index) {
    if (_bloqueado || index < 0 || index >= _cartas.length ||
        _virada[index] || _encontrada[index]) return;

    _playSound('audio/pressing.wav');

    if (_primeira == null) {
      setState(() { _virada[index] = true; _primeira = index; });
      return;
    }

    final a = _primeira!;
    if (a == index) return;

    setState(() {
      _virada[index] = true;
      _bloqueado = true;
      _primeira  = null;
      _tentativas++;
    });

    if (_cartas[a] == _cartas[index]) {
      _playSound('audio/correct.wav');
      _streak++;
      setState(() {
        _encontrada[a]     = true;
        _encontrada[index] = true;
        _bloqueado = false;
      });
      _mostrarMensagem(_streak >= 3
          ? _mensagensStreak[min(_streak - 3, _mensagensStreak.length - 1)]
          : _mensagensAcerto[_random.nextInt(_mensagensAcerto.length)]);
      if (_ganhou) { _playSound('audio/win.wav'); _timer?.cancel(); _dispararConfete(); }
    } else {
      _playSound('audio/wrong.wav');
      _streak = 0;
      setState(() { _erroA = a; _erroB = index; });
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        setState(() {
          _virada[a]     = false;
          _virada[index] = false;
          _bloqueado = false;
          _erroA = null;
          _erroB = null;
        });
      });
    }
  }

  bool get _ganhou => _encontrada.every((e) => e);

  // ─── Build ────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.colors.bg,
      body: _showLevelSelect ? _buildLevelSelect() : _buildGame(),
    );
  }

  // ─── Botão circular áudio ─────────────────────────────────

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
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.bgCardNeutral,
          boxShadow: [BoxShadow(color: colors.divider, offset: const Offset(0, 3))],
        ),
        child: Center(
          child: SvgPicture.asset(
            ativo ? iconOn : iconOff,
            width: 20, height: 20,
            colorFilter: ColorFilter.mode(
              ativo ? colors.textMain : colors.textMuted,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  // ─── Tela de seleção de nível ─────────────────────────────

  Widget _buildLevelSelect() {
    final colors = widget.colors;
    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                _Bounce(
                  onTap: () { _playSound('audio/pressing.wav'); Navigator.of(context).pop(); },
                  child: Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.bgCardNeutral,
                      boxShadow: [BoxShadow(color: colors.divider, offset: const Offset(0, 3))],
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/back.svg', width: 20, height: 20,
                        colorFilter: ColorFilter.mode(colors.textMain, BlendMode.srcIn),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                _audioBtn(
                  ativo: _soundOn,
                  iconOn: 'assets/icons/speaker-icon.svg',
                  iconOff: 'assets/icons/speaker-off-icon.svg',
                  onTap: _toggleSound,
                ),
                _audioBtn(
                  ativo: _musicOn,
                  iconOn: 'assets/icons/music_on.svg',
                  iconOff: 'assets/icons/music_off.svg',
                  onTap: _toggleMusic,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Text(
            '🎮 Escolhe o nível',
            style: TextStyle(
              fontFamily: 'ComicSansMS',
              fontWeight: FontWeight.w700,
              fontSize: 22,
              color: colors.textMain,
            ),
          ),
          const SizedBox(height: 20),

          // Grid de níveis — usa Wrap para nunca colapsar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _niveis.map((n) {
                return _buildLevelCard(
                  emoji: n['emoji'] as String,
                  label: n['label'] as String,
                  pairs: n['pairs'] as int,
                  cor: n['cor'] as Color,
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // Temporizador
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.bgCardNeutral,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: colors.divider, offset: const Offset(0, 3))],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('⏱️', style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      Text('Temporizador', style: TextStyle(
                        fontFamily: 'ComicSansMS',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: colors.textMain,
                      )),
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
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text('$_timerDuration s', style: TextStyle(
                          fontFamily: 'ComicSansMS',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: colors.textMain,
                        )),
                        Expanded(
                          child: SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: AppColors.green,
                              inactiveTrackColor: colors.divider,
                              thumbColor: AppColors.green,
                              overlayColor: AppColors.green.withOpacity(0.15),
                            ),
                            child: Slider(
                              value: _timerDuration.toDouble(),
                              min: 15, max: 120, divisions: 7,
                              label: '$_timerDuration s',
                              onChanged: (val) => setState(() => _timerDuration = val.round()),
                            ),
                          ),
                        ),
                        Text('2 min', style: TextStyle(fontSize: 12, color: colors.textMuted)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLevelCard({
    required String emoji,
    required String label,
    required int pairs,
    required Color cor,
  }) {
    final colors = widget.colors;
    // calcula metade do ecrã menos padding e spacing
    final cardW = (MediaQuery.of(context).size.width - 32 - 12) / 2;

    return _Bounce(
      onTap: () {
        _playSound('audio/pressing.wav');
        _iniciarJogo(pairs, _timerEnabled, _timerDuration);
      },
      child: Container(
        width: cardW,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
        decoration: BoxDecoration(
          color: cor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: cor.withOpacity(0.5), width: 2),
          boxShadow: [BoxShadow(color: cor.withOpacity(0.18), offset: const Offset(0, 4), blurRadius: 8)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 42)),
            const SizedBox(height: 10),
            Text(label, style: TextStyle(
              fontFamily: 'ComicSansMS',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: cor,
            )),
            const SizedBox(height: 4),
            Text('$pairs pares', style: TextStyle(fontSize: 12, color: colors.textMuted)),
          ],
        ),
      ),
    );
  }

  // ─── Tela do jogo ─────────────────────────────────────────

  Widget _buildGame() {
    final colors = widget.colors;
    // Descobre colunas consoante pares
    final cols = _levelPairs <= 4 ? 4 : 4;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: _Bounce(
            onTap: _voltarParaNiveis,
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.bgCardNeutral,
                boxShadow: [BoxShadow(color: colors.divider, offset: const Offset(0, 3))],
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/back.svg', width: 18, height: 18,
                  colorFilter: ColorFilter.mode(colors.textMain, BlendMode.srcIn),
                ),
              ),
            ),
          ),
        ),
        title: Text('Jogo da Memória', style: TextStyle(
          fontFamily: 'ComicSansMS',
          fontWeight: FontWeight.w700,
          fontSize: 17,
          color: colors.textMain,
        )),
        actions: [
          _audioBtn(
            ativo: _soundOn,
            iconOn: 'assets/icons/speaker-icon.svg',
            iconOff: 'assets/icons/speaker-off-icon.svg',
            onTap: _toggleSound,
          ),
          _audioBtn(
            ativo: _musicOn,
            iconOn: 'assets/icons/music_on.svg',
            iconOff: 'assets/icons/music_off.svg',
            onTap: _toggleMusic,
          ),
          const SizedBox(width: 8),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$_tentativas tent.', style: TextStyle(fontSize: 12, color: colors.textMuted)),
                  if (_timerEnabled)
                    Text('⏳ $_remainingSeconds s', style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _remainingSeconds <= 10 ? Colors.red : colors.textMuted,
                    )),
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
              // Banner topo (vitória ou streak)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                child: _ganhou
                    ? _buildBannerVitoria()
                    : _streak >= 2
                        ? _buildBannerStreak()
                        : const SizedBox.shrink(key: ValueKey('vazio')),
              ),

              // ─── GRID DAS CARTAS ───────────────────────────
              // Usa LayoutBuilder + GridView com shrinkWrap:false
              // e sem NeverScrollableScrollPhysics para o web
              // nunca colapsar a altura.
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final total   = _cartas.length; // sempre par
                    final spacing = 10.0;
                    final pad     = 16.0;
                    final availW  = constraints.maxWidth - pad * 2;
                    final cellW   = (availW - spacing * (cols - 1)) / cols;
                    final rows    = (total / cols).ceil();
                    final gridH   = rows * cellW + (rows - 1) * spacing;
                    final availH  = constraints.maxHeight - pad * 2;
                    // Se cabe sem scroll usa SizedBox fixo, senão scrollável
                    final needsScroll = gridH > availH;

                    final grid = GridView.builder(
                      padding: EdgeInsets.all(pad),
                      physics: needsScroll
                          ? const BouncingScrollPhysics()
                          : const NeverScrollableScrollPhysics(),
                      shrinkWrap: needsScroll ? false : true,
                      itemCount: total,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        mainAxisSpacing: spacing,
                        crossAxisSpacing: spacing,
                      ),
                      itemBuilder: (_, i) => _Carta(
                        key: ValueKey('carta_$i'),
                        colors: colors,
                        letra: _cartas[i],
                        virada: _virada[i],
                        encontrada: _encontrada[i],
                        errou: i == _erroA || i == _erroB,
                        onTap: () => _tocar(i),
                      ),
                    );

                    return needsScroll ? grid : SingleChildScrollView(child: grid);
                  },
                ),
              ),
            ],
          ),

          // Mensagem flutuante
          if (_mensagem != null)
            IgnorePointer(
              child: Center(
                child: TweenAnimationBuilder<double>(
                  key: ValueKey(_mensagem),
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.elasticOut,
                  builder: (_, t, child) => Transform.scale(
                    scale: t, child: Opacity(opacity: t.clamp(0, 1), child: child),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                    decoration: BoxDecoration(
                      color: colors.bgCardNeutral,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: colors.divider, blurRadius: 16, offset: const Offset(0, 6))],
                    ),
                    child: Text(_mensagem!, style: TextStyle(
                      fontFamily: 'ComicSansMS',
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      color: colors.textMain,
                    )),
                  ),
                ),
              ),
            ),

          // Confete
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

  Widget _buildBannerVitoria() {
    return Container(
      key: const ValueKey('venceu'),
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: AppColors.greenShadow, offset: Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('🎉 Parabéns! $_tentativas tent.', style: const TextStyle(
            fontFamily: 'ComicSansMS', fontWeight: FontWeight.w700,
            fontSize: 14, color: Colors.white,
          )),
          _Bounce(
            onTap: () { _playSound('audio/pressing.wav'); _iniciarJogo(_levelPairs, _timerEnabled, _timerDuration); },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Jogar de novo', style: TextStyle(
                fontFamily: 'ComicSansMS', fontWeight: FontWeight.w700,
                fontSize: 12, color: Colors.white,
              )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerStreak() {
    return Container(
      key: ValueKey('streak$_streak'),
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.orange,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🔥 Sequência: $_streak em linha!', style: const TextStyle(
            fontFamily: 'ComicSansMS', fontWeight: FontWeight.w700,
            fontSize: 13, color: Colors.white,
          )),
        ],
      ),
    );
  }
}

// ─── _Bounce ──────────────────────────────────────────────────────────────────

class _Bounce extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _Bounce({required this.child, required this.onTap});

  @override
  State<_Bounce> createState() => _BounceState();
}

class _BounceState extends State<_Bounce> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

// ─── _Carta ───────────────────────────────────────────────────────────────────
//
// StatefulWidget com AnimationController próprio.
// A key ValueKey('carta_$index') no GridView garante que o Flutter
// nunca reutiliza o Element desta carta para outra posição.

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
  late final AnimationController _flip;
  late final AnimationController _shake;
  late final AnimationController _pop;

  bool get _revealed => widget.virada || widget.encontrada;

  @override
  void initState() {
    super.initState();
    _flip = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      value: _revealed ? 1.0 : 0.0,
    );
    _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _pop   = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    if (widget.encontrada) _pop.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant _Carta old) {
    super.didUpdateWidget(old);
    final wasRevealed = old.virada || old.encontrada;
    if (_revealed != wasRevealed) {
      _revealed ? _flip.forward() : _flip.reverse();
    }
    if (widget.errou && !old.errou) _shake.forward(from: 0);
    if (widget.encontrada && !old.encontrada) _pop.forward(from: 0.8);
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

    final faceColor = widget.encontrada
        ? AppColors.green
        : _revealed
            ? colors.bgCardNeutral
            : colors.c2Bg;

    final verso = Container(
      decoration: BoxDecoration(
        color: colors.c2Bg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: colors.divider, offset: const Offset(0, 3))],
      ),
      // Padrão no verso para ser mais divertido
      child: Center(
        child: Text('?', style: TextStyle(
          fontFamily: 'ComicSansMS',
          fontWeight: FontWeight.w700,
          fontSize: 26,
          color: colors.textMuted.withOpacity(0.3),
        )),
      ),
    );

    final face = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: faceColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: widget.encontrada ? AppColors.greenShadow : colors.divider,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(widget.letra, style: TextStyle(
          fontFamily: 'ComicSansMS',
          fontWeight: FontWeight.w700,
          fontSize: 28,
          color: widget.encontrada ? Colors.white : colors.textMain,
        )),
      ),
    );

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_flip, _shake, _pop]),
        builder: (_, __) {
          final t     = _flip.value;
          final angle = (1 - t) * pi / 2;
          final showFace = t > 0.5;

          Widget w = Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0015)
              ..rotateY(angle),
            child: showFace
                ? face
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: verso,
                  ),
          );

          // Shake ao errar
          if (_shake.value > 0 && _shake.value < 1) {
            final s = sin(_shake.value * pi * 6) * (1 - _shake.value) * 7;
            w = Transform.translate(offset: Offset(s, 0), child: w);
          }

          // Pop ao acertar
          if (widget.encontrada) {
            final scale = 0.8 + 0.2 * _pop.value;
            w = Transform.scale(scale: scale, child: w);
          }

          return w;
        },
      ),
    );
  }
}

// ─── _DuoSwitch ───────────────────────────────────────────────────────────────

class _DuoSwitch extends StatelessWidget {
  final AppColors colors;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _DuoSwitch({required this.colors, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52, height: 30,
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
            width: 24, height: 24,
            decoration: BoxDecoration(
              color: colors.switchThumb,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(
                color: colors.switchThumbShadow,
                offset: const Offset(0, 2),
                blurRadius: 4,
              )],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Confete ──────────────────────────────────────────────────────────────────

class _ConfettiParticle {
  final double startX;
  final double angle;
  final double size;
  final Color color;
  final double spin;
  final bool isCircle;

  _ConfettiParticle(Random r)
      : startX   = r.nextDouble(),
        angle    = (r.nextDouble() - 0.5) * pi * 0.9,
        size     = 5 + r.nextDouble() * 8,
        spin     = (r.nextDouble() - 0.5) * 14,
        isCircle = r.nextBool(),
        color    = [
          AppColors.green,
          AppColors.orange,
          const Color(0xFF1CB0F6),
          const Color(0xFFFF4B8C),
          const Color(0xFFCE82FF),
          const Color(0xFFFFC800),
        ][r.nextInt(6)];
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;
  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in particles) {
      final fade = (1 - progress).clamp(0.0, 1.0);
      final dx = size.width * p.startX + sin(p.angle) * 160 * progress;
      final dy = -30 + size.height * progress * progress * 0.95;
      paint.color = p.color.withOpacity(fade);
      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(p.spin * progress);
      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size * 0.5, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.5),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => true;
}