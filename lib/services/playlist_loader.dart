import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/playlist_model.dart';

class PlaylistLoader {
  static const String basePath =
      'assets/links/videos/playlists/EnsinandoMeuFilho';

  static Future<List<PlaylistItem>> loadAllPlaylists() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final allAssets = manifest.listAssets();

    final jsonPaths = allAssets
        .where((path) =>
            path.startsWith(basePath) && path.endsWith('videos.json'))
        .toList()
      ..sort();

    final List<PlaylistItem> playlists = [];

    for (int i = 0; i < jsonPaths.length; i++) {
      final path = jsonPaths[i];
      try {
        final content = await rootBundle.loadString(path);
        final data = json.decode(content) as Map<String, dynamic>;

        final segments = path.split('/');
        final pastaNome = segments.length >= 2
            ? segments[segments.length - 2]
            : 'playlist_$i';

        playlists.add(
          PlaylistItem.fromJson(data, pastaNome, i % 6),
        );
      } catch (e) {
        continue;
      }
    }

    return playlists;
  }
}