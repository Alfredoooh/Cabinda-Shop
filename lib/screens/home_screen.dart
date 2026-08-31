// screens/home_screen.dart — trilha vertical mais compacta
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'
    show AppColors, GridMode, DrawerSection, SoundManager, ThemePrefs, AppPrefs, kConsonants, applySystemUi;
import 'detail_screen.dart';
import 'games_screen.dart';
import 'playlist_covers_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool isDark = false;
  GridMode currentMode = GridMode.all;
  DrawerSection currentSection = DrawerSection.alphabet;
  bool soundEnabled = true;
  bool musicEnabled = true;
  bool voiceEnabled = true;

  late AnimationController _drawerController;
  late Animation<Offset> _drawerSlide;
  bool _drawerOpen = false;

  static const double _drawerWidthFactor = 0.78;
  static const Curve _drawerCurve = Curves.easeInOutCubic;

  @override
  void initState() {
    super.initState();
    applySystemUi(isDark);
    _loadTheme();
    _loadPreferences();
    _drawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    );
    _drawerSlide = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _drawerController,
      curve: _drawerCurve,
    ));
  }

  Future<void> _loadTheme() async {
    final saved = await ThemePrefs.getIsDark();
    if (mounted && saved != null) {
      setState(() => isDark = saved);
      applySystemUi(saved);
    }
  }

  Future<void> _loadPreferences() async {
    await AppPrefs.load();
    if (!mounted) return;
    setState(() {
      soundEnabled = AppPrefs.soundEnabled;
      musicEnabled = AppPrefs.musicEnabled;
      voiceEnabled = AppPrefs.voiceEnabled;
    });
  }

  @override
  void dispose() {
    _drawerController.dispose();
    super.dispose();
  }

  void openDrawer() {
    setState(() => _drawerOpen = true);
    _drawerController.forward();
  }

  void closeDrawer() {
    _drawerController.reverse().then((_) {
      if (mounted) setState(() => _drawerOpen = false);
    });
  }

  void toggleTheme() {
    setState(() => isDark = !isDark);
    applySystemUi(isDark);
    ThemePrefs.setIsDark(isDark);
  }

  void toggleSound() {
    setState(() {
      soundEnabled = !soundEnabled;
    });
  }

  void openSettings() async {
    closeDrawer();
    await AppPrefs.load();
    if (!mounted) return;
    final result = await Navigator.of(context).push<AppSettingsResult>(
      CupertinoPageRoute(
        builder: (_) => SettingsScreen(
          colors: AppColors(isDark),
          isDark: isDark,
          soundEnabled: AppPrefs.soundEnabled,
          musicEnabled: AppPrefs.musicEnabled,
          voiceEnabled: AppPrefs.voiceEnabled,
        ),
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      isDark = result.isDark;
      applySystemUi(isDark);
      soundEnabled = result.soundEnabled;
      musicEnabled = result.musicEnabled;
      voiceEnabled = result.voiceEnabled;
    });

    AppPrefs.setSoundEnabled(soundEnabled);
    AppPrefs.setMusicEnabled(musicEnabled);
    AppPrefs.setVoiceEnabled(voiceEnabled);
  }

  void openDetail(int consonantIndex) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => DetailScreen(
          colors: AppColors(isDark),
          initialConsonantIndex: consonantIndex,
        ),
      ),
    );
  }

  Widget _buildSection(AppColors colors) {
    switch (currentSection) {
      case DrawerSection.alphabet:
        return _AlphabetSection(
          key: const ValueKey(DrawerSection.alphabet),
          colors: colors,
          currentMode: currentMode,
          onConsonantTap: openDetail,
        );
      case DrawerSection.games:
        return GamesScreen(
          key: const ValueKey(DrawerSection.games),
          colors: colors,
        );
      case DrawerSection.videos:
        return PlaylistCoversScreen(
          key: const ValueKey(DrawerSection.videos),
          colors: colors,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(isDark);
    final isAlphabet = currentSection == DrawerSection.alphabet;
    // Cor do appbar/header nesta secção — a statusbar segue esta cor,
    // exatamente como pedido: statusbar sempre igual à cor principal
    // do appbar/header ativo.
    final appBarColor = isAlphabet ? colors.bgCardNeutral : colors.bg;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: appBarColor,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: colors.bg,
        body: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _AppBarWidget(
                    colors: colors,
                    onMenuTap: openDrawer,
                    currentSection: currentSection,
                    currentMode: currentMode,
                    onModeChange: (m) => setState(() => currentMode = m),
                    soundEnabled: soundEnabled,
                    onSoundToggle: toggleSound,
                  ),
                  Expanded(
                    child: SafeArea(
                      top: false,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        switchInCurve: const Cubic(0.22, 1, 0.36, 1),
                        switchOutCurve: const Cubic(0.22, 1, 0.36, 1),
                        transitionBuilder: (child, animation) {
                          final slide = Tween<Offset>(
                            begin: const Offset(0.06, 0),
                            end: Offset.zero,
                          ).animate(animation);
                          return ClipRect(
                            child: SlideTransition(
                              position: slide,
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            ),
                          );
                        },
                        layoutBuilder: (currentChild, previousChildren) {
                          return Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              ...previousChildren,
                              if (currentChild != null) currentChild,
                            ],
                          );
                        },
                        child: _buildSection(colors),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_drawerOpen)
              AnimatedBuilder(
                animation: _drawerController,
                builder: (context, _) => GestureDetector(
                  onTap: closeDrawer,
                  child: Container(
                    color: Color.lerp(
                      Colors.transparent,
                      colors.overlay,
                      _drawerController.value,
                    ),
                  ),
                ),
              ),
            if (_drawerOpen)
              SlideTransition(
                position: _drawerSlide,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _AppDrawer(
                    colors: colors,
                    isDark: isDark,
                    currentSection: currentSection,
                    onSectionSelected: (s) {
                      setState(() => currentSection = s);
                      closeDrawer();
                    },
                    onThemeToggle: toggleTheme,
                    onSettingsTap: openSettings,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Persistência do tema
// ─────────────────────────────────────────────
class ThemePrefs {
  static const _key = 'is_dark_theme';

  static Future<bool?> getIsDark() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_key)) return null;
    return prefs.getBool(_key);
  }

  static Future<void> setIsDark(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }
}

// ─────────────────────────────────────────────
// AppBar
// ─────────────────────────────────────────────
class _AppBarWidget extends StatelessWidget {
  final AppColors colors;
  final VoidCallback onMenuTap;
  final DrawerSection currentSection;
  final GridMode currentMode;
  final ValueChanged<GridMode> onModeChange;
  final bool soundEnabled;
  final VoidCallback onSoundToggle;

  const _AppBarWidget({
    required this.colors,
    required this.onMenuTap,
    required this.currentSection,
    required this.currentMode,
    required this.onModeChange,
    required this.soundEnabled,
    required this.onSoundToggle,
  });

  // Raio da curva em baixo do appbar — mesma referência visual
  // pedida (appbar com curva côncava na base).
  static const double _appBarCurveRadius = 28;

  String get _iconeAtivo {
    switch (currentSection) {
      case DrawerSection.alphabet:
        return 'assets/icons/alphabet-icon.png';
      case DrawerSection.games:
        return 'assets/icons/games-icon.png';
      case DrawerSection.videos:
        return 'assets/icons/videos-icon.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAlphabet = currentSection == DrawerSection.alphabet;

    return SafeArea(
      bottom: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        decoration: BoxDecoration(
          color: isAlphabet ? colors.bgCardNeutral : colors.bg,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(_appBarCurveRadius),
            bottomRight: Radius.circular(_appBarCurveRadius),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _PressableIconButton(
                  colors: colors,
                  onTap: onMenuTap,
                  child: SvgPicture.asset(
                    'assets/icons/menu-icon.svg',
                    width: 18,
                    height: 18,
                    colorFilter:
                        ColorFilter.mode(colors.textMuted, BlendMode.srcIn),
                  ),
                ),
                const SizedBox(width: 10),
                Image.asset(
                  _iconeAtivo,
                  width: 22,
                  height: 22,
                  errorBuilder: (_, __, ___) =>
                      const SizedBox(width: 22, height: 22),
                ),
                const Spacer(),
                _PressableIconButton(
                  colors: colors,
                  onTap: onSoundToggle,
                  child: SvgPicture.asset(
                    soundEnabled
                        ? 'assets/icons/speaker-icon.svg'
                        : 'assets/icons/speaker-off-icon.svg',
                    width: 18,
                    height: 18,
                    colorFilter:
                        ColorFilter.mode(colors.textMuted, BlendMode.srcIn),
                  ),
                ),
              ],
            ),
            if (isAlphabet) ...[
              const SizedBox(height: 14),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colors.bg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      _ToggleButton(
                        colors: colors,
                        label: 'ABC',
                        active: currentMode == GridMode.all,
                        onTap: () => onModeChange(GridMode.all),
                      ),
                      const SizedBox(width: 8),
                      _ToggleButton(
                        colors: colors,
                        label: 'AEI',
                        active: currentMode == GridMode.vowels,
                        onTap: () => onModeChange(GridMode.vowels),
                      ),
                      const SizedBox(width: 8),
                      _ToggleButton(
                        colors: colors,
                        label: 'BCD',
                        active: currentMode == GridMode.consonants,
                        onTap: () => onModeChange(GridMode.consonants),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PressableIconButton extends StatefulWidget {
  final AppColors colors;
  final Widget child;
  final VoidCallback onTap;

  const _PressableIconButton({
    required this.colors,
    required this.child,
    required this.onTap,
  });

  @override
  State<_PressableIconButton> createState() => _PressableIconButtonState();
}

class _PressableIconButtonState extends State<_PressableIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..translate(0.0, _pressed ? 3.0 : 0.0),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: widget.colors.bg,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.colors.neutralShadow,
              offset: Offset(0, _pressed ? 0 : 3),
            ),
          ],
        ),
        child: Center(child: widget.child),
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final AppColors colors;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.colors,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: active
              ? (Matrix4.identity()..translate(0.0, -2.0))
              : Matrix4.identity(),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: active ? AppColors.green : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: active
                ? [
                    const BoxShadow(
                      color: AppColors.greenShadow,
                      offset: Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: active ? Colors.white : colors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Alphabet section — trilha vertical compacta
// ─────────────────────────────────────────────
class _AlphabetSection extends StatelessWidget {
  final AppColors colors;
  final GridMode currentMode;
  final ValueChanged<int> onConsonantTap;

  const _AlphabetSection({
    super.key,
    required this.colors,
    required this.currentMode,
    required this.onConsonantTap,
  });

  List<String> get _letters {
    switch (currentMode) {
      case GridMode.vowels:
        return const ['a', 'e', 'i', 'o', 'u'];
      case GridMode.consonants:
        return kConsonants;
      case GridMode.all:
        return const [
          'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
          'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
        ];
    }
  }

  double _offsetForIndex(int index, double amplitude) {
    final phase = index % 4;
    switch (phase) {
      case 0:
        return 0;
      case 1:
        return amplitude;
      case 2:
        return 0;
      case 3:
        return -amplitude;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConsonantMode = currentMode == GridMode.consonants;
    final letters = _letters;
    final screenWidth = MediaQuery.of(context).size.width;
    final amplitude = math.min(screenWidth * 0.16, 70.0);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      itemCount: letters.length,
      itemBuilder: (context, index) {
        final letter = letters[index];
        final dx = _offsetForIndex(index, amplitude);
        return Padding(
          // era 22 — reduzido para diminuir a altura total da trilha
          padding: const EdgeInsets.only(bottom: 10),
          child: Center(
            child: Transform.translate(
              offset: Offset(dx, 0),
              child: _LetterNode(
                colors: colors,
                letter: letter,
                index: index,
                onTapDown: () => SoundManager.instance.playLetter(letter),
                onTap: () {
                  if (isConsonantMode) {
                    onConsonantTap(kConsonants.indexOf(letter));
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LetterNode extends StatefulWidget {
  final AppColors colors;
  final String letter;
  final int index;
  final VoidCallback? onTapDown;
  final VoidCallback onTap;

  const _LetterNode({
    required this.colors,
    required this.letter,
    required this.index,
    this.onTapDown,
    required this.onTap,
  });

  @override
  State<_LetterNode> createState() => _LetterNodeState();
}

class _LetterNodeState extends State<_LetterNode> {
  bool _pressed = false;

  // diâmetro reduzido de 92 → 68, e o "degrau" 3D de 10 → 6
  static const double diameter = 68;
  static const double stepDepth = 6;

  Color _generateLetterColor({
    required bool isDark,
    required int letterIndex,
    required bool foreground,
  }) {
    final hue = (letterIndex * 360.0 / 26.0) % 360.0;
    if (foreground) {
      return HSLColor.fromAHSL(
        1, hue, isDark ? 0.60 : 0.70, isDark ? 0.58 : 0.42,
      ).toColor();
    } else {
      return HSLColor.fromAHSL(
        1, hue, isDark ? 0.35 : 0.45, isDark ? 0.20 : 0.92,
      ).toColor();
    }
  }

  @override
  Widget build(BuildContext context) {
    final letterIndex =
        widget.letter.toLowerCase().codeUnitAt(0) - 'a'.codeUnitAt(0);
    final fg = _generateLetterColor(
      isDark: widget.colors.isDark,
      letterIndex: letterIndex,
      foreground: true,
    );
    // sombra/base mais escura que o topo, para dar profundidade
    // sem depender do contraste do fundo do card
    final rim = HSLColor.fromColor(fg)
        .withLightness(
          (HSLColor.fromColor(fg).lightness - (widget.colors.isDark ? 0.14 : 0.16))
              .clamp(0.0, 1.0),
        )
        .toColor();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) {
        setState(() => _pressed = true);
        widget.onTapDown?.call();
      },
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: SizedBox(
        width: diameter,
        height: diameter + stepDepth,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: stepDepth,
              child: Container(
                width: diameter,
                height: diameter,
                decoration: BoxDecoration(shape: BoxShape.circle, color: rim),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 90),
              curve: Curves.easeOut,
              top: _pressed ? stepDepth - 2 : 0,
              child: Container(
                width: diameter,
                height: diameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: fg,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.22),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.letter.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'ComicSansMS',
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Drawer
// ─────────────────────────────────────────────
class _AppDrawer extends StatelessWidget {
  final AppColors colors;
  final bool isDark;
  final DrawerSection currentSection;
  final ValueChanged<DrawerSection> onSectionSelected;
  final VoidCallback onThemeToggle;
  final VoidCallback onSettingsTap;

  const _AppDrawer({
    required this.colors,
    required this.isDark,
    required this.currentSection,
    required this.onSectionSelected,
    required this.onThemeToggle,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.78,
      ),
      height: double.infinity,
      decoration: BoxDecoration(
        color: colors.drawerBg,
        boxShadow: [
          BoxShadow(
            color: colors.drawerShadow,
            offset: const Offset(4, 0),
            blurRadius: 24,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 12),
                children: [
                  _DrawerItem(
                    colors: colors,
                    label: 'Alfabeto',
                    assetPath: 'assets/icons/alphabet-icon.png',
                    active: currentSection == DrawerSection.alphabet,
                    onTap: () => onSectionSelected(DrawerSection.alphabet),
                  ),
                  const SizedBox(height: 10),
                  _DrawerItem(
                    colors: colors,
                    label: 'Jogos',
                    assetPath: 'assets/icons/games-icon.png',
                    active: currentSection == DrawerSection.games,
                    onTap: () => onSectionSelected(DrawerSection.games),
                  ),
                  const SizedBox(height: 10),
                  _DrawerItem(
                    colors: colors,
                    label: 'Vídeos',
                    assetPath: 'assets/icons/videos-icon.png',
                    active: currentSection == DrawerSection.videos,
                    onTap: () => onSectionSelected(DrawerSection.videos),
                  ),
                  const SizedBox(height: 10),
                  _DrawerItem(
                    colors: colors,
                    label: 'Definições',
                    assetPath: 'assets/icons/settings.svg',
                    active: false,
                    onTap: onSettingsTap,
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

class _DrawerItem extends StatefulWidget {
  final AppColors colors;
  final String label;
  final String assetPath;
  final bool active;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.colors,
    required this.label,
    required this.assetPath,
    required this.active,
    required this.onTap,
  });

  @override
  State<_DrawerItem> createState() => _DrawerItemState();
}

class _DrawerItemState extends State<_DrawerItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.active ? AppColors.green : widget.colors.bgCardNeutral;
    final shadowColor =
        widget.active ? AppColors.greenShadow : widget.colors.divider;
    final labelColor =
        widget.active ? Colors.white : widget.colors.textMain;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: double.infinity,
        transform: Matrix4.identity()..translate(0.0, _pressed ? 3.0 : 0.0),
        padding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: shadowColor,
                offset: Offset(0, _pressed ? 1 : 4)),
          ],
        ),
        child: Row(
          children: [
            widget.assetPath.toLowerCase().endsWith('.svg')
                ? SvgPicture.asset(
                    widget.assetPath,
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(
                      labelColor,
                      BlendMode.srcIn,
                    ),
                  )
                : Image.asset(
                    widget.assetPath,
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const SizedBox(width: 24, height: 24),
                  ),
            const SizedBox(width: 14),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: labelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}