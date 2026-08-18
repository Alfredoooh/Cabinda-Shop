import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    const AlfabetoApp(),
  );
}

class AlfabetoApp extends StatelessWidget {
  const AlfabetoApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const colors = AppColors(false);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ABCtube',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor:
            colors.bg,
        fontFamily: 'ComicSansMS',
        splashFactory:
            NoSplash.splashFactory,
        highlightColor:
            Colors.transparent,
        hoverColor:
            Colors.transparent,
        useMaterial3: false,
      ),
      home: const HomeScreen(),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// CORES ÚNICAS DO ABCTUBE
// ══════════════════════════════════════════════════════════════

class AppColors {
  final bool isDark;

  const AppColors(
    this.isDark,
  );

  // ──────────────────────────────────────────────────────────
  // FUNDO
  // ──────────────────────────────────────────────────────────

  Color get bg =>
      isDark
          ? const Color(0xFF1E1B16)
          : const Color(0xFFFFF8EE);

  Color get bgCardNeutral =>
      isDark
          ? const Color(0xFF2E2A22)
          : const Color(0xFFF0E6D2);

  Color get bgElevated =>
      isDark
          ? const Color(0xFF39342B)
          : const Color(0xFFFFFCF7);

  Color get surface =>
      bgCardNeutral;

  Color get dialogBackground =>
      bgElevated;

  // ──────────────────────────────────────────────────────────
  // TEXTO
  // ──────────────────────────────────────────────────────────

  Color get textMain =>
      isDark
          ? const Color(0xFFF5EEDD)
          : const Color(0xFF3D2B1F);

  Color get textSecondary =>
      isDark
          ? const Color(0xFFB5A896)
          : const Color(0xFF755E45);

  Color get textMuted =>
      isDark
          ? const Color(0xFF9C9082)
          : const Color(0xFFA08868);

  Color get textTertiary =>
      isDark
          ? const Color(0xFF756B5E)
          : const Color(0xFFB29D82);

  // ──────────────────────────────────────────────────────────
  // BORDAS
  // ──────────────────────────────────────────────────────────

  Color get divider =>
      isDark
          ? const Color(0xFF3A352A)
          : const Color(0xFFEDE1C8);

  Color get border =>
      divider;

  Color get borderSoft =>
      isDark
          ? const Color(0x253A352A)
          : const Color(0x40EDE1C8);

  // ──────────────────────────────────────────────────────────
  // SOMBRAS
  // ──────────────────────────────────────────────────────────

  Color get neutralShadow =>
      isDark
          ? const Color(0x40000000)
          : const Color(0x1A000000);

  Color get drawerShadow =>
      isDark
          ? const Color(0x66000000)
          : const Color(0x33000000);

  Color get overlay =>
      isDark
          ? const Color(0x99000000)
          : const Color(0x66000000);

  // ──────────────────────────────────────────────────────────
  // DRAWER
  // ──────────────────────────────────────────────────────────

  Color get drawerBg =>
      isDark
          ? const Color(0xFF26221B)
          : Colors.white;

  // ──────────────────────────────────────────────────────────
  // SWITCH
  // ──────────────────────────────────────────────────────────

  Color get switchThumb =>
      isDark
          ? const Color(0xFFF5EEDD)
          : Colors.white;

  Color get switchThumbShadow =>
      isDark
          ? const Color(0x40000000)
          : const Color(0x33000000);

  // ──────────────────────────────────────────────────────────
  // CORES PRINCIPAIS
  // ──────────────────────────────────────────────────────────

  static const Color green =
      Color(0xFF58CC02);

  static const Color greenShadow =
      Color(0xFF46A302);

  static const Color red =
      Color(0xFFFF4B4B);

  static const Color redShadow =
      Color(0xFFD63D3D);

  static const Color orange =
      Color(0xFFFF9600);

  static const Color blue =
      Color(0xFF1CB0F6);

  static const Color pink =
      Color(0xFFFF4B8C);

  static const Color purple =
      Color(0xFFCE82FF);

  static const Color yellow =
      Color(0xFFFFC800);

  Color get primary =>
      green;

  Color get accentPrimary =>
      green;

  Color get primaryShadow =>
      greenShadow;

  Color get success =>
      green;

  Color get danger =>
      red;

  Color get warning =>
      orange;

  Color get info =>
      blue;

  // ──────────────────────────────────────────────────────────
  // CARD AZUL
  // ──────────────────────────────────────────────────────────

  Color get c0Bg =>
      isDark
          ? const Color(0xFF17394A)
          : const Color(0xFFDDF4FF);

  Color get c0Fg =>
      isDark
          ? const Color(0xFF6FCBFA)
          : blue;

  Color get c0Shadow =>
      isDark
          ? const Color(0xFF0E2732)
          : const Color(0x591CB0F6);

  // ──────────────────────────────────────────────────────────
  // CARD LARANJA
  // ──────────────────────────────────────────────────────────

  Color get c1Bg =>
      isDark
          ? const Color(0xFF4A3320)
          : const Color(0xFFFFE8D6);

  Color get c1Fg =>
      isDark
          ? const Color(0xFFFFB05C)
          : orange;

  Color get c1Shadow =>
      isDark
          ? const Color(0xFF302014)
          : const Color(0x59FF9600);

  // ──────────────────────────────────────────────────────────
  // CARD VERDE
  // ──────────────────────────────────────────────────────────

  Color get c2Bg =>
      isDark
          ? const Color(0xFF22421C)
          : const Color(0xFFE3F9D9);

  Color get c2Fg =>
      isDark
          ? const Color(0xFF86E048)
          : green;

  Color get c2Shadow =>
      isDark
          ? const Color(0xFF152912)
          : const Color(0x5958CC02);

  // ──────────────────────────────────────────────────────────
  // CARD ROSA
  // ──────────────────────────────────────────────────────────

  Color get c3Bg =>
      isDark
          ? const Color(0xFF4A2333)
          : const Color(0xFFFFE0EC);

  Color get c3Fg =>
      isDark
          ? const Color(0xFFFF83B0)
          : pink;

  Color get c3Shadow =>
      isDark
          ? const Color(0xFF2E1521)
          : const Color(0x59FF4B8C);

  // ──────────────────────────────────────────────────────────
  // CARD ROXO
  // ──────────────────────────────────────────────────────────

  Color get c4Bg =>
      isDark
          ? const Color(0xFF362142)
          : const Color(0xFFF1E4FF);

  Color get c4Fg =>
      isDark
          ? const Color(0xFFDCA6FF)
          : purple;

  Color get c4Shadow =>
      isDark
          ? const Color(0xFF21142A)
          : const Color(0x59CE82FF);

  // ──────────────────────────────────────────────────────────
  // CARD AMARELO
  // ──────────────────────────────────────────────────────────

  Color get c5Bg =>
      isDark
          ? const Color(0xFF453A16)
          : const Color(0xFFFFF4CC);

  Color get c5Fg =>
      isDark
          ? const Color(0xFFFFDD6B)
          : yellow;

  Color get c5Shadow =>
      isDark
          ? const Color(0xFF2B240E)
          : const Color(0x59FFC800);

  // ──────────────────────────────────────────────────────────
  // LISTAS DOS JOGOS
  // ──────────────────────────────────────────────────────────

  List<Color> get cardBgList => [
        c0Bg,
        c1Bg,
        c2Bg,
        c3Bg,
        c4Bg,
        c5Bg,
      ];

  List<Color> get cardFgList => [
        c0Fg,
        c1Fg,
        c2Fg,
        c3Fg,
        c4Fg,
        c5Fg,
      ];

  List<Color> get cardShadowList => [
        c0Shadow,
        c1Shadow,
        c2Shadow,
        c3Shadow,
        c4Shadow,
        c5Shadow,
      ];

  // ──────────────────────────────────────────────────────────
  // RAIOS ÚNICOS
  // ──────────────────────────────────────────────────────────

  double get radiusSmall =>
      12;

  double get radiusMedium =>
      16;

  double get radiusLarge =>
      20;
}

// ══════════════════════════════════════════════════════════════
// LETRAS
// ══════════════════════════════════════════════════════════════

const List<String> kVowels = [
  'a',
  'e',
  'i',
  'o',
  'u',
];

const List<String> kAllLetters = [
  'a',
  'b',
  'c',
  'd',
  'e',
  'f',
  'g',
  'h',
  'i',
  'j',
  'k',
  'l',
  'm',
  'n',
  'o',
  'p',
  'q',
  'r',
  's',
  't',
  'u',
  'v',
  'w',
  'x',
  'y',
  'z',
];

final List<String> kConsonants =
    kAllLetters
        .where(
          (letter) =>
              !kVowels.contains(
            letter,
          ),
        )
        .toList();

String buildSyllable(
  String consonant,
  String vowel,
  bool upper,
) {
  final c =
      upper
          ? consonant.toUpperCase()
          : consonant.toLowerCase();

  final v =
      vowel.toLowerCase();

  if (consonant
          .toLowerCase() ==
      'q') {
    if (v == 'a') {
      return '${c}ua';
    }

    if (v == 'e') {
      return '${c}ue';
    }

    if (v == 'i') {
      return '${c}ui';
    }

    if (v == 'o') {
      return '${c}uo';
    }

    if (v == 'u') {
      return '${c}u';
    }
  }

  return '$c$v';
}

// ══════════════════════════════════════════════════════════════
// GRID MODE
// ══════════════════════════════════════════════════════════════

enum GridMode {
  all,
  vowels,
  consonants,
}

// ══════════════════════════════════════════════════════════════
// DRAWER SECTION
// ══════════════════════════════════════════════════════════════

enum DrawerSection {
  alphabet,
  games,
  videos,
}

// ══════════════════════════════════════════════════════════════
// ASSET UTILS
// ══════════════════════════════════════════════════════════════

class AssetUtils {
  static List<String>? _cache;

  static Future<List<String>>
      getAssets() async {
    if (_cache != null) {
      return _cache!;
    }

    final manifest =
        await AssetManifest
            .loadFromAssetBundle(
      rootBundle,
    );

    _cache =
        manifest
            .listAssets()
            .toList(
              growable: false,
            );

    return _cache!;
  }

  static Future<bool> exists(
    String path,
  ) async {
    final assets =
        await getAssets();

    final normalized =
        path
            .replaceAll(
              '\\',
              '/',
            )
            .replaceFirst(
              RegExp(
                r'^/+',
              ),
              '',
            );

    return assets.contains(
          normalized,
        ) ||
        assets.contains(
          'assets/$normalized',
        );
  }

  static Future<List<String>>
      getAssetsInFolder(
    String folder,
  ) async {
    final assets =
        await getAssets();

    var normalized =
        folder
            .replaceAll(
              '\\',
              '/',
            )
            .replaceFirst(
              RegExp(
                r'^/+',
              ),
              '',
            );

    if (normalized
        .startsWith(
      'assets/',
    )) {
      normalized =
          normalized.substring(
        7,
      );
    }

    normalized =
        normalized.replaceFirst(
      RegExp(
        r'/+$',
      ),
      '',
    );

    if (normalized
        .isEmpty) {
      return const [];
    }

    final prefix =
        'assets/$normalized/';

    final result =
        <String>[];

    for (final asset
        in assets) {
      if (!asset
          .startsWith(
        prefix,
      )) {
        continue;
      }

      final relative =
          asset.substring(
        prefix.length,
      );

      if (relative
          .isEmpty) {
        continue;
      }

      if (relative
          .contains(
        '/',
      )) {
        continue;
      }

      result.add(
        asset,
      );
    }

    result.sort();

    return result;
  }
}

// ══════════════════════════════════════════════════════════════
// SOUND MANAGER
// ══════════════════════════════════════════════════════════════

class SoundManager {
  SoundManager._();

  static final SoundManager
      instance =
      SoundManager._();

  final AudioPlayer
      _player =
      AudioPlayer();

  final FlutterTts
      _tts =
      FlutterTts();

  bool muted =
      false;

  bool clickMuted =
      false;

  bool musicMuted =
      false;

  bool _ttsReady =
      false;

  Future<void>
      _initTts() async {
    if (_ttsReady) {
      return;
    }

    try {
      await _tts
          .setLanguage(
        'pt-PT',
      );

      await _tts
          .setSpeechRate(
        0.38,
      );

      await _tts
          .setPitch(
        1.0,
      );

      await _tts
          .setVolume(
        1.0,
      );

      _ttsReady =
          true;
    } catch (_) {}
  }

  Future<void> playClick() async {
    if (muted ||
        clickMuted) {
      return;
    }

    if (await AssetUtils
        .exists(
      'audio/pressing.wav',
    )) {
      await _playAsset(
        'audio/pressing.wav',
      );

      return;
    }

    await speak(
      'clique',
      rate:
          0.55,
    );
  }

  Future<void> play(
    String value,
  ) async {
    final text =
        value
            .trim()
            .toLowerCase();

    if (text
            .isEmpty ||
        muted) {
      return;
    }

    if (text.length ==
        1) {
      await playLetter(
        text,
      );
      return;
    }

    if (_isSyllable(
      text,
    )) {
      await playSyllable(
        text,
      );
      return;
    }

    await playWord(
      text,
    );
  }

  Future<void> playLetter(
    String letter,
  ) async {
    final value =
        letter
            .trim()
            .toLowerCase();

    if (value.length !=
            1 ||
        muted) {
      return;
    }

    final folder =
        kVowels.contains(
      value,
    )
            ? 'audio/vowels'
            : 'audio/consonants';

    final path =
        '$folder/$value.wav';

    if (await AssetUtils
        .exists(
      path,
    )) {
      await _playAsset(
        path,
      );
      return;
    }

    await speak(
      value,
      rate:
          0.30,
    );
  }

  Future<void>
      playSyllable(
    String syllable,
  ) async {
    final value =
        syllable
            .trim()
            .toLowerCase();

    if (value
            .isEmpty ||
        muted) {
      return;
    }

    String? consonant;

    for (final item
        in kConsonants) {
      if (value.startsWith(
        item,
      )) {
        consonant =
            item;
        break;
      }
    }

    if (consonant !=
        null) {
      final path =
          'audio/syllables/'
          '$consonant/'
          '$value.wav';

      if (await AssetUtils
          .exists(
        path,
      )) {
        await _playAsset(
          path,
        );
        return;
      }
    }

    await speak(
      value,
      rate:
          0.34,
    );
  }

  Future<void>
      playExample(
    String syllable,
  ) async {
    final value =
        syllable
            .trim()
            .toLowerCase();

    if (value
            .isEmpty ||
        muted) {
      return;
    }

    String? consonant;

    for (final item
        in kConsonants) {
      if (value.startsWith(
        item,
      )) {
        consonant =
            item;
        break;
      }
    }

    if (consonant !=
        null) {
      final path =
          'audio/syllables/'
          '$consonant/'
          '${value}_ex.wav';

      if (await AssetUtils
          .exists(
        path,
      )) {
        await _playAsset(
          path,
        );
        return;
      }
    }

    await speak(
      value,
      rate:
          0.34,
    );
  }

  Future<void>
      playWord(
    String word,
  ) async {
    final value =
        word
            .trim()
            .toLowerCase();

    if (value
            .isEmpty ||
        muted) {
      return;
    }

    final filename =
        value
            .replaceAll(
              RegExp(
                r'[^a-z0-9áàâãéêíóôõúç ]',
              ),
              '',
            )
            .replaceAll(
              ' ',
              '_',
            );

    final path =
        'audio/words/'
        '$filename.wav';

    if (await AssetUtils
        .exists(
      path,
    )) {
      await _playAsset(
        path,
      );
      return;
    }

    await speak(
      value,
      rate:
          0.36,
    );
  }

  Future<void> speak(
    String text, {
    double rate =
        0.38,
  }) async {
    if (muted ||
        text.trim().isEmpty) {
      return;
    }

    try {
      await _initTts();

      await _tts.stop();

      await _tts
          .setSpeechRate(
        rate,
      );

      await _tts
          .speak(
        text.trim(),
      );
    } catch (_) {}
  }

  bool _isSyllable(
    String value,
  ) {
    if (value.length <
            2 ||
        value.length >
            4) {
      return false;
    }

    for (final consonant
        in kConsonants) {
      if (!value.startsWith(
        consonant,
      )) {
        continue;
      }

      for (final vowel
          in kVowels) {
        if (buildSyllable(
              consonant,
              vowel,
              false,
            ) ==
            value) {
          return true;
        }
      }
    }

    return false;
  }

  Future<void>
      _playAsset(
    String path,
  ) async {
    if (muted) {
      return;
    }

    try {
      await _player.stop();

      await _player
          .play(
        AssetSource(
          path,
        ),
      );
    } catch (_) {}
  }

  Future<void> stop() async {
    try {
      await _player
          .stop();
    } catch (_) {}

    try {
      await _tts.stop();
    } catch (_) {}
  }

  Future<void> dispose() async {
    await stop();

    await _player
        .dispose();
  }
}