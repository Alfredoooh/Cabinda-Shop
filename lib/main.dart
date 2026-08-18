import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const AlfabetoApp());
}

class AlfabetoApp extends StatelessWidget {
  const AlfabetoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Leya',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'ComicSansMS',
      ),
      home: const HomeScreen(),
    );
  }
}

enum AppThemeMode {
  light,
  dark,
}

enum AppVisualStyle {
  playful,
  clean,
  calm,
  contrast,
}

class AppSettings extends ChangeNotifier {
  AppSettings._();

  static final AppSettings instance = AppSettings._();

  AppThemeMode themeMode = AppThemeMode.light;
  AppVisualStyle visualStyle = AppVisualStyle.playful;
  bool clickSoundsEnabled = true;
  bool musicEnabled = true;

  bool get isDark => themeMode == AppThemeMode.dark;

  void setTheme(AppThemeMode value) {
    if (themeMode == value) return;
    themeMode = value;
    notifyListeners();
  }

  void setStyle(AppVisualStyle value) {
    if (visualStyle == value) return;
    visualStyle = value;
    notifyListeners();
  }

  Future<void> setClickSounds(bool value) async {
    if (clickSoundsEnabled == value) return;
    clickSoundsEnabled = value;
    SoundManager.instance.muted = !value;
    notifyListeners();
  }

  Future<void> setMusic(bool value) async {
    if (musicEnabled == value) return;
    musicEnabled = value;
    await MusicManager.instance.setEnabled(value);
    notifyListeners();
  }
}

class MusicManager {
  MusicManager._();

  static final MusicManager instance = MusicManager._();

  final AudioPlayer _player = AudioPlayer();
  bool enabled = true;
  bool _started = false;
  String? _currentAsset;

  Future<void> playLoop(String asset) async {
    if (!enabled) return;

    try {
      if (_started && _currentAsset == asset) {
        await _player.resume();
        return;
      }

      _currentAsset = asset;
      _started = true;
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(0.35);
      await _player.play(AssetSource(asset));
    } catch (_) {}
  }

  Future<void> setEnabled(bool value) async {
    enabled = value;

    try {
      if (value) {
        if (_currentAsset != null) {
          await _player.resume();
        }
      } else {
        await _player.pause();
      }
    } catch (_) {}
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}

class AppColors {
  final bool isDark;
  final AppVisualStyle style;

  AppColors(
    this.isDark, [
    this.style = AppVisualStyle.playful,
  ]);

  Color get bg {
    if (style == AppVisualStyle.clean) {
      return isDark ? const Color(0xFF181A1F) : const Color(0xFFF7F9FC);
    }
    if (style == AppVisualStyle.calm) {
      return isDark ? const Color(0xFF15211F) : const Color(0xFFF1FAF7);
    }
    if (style == AppVisualStyle.contrast) {
      return isDark ? const Color(0xFF101010) : const Color(0xFFFFFFFF);
    }
    return isDark ? const Color(0xFF1E1B16) : const Color(0xFFFFF8EE);
  }

  Color get bgCardNeutral {
    if (style == AppVisualStyle.clean) {
      return isDark ? const Color(0xFF242830) : const Color(0xFFFFFFFF);
    }
    if (style == AppVisualStyle.calm) {
      return isDark ? const Color(0xFF20302C) : const Color(0xFFFFFFFF);
    }
    if (style == AppVisualStyle.contrast) {
      return isDark ? const Color(0xFF202020) : const Color(0xFFF2F2F2);
    }
    return isDark ? const Color(0xFF2E2A22) : const Color(0xFFF0E6D2);
  }

  Color get textMain {
    if (style == AppVisualStyle.clean) {
      return isDark ? const Color(0xFFF3F5F7) : const Color(0xFF17202A);
    }
    if (style == AppVisualStyle.calm) {
      return isDark ? const Color(0xFFE8F4F1) : const Color(0xFF17312C);
    }
    if (style == AppVisualStyle.contrast) {
      return isDark ? Colors.white : Colors.black;
    }
    return isDark ? const Color(0xFFF5EEDD) : const Color(0xFF3D2B1F);
  }

