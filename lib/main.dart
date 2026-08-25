import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppPrefs.load();
  await SoundManager.instance.preloadAssets(_buildAllAudioPaths());
  applySystemUi(false);
  runApp(const AlfabetoApp());
}

List<String> _buildAllAudioPaths() {
  final paths = <String>[
    ...kVowels.map((v) => 'audio/vowels/$v.wav'),
    ...kConsonants.map((c) => 'audio/consonants/$c.wav'),
    'audio/pressing.wav',
    'audio/correct.wav',
    'audio/wrong.wav',
    'audio/win.wav',
  ];

  for (final c in kConsonants) {
    for (final v in vowelsForConsonant(c)) {
      final syllable = buildSyllable(c, v, false);
      if (syllable.isEmpty) continue;
      paths.add('audio/syllables/$c/$syllable.wav');
      paths.add('audio/syllables/$c/${syllable}_ex.wav');
    }
  }

  return paths;
}

void applySystemUi(bool isDark) {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
  ));
}

class AlfabetoApp extends StatelessWidget {
  const AlfabetoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Alfabeto',
      home: HomeScreen(),
    );
  }
}


class AppPrefs {
  static const _soundKey = 'sound_enabled';
  static const _musicKey = 'music_enabled';
  static const _voiceKey = 'voice_enabled';

  static bool soundEnabled = true;
  static bool musicEnabled = true;
  static bool voiceEnabled = true;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    soundEnabled = prefs.getBool(_soundKey) ?? true;
    musicEnabled = prefs.getBool(_musicKey) ?? true;
    voiceEnabled = prefs.getBool(_voiceKey) ?? true;
    _applyToSoundManager();
  }

  static Future<void> setSoundEnabled(bool value) async {
    soundEnabled = value;
    _applyToSoundManager();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundKey, value);
  }

  static Future<void> setMusicEnabled(bool value) async {
    musicEnabled = value;
    _applyToSoundManager();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_musicKey, value);
  }

  static Future<void> setVoiceEnabled(bool value) async {
    voiceEnabled = value;
    _applyToSoundManager();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_voiceKey, value);
  }

  static void _applyToSoundManager() {
    SoundManager.instance.muted = !soundEnabled;
    SoundManager.instance.clickMuted = !soundEnabled;
    SoundManager.instance.musicMuted = !musicEnabled;
    SoundManager.instance.voiceEnabled = voiceEnabled;
  }
}

class AppColors {
  final bool isDark;
  AppColors(this.isDark);

  Color get bg => isDark ? const Color(0xFF1E1B16) : const Color(0xFFFFF8EE);
  Color get bgCardNeutral =>
      isDark ? const Color(0xFF2E2A22) : const Color(0xFFF0E6D2);
  Color get textMain =>
      isDark ? const Color(0xFFF5EEDD) : const Color(0xFF3D2B1F);
  Color get textMuted =>
      isDark ? const Color(0xFF9C9082) : const Color(0xFFA08868);
  Color get divider =>
      isDark ? const Color(0xFF3A352A) : const Color(0xFFEDE1C8);
  Color get drawerBg =>
      isDark ? const Color(0xFF26221B) : const Color(0xFFFFFFFF);
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

  Color get primary => green;
  Color get accentPrimary => green;
  Color get success => green;
  Color get danger => red;
  Color get warning => orange;
  Color get info => const Color(0xFF1CB0F6);

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

const List<String> kQVowels = ['a', 'e', 'i', 'o'];

List<String> vowelsForConsonant(String consonant) =>
    consonant.toLowerCase() == 'q' ? kQVowels : kVowels;

String displayConsonant(String consonant, {required bool upper}) {
  if (consonant.toLowerCase() == 'q') return 'Q';
  return upper ? consonant.toUpperCase() : consonant.toLowerCase();
}

String buildSyllable(String consonant, String vowel, bool consonantUpper) {
  final c = consonant.toLowerCase();
  final v = vowel.toLowerCase();
  if (c == 'q') {
    if (!kQVowels.contains(v)) return '';
    final prefix = consonantUpper ? 'QU' : 'qu';
    return '$prefix$v';
  }
  final cRaw = consonantUpper ? consonant.toUpperCase() : consonant.toLowerCase();
  return '$cRaw$v';
}

enum GridMode { all, vowels, consonants }
enum DrawerSection { alphabet, games, videos }

class AssetUtils {
  static List<String>? _cachedAssets;

  static Future<List<String>> getAssets() async {
    if (_cachedAssets != null) return _cachedAssets!;
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    _cachedAssets = manifest.listAssets().toList(growable: false);
    return _cachedAssets!;
  }

  static String _normalize(String path) {
    var value = path.trim().replaceAll('\\', '/');
    value = value.replaceFirst(RegExp(r'^/+'), '');
    return value;
  }

  static Future<bool> exists(String path) async {
    final normalized = _normalize(path);
    final assets = await getAssets();
    return assets.contains(normalized) || assets.contains('assets/$normalized');
  }

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

  final Map<String, List<AudioPlayer>> _assetPlayers = {};
  final Map<String, int> _assetCursors = {};
  final Set<String> _preloadedAssets = {};
  final Set<String> _missingAssets = {};

  bool muted = false;
  bool clickMuted = false;
  bool musicMuted = false;
  bool voiceEnabled = true;

  Future<void> preloadAssets(Iterable<String> paths) async {
    final missing = paths.where(
      (path) => !_preloadedAssets.contains(path) && !_missingAssets.contains(path),
    );
    if (missing.isEmpty) return;
    await _preload(missing);
  }

  Future<void> _preload(Iterable<String> paths) async {
    for (final path in paths.toSet()) {
      if (_preloadedAssets.contains(path) || _missingAssets.contains(path)) continue;

      if (!await AssetUtils.exists(path)) {
        _missingAssets.add(path);
        continue;
      }

      final players = <AudioPlayer>[];
      for (var i = 0; i < 2; i++) {
        final player = AudioPlayer();
        try {
          await player.setSource(AssetSource(path));
          players.add(player);
        } catch (_) {
          await player.dispose();
        }
      }
      if (players.isNotEmpty) {
        _assetPlayers[path] = players;
        _assetCursors[path] = 0;
        _preloadedAssets.add(path);
      } else {
        _missingAssets.add(path);
      }
    }
  }

  Future<void> playAsset(String assetPath) async {
    if (muted) return;
    if (_missingAssets.contains(assetPath)) return;

    var players = _assetPlayers[assetPath];
    if (players == null || players.isEmpty) {
      await preloadAssets([assetPath]);
      players = _assetPlayers[assetPath];
    }
    if (players == null || players.isEmpty) return;

    final cursor = _assetCursors[assetPath] ?? 0;
    final player = players[cursor % players.length];
    _assetCursors[assetPath] = cursor + 1;
    try {
      await player.seek(Duration.zero);
      await player.resume();
    } catch (_) {}
  }

  Future<void> playLetter(String letter) async {
    final l = letter.trim().toLowerCase();
    if (l.length != 1 || muted) return;

    final path = kVowels.contains(l)
        ? 'audio/vowels/$l.wav'
        : 'audio/consonants/$l.wav';

    await playAsset(path);
  }

  Future<void> playSyllable(String syllable) async {
    final s = syllable.trim().toLowerCase();
    if (s.isEmpty || muted) return;

    String? firstConsonant;
    for (final c in kConsonants) {
      if (s.startsWith(c)) {
        firstConsonant = c;
        break;
      }
    }
    if (firstConsonant == null) return;

    final path = 'audio/syllables/$firstConsonant/$s.wav';
    await playAsset(path);
  }

  Future<void> playExample(String syllable) async {
    final s = syllable.trim().toLowerCase();
    if (s.isEmpty || muted) return;

    String? firstConsonant;
    for (final c in kConsonants) {
      if (s.startsWith(c)) {
        firstConsonant = c;
        break;
      }
    }
    if (firstConsonant == null) return;

    final path = 'audio/syllables/$firstConsonant/${s}_ex.wav';
    await playAsset(path);
  }

  Future<void> playWord(String word) async {
    final value = word.trim().toLowerCase();
    if (value.isEmpty || muted) return;

    final fileName = value
        .replaceAll(
          RegExp(r'[^a-z0-9áàâãéêíóôõúç ]'),
          '',
        )
        .replaceAll(' ', '_');

    final path = 'audio/words/$fileName.wav';
    await playAsset(path);
  }

  Future<void> play(String text) async {
    final value = text.trim().toLowerCase();
    if (value.isEmpty || muted) return;

    if (value.length == 1) {
      await playLetter(value);
      return;
    }

    bool isSyllable = false;

    if (value.length >= 2 && value.length <= 4) {
      for (final c in kConsonants) {
        if (!value.startsWith(c)) continue;
        for (final v in kVowels) {
          if (buildSyllable(c, v, false) == value) {
            isSyllable = true;
            break;
          }
        }
        if (isSyllable) break;
      }
    }

    if (isSyllable) {
      await playSyllable(value);
    } else {
      await playWord(value);
    }
  }

  Future<void> stop() async {
    for (final players in _assetPlayers.values) {
      for (final player in players) {
        try {
          await player.stop();
        } catch (_) {}
      }
    }
  }

  Future<void> dispose() async {
    await stop();
    for (final players in _assetPlayers.values) {
      for (final player in players) {
        try {
          await player.dispose();
        } catch (_) {}
      }
    }
  }
}