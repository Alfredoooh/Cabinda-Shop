import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:audioplayers/audioplayers.dart';
import '../main.dart' show AppColors;
import 'game_memory_screen.dart';
import 'game_quiz_screen.dart';

final AudioPlayer _soundPlayer = AudioPlayer();

class GamesScreen extends StatelessWidget {
  final AppColors colors;
  const GamesScreen({super.key, required this.colors});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        _GameCard(
          colors: colors,
          titulo: 'Jogo da Memória',
          descricao: 'Encontra os pares de letras antes que o tempo acabe!',
          emoji: '🧠',
          corCard: const Color(0xFF1CB0F6),
          corShadow: const Color(0xFF0A8AC4),
          onTap: () => Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (_) => GameMemoryScreen(colors: colors),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _GameCard(
          colors: colors,
          titulo: 'Quiz do Alfabeto',
          descricao: 'Testa o teu conhecimento das letras e sons!',
          emoji: '🎯',
          corCard: const Color(0xFFFF9600),
          corShadow: const Color(0xFFCC7700),
          onTap: () => Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (_) => GameQuizScreen(colors: colors),
            ),
          ),
        ),
      ],
    );
  }
}

class _GameCard extends StatefulWidget {
  final AppColors colors;
  final String titulo;
  final String descricao;
  final String emoji;
  final Color corCard;
  final Color corShadow;
  final VoidCallback onTap;

  const _GameCard({
    required this.colors,
    required this.titulo,
    required this.descricao,
    required this.emoji,
    required this.corCard,
    required this.corShadow,
    required this.onTap,
  });

  @override
  State<_GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<_GameCard>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _playPress() async {
    try {
      await _soundPlayer.stop();
      await _soundPlayer.play(AssetSource('audio/pressing.wav'));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _playPress();
        widget.onTap();
      },
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.identity()..translate(0.0, _pressed ? 4.0 : 0.0),
        decoration: BoxDecoration(
          color: colors.c2Bg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: widget.corShadow.withOpacity(0.35),
              offset: Offset(0, _pressed ? 1 : 5),
              blurRadius: 10,
            ),
            BoxShadow(
              color: colors.divider,
              offset: Offset(0, _pressed ? 1 : 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Banner colorido com emoji animado ──────────
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: widget.corCard.withOpacity(0.15),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: widget.corCard.withOpacity(0.25),
                    width: 1.5,
                  ),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Círculo decorativo de fundo
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.corCard.withOpacity(0.12),
                    ),
                  ),
                  // Emoji pulsante
                  AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (_, __) => Transform.scale(
                      scale: _pressed ? 0.88 : _pulseAnim.value,
                      child: Text(
                        widget.emoji,
                        style: const TextStyle(fontSize: 64),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Informações + botão ────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.titulo,
                    style: TextStyle(
                      fontFamily: 'ComicSansMS',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: colors.textMain,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.descricao,
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Botão JOGAR
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      color: widget.corCard,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: widget.corShadow,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'JOGAR',
                          style: TextStyle(
                            fontFamily: 'ComicSansMS',
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('▶', style: TextStyle(color: Colors.white, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}