import 'package:flutter/material.dart';
import '../models/playlist_model.dart';
import 'video_player_screen.dart';

class PlaylistVideosScreen extends StatelessWidget {
  final dynamic colors;
  final PlaylistItem playlist;

  const PlaylistVideosScreen({
    super.key,
    required this.colors,
    required this.playlist,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.textMain),
        title: Text(
          playlist.nome,
          style: TextStyle(
            fontFamily: 'ComicSansMS',
            fontWeight: FontWeight.w700,
            color: colors.textMain,
            fontSize: 18,
          ),
        ),
      ),
      body: playlist.videos.isEmpty
          ? Center(
              child: Text(
                'Nenhum vídeo nesta playlist.',
                style: TextStyle(color: colors.textMuted),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: playlist.videos.length,
              itemBuilder: (context, index) {
                final video = playlist.videos[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _VideoCard(
                    colors: colors,
                    video: video,
                    corIndex: index % 6,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => VideoPlayerScreen(
                            colors: colors,
                            video: video,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class _VideoCard extends StatefulWidget {
  final dynamic colors;
  final VideoItem video;
  final int corIndex;
  final VoidCallback onTap;

  const _VideoCard({
    required this.colors,
    required this.video,
    required this.corIndex,
    required this.onTap,
  });

  @override
  State<_VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<_VideoCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final bgList = colors.cardBgList as List<Color>;
    final shadowList = colors.cardShadowList as List<Color>;

    final bg = bgList[widget.corIndex];
    final shadow = shadowList[widget.corIndex];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.identity()..translate(0.0, _pressed ? 2.0 : 0.0),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: shadow,
              offset: Offset(0, _pressed ? 1 : 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    widget.video.thumbnailUrl,
                    width: 100,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 100,
                      height: 70,
                      color: colors.bgCardNeutral,
                      child: Icon(
                        Icons.smart_display_rounded,
                        color: colors.textMuted,
                        size: 28,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -6,
                  left: -6,
                  child: Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFF58CC02),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${widget.video.posicao}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.video.titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'ComicSansMS',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: colors.textMain,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded,
                            size: 13, color: colors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          widget.video.duracaoFormatada,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textMuted,
                          ),
                        ),
                      ],
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