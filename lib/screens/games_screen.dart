import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:audioplayers/audioplayers.dart'; // novo import
import '../main.dart' show AppColors;
import 'game_memory_screen.dart';
import 'game_quiz_screen.dart';

// Player global para o som de clique
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
          descricao: 'Encontra os pares de letras e imagens!',
          coverPath: 'assets/covers/game_memory_cover.png',
          corIndex: 0,
          onTap: () => Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (_) => GameMemoryScreen(colors: colors),
            ),
          ),
        ),
        const SizedBox(height: 14),
        _GameCard(
          colors: colors,
          titulo: 'Quiz do Alfabeto',
          descricao: 'Testa o teu conhecimento das letras!',
          coverPath: 'assets/covers/game_quiz_cover.png',
          corIndex: 2,
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
  final String coverPath;
  final int corIndex;
  final VoidCallback onTap;

  const _GameCard({
    required this.colors,
    required this.titulo,
    required this.descricao,
    required this.coverPath,
    required this.corIndex,
    required this.onTap,
  });

  @override
  State<_GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<_GameCard> {
  bool _pressed = false;

  // Função para tocar o som
  Future<void> _playPressSound() async {
    try {
      await _soundPlayer.play(AssetSource('audio/pressing.wav'));
    } catch (e) {
      // Ignora erros, por exemplo se o arquivo não existir
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgList = widget.colors.cardBgList as List<Color>;
    final shadowList = widget.colors.cardShadowList as List<Color>;
    final bg = bgList[widget.corIndex];
    final shadow = shadowList[widget.corIndex];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _playPressSound(); // toca o som
        widget.onTap();    // executa a ação original
      },
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform:
            Matrix4.identity()..translate(0.0, _pressed ? 3.0 : 0.0),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: shadow,
              offset: Offset(0, _pressed ? 1 : 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cover com espaçamento e bordas curvas
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  widget.coverPath,
                  height: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 160,
                    color: widget.colors.bgCardNeutral,
                  ),
                ),
              ),
            ),
            // Informações
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.titulo,
                    style: TextStyle(
                      fontFamily: 'ComicSansMS',
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      color: widget.colors.textMain,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.descricao,
                    style: TextStyle(
                      fontSize: 13,
                      color: widget.colors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Botão JOGAR (visual, o clique é capturado pelo card)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
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
                    child: const Text(
                      'JOGAR',
                      style: TextStyle(
                        fontFamily: 'ComicSansMS',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
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