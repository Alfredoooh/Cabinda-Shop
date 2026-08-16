import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class VideoStreamInfo {
  final String urlDireto;
  final String qualidade;
  final int tamanhoBytes;
  final String container;

  VideoStreamInfo({
    required this.urlDireto,
    required this.qualidade,
    required this.tamanhoBytes,
    required this.container,
  });
}

class VideoStreamExtractor {
  static final YoutubeExplode _yt = YoutubeExplode();

  /// Recebe o ID do vídeo (ex: "dQw4w9WgXcQ") e devolve o URL real do
  /// stream de vídeo, pronto para o teu player usar diretamente.
  static Future<VideoStreamInfo> extrairLinkDireto(String videoId) async {
    final manifest = await _yt.videos.streamsClient.getManifest(videoId);

    // Pega o stream com melhor qualidade que já vem com vídeo+áudio juntos
    // (muxed), para não precisares de sincronizar duas streams separadas.
    final streamInfo = manifest.muxed.withHighestBitrate();

    return VideoStreamInfo(
      urlDireto: streamInfo.url.toString(),
      qualidade: streamInfo.qualityLabel,
      tamanhoBytes: streamInfo.size.totalBytes,
      container: streamInfo.container.name,
    );
  }

  static void dispose() {
    _yt.close();
  }
}