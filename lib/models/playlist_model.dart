class VideoItem {
  final int posicao;
  final String titulo;
  final String link;
  final String id;
  final int? duracaoSegundos;

  VideoItem({
    required this.posicao,
    required this.titulo,
    required this.link,
    required this.id,
    this.duracaoSegundos,
  });

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      posicao: json['posicao'] ?? 0,
      titulo: json['titulo'] ?? '',
      link: json['link'] ?? '',
      id: json['id'] ?? '',
      duracaoSegundos: json['duracao_segundos'],
    );
  }

  String get thumbnailUrl => 'https://img.youtube.com/vi/$id/hqdefault.jpg';

  String get duracaoFormatada {
    if (duracaoSegundos == null) return '--:--';
    final minutos = duracaoSegundos! ~/ 60;
    final segundos = duracaoSegundos! % 60;
    return '$minutos:${segundos.toString().padLeft(2, '0')}';
  }
}

class PlaylistItem {
  final String pastaNome;
  final String nome;
  final String playlistLink;
  final int totalVideos;
  final List<VideoItem> videos;
  final int corIndex;

  PlaylistItem({
    required this.pastaNome,
    required this.nome,
    required this.playlistLink,
    required this.totalVideos,
    required this.videos,
    required this.corIndex,
  });

  factory PlaylistItem.fromJson(
    Map<String, dynamic> json,
    String pastaNome,
    int corIndex,
  ) {
    final videosJson = json['videos'] as List<dynamic>? ?? [];
    return PlaylistItem(
      pastaNome: pastaNome,
      nome: json['playlist'] ?? pastaNome,
      playlistLink: json['playlist_link'] ?? '',
      totalVideos: json['total_videos'] ?? videosJson.length,
      videos: videosJson.map((v) => VideoItem.fromJson(v)).toList(),
      corIndex: corIndex,
    );
  }
}