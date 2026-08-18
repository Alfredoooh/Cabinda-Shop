import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:audioplayers/audioplayers.dart';
import '../main.dart' show AppColors, SoundManager;

enum _WordMode { letters, syllables }

class GameWordBuilderScreen extends StatefulWidget {
  final AppColors colors;
  const GameWordBuilderScreen({super.key, required this.colors});

  @override
  State<GameWordBuilderScreen> createState() => _GameWordBuilderScreenState();
}

class _GameWordBuilderScreenState extends State<GameWordBuilderScreen>
    with TickerProviderStateMixin {
  static const List<String> _lettersWords = [
    'casa', 'bola', 'gato', 'pato', 'mala', 'mesa', 'sapo', 'rato',
    'faca', 'boca', 'dado', 'galo', 'lata', 'mapa', 'vaca', 'vela',
    'banana', 'cavalo', 'caneta', 'tomate', 'macaco', 'sapato', 'boneca',
    'pipoca', 'janela', 'camisa', 'escola', 'amigo', 'abacaxi', 'bebe',
  ];

  static const List<List<String>> _syllableWords = [
    ['ca', 'sa'], ['bo', 'la'], ['ga', 'to'], ['pa', 'to'], ['ma', 'la'],
    ['me', 'sa'], ['sa', 'po'], ['ra', 'to'], ['fa', 'ca'], ['bo', 'ca'],
    ['da', 'do'], ['ga', 'lo'], ['la', 'ta'], ['ma', 'pa'], ['va', 'ca'],
    ['ve', 'la'], ['ba', 'na', 'na'], ['ca', 'va', 'lo'], ['ca', 'ne', 'ta'],
    ['to', 'ma', 'te'], ['ma', 'ca', 'co'], ['sa', 'pa', 'to'], ['bo', 'ne', 'ca'],
  ];

  final AudioPlayer _player = AudioPlayer();
  final Random _random = Random();

  _WordMode _mode = _WordMode.letters;
  late String _palavra;
  late List<String> _corretas;
  late List<String> _pecasDisponiveis;
  List<String> _montagem = [];

  int _streak = 0;
  int _melhorStreak = 0;
  int _corretasCount = 0;
  int _total = 0;
  int _xp = 0;
  int _vidas = 3;
  int _questao = 0;
  static const int _meta = 10;

  bool _bloqueado = false;
  String? _feedback;
  Timer? _feedbackTimer;
  Timer? _nextTimer;

  late AnimationController _success;
  late AnimationController _shake;

  @override
  void initState() {
    super.initState();
    _success = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _novaPalavra();
  }

  @override
  void dispose() {
    _feedbackTimer?.cancel();
    _nextTimer?.cancel();
    _success.dispose();
    _shake.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _click() async {
    if (SoundManager.instance.clickMuted) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/pressing.wav'));
    } catch (_) {}
  }

  Future<void> _correctSound() async {
    if (SoundManager.instance.muted) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/correct.wav'));
    } catch (_) {}
  }

  Future<void> _wrongSound() async {
    if (SoundManager.instance.muted) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/wrong.wav'));
    } catch (_) {}
  }

  void _novaPalavra() {
    _bloqueado = false;
    _feedback = null;
    _feedbackTimer?.cancel();
    _nextTimer?.cancel();

    if (_mode == _WordMode.letters) {
      final word = _lettersWords[_random.nextInt(_lettersWords.length)];
      _palavra = word;
      _corretas = word.split('');
    } else {
      final parts = _syllableWords[_random.nextInt(_syllableWords.length)];
      _corretas = [...parts];
      _palavra = parts.join('');
    }

    final extras = _mode == _WordMode.letters
        ? const ['a', 'e', 'i', 'o', 'u', 'm', 'r', 's', 't', 'l', 'p', 'c']
        : const ['ba', 'be', 'bi', 'ca', 'co', 'da', 'la', 'ma', 'pa', 'ra', 'sa', 'to'];

    final pieces = [..._corretas];
    while (pieces.length < max(6, _corretas.length + 3)) {
      pieces.add(extras[_random.nextInt(extras.length)]);
    }
    pieces.shuffle(_random);

    setState(() {
      _pecasDisponiveis = pieces;
      _montagem = [];
    });
  }

  void _adicionarPeca(int index) {
    if (_bloqueado || index < 0 || index >= _pecasDisponiveis.length) return;

    _click();
    final value = _pecasDisponiveis[index];

    setState(() {
      _montagem.add(value);
      _pecasDisponiveis.removeAt(index);
    });

    if (_montagem.length == _corretas.length) {
      _verificar();
    }
  }

  void _removerPeca(int index) {
    if (_bloqueado || index < 0 || index >= _montagem.length) return;

    _click();
    final value = _montagem.removeAt(index);
    setState(() {
      _pecasDisponiveis.add(value);
    });
  }

  void _verificar() {
    _bloqueado = true;
    final ok = _montagem.length == _corretas.length &&
        List.generate(_corretas.length, (i) => _montagem[i] == _corretas[i])
            .every((v) => v);

    setState(() {
      _total++;
      _questao++;
      if (ok) {
        _corretasCount++;
        _streak++;
        _melhorStreak = max(_melhorStreak, _streak);
        _xp += 12 + (_streak >= 3 ? 5 : 0);
        _feedback = 'Muito bem! ✨';
      } else {
        _vidas = max(0, _vidas - 1);
        _streak = 0;
        _feedback = 'Quase! Tenta outra vez.';
      }
    });

    if (ok) {
      _correctSound();
      _success.forward(from: 0);
    } else {
      _wrongSound();
      _shake.forward(from: 0);
    }

    _feedbackTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      if (_questao >= _meta || _vidas == 0) {
        _mostrarResultado();
      } else {
        _novaPalavra();
      }
    });
  }

  void _trocarModo(_WordMode mode) {
    if (_mode == mode || _bloqueado) return;
    _click();
    setState(() => _mode = mode);
    _novaPalavra();
  }

  void _mostrarResultado() {
    if (!mounted) return;
    final colors = widget.colors;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: colors.bgCardNeutral,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text('🎉 Lição concluída!', style: TextStyle(
          fontFamily: 'ComicSansMS', fontWeight: FontWeight.w700, color: colors.textMain,
        )),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ResultLine(label: 'Palavras', value: '$_corretasCount / $_total', colors: colors),
            _ResultLine(label: 'XP', value: '+$_xp', colors: colors),
            _ResultLine(label: 'Melhor sequência', value: '🔥 $_melhorStreak', colors: colors),
            _ResultLine(label: 'Vidas', value: '$_vidas / 3', colors: colors),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _questao = 0;
                _total = 0;
                _corretasCount = 0;
                _streak = 0;
                _melhorStreak = 0;
                _xp = 0;
                _vidas = 3;
              });
              _novaPalavra();
            },
            child: Text('Nova lição', style: TextStyle(color: colors.c2Fg, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final progress = (_questao / _meta).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 58,
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  _IconButton(
                    colors: colors,
                    asset: 'assets/icons/back.svg',
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text('Monta a Palavra', style: TextStyle(
                    fontFamily: 'ComicSansMS', fontWeight: FontWeight.w700,
                    fontSize: 18, color: colors.textMain,
                  ))),
                  Text('⚡ $_xp', style: TextStyle(fontWeight: FontWeight.w700, color: colors.c1Fg)),
                  const SizedBox(width: 12),
                  Text('❤️ $_vidas', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.redAccent)),
                  const SizedBox(width: 12),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: progress,
                  backgroundColor: colors.bgCardNeutral,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.c2Fg),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: colors.bgCardNeutral, borderRadius: BorderRadius.circular(14)),
                child: Row(children: [
                  _ModeButton(colors: colors, label: 'Letras', active: _mode == _WordMode.letters, onTap: () => _trocarModo(_WordMode.letters)),
                  const SizedBox(width: 4),
                  _ModeButton(colors: colors, label: 'Sílabas', active: _mode == _WordMode.syllables, onTap: () => _trocarModo(_WordMode.syllables)),
                ]),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                child: Column(
                  children: [
                    Text('Constrói a palavra', style: TextStyle(
                      fontFamily: 'ComicSansMS', fontWeight: FontWeight.w700,
                      fontSize: 21, color: colors.textMain,
                    )),
                    const SizedBox(height: 6),
                    Text('Escolhe as peças pela ordem correta.', style: TextStyle(color: colors.textMuted)),
                    const SizedBox(height: 18),
                    AnimatedBuilder(
                      animation: Listenable.merge([_success, _shake]),
                      builder: (_, child) {
                        final dx = sin(_shake.value * pi * 6) * (1 - _shake.value) * 7;
                        final scale = 1 + (_success.value * 0.025);
                        return Transform.translate(offset: Offset(dx, 0), child: Transform.scale(scale: scale, child: child));
                      },
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 105),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: colors.c1Bg, borderRadius: BorderRadius.circular(22)),
                        child: _montagem.isEmpty
                            ? Center(child: Text('Toque nas peças abaixo', style: TextStyle(color: colors.textMuted, fontSize: 15)))
                            : Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 8,
                                runSpacing: 8,
                                children: List.generate(_montagem.length, (i) => GestureDetector(
                                  onTap: () => _removerPeca(i),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: _mode == _WordMode.letters ? 14 : 12, vertical: 10),
                                    decoration: BoxDecoration(color: colors.c1Fg, borderRadius: BorderRadius.circular(12)),
                                    child: Text(_montagem[i].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22)),
                                  ),
                                )),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: _feedback == null
                          ? const SizedBox(height: 26)
                          : Text(_feedback!, key: ValueKey(_feedback), style: TextStyle(
                              fontFamily: 'ComicSansMS', fontWeight: FontWeight.w700,
                              color: _feedback!.startsWith('Muito') ? colors.c2Fg : AppColors.red,
                              fontSize: 16,
                            )),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _pecasDisponiveis.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.35,
                      ),
                      itemBuilder: (_, index) {
                        final piece = _pecasDisponiveis[index];
                        return GestureDetector(
                          onTap: () => _adicionarPeca(index),
                          child: Container(
                            decoration: BoxDecoration(
                              color: colors.c2Bg,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [BoxShadow(color: colors.c2Shadow, offset: const Offset(0, 4))],
                            ),
                            child: Center(child: Text(piece.toUpperCase(), style: TextStyle(
                              fontFamily: 'ComicSansMS', fontWeight: FontWeight.w700,
                              fontSize: _mode == _WordMode.letters ? 26 : 21,
                              color: colors.c2Fg,
                            ))),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
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
  const _ModeButton({required this.colors, required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? colors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: active ? [BoxShadow(color: colors.primaryShadow, offset: const Offset(0, 3))] : const [],
          ),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'ComicSansMS', fontWeight: FontWeight.w700, color: active ? Colors.white : colors.textMuted)),
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final AppColors colors;
  final String asset;
  final VoidCallback onTap;
  const _IconButton({required this.colors, required this.asset, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(color: colors.bgCardNeutral, borderRadius: BorderRadius.circular(12)),
        child: Center(child: SvgPicture.asset(asset, width: 20, height: 20, colorFilter: ColorFilter.mode(colors.textMain, BlendMode.srcIn))),
      ),
    );
  }
}

class _ResultLine extends StatelessWidget {
  final String label;
  final String value;
  final AppColors colors;
  const _ResultLine({required this.label, required this.value, required this.colors});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(color: colors.textMuted)),
      Text(value, style: TextStyle(fontWeight: FontWeight.w700, color: colors.textMain)),
    ]),
  );
}