  Color get textMuted {
    if (style == AppVisualStyle.clean) {
      return isDark ? const Color(0xFFA6AFBB) : const Color(0xFF687385);
    }
    if (style == AppVisualStyle.calm) {
      return isDark ? const Color(0xFF9CB6AE) : const Color(0xFF68827B);
    }
    if (style == AppVisualStyle.contrast) {
      return isDark ? const Color(0xFFE0E0E0) : const Color(0xFF333333);
    }
    return isDark ? const Color(0xFF9C9082) : const Color(0xFFA08868);
  }

  Color get divider {
    if (style == AppVisualStyle.clean) {
      return isDark ? const Color(0xFF343943) : const Color(0xFFE1E6ED);
    }
    if (style == AppVisualStyle.calm) {
      return isDark ? const Color(0xFF30423E) : const Color(0xFFD7EAE5);
    }
    if (style == AppVisualStyle.contrast) {
      return isDark ? const Color(0xFF505050) : const Color(0xFFCCCCCC);
    }
    return isDark ? const Color(0xFF3A352A) : const Color(0xFFEDE1C8);
  }

  Color get drawerBg {
    if (style == AppVisualStyle.clean) {
      return isDark ? const Color(0xFF1E2228) : const Color(0xFFFFFFFF);
    }
    if (style == AppVisualStyle.calm) {
      return isDark ? const Color(0xFF1A2925) : const Color(0xFFFFFFFF);
    }
    if (style == AppVisualStyle.contrast) {
      return isDark ? const Color(0xFF151515) : const Color(0xFFFFFFFF);
    }
    return isDark ? const Color(0xFF26221B) : const Color(0xFFFFFFFF);
  }

  Color get overlay =>
      isDark ? const Color(0x99000000) : const Color(0x66000000);

  Color get neutralShadow =>
      isDark ? const Color(0x40000000) : const Color(0x1A000000);

  Color get drawerShadow =>
      isDark ? const Color(0x66000000) : const Color(0x33000000);

  Color get switchThumb =>
      isDark ? const Color(0xFFF5EEDD) : const Color(0xFFFFFFFF);

  Color get switchThumbShadow =>
      isDark ? const Color(0x40000000) : const Color(0x33000000);

  double get radiusSmall {
    switch (style) {
      case AppVisualStyle.clean:
        return 10;
      case AppVisualStyle.calm:
        return 16;
      case AppVisualStyle.contrast:
        return 6;
      case AppVisualStyle.playful:
        return 14;
    }
  }

  double get radiusLarge {
    switch (style) {
      case AppVisualStyle.clean:
        return 14;
      case AppVisualStyle.calm:
        return 22;
      case AppVisualStyle.contrast:
        return 8;
      case AppVisualStyle.playful:
        return 20;
    }
  }

  Color get c0Bg => isDark ? const Color(0xFF17394A) : const Color(0xFFDDF4FF);
  Color get c0Fg => isDark ? const Color(0xFF6FCBFA) : const Color(0xFF1CB0F6);
  Color get c0Shadow =>
      isDark ? const Color(0xFF0E2732) : const Color(0x591CB0F6);

  Color get c1Bg => isDark ? const Color(0xFF4A3320) : const Color(0xFFFFE8D6);
  Color get c1Fg => isDark ? const Color(0xFFFFB05C) : const Color(0xFFFF9600);
  Color get c1Shadow =>
      isDark ? const Color(0xFF302014) : const Color(0x59FF9600);

  Color get c2Bg => isDark ? const Color(0xFF22421C) : const Color(0xFFE3F9D9);
  Color get c2Fg => isDark ? const Color(0xFF86E048) : const Color(0xFF58CC02);
  Color get c2Shadow =>
      isDark ? const Color(0xFF152912) : const Color(0x5958CC02);

  Color get c3Bg => isDark ? const Color(0xFF4A2333) : const Color(0xFFFFE0EC);
  Color get c3Fg => isDark ? const Color(0xFFFF83B0) : const Color(0xFFFF4B8C);
  Color get c3Shadow =>
      isDark ? const Color(0xFF2E1521) : const Color(0x59FF4B8C);

