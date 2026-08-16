import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';
import '../models/playlist_model.dart';
import '../services/video_stream_extractor.dart';

class VideoPlayerScreen extends StatefulWidget {
  final dynamic colors;
  final VideoItem video;

  const VideoPlayerScreen({
    super.key,
    required this.colors,
    required this.video,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _extrairEIniciar();
  }

  Future<void> _extrairEIniciar() async {
    try {
      final streamInfo =
          await VideoStreamExtractor.extrairLinkDireto(widget.video.id);
      final controller =
          VideoPlayerController.networkUrl(Uri.parse(streamInfo.urlDireto));
      await controller.initialize();
      if (!mounted) return;
      setState(() {
        _controller = controller;
        _carregando = false;
      });
      controller.play();
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
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/back.svg',
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.video.titulo,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Center(
        child: _carregando
            ? const CircularProgressIndicator(color: Colors.white)
            : _erro != null
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _erro!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  )
                : AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        VideoPlayer(_controller!),
                        _CustomControls(controller: _controller!),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class _CustomControls extends StatefulWidget {
  final VideoPlayerController controller;
  const _CustomControls({required this.controller});

  @override
  State<_CustomControls> createState() => _CustomControlsState();
}

class _CustomControlsState extends State<_CustomControls> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTick);
  }

  void _onTick() => setState(() {});

  @override
  void dispose() {
    widget.controller.removeListener(_onTick);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.controller.value;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black87],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          VideoProgressIndicator(
            widget.controller,
            allowScrubbing: true,
            colors: const VideoProgressColors(
              playedColor: Color(0xFF58CC02),
              bufferedColor: Colors.white30,
              backgroundColor: Colors.white12,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              IconButton(
                icon: SvgPicture.asset(
                  value.isPlaying
                      ? 'assets/icons/pause.svg'
                      : 'assets/icons/play.svg',
                  width: 26,
                  height: 26,
                  colorFilter:
                      const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
                onPressed: () {
                  setState(() {
                    value.isPlaying
                        ? widget.controller.pause()
                        : widget.controller.play();
                  });
                },
              ),
              Text(
                '${_formatar(value.position)} / ${_formatar(value.duration)}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatar(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}