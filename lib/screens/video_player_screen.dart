import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';
import '../main.dart' show AppColors;
import '../models/playlist_model.dart';
import '../services/video_stream_extractor.dart';
import '../widgets/abc_loader.dart';

class VideoPlayerScreen extends StatefulWidget {
  final dynamic colors;
  final VideoItem video;
  final PlaylistItem playlist;
  final List<PlaylistItem> todasPlaylists;

  const VideoPlayerScreen({
    super.key,
    required this.colors,
    required this.video,
    required this.playlist,
    required this.todasPlaylists,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _carregando = true;
  String? _erro;
  bool _controlesVisiveis = true;
  Timer? _hideTimer;
  late VideoItem _videoAtual;

  @override
  void initState() {
    super.initState();
    _videoAtual = widget.video;
    _carregarVideo(_videoAtual);
    _agendarOcultacao();
  }

  Future<void> _carregarVideo(VideoItem video) async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    _controller?.dispose();
    _controller = null;
    try {
      final streamInfo =
          await VideoStreamExtractor.extrairLinkDireto(video.id);
      final controller =
          VideoPlayerController.networkUrl(Uri.parse(streamInfo.urlDireto));
      await controller.initialize();
      if (!mounted) return;
      setState(() {
        _controller = controller;
        _carregando = false;
        _videoAtual = video;
      });
      controller.play();
      _agendarOcultacao();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = 'Não consegui carregar este vídeo. Tenta novamente.';
        _carregando = false;
      });
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  void _agendarOcultacao() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      setState(() => _controlesVisiveis = false);
    });
  }

  void _mostrarControles() {
    if (!mounted) return;
    setState(() => _controlesVisiveis = true);
    _agendarOcultacao();
  }

  void _ocultarControles() {
    if (!mounted) return;
    _hideTimer?.cancel();
    setState(() => _controlesVisiveis = false);
  }

  void _togglePlayerControls() {
    if (_controlesVisiveis) {
      _ocultarControles();
    } else {
      _mostrarControles();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final playlist = widget.playlist;
    final outrosVideos = playlist.videos
        .where((v) => v.id != _videoAtual.id)
        .toList();
    final outrasPlaylists = widget.todasPlaylists
        .where((p) => p.pastaNome != playlist.pastaNome)
        .toList();

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Player no topo, proporção 16:9 ──
            _PlayerTopo(
              colors: colors,
              video: _videoAtual,
              controller: _controller,
              carregando: _carregando,
              erro: _erro,
              controlesVisiveis: _controlesVisiveis,
              onPlayerTap: _togglePlayerControls,
              onInteraction: _mostrarControles,
              onBack: () => Navigator.of(context).pop(),
              onRetry: () { _mostrarControles(); _carregarVideo(_videoAtual); },
            ),

            // ── Título e info do vídeo ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _videoAtual.titulo,
                    style: TextStyle(
                      fontFamily: 'ComicSansMS',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: colors.textMain,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/clock.svg',
                        width: 13,
                        height: 13,
                        colorFilter: ColorFilter.mode(
                            colors.textMuted, BlendMode.srcIn),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _videoAtual.duracaoFormatada,
                        style: TextStyle(
                            fontSize: 12, color: colors.textMuted),
                      ),
                      const SizedBox(width: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: colors.c2Bg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          playlist.nome,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: colors.c2Fg,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Lista scrollável: outros vídeos + outras playlists ──
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                children: [
                  // Outros vídeos desta playlist
                  if (outrosVideos.isNotEmpty) ...[
                    _SectionHeader(
                      colors: colors,
                      label: 'Nesta playlist',
                      iconPath: 'assets/icons/videos-icon.png',
                    ),
                    const SizedBox(height: 10),
                    ...outrosVideos.asMap().entries.map((e) {
                      final v = e.value;
                      final idx = e.key % 6;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _MiniVideoCard(
                          colors: colors,
                          video: v,
                          corIndex: idx,
                          ativo: v.id == _videoAtual.id,
                          onTap: () => _carregarVideo(v),
                        ),
                      );
                    }),
                    const SizedBox(height: 6),
                  ],

                  // Outras playlists
                  if (outrasPlaylists.isNotEmpty) ...[
                    _SectionHeader(
                      colors: colors,
                      label: 'Outras playlists',
                      iconPath: 'assets/icons/alphabet-icon.png',
                    ),
                    const SizedBox(height: 10),
                    ...outrasPlaylists.asMap().entries.map((e) {
                      final p = e.value;
                      final idx = e.key % 6;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _MiniPlaylistCard(
                          colors: colors,
                          playlist: p,
                          corIndex: idx,
                          onTap: () {
                            if (p.videos.isEmpty) return;
                            Navigator.of(context).pushReplacement(
                              CupertinoPageRoute(
                                builder: (_) => VideoPlayerScreen(
                                  colors: colors,
                                  video: p.videos.first,
                                  playlist: p,
                                  todasPlaylists: widget.todasPlaylists,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Player no topo
// ─────────────────────────────────────────────
class _PlayerTopo extends StatelessWidget {
  final dynamic colors;
  final VideoItem video;
  final VideoPlayerController? controller;
  final bool carregando;
  final String? erro;
  final bool controlesVisiveis;
  final VoidCallback onPlayerTap;
  final VoidCallback onInteraction;
  final VoidCallback onBack;
  final VoidCallback onRetry;

  const _PlayerTopo({
    required this.colors,
    required this.video,
    required this.controller,
    required this.carregando,
    required this.erro,
    required this.controlesVisiveis,
    required this.onPlayerTap,
    required this.onInteraction,
    required this.onBack,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Fundo preto
          Container(color: Colors.black),

          // Thumbnail enquanto carrega
          if (carregando || erro != null)
            Image.network(
              video.thumbnailUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.black),
            ),

          // Vídeo
          if (controller != null && !carregando && erro == null)
            VideoPlayer(controller!),

          if (controller != null && !carregando && erro == null)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onPlayerTap,
                child: const SizedBox.expand(),
              ),
            ),

          // Loader
          if (carregando)
            Center(
              child: AbcLoader(corMuted: Colors.white54),
            ),

          // Erro
          if (erro != null)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/icons/play.svg',
                    width: 40,
                    height: 40,
                    colorFilter: const ColorFilter.mode(
                        Colors.white54, BlendMode.srcIn),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Erro ao carregar vídeo',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: onRetry,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF58CC02),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Tentar novamente',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Controlos sobrepostos
          if (controller != null && !carregando && erro == null)
            AnimatedOpacity(
              opacity: controlesVisiveis ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: !controlesVisiveis,
                child: _Controlos(
                  controller: controller!,
                  onBack: onBack,
                  onInteraction: onInteraction,
                ),
              ),
            ),

          // Botão back sempre visível
          if (carregando || erro != null)
            Positioned(
              top: 8,
              left: 4,
              child: _BackButton(onBack: onBack),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Controlos do player
// ─────────────────────────────────────────────
class _Controlos extends StatefulWidget {
  final VideoPlayerController controller;
  final VoidCallback onBack;
  final VoidCallback onInteraction;

  const _Controlos({required this.controller, required this.onBack, required this.onInteraction});

  @override
  State<_Controlos> createState() => _ControlosState();
}

class _ControlosState extends State<_Controlos> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_tick);
  }

  void _tick() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_tick);
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _interaction() => widget.onInteraction();

  @override
  Widget build(BuildContext context) {
    final val = widget.controller.value;
    final total = val.duration.inMilliseconds;
    final pos = val.position.inMilliseconds;
    final progress = total > 0 ? pos / total : 0.0;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xCC000000), Colors.transparent, Color(0xCC000000)],
          stops: [0.0, 0.4, 1.0],
        ),
      ),
      child: Column(
        children: [
          // Top bar: back + espaço
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 8, 0),
            child: Row(
              children: [
                _BackButton(onBack: widget.onBack),
              ],
            ),
          ),

          const Spacer(),

          // Centro: rewind, play/pause, forward
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SvgBtn(
                path: 'assets/icons/rewind.svg',
                size: 32,
                onTap: () {
                  _interaction();
                  final pos = val.position - const Duration(seconds: 10);
                  widget.controller
                      .seekTo(pos < Duration.zero ? Duration.zero : pos);
                },
              ),
              const SizedBox(width: 28),
              _SvgBtn(
                path: val.isPlaying
                    ? 'assets/icons/pause.svg'
                    : 'assets/icons/play.svg',
                size: 48,
                onTap: () {
                  val.isPlaying
                      ? widget.controller.pause()
                      : widget.controller.play();
                },
              ),
              const SizedBox(width: 28),
              _SvgBtn(
                path: 'assets/icons/forward.svg',
                size: 32,
                onTap: () {
                  _interaction();
                  final pos = val.position + const Duration(seconds: 10);
                  final dur = val.duration;
                  widget.controller
                      .seekTo(pos > dur ? dur : pos);
                },
              ),
            ],
          ),

          const Spacer(),

          // Bottom: barra de progresso + tempo
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Column(
              children: [
                // Barra de progresso customizada
                GestureDetector(
                  onHorizontalDragStart: (_) => _interaction(),
                  onHorizontalDragUpdate: (details) {
                    final box = context.findRenderObject() as RenderBox;
                    final localDx =
                        details.localPosition.dx.clamp(0.0, box.size.width);
                    final ratio = localDx / box.size.width;
                    widget.controller.seekTo(
                        val.duration * ratio.clamp(0.0, 1.0));
                  },
                  child: Container(
                    height: 20,
                    color: Colors.transparent,
                    child: Align(
                      alignment: Alignment.center,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.centerLeft,
                        children: [
                          // Track fundo
                          Container(
                            height: 3,
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          // Buffered
                          FractionallySizedBox(
                            widthFactor: () {
                              final buf = val.buffered;
                              if (buf.isEmpty || total == 0) return 0.0;
                              return (buf.last.end.inMilliseconds / total)
                                  .clamp(0.0, 1.0);
                            }(),
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color: Colors.white38,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          // Progresso
                          FractionallySizedBox(
                            widthFactor: progress.clamp(0.0, 1.0),
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color: const Color(0xFF58CC02),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          // Thumb
                          Positioned(
                            left: (MediaQuery.of(context).size.width *
                                    progress.clamp(0.0, 1.0)) -
                                6,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Color(0xFF58CC02),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _fmt(val.position),
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 11),
                    ),
                    Text(
                      _fmt(val.duration),
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onBack;
  const _BackButton({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onBack,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black45,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/icons/back.svg',
            width: 18,
            height: 18,
            colorFilter:
                const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}

class _SvgBtn extends StatelessWidget {
  final String path;
  final double size;
  final VoidCallback onTap;

  const _SvgBtn({
    required this.path,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SvgPicture.asset(
        path,
        width: size,
        height: size,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Section header
// ─────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final dynamic colors;
  final String label;
  final String iconPath;

  const _SectionHeader({
    required this.colors,
    required this.label,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(iconPath, width: 18, height: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'ComicSansMS',
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: colors.textMain,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Card de vídeo pequeno
// ─────────────────────────────────────────────
class _MiniVideoCard extends StatefulWidget {
  final dynamic colors;
  final VideoItem video;
  final int corIndex;
  final bool ativo;
  final VoidCallback onTap;

  const _MiniVideoCard({
    required this.colors,
    required this.video,
    required this.corIndex,
    required this.ativo,
    required this.onTap,
  });

  @override
  State<_MiniVideoCard> createState() => _MiniVideoCardState();
}

class _MiniVideoCardState extends State<_MiniVideoCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final bgList = colors.cardBgList as List<Color>;
    final shadowList = colors.cardShadowList as List<Color>;
    final bg = widget.ativo
        ? const Color(0xFF58CC02)
        : bgList[widget.corIndex];
    final shadow = widget.ativo
        ? const Color(0xFF46A302)
        : shadowList[widget.corIndex];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform:
            Matrix4.identity()..translate(0.0, _pressed ? 2.0 : 0.0),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: shadow, offset: Offset(0, _pressed ? 1 : 3)),
          ],
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    widget.video.thumbnailUrl,
                    width: 86,
                    height: 58,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 86,
                      height: 58,
                      color: colors.bgCardNeutral,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/play.svg',
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                          Colors.white, BlendMode.srcIn),
                    ),
                  ),
                ),
                Positioned(
                  top: -5,
                  left: -5,
                  child: Container(
                    width: 18,
                    height: 18,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: widget.ativo
                          ? Colors.white
                          : const Color(0xFF58CC02),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${widget.video.posicao}',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: widget.ativo
                            ? const Color(0xFF58CC02)
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
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
                      fontSize: 13,
                      color: widget.ativo
                          ? Colors.white
                          : colors.textMain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/clock.svg',
                        width: 11,
                        height: 11,
                        colorFilter: ColorFilter.mode(
                          widget.ativo
                              ? Colors.white70
                              : colors.textMuted,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.video.duracaoFormatada,
                        style: TextStyle(
                          fontSize: 11,
                          color: widget.ativo
                              ? Colors.white70
                              : colors.textMuted,
                        ),
                      ),
                    ],
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

// ─────────────────────────────────────────────
// Card de playlist pequeno
// ─────────────────────────────────────────────
class _MiniPlaylistCard extends StatefulWidget {
  final dynamic colors;
  final PlaylistItem playlist;
  final int corIndex;
  final VoidCallback onTap;

  const _MiniPlaylistCard({
    required this.colors,
    required this.playlist,
    required this.corIndex,
    required this.onTap,
  });

  @override
  State<_MiniPlaylistCard> createState() => _MiniPlaylistCardState();
}

class _MiniPlaylistCardState extends State<_MiniPlaylistCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final bgList = colors.cardBgList as List<Color>;
    final shadowList = colors.cardShadowList as List<Color>;
    final bg = bgList[widget.corIndex];
    final shadow = shadowList[widget.corIndex];
    final capa = widget.playlist.videoCapa;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform:
            Matrix4.identity()..translate(0.0, _pressed ? 2.0 : 0.0),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: shadow, offset: Offset(0, _pressed ? 1 : 3)),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
              child: capa != null
                  ? Image.network(
                      capa.thumbnailUrl,
                      width: 86,
                      height: 58,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 86,
                        height: 58,
                        color: colors.bgCardNeutral,
                      ),
                    )
                  : Container(
                      width: 86,
                      height: 58,
                      color: colors.bgCardNeutral,
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.playlist.nome,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'ComicSansMS',
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: colors.textMain,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.playlist.totalVideos} vídeos',
                      style: TextStyle(
                          fontSize: 11, color: colors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: SvgPicture.asset(
                'assets/icons/chevron-right.svg',
                width: 14,
                height: 14,
                colorFilter: ColorFilter.mode(
                    colors.textMuted, BlendMode.srcIn),
              ),
            ),
          ],
        ),
      ),
    );
  }
}