  Color get c4Bg => isDark ? const Color(0xFF362142) : const Color(0xFFF1E4FF);
  Color get c4Fg => isDark ? const Color(0xFFDCA6FF) : const Color(0xFFCE82FF);
  Color get c4Shadow =>
      isDark ? const Color(0xFF21142A) : const Color(0x59CE82FF);

  Color get c5Bg => isDark ? const Color(0xFF453A16) : const Color(0xFFFFF4CC);
  Color get c5Fg => isDark ? const Color(0xFFFFDD6B) : const Color(0xFFFFC800);
  Color get c5Shadow =>
      isDark ? const Color(0xFF2B240E) : const Color(0x59FFC800);

  static const green = Color(0xFF58CC02);
  static const greenShadow = Color(0xFF46A302);
  static const red = Color(0xFFFF4B4B);
  static const redShadow = Color(0xFFD63D3D);
  static const orange = Color(0xFFFF9600);

  List<Color> get cardBgList => [c0Bg, c1Bg, c2Bg, c3Bg, c4Bg, c5Bg];
  List<Color> get cardFgList => [c0Fg, c1Fg, c2Fg, c3Fg, c4Fg, c5Fg];
  List<Color> get cardShadowList =>
      [c0Shadow, c1Shadow, c2Shadow, c3Shadow, c4Shadow, c5Shadow];
}

const List<String> kVowels = ['a', 'e', 'i', 'o', 'u'];
const List<String> kAllLetters = [
  'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o',
  'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
];
final List<String> kConsonants =
    kAllLetters.where((l) => !kVowels.contains(l)).toList();

String buildSyllable(String consonant, String vowel, bool consonantUpper) {
  final cRaw =
      consonantUpper ? consonant.toUpperCase() : consonant.toLowerCase();
  final v = vowel.toLowerCase();
  if (consonant.toLowerCase() == 'q') {
    if (v == 'e') return '${cRaw}ue';
    if (v == 'i') return '${cRaw}ui';
    if (v == 'a') return '${cRaw}ua';
    if (v == 'o') return '${cRaw}uo';
    if (v == 'u') return '${cRaw}u';
  }
  return '$cRaw$v';
}

enum GridMode { all, vowels, consonants }
enum DrawerSection { alphabet, games, videos }

class AssetUtils {
  static Future<List<String>> getAssetsInFolder(String folder) async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final keys = manifest.listAssets().where((key) =>
        key.startsWith(folder) &&
        (key.endsWith('.png') || key.endsWith('.jpg') || key.endsWith('.jpeg')));
    final list = keys.toList()..sort();
    return list;
  }
}

class SoundManager {
  SoundManager._();
  static final SoundManager instance = SoundManager._();
  final AudioPlayer _player = AudioPlayer();
  bool muted = false;

  Future<void> playClick() async {
    await _play('audio/pressing.wav');
  }

  Future<void> playLetter(String letter) async {
    final l = letter.toLowerCase();
    if (l.isEmpty || l.length != 1) return;
    final path =
        kVowels.contains(l) ? 'audio/vowels/$l.wav' : 'audio/consonants/$l.wav';
    await _play(path);
  }

  Future<void> playSyllable(String syllable) async {
    final s = syllable.toLowerCase();
    if (s.isEmpty) return;
    final firstConsonant = s[0];
    if (!kConsonants.contains(firstConsonant)) {
      await playLetter(firstConsonant);
      return;
    }
    await _play('audio/syllables/$firstConsonant/$s.wav');
  }

  Future<void> playExample(String syllable) async {
    final s = syllable.toLowerCase();
    if (s.isEmpty) return;
    final firstConsonant = s[0];
    if (!kConsonants.contains(firstConsonant)) return;
    await _play('audio/syllables/$firstConsonant/${s}_ex.wav');
  }

  Future<void> play(String text) async {
    final t = text.toLowerCase();
    if (t.length == 1) {
      await playLetter(t);
    } else {
      await playSyllable(t);
    }
  }

  Future<void> _play(String assetPath) async {
    if (muted) return;
    try {
      await _player.stop();
      await _player.play(AssetSource(assetPath));
    } catch (_) {}
  }
}