import 'package:flutter/material.dart';
import '../models/playlist_model.dart';
import '../services/playlist_loader.dart';
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
            child: CircularProgressIndicator(color: colors.textMuted),
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

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: playlists.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  final playlist = playlists[index];
                  return _PlaylistCard(
                    colors: colors,
                    playlist: playlist,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PlaylistVideosScreen(
                            colors: colors,
                            playlist: playlist,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
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
    final fgList = colors.cardFgList as List<Color>;
    final shadowList = colors.cardShadowList as List<Color>;

    final idx = widget.playlist.corIndex;
    final bg = bgList[idx];
    final fg = fgList[idx];
    final shadow = shadowList[idx];

    final palavras = widget.playlist.nome.trim().split(' ');
    final iniciais = palavras.isNotEmpty
        ? (palavras.length > 1
            ? '${palavras[0][0]}${palavras[1][0]}'
            : palavras[0].substring(0, palavras[0].length >= 2 ? 2 : 1))
        : '??';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.identity()..translate(0.0, _pressed ? 4.0 : 0.0),
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Center(
                  child: Text(
                    iniciais.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'ComicSansMS',
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: fg,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.playlist.nome,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'ComicSansMS',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colors.textMain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.playlist.totalVideos} vídeos',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textMuted,
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