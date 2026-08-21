import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/playlist_model.dart';
import '../services/playlist_loader.dart';
import '../widgets/abc_loader.dart';
import 'playlist_videos_screen.dart';

class PlaylistCoversScreen extends StatefulWidget {
  final dynamic colors;

  const PlaylistCoversScreen({super.key, required this.colors});

  @override
  State<PlaylistCoversScreen> createState() => _PlaylistCoversScreenState();
}

class _PlaylistCoversScreenState extends State<PlaylistCoversScreen> {
  late Future<List<PlaylistItem>> _futurePlaylists;

  @override
  void initState() {
    super.initState();
    _futurePlaylists = PlaylistLoader.loadAllPlaylists();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;

    return FutureBuilder<List<PlaylistItem>>(
      future: _futurePlaylists,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: AbcLoader(corMuted: colors.textMuted),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Não consegui carregar as playlists.\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textMuted),
              ),
            ),
          );
        }

        final playlists = snapshot.data ?? [];

        if (playlists.isEmpty) {
          return Center(
            child: Text(
              'Nenhuma playlist encontrada.',
              style: TextStyle(color: colors.textMuted),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          itemCount: playlists.length,
          itemBuilder: (context, index) {
            final playlist = playlists[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _PlaylistCard(
                colors: colors,
                playlist: playlist,
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => PlaylistVideosScreen(
                        colors: colors,
                        playlist: playlist,
                        todasPlaylists: playlists,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _PlaylistCard extends StatefulWidget {
  final dynamic colors;
  final PlaylistItem playlist;
  final VoidCallback onTap;

  const _PlaylistCard({
    required this.colors,
    required this.playlist,
    required this.onTap,
  });

  @override
  State<_PlaylistCard> createState() => _PlaylistCardState();
}

class _PlaylistCardState extends State<_PlaylistCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final bgList = colors.cardBgList as List<Color>;
    final shadowList = colors.cardShadowList as List<Color>;

    final idx = widget.playlist.corIndex;
    final bg = bgList[idx];
    final shadow = shadowList[idx];
    final videoCapa = widget.playlist.videoCapa;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.identity()..translate(0.0, _pressed ? 3.0 : 0.0),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: shadow, offset: Offset(0, _pressed ? 1 : 4)),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              child: videoCapa != null
                  ? Image.network(
                      videoCapa.thumbnailUrl,
                      width: 110,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 110,
                        height: 90,
                        color: Colors.black12,
                      ),
                    )
                  : Container(
                      width: 110,
                      height: 90,
                      color: Colors.black12,
                    ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.playlist.nome,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'ComicSansMS',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.textMain,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${widget.playlist.totalVideos} vídeos',
                      style: TextStyle(fontSize: 12, color: colors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: SvgPicture.asset(
                'assets/icons/chevron-right.svg',
                width: 16,
                height: 16,
                colorFilter:
                    ColorFilter.mode(colors.textMuted, BlendMode.srcIn),
              ),
            ),
          ],
        ),
      ),
    );
  }
}