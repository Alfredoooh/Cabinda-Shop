import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'screens/home_screen.dart';

// ══════════════════════════════════════════════════════════════
// MAIN
// ══════════════════════════════════════════════════════════════

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
    const ABCtubeApp(),
  );
}

// ══════════════════════════════════════════════════════════════
// APP
// ══════════════════════════════════════════════════════════════

class ABCtubeApp extends StatelessWidget {
  const ABCtubeApp({super.key});

  @override
  Widget build(BuildContext context) {
    const isDark = false;

    final colors = AppColors(
      isDark,
      AppStyle.classic,
      AppDesign.custom,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ABCtube',
      theme: AppTheme.build(
        colors: colors,
        isDark: isDark,
        design: AppDesign.custom,
      ),
      home: HomeScreen(
        initialColors: colors,
        initialDark: isDark,
        initialStyle: AppStyle.classic,
        initialDesign: AppDesign.custom,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// DESIGN
// ══════════════════════════════════════════════════════════════

enum AppDesign {
  custom,
  material,
}

enum AppStyle {
  classic,
  playful,
  ocean,
  sunset,
  monochrome,
}

enum GridMode {
  all,
  vowels,
  consonants,
}

enum DrawerSection {
  alphabet,
  games,
  videos,
}

// ══════════════════════════════════════════════════════════════
// APP COLORS
// ══════════════════════════════════════════════════════════════

class AppColors {
  final bool isDark;
  final AppStyle style;
  final AppDesign design;

  AppColors(
    this.isDark, [
    this.style = AppStyle.classic,
    this.design = AppDesign.custom,
  ]);

  // ════════════════════════════════════════════════════════════
  // CORES ESTÁTICAS
  // ════════════════════════════════════════════════════════════

  static const Color green = Color(
    0xFF58CC02,
  );

  static const Color greenShadow = Color(
    0xFF46A302,
  );

  static const Color orange = Color(
    0xFFFF9600,
  );

  static const Color red = Color(
    0xFFFF4B4B,
  );

  static const Color redShadow = Color(
    0xFFD63D3D,
  );

  static const Color blue = Color(
    0xFF1CB0F6,
  );

  static const Color pink = Color(
    0xFFFF4B8C,
  );

  static const Color purple = Color(
    0xFFCE82FF,
  );

  static const Color yellow = Color(
    0xFFFFC800,
  );

  // ════════════════════════════════════════════════════════════
  // BACKGROUND
  // ════════════════════════════════════════════════════════════

  Color get bg {
    switch (style) {
      case AppStyle.classic:
        return isDark
            ? const Color(0xFF242424)
            : const Color(0xFFFFFFFF);

      case AppStyle.playful:
        return isDark
            ? const Color(0xFF211523)
            : const Color(0xFFFFF5FB);

      case AppStyle.ocean:
        return isDark
            ? const Color(0xFF071E29)
            : const Color(0xFFF1FBFF);

      case AppStyle.sunset:
        return isDark
            ? const Color(0xFF271611)
            : const Color(0xFFFFF7F1);

      case AppStyle.monochrome:
        return isDark
            ? const Color(0xFF181818)
            : const Color(0xFFF5F5F5);
    }
  }

  Color get bgSecondary {
    switch (style) {
      case AppStyle.classic:
        return isDark
            ? const Color(0xFF2C2C2E)
            : const Color(0xFFF5F5F5);

      case AppStyle.playful:
        return isDark
            ? const Color(0xFF35233A)
            : const Color(0xFFFFE9F5);

      case AppStyle.ocean:
        return isDark
            ? const Color(0xFF103746)
            : const Color(0xFFE1F6FF);

      case AppStyle.sunset:
        return isDark
            ? const Color(0xFF40251D)
            : const Color(0xFFFFE9DA);

      case AppStyle.monochrome:
        return isDark
            ? const Color(0xFF292929)
            : const Color(0xFFFFFFFF);
    }
  }

  Color get bgTertiary {
    return isDark
        ? const Color(0xFF333335)
        : const Color(0xFFEDEDED);
  }

  Color get bgElevated {
    return isDark
        ? const Color(0xFF3A3A3D)
        : const Color(0xFFFFFFFF);
  }

  Color get surface => bgCardNeutral;

  Color get bgCardNeutral => bgSecondary;

  Color get dialogBackground =>
      bgElevated;

  // ════════════════════════════════════════════════════════════
  // TEXT
  // ════════════════════════════════════════════════════════════

  Color get textMain {
    switch (style) {
      case AppStyle.classic:
        return isDark
            ? const Color(0xFFF2F2F2)
            : const Color(0xFF242424);

      case AppStyle.playful:
        return isDark
            ? const Color(0xFFFFECF8)
            : const Color(0xFF321D2E);

      case AppStyle.ocean:
        return isDark
            ? const Color(0xFFE8FBFF)
            : const Color(0xFF12323D);

      case AppStyle.sunset:
        return isDark
            ? const Color(0xFFFFEEE7)
            : const Color(0xFF3B2016);

      case AppStyle.monochrome:
        return isDark
            ? const Color(0xFFF2F2F2)
            : const Color(0xFF252525);
    }
  }

  Color get textSecondary {
    return isDark
        ? const Color(0xFFA8A8AC)
        : const Color(0xFF555555);
  }

  Color get textMuted {
    return isDark
        ? const Color(0xFFA8A8AC)
        : const Color(0xFF6E6E73);
  }

  Color get textTertiary {
    return isDark
        ? const Color(0xFF6E6E73)
        : const Color(0xFF888888);
  }

  // ════════════════════════════════════════════════════════════
  // BORDER / DIVIDER / SHADOW
  // ════════════════════════════════════════════════════════════

  Color get divider {
    return isDark
        ? const Color(0xFF3D3D40)
        : const Color(0xFFE0E0E0);
  }

  Color get border => divider;

  Color get borderSoft {
    return isDark
        ? const Color(0x303D3D40)
        : const Color(0x20D0D0D0);
  }

  Color get neutralShadow {
    return isDark
        ? const Color(0x40000000)
        : const Color(0x20000000);
  }

  Color get drawerShadow {
    return isDark
        ? const Color(0x66000000)
        : const Color(0x33000000);
  }

  Color get overlay {
    return isDark
        ? const Color(0x99000000)
        : const Color(0x66000000);
  }

  // ════════════════════════════════════════════════════════════
  // PRIMARY
  // ════════════════════════════════════════════════════════════

  Color get primary {
    switch (style) {
      case AppStyle.classic:
        return green;

      case AppStyle.playful:
        return isDark
            ? const Color(0xFFFF75B9)
            : const Color(0xFFFF4B8C);

      case AppStyle.ocean:
        return isDark
            ? const Color(0xFF64D8FF)
            : const Color(0xFF0288D1);

      case AppStyle.sunset:
        return isDark
            ? const Color(0xFFFFB74D)
            : const Color(0xFFF4511E);

      case AppStyle.monochrome:
        return isDark
            ? const Color(0xFFE0E0E0)
            : const Color(0xFF424242);
    }
  }

  Color get accentPrimary => primary;

  Color get primaryShadow {
    return Color.alphaBlend(
      const Color(0x66000000),
      primary,
    );
  }

  Color get danger {
    return isDark
        ? const Color(0xFFFF6B6B)
        : const Color(0xFFD32F2F);
  }

  Color get success => green;

  Color get warning => yellow;

  Color get info => blue;

  // ════════════════════════════════════════════════════════════
  // DRAWER
  // ════════════════════════════════════════════════════════════

  Color get drawerBg => bgSecondary;

  // ════════════════════════════════════════════════════════════
  // SWITCH
  // ════════════════════════════════════════════════════════════

  Color get switchThumb => Colors.white;

  Color get switchThumbShadow {
    return isDark
        ? const Color(0x55000000)
        : const Color(0x33000000);
  }

  // ════════════════════════════════════════════════════════════
  // CARD 0
  // ════════════════════════════════════════════════════════════

  Color get c0Bg {
    return isDark
        ? const Color(0xFF17394A)
        : const Color(0xFFDDF4FF);
  }

  Color get c0Fg {
    return isDark
        ? const Color(0xFF6FCBFA)
        : blue;
  }

  Color get c0Shadow {
    return isDark
        ? const Color(0xFF0E2732)
        : const Color(0x591CB0F6);
  }

  // ════════════════════════════════════════════════════════════
  // CARD 1
  // ════════════════════════════════════════════════════════════

  Color get c1Bg {
    return isDark
        ? const Color(0xFF4A3320)
        : const Color(0xFFFFE8D6);
  }

  Color get c1Fg {
    return isDark
        ? const Color(0xFFFFB05C)
        : orange;
  }

  Color get c1Shadow {
    return isDark
        ? const Color(0xFF302014)
        : const Color(0x59FF9600);
  }

  // ════════════════════════════════════════════════════════════
  // CARD 2
  // ════════════════════════════════════════════════════════════

  Color get c2Bg {
    return isDark
        ? const Color(0xFF22421C)
        : const Color(0xFFE3F9D9);
  }

  Color get c2Fg {
    return isDark
        ? const Color(0xFF86E048)
        : green;
  }

  Color get c2Shadow {
    return isDark
        ? const Color(0xFF152912)
        : const Color(0x5958CC02);
  }

  // ════════════════════════════════════════════════════════════
  // CARD 3
  // ════════════════════════════════════════════════════════════

  Color get c3Bg {
    return isDark
        ? const Color(0xFF4A2333)
        : const Color(0xFFFFE0EC);
  }

  Color get c3Fg {
    return isDark
        ? const Color(0xFFFF83B0)
        : pink;
  }

  Color get c3Shadow {
    return isDark
        ? const Color(0xFF2E1521)
        : const Color(0x59FF4B8C);
  }

  // ════════════════════════════════════════════════════════════
  // CARD 4
  // ════════════════════════════════════════════════════════════

  Color get c4Bg {
    return isDark
        ? const Color(0xFF362142)
        : const Color(0xFFF1E4FF);
  }

  Color get c4Fg {
    return isDark
        ? const Color(0xFFDCA6FF)
        : purple;
  }

  Color get c4Shadow {
    return isDark
        ? const Color(0xFF21142A)
        : const Color(0x59CE82FF);
  }

  // ════════════════════════════════════════════════════════════
  // CARD 5
  // ════════════════════════════════════════════════════════════

  Color get c5Bg {
    return isDark
        ? const Color(0xFF453A16)
        : const Color(0xFFFFF4CC);
  }

  Color get c5Fg {
    return isDark
        ? const Color(0xFFFFDD6B)
        : yellow;
  }

  Color get c5Shadow {
    return isDark
        ? const Color(0xFF2B240E)
        : const Color(0x59FFC800);
  }

  // ════════════════════════════════════════════════════════════
  // LISTAS DOS JOGOS
  // ════════════════════════════════════════════════════════════

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

  // ════════════════════════════════════════════════════════════
  // RADIUS
  // ════════════════════════════════════════════════════════════

  double get radiusSmall {
    return design == AppDesign.material
        ? 8
        : 12;
  }

  double get radiusMedium {
    return design == AppDesign.material
        ? 12
        : 16;
  }

  double get radiusLarge {
    return design == AppDesign.material
        ? 16
        : 20;
  }
}

// ══════════════════════════════════════════════════════════════
// APP THEME
// ══════════════════════════════════════════════════════════════

class AppTheme {
  static ThemeData build({
    required AppColors colors,
    required bool isDark,
    required AppDesign design,
  }) {
    final brightness =
        isDark
            ? Brightness.dark
            : Brightness.light;

    if (design == AppDesign.material) {
      return ThemeData(
        useMaterial3: true,
        brightness: brightness,
        scaffoldBackgroundColor:
            colors.bg,
        colorScheme:
            ColorScheme.fromSeed(
          seedColor:
              colors.primary,
          brightness:
              brightness,
        ),
        appBarTheme:
            AppBarTheme(
          backgroundColor:
              Colors.transparent,
          surfaceTintColor:
              Colors.transparent,
          elevation: 0,
          scrolledUnderElevation:
              0,
          foregroundColor:
              colors.textMain,
        ),
        cardTheme:
            CardThemeData(
          color:
              colors.bgCardNeutral,
          elevation: 0,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              12,
            ),
          ),
        ),
        switchTheme:
            SwitchThemeData(
          thumbColor:
              WidgetStateProperty.resolveWith(
            (states) {
              if (states.contains(
                WidgetState.selected,
              )) {
                return colors.primary;
              }

              return colors.switchThumb;
            },
          ),
          trackColor:
              WidgetStateProperty.resolveWith(
            (states) {
              if (states.contains(
                WidgetState.selected,
              )) {
                return colors.primary.withOpacity(
                  0.35,
                );
              }

              return colors.divider;
            },
          ),
        ),
      );
    }

    return ThemeData(
      useMaterial3: false,
      brightness: brightness,
      scaffoldBackgroundColor:
          colors.bg,
      colorScheme:
          ColorScheme.fromSeed(
        seedColor:
            colors.primary,
        brightness:
            brightness,
      ),
    );
  }
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
              !kVowels.contains(letter),
        )
        .toList();

String buildSyllable(
  String consonant,
  String vowel,
  bool consonantUpper,
) {
  final c =
      consonantUpper
          ? consonant.toUpperCase()
          : consonant.toLowerCase();

  final v =
      vowel.toLowerCase();

  if (consonant.toLowerCase() == 'q') {
    switch (v) {
      case 'a':
        return '${c}ua';

      case 'e':
        return '${c}ue';

      case 'i':
        return '${c}ui';

      case 'o':
        return '${c}uo';

      case 'u':
        return '${c}u';
    }
  }

  return '$c$v';
}

// ══════════════════════════════════════════════════════════════
// ASSET UTILS
// ══════════════════════════════════════════════════════════════

class AssetUtils {
  static List<String>? _cachedAssets;

  static Future<List<String>> getAssets() async {
    if (_cachedAssets != null) {
      return _cachedAssets!;
    }

    final manifest =
        await AssetManifest.loadFromAssetBundle(
      rootBundle,
    );

    _cachedAssets =
        manifest
            .listAssets()
            .toList(
              growable: false,
            );

    return _cachedAssets!;
  }

  static Future<List<String>> assets() async {
    return getAssets();
  }

  static String _normalizePath(
    String value,
  ) {
    var path = value.trim();

    path = path.replaceAll(
      '\\',
      '/',
    );

    path = path.replaceFirst(
      RegExp(r'^/+'),
      '',
    );

    return path;
  }

  static Future<bool> exists(
    String path,
  ) async {
    final normalized =
        _normalizePath(
      path,
    );

    final all =
        await getAssets();

    if (all.contains(
      normalized,
    )) {
      return true;
    }

    if (all.contains(
      'assets/$normalized',
    )) {
      return true;
    }

    return false;
  }

  static Future<List<String>>
      getAssetsInFolder(
    String folderPath,
  ) async {
    final all =
        await getAssets();

    var folder =
        _normalizePath(
      folderPath,
    );

    if (folder.startsWith(
      'assets/',
    )) {
      folder =
          folder.substring(
        'assets/'.length,
      );
    }

    folder =
        folder.replaceFirst(
      RegExp(r'/+$'),
      '',
    );

    if (folder.isEmpty) {
      return const [];
    }

    final prefix =
        'assets/$folder/';

    final result =
        <String>[];

    for (final asset in all) {
      if (!asset.startsWith(
        prefix,
      )) {
        continue;
      }

      final relative =
          asset.substring(
        prefix.length,
      );

      if (relative.isEmpty) {
        continue;
      }

      if (relative.contains(
        '/',
      )) {
        continue;
      }

      result.add(
        asset,
      );
    }

    result.sort();

    return List<String>.unmodifiable(
      result,
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SOUND MANAGER
// ══════════════════════════════════════════════════════════════

class SoundManager {
  SoundManager._();

  static final SoundManager instance =
      SoundManager._();

  final AudioPlayer _player =
      AudioPlayer();

  final FlutterTts _tts =
      FlutterTts();

  bool muted = false;

  bool clickMuted = false;

  bool musicMuted = false;

  bool _ttsInitialized = false;

  Future<void> _initializeTts() async {
    if (_ttsInitialized) {
      return;
    }

    try {
      await _tts.setLanguage(
        'pt-PT',
      );

      await _tts.setSpeechRate(
        0.38,
      );

      await _tts.setPitch(
        1.0,
      );

      await _tts.setVolume(
        1.0,
      );

      _ttsInitialized = true;
    } catch (_) {}
  }

  Future<void> playClick() async {
    if (muted ||
        clickMuted) {
      return;
    }

    if (await AssetUtils.exists(
      'audio/pressing.wav',
    )) {
      await _playAsset(
        'audio/pressing.wav',
      );

      return;
    }

    await speak(
      'clique',
      rate: 0.55,
    );
  }

  Future<void> play(
    String value,
  ) async {
    final text =
        value.trim().toLowerCase();

    if (text.isEmpty ||
        muted) {
      return;
    }

    if (text.length == 1) {
      await playLetter(
        text,
      );

      return;
    }

    if (_looksLikeSyllable(
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
        letter.trim().toLowerCase();

    if (value.length != 1 ||
        muted) {
      return;
    }

    final folder =
        kVowels.contains(value)
            ? 'audio/vowels'
            : 'audio/consonants';

    final path =
        '$folder/$value.wav';

    if (await AssetUtils.exists(
      path,
    )) {
      await _playAsset(
        path,
      );

      return;
    }

    await speak(
      value,
      rate: 0.30,
    );
  }

  Future<void> playSyllable(
    String syllable,
  ) async {
    final value =
        syllable.trim().toLowerCase();

    if (value.isEmpty ||
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

      if (await AssetUtils.exists(
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
      rate: 0.34,
    );
  }

  Future<void> playExample(
    String syllable,
  ) async {
    final value =
        syllable.trim().toLowerCase();

    if (value.isEmpty ||
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

    if (consonant != null) {
      final path =
          'audio/syllables/'
          '$consonant/'
          '${value}_ex.wav';

      if (await AssetUtils.exists(
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
      rate: 0.34,
    );
  }

  Future<void> playWord(
    String word,
  ) async {
    final value =
        word.trim().toLowerCase();

    if (value.isEmpty ||
        muted) {
      return;
    }

    final fileName =
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
        'audio/words/$fileName.wav';

    if (await AssetUtils.exists(
      path,
    )) {
      await _playAsset(
        path,
      );

      return;
    }

    await speak(
      value,
      rate: 0.36,
    );
  }

  Future<void> speak(
    String text, {
    double rate = 0.38,
  }) async {
    if (muted ||
        text.trim().isEmpty) {
      return;
    }

    try {
      await _initializeTts();

      await _tts.stop();

      await _tts.setSpeechRate(
        rate,
      );

      await _tts.speak(
        text.trim(),
      );
    } catch (_) {}
  }

  bool _looksLikeSyllable(
    String value,
  ) {
    if (value.length < 2 ||
        value.length > 4) {
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
        final built =
            buildSyllable(
          consonant,
          vowel,
          false,
        );

        if (built == value) {
          return true;
        }
      }
    }

    return false;
  }

  Future<void> _playAsset(
    String path,
  ) async {
    if (muted) {
      return;
    }

    try {
      await _player.stop();

      await _player.play(
        AssetSource(
          path,
        ),
      );
    } catch (_) {}
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}

    try {
      await _tts.stop();
    } catch (_) {}
  }

  Future<void> dispose() async {
    await stop();

    await _player.dispose();
  }
}

// ══════════════════════════════════════════════════════════════
// APP ICON
// ══════════════════════════════════════════════════════════════

class AppIcon extends StatelessWidget {
  final AppColors colors;
  final IconData materialIcon;
  final String? customAsset;
  final double size;

  const AppIcon({
    super.key,
    required this.colors,
    required this.materialIcon,
    this.customAsset,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    if (colors.design ==
        AppDesign.material) {
      return Icon(
        materialIcon,
        size: size,
        color: colors.textMain,
      );
    }

    if (customAsset != null) {
      return Image.asset(
        customAsset!,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder:
            (
          _,
          __,
          ___,
        ) {
          return Icon(
            materialIcon,
            size: size,
            color: colors.textMain,
          );
        },
      );
    }

    return Icon(
      materialIcon,
      size: size,
      color: colors.textMain,
    );
  }
}