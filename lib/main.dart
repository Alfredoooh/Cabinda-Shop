import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const AlfabetoApp());
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