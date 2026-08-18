import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

import '../main.dart'
    show
        AppColors,
        GridMode,
        DrawerSection,
        SoundManager,
        kConsonants,
        AppStyle;

import 'detail_screen.dart';
import 'games_screen.dart';
import 'playlist_covers_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  bool isDark = false;

  AppStyle appStyle = AppStyle.classic;

  GridMode currentMode = GridMode.all;

  DrawerSection currentSection =
      DrawerSection.alphabet;

  bool soundEnabled = true;
  bool musicEnabled = true;

  late AnimationController _drawerController;
  late Animation<Offset> _drawerSlide;

  bool _drawerOpen = false;

  static const double _drawerWidthFactor = 0.78;

  static const Curve _drawerCurve =
      Curves.easeInOutCubic;

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        statusBarIconBrightness:
            Brightness.dark,
        systemNavigationBarIconBrightness:
            Brightness.dark,
      ),
    );

    _drawerController =
        AnimationController(
      vsync: this,
      duration:
          const Duration(milliseconds: 340),
    );

    _drawerSlide = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _drawerController,
        curve: _drawerCurve,
      ),
    );
  }

  @override
  void dispose() {
    _drawerController.dispose();
    super.dispose();
  }

  void openDrawer() {
    if (_drawerOpen) return;

    setState(() {
      _drawerOpen = true;
    });

    _drawerController.forward();
  }

  void closeDrawer() {
    if (!_drawerOpen) return;

    _drawerController.reverse().then((_) {
      if (!mounted) return;

      setState(() {
        _drawerOpen = false;
      });
    });
  }

  void toggleTheme() {
    setState(() {
      isDark = !isDark;
    });

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor:
            Colors.transparent,
        statusBarIconBrightness:
            isDark
                ? Brightness.light
                : Brightness.dark,
        statusBarBrightness:
            isDark
                ? Brightness.dark
                : Brightness.light,
        systemNavigationBarIconBrightness:
            isDark
                ? Brightness.light
                : Brightness.dark,
      ),
    );
  }

  Future<void> openSettings() async {
    closeDrawer();

    final result =
        await Navigator.of(context)
            .push<AppSettingsResult>(
      CupertinoPageRoute(
        builder: (_) =>
            SettingsScreen(
          colors: AppColors(
            isDark,
            appStyle,
          ),
          isDark: isDark,
          style: appStyle,
          soundEnabled:
              soundEnabled,
          musicEnabled:
              musicEnabled,
        ),
      ),
    );

    if (result == null ||
        !mounted) {
      return;
    }

    setState(() {
      isDark =
          result.isDark;

      appStyle =
          result.style;

      soundEnabled =
          result.soundEnabled;

      musicEnabled =
          result.musicEnabled;
    });

    SoundManager.instance.muted =
        !soundEnabled;

    SoundManager.instance.clickMuted =
        !soundEnabled;

    SoundManager.instance.musicMuted =
        !musicEnabled;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor:
            Colors.transparent,
        systemNavigationBarColor:
            Colors.transparent,
        statusBarIconBrightness:
            isDark
                ? Brightness.light
                : Brightness.dark,
        statusBarBrightness:
            isDark
                ? Brightness.dark
                : Brightness.light,
        systemNavigationBarIconBrightness:
            isDark
                ? Brightness.light
                : Brightness.dark,
      ),
    );
  }

  void toggleSound() {
    setState(() {
      soundEnabled =
          !soundEnabled;
    });

    SoundManager.instance.muted =
        !soundEnabled;

    SoundManager.instance.clickMuted =
        !soundEnabled;

    if (soundEnabled) {
      SoundManager.instance.playClick();
    }
  }

  void openDetail(
    int consonantIndex,
  ) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) =>
            DetailScreen(
          colors: AppColors(
            isDark,
            appStyle,
          ),
          initialConsonantIndex:
              consonantIndex,
        ),
      ),
    );
  }

  Widget _buildSection(
    AppColors colors,
  ) {
    switch (currentSection) {
      case DrawerSection.alphabet:
        return _AlphabetSection(
          key: const ValueKey(
            DrawerSection.alphabet,
          ),
          colors: colors,
          currentMode:
              currentMode,
          onConsonantTap:
              openDetail,
        );

      case DrawerSection.games:
        return GamesScreen(
          key: const ValueKey(
            DrawerSection.games,
          ),
          colors: colors,
        );

      case DrawerSection.videos:
        return PlaylistCoversScreen(
          key: const ValueKey(
            DrawerSection.videos,
          ),
          colors: colors,
        );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final colors =
        AppColors(
      isDark,
      appStyle,
    );

    final media =
        MediaQuery.of(context);

    return AnnotatedRegion<
        SystemUiOverlayStyle>(
      value:
          SystemUiOverlayStyle(
        statusBarColor:
            Colors.transparent,
        systemNavigationBarColor:
            Colors.transparent,
        statusBarIconBrightness:
            isDark
                ? Brightness.light
                : Brightness.dark,
        statusBarBrightness:
            isDark
                ? Brightness.dark
                : Brightness.light,
        systemNavigationBarIconBrightness:
            isDark
                ? Brightness.light
                : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor:
            colors.bg,
        extendBody: true,
        extendBodyBehindAppBar:
            true,
        body: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _AppBarWidget(
                    colors: colors,
                    onMenuTap:
                        openDrawer,
                    currentSection:
                        currentSection,
                    currentMode:
                        currentMode,
                    onModeChange:
                        (mode) {
                      setState(() {
                        currentMode =
                            mode;
                      });
                    },
                    soundEnabled:
                        soundEnabled,
                    onSoundToggle:
                        toggleSound,
                  ),

                  Expanded(
                    child: SafeArea(
                      top: false,
                      child:
                          AnimatedSwitcher(
                        duration:
                            const Duration(
                          milliseconds:
                              260,
                        ),
                        switchInCurve:
                            const Cubic(
                          0.22,
                          1,
                          0.36,
                          1,
                        ),
                        switchOutCurve:
                            const Cubic(
                          0.22,
                          1,
                          0.36,
                          1,
                        ),
                        transitionBuilder:
                            (
                          child,
                          animation,
                        ) {
                          final slide =
                              Tween<
                                  Offset>(
                            begin:
                                const Offset(
                              0.06,
                              0,
                            ),
                            end:
                                Offset.zero,
                          ).animate(
                            animation,
                          );

                          return ClipRect(
                            child:
                                SlideTransition(
                              position:
                                  slide,
                              child:
                                  FadeTransition(
                                opacity:
                                    animation,
                                child:
                                    child,
                              ),
                            ),
                          );
                        },
                        layoutBuilder:
                            (
                          currentChild,
                          previousChildren,
                        ) {
                          return Stack(
                            alignment:
                                Alignment
                                    .topCenter,
                            children: [
                              ...previousChildren,
                              if (currentChild !=
                                  null)
                                currentChild,
                            ],
                          );
                        },
                        child:
                            _buildSection(
                          colors,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_drawerOpen)
              Positioned.fill(
                child:
                    AnimatedBuilder(
                  animation:
                      _drawerController,
                  builder:
                      (
                    context,
                    child,
                  ) {
                    return GestureDetector(
                      onTap:
                          closeDrawer,
                      child:
                          Container(
                        color:
                            Color.lerp(
                          Colors
                              .transparent,
                          colors
                              .overlay,
                          _drawerController
                              .value,
                        ),
                      ),
                    );
                  },
                ),
              ),

            if (_drawerOpen)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width:
                    media.size.width *
                        _drawerWidthFactor,
                child:
                    SlideTransition(
                  position:
                      _drawerSlide,
                  child:
                      _AppDrawer(
                    colors:
                        colors,
                    isDark:
                        isDark,
                    currentSection:
                        currentSection,
                    onSectionSelected:
                        (
                      section,
                    ) {
                      setState(() {
                        currentSection =
                            section;
                      });

                      closeDrawer();
                    },
                    onThemeToggle:
                        toggleTheme,
                    onSettingsTap:
                        openSettings,
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
// APP BAR
// ─────────────────────────────────────────────

class _AppBarWidget
    extends StatelessWidget {
  final AppColors colors;
  final VoidCallback onMenuTap;
  final DrawerSection currentSection;
  final GridMode currentMode;
  final ValueChanged<GridMode>
      onModeChange;
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
  Widget build(
    BuildContext context,
  ) {
    final isAlphabet =
        currentSection ==
            DrawerSection.alphabet;

    return SafeArea(
      bottom: false,
      child: Container(
        width:
            double.infinity,
        padding:
            const EdgeInsets.fromLTRB(
          16,
          12,
          16,
          14,
        ),
        decoration:
            BoxDecoration(
          color: isAlphabet
              ? colors
                  .bgCardNeutral
              : colors.bg,
          borderRadius:
              isAlphabet
                  ? BorderRadius.zero
                  : const BorderRadius
                      .only(
                    bottomLeft:
                        Radius.circular(
                      24,
                    ),
                    bottomRight:
                        Radius.circular(
                      24,
                    ),
                  ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,
          children: [
            Row(
              children: [
                _HamburgerButton(
                  colors: colors,
                  onTap: onMenuTap,
                ),
                const SizedBox(
                  width: 10,
                ),
                Image.asset(
                  _iconeAtivo,
                  width: 22,
                  height: 22,
                  errorBuilder:
                      (
                    _,
                    __,
                    ___,
                  ) {
                    return Icon(
                      currentSection ==
                              DrawerSection
                                  .games
                          ? Icons
                              .sports_esports_outlined
                          : currentSection ==
                                  DrawerSection
                                      .videos
                              ? Icons
                                  .video_library_outlined
                              : Icons
                                  .menu_book_outlined,
                      size: 22,
                      color:
                          colors.textMain,
                    );
                  },
                ),
                const Spacer(),
                _SpeakerToggleButton(
                  colors: colors,
                  soundEnabled:
                      soundEnabled,
                  onTap:
                      onSoundToggle,
                ),
              ],
            ),

            if (isAlphabet) ...[
              const SizedBox(
                height: 14,
              ),
              _LetterFilter(
                colors: colors,
                currentMode:
                    currentMode,
                onModeChange:
                    onModeChange,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HAMBURGER
// ─────────────────────────────────────────────

class _HamburgerButton
    extends StatelessWidget {
  final AppColors colors;
  final VoidCallback onTap;

  const _HamburgerButton({
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Material(
      color:
          Colors.transparent,
      child:
          InkWell(
        borderRadius:
            BorderRadius.circular(
          12,
        ),
        onTap:
            onTap,
        child:
            Ink(
          width:
              42,
          height:
              42,
          decoration:
              BoxDecoration(
            color:
                colors.bg,
            borderRadius:
                BorderRadius.circular(
              12,
            ),
            border:
                Border.all(
              color:
                  colors.divider,
            ),
          ),
          child:
              Icon(
            Icons.menu_rounded,
            size:
                22,
            color:
                colors.textMain,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SPEAKER
// ─────────────────────────────────────────────

class _SpeakerToggleButton
    extends StatelessWidget {
  final AppColors colors;
  final bool soundEnabled;
  final VoidCallback onTap;

  const _SpeakerToggleButton({
    required this.colors,
    required this.soundEnabled,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Material(
      color:
          Colors.transparent,
      child:
          InkWell(
        borderRadius:
            BorderRadius.circular(
          12,
        ),
        onTap:
            onTap,
        child:
            Ink(
          width:
              42,
          height:
              42,
          decoration:
              BoxDecoration(
            color:
                colors.bg,
            borderRadius:
                BorderRadius.circular(
              12,
            ),
            border:
                Border.all(
              color:
                  colors.divider,
            ),
          ),
          child:
              Center(
            child:
                SvgPicture.asset(
              soundEnabled
                  ? 'assets/icons/speaker-icon.svg'
                  : 'assets/icons/speaker-off-icon.svg',
              width:
                  20,
              height:
                  20,
              colorFilter:
                  ColorFilter.mode(
                colors.textMain,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FILTRO
// ─────────────────────────────────────────────

class _LetterFilter
    extends StatelessWidget {
  final AppColors colors;
  final GridMode currentMode;
  final ValueChanged<GridMode>
      onModeChange;

  const _LetterFilter({
    required this.colors,
    required this.currentMode,
    required this.onModeChange,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        4,
      ),
      decoration:
          BoxDecoration(
        color:
            colors.bg,
        borderRadius:
            BorderRadius.circular(
          14,
        ),
      ),
      child:
          Row(
        children: [
          _ToggleButton(
            colors:
                colors,
            label:
                'Todas',
            active:
                currentMode ==
                    GridMode.all,
            onTap:
                () {
              SoundManager.instance
                  .playClick();
              onModeChange(
                GridMode.all,
              );
            },
          ),
          _ToggleButton(
            colors:
                colors,
            label:
                'Vogais',
            active:
                currentMode ==
                    GridMode.vowels,
            onTap:
                () {
              SoundManager.instance
                  .playClick();
              onModeChange(
                GridMode.vowels,
              );
            },
          ),
          _ToggleButton(
            colors:
                colors,
            label:
                'Consoantes',
            active:
                currentMode ==
                    GridMode.consonants,
            onTap:
                () {
              SoundManager.instance
                  .playClick();
              onModeChange(
                GridMode.consonants,
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TOGGLE BUTTON
// ─────────────────────────────────────────────

class _ToggleButton
    extends StatelessWidget {
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
  Widget build(
    BuildContext context,
  ) {
    return Expanded(
      child:
          GestureDetector(
        onTap:
            onTap,
        child:
            AnimatedContainer(
          duration:
              const Duration(
            milliseconds:
                200,
          ),
          transform:
              active
                  ? (Matrix4
                        .identity()
                    ..translate(
                      0.0,
                      -2.0,
                    ))
                  : Matrix4
                      .identity(),
          padding:
              const EdgeInsets.symmetric(
            vertical:
                10,
            horizontal:
                4,
          ),
          decoration:
              BoxDecoration(
            color:
                active
                    ? colors.primary
                    : Colors.transparent,
            borderRadius:
                BorderRadius.circular(
              16,
            ),
            boxShadow:
                active
                    ? [
                        BoxShadow(
                          color:
                              colors.primaryShadow,
                          offset:
                              const Offset(
                            0,
                            4,
                          ),
                        ),
                      ]
                    : const [],
          ),
          child:
              Text(
            label,
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              fontSize:
                  16,
              fontWeight:
                  FontWeight.w700,
              letterSpacing:
                  0.5,
              color:
                  active
                      ? Colors.white
                      : colors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ALPHABET SECTION
// ─────────────────────────────────────────────

class _AlphabetSection
    extends StatelessWidget {
  final AppColors colors;
  final GridMode currentMode;
  final ValueChanged<int>
      onConsonantTap;

  const _AlphabetSection({
    super.key,
    required this.colors,
    required this.currentMode,
    required this.onConsonantTap,
  });

  List<String> get _letters {
    switch (currentMode) {
      case GridMode.all:
        return List<String>.from(
          [
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
          ],
        );

      case GridMode.vowels:
        return const [
          'a',
          'e',
          'i',
          'o',
          'u',
        ];

      case GridMode.consonants:
        return kConsonants;
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return GridView.builder(
      padding:
          const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        24,
      ),
      physics:
          const BouncingScrollPhysics(),
      itemCount:
          _letters.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:
            3,
        crossAxisSpacing:
            12,
        mainAxisSpacing:
            12,
        childAspectRatio:
            1.12,
      ),
      itemBuilder:
          (
        context,
        index,
      ) {
        final letter =
            _letters[index];

        final originalIndex =
            'abcdefghijklmnopqrstuvwxyz'
                .indexOf(
          letter,
        );

        return _LetterCard(
          colors:
              colors,
          letter:
              letter,
          onTap:
              () {
            SoundManager.instance
                .play(
              letter,
            );

            if (originalIndex >=
                0) {
              onConsonantTap(
                originalIndex,
              );
            }
          },
          onTapDown:
              () {},
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// LETTER CARD
// ─────────────────────────────────────────────

class _LetterCard
    extends StatefulWidget {
  final AppColors colors;
  final String letter;
  final VoidCallback onTap;
  final VoidCallback? onTapDown;

  const _LetterCard({
    required this.colors,
    required this.letter,
    required this.onTap,
    this.onTapDown,
  });

  @override
  State<_LetterCard> createState() =>
      _LetterCardState();
}

class _LetterCardState
    extends State<_LetterCard> {
  bool _pressed =
      false;

  Color _generateLetterColor({
    required bool isDark,
    required int letterIndex,
    required bool foreground,
  }) {
    const colors =
        <Color>[
      Color(0xFF1CB0F6),
      Color(0xFFFF9600),
      Color(0xFF58CC02),
      Color(0xFFFF4B8C),
      Color(0xFFCE82FF),
      Color(0xFFFFC800),
    ];

    final base =
        colors[
            letterIndex %
                colors.length];

    if (foreground) {
      if (!isDark) {
        return base;
      }

      return Color.lerp(
        base,
        Colors.white,
        0.18,
      )!;
    }

    if (!isDark) {
      return Color.lerp(
        base,
        Colors.white,
        0.82,
      )!;
    }

    return Color.lerp(
      base,
      Colors.black,
      0.68,
    )!;
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final letterIndex =
        widget.letter
                .toLowerCase()
                .codeUnitAt(0) -
            'a'
                .codeUnitAt(0);

    final bg =
        _generateLetterColor(
      isDark:
          widget.colors.isDark,
      letterIndex:
          letterIndex,
      foreground:
          false,
    );

    final fg =
        _generateLetterColor(
      isDark:
          widget.colors.isDark,
      letterIndex:
          letterIndex,
      foreground:
          true,
    );

    final shadow =
        fg.withOpacity(
      widget.colors.isDark
          ? 0.35
          : 0.25,
    );

    return GestureDetector(
      behavior:
          HitTestBehavior.opaque,
      onTap:
          widget.onTap,
      onTapDown:
          (_) {
        setState(
          () {
            _pressed =
                true;
          },
        );

        widget.onTapDown
            ?.call();
      },
      onTapUp:
          (_) {
        setState(
          () {
            _pressed =
                false;
          },
        );
      },
      onTapCancel:
          () {
        setState(
          () {
            _pressed =
                false;
          },
        );
      },
      child:
          AnimatedContainer(
        duration:
            const Duration(
          milliseconds:
              60,
        ),
        transform:
            Matrix4
                .identity()
              ..translate(
                0.0,
                _pressed
                    ? 4.0
                    : 0.0,
              ),
        padding:
            const EdgeInsets.symmetric(
          vertical:
              16,
          horizontal:
              6,
        ),
        decoration:
            BoxDecoration(
          color:
              bg,
          borderRadius:
              BorderRadius.circular(
            18,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  shadow,
              offset:
                  Offset(
                0,
                _pressed
                    ? 1
                    : 4,
              ),
            ),
          ],
        ),
        child:
            Row(
          mainAxisAlignment:
              MainAxisAlignment
                  .center,
          crossAxisAlignment:
              CrossAxisAlignment
                  .baseline,
          textBaseline:
              TextBaseline
                  .alphabetic,
          children: [
            Text(
              widget.letter
                  .toUpperCase(),
              style:
                  TextStyle(
                fontFamily:
                    'ComicSansMS',
                fontSize:
                    30,
                fontWeight:
                    FontWeight.w700,
                color:
                    fg,
              ),
            ),
            const SizedBox(
              width:
                  6,
            ),
            Opacity(
              opacity:
                  0.85,
              child:
                  Text(
                widget.letter,
                style:
                    TextStyle(
                  fontFamily:
                      'ComicSansMS',
                  fontSize:
                      22,
                  fontWeight:
                      FontWeight.w700,
                  color:
                      fg,
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
// DRAWER
// ─────────────────────────────────────────────

class _AppDrawer
    extends StatelessWidget {
  final AppColors colors;
  final bool isDark;
  final DrawerSection currentSection;
  final ValueChanged<DrawerSection>
      onSectionSelected;
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
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width:
          double.infinity,
      height:
          double.infinity,
      decoration:
          BoxDecoration(
        color:
            colors.drawerBg,
        boxShadow: [
          BoxShadow(
            color:
                colors.drawerShadow,
            offset:
                const Offset(
              4,
              0,
            ),
            blurRadius:
                24,
          ),
        ],
      ),
      child:
          SafeArea(
        child:
            Column(
          children: [
            Expanded(
              child:
                  ListView(
                physics:
                    const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.fromLTRB(
                  10,
                  20,
                  10,
                  12,
                ),
                children: [
                  _DrawerItem(
                    colors:
                        colors,
                    label:
                        'Alfabeto',
                    assetPath:
                        'assets/icons/alphabet-icon.png',
                    active:
                        currentSection ==
                            DrawerSection
                                .alphabet,
                    onTap:
                        () =>
                            onSectionSelected(
                      DrawerSection
                          .alphabet,
                    ),
                  ),
                  const SizedBox(
                    height:
                        10,
                  ),
                  _DrawerItem(
                    colors:
                        colors,
                    label:
                        'Jogos',
                    assetPath:
                        'assets/icons/games-icon.png',
                    active:
                        currentSection ==
                            DrawerSection
                                .games,
                    onTap:
                        () =>
                            onSectionSelected(
                      DrawerSection
                          .games,
                    ),
                  ),
                  const SizedBox(
                    height:
                        10,
                  ),
                  _DrawerItem(
                    colors:
                        colors,
                    label:
                        'Vídeos',
                    assetPath:
                        'assets/icons/videos-icon.png',
                    active:
                        currentSection ==
                            DrawerSection
                                .videos,
                    onTap:
                        () =>
                            onSectionSelected(
                      DrawerSection
                          .videos,
                    ),
                  ),
                  const SizedBox(
                    height:
                        10,
                  ),
                  _DrawerItem(
                    colors:
                        colors,
                    label:
                        'Definições',
                    iconData:
                        Icons
                            .settings_outlined,
                    active:
                        false,
                    onTap:
                        onSettingsTap,
                  ),
                ],
              ),
            ),

            Container(
              padding:
                  const EdgeInsets.all(
                16,
              ),
              decoration:
                  BoxDecoration(
                border:
                    Border(
                  top:
                      BorderSide(
                    color:
                        colors.divider,
                  ),
                ),
              ),
              child:
                  Row(
                children: [
                  Container(
                    width:
                        38,
                    height:
                        38,
                    decoration:
                        BoxDecoration(
                      color:
                          colors.primary
                              .withOpacity(
                        0.12,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        11,
                      ),
                    ),
                    child:
                        Icon(
                      isDark
                          ? Icons
                              .dark_mode_outlined
                          : Icons
                              .light_mode_outlined,
                      size:
                          21,
                      color:
                          colors.primary,
                    ),
                  ),
                  const SizedBox(
                    width:
                        11,
                  ),
                  Expanded(
                    child:
                        Text(
                      isDark
                          ? 'Tema escuro'
                          : 'Tema claro',
                      style:
                          TextStyle(
                        fontWeight:
                            FontWeight.w700,
                        color:
                            colors.textMain,
                      ),
                    ),
                  ),
                  _ThemeSwitch(
                    colors:
                        colors,
                    isDark:
                        isDark,
                    onTap:
                        onThemeToggle,
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

// ─────────────────────────────────────────────
// DRAWER ITEM
// ─────────────────────────────────────────────

class _DrawerItem
    extends StatefulWidget {
  final AppColors colors;
  final String label;
  final String? assetPath;
  final IconData? iconData;
  final bool active;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.colors,
    required this.label,
    this.assetPath,
    this.iconData,
    required this.active,
    required this.onTap,
  });

  @override
  State<_DrawerItem> createState() =>
      _DrawerItemState();
}

class _DrawerItemState
    extends State<_DrawerItem> {
  bool _pressed =
      false;

  @override
  Widget build(
    BuildContext context,
  ) {
    final bg =
        widget.active
            ? widget.colors.primary
            : widget.colors.bgCardNeutral;

    final shadowColor =
        widget.active
            ? widget.colors.primaryShadow
            : widget.colors.divider;

    final labelColor =
        widget.active
            ? Colors.white
            : widget.colors.textMain;

    return GestureDetector(
      behavior:
          HitTestBehavior.opaque,
      onTap:
          widget.onTap,
      onTapDown:
          (_) {
        setState(
          () {
            _pressed =
                true;
          },
        );
      },
      onTapUp:
          (_) {
        setState(
          () {
            _pressed =
                false;
          },
        );
      },
      onTapCancel:
          () {
        setState(
          () {
            _pressed =
                false;
          },
        );
      },
      child:
          AnimatedContainer(
        duration:
            const Duration(
          milliseconds:
              100,
        ),
        width:
            double.infinity,
        transform:
            Matrix4
                .identity()
              ..translate(
                0.0,
                _pressed
                    ? 3.0
                    : 0.0,
              ),
        padding:
            const EdgeInsets.symmetric(
          vertical:
              14,
          horizontal:
              16,
        ),
        decoration:
            BoxDecoration(
          color:
              bg,
          borderRadius:
              BorderRadius.circular(
            14,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  shadowColor,
              offset:
                  Offset(
                0,
                _pressed
                    ? 1
                    : 4,
              ),
            ),
          ],
        ),
        child:
            Row(
          children: [
            if (widget.iconData !=
                null)
              Icon(
                widget.iconData,
                size:
                    24,
                color:
                    labelColor,
              )
            else if (widget.assetPath !=
                null)
              Image.asset(
                widget.assetPath!,
                width:
                    24,
                height:
                    24,
                fit:
                    BoxFit.contain,
                errorBuilder:
                    (
                  _,
                  __,
                  ___,
                ) {
                  return Icon(
                    Icons
                        .image_outlined,
                    size:
                        24,
                    color:
                        labelColor,
                  );
                },
              ),
            const SizedBox(
              width:
                  14,
            ),
            Text(
              widget.label,
              style:
                  TextStyle(
                fontSize:
                    15,
                fontWeight:
                    FontWeight.w700,
                color:
                    labelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// THEME SWITCH
// ─────────────────────────────────────────────

class _ThemeSwitch
    extends StatelessWidget {
  final AppColors colors;
  final bool isDark;
  final VoidCallback onTap;

  const _ThemeSwitch({
    required this.colors,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
      onTap:
          onTap,
      child:
          Container(
        width:
            52,
        height:
            30,
        padding:
            const EdgeInsets.all(
          3,
        ),
        decoration:
            BoxDecoration(
          color:
              colors.bgCardNeutral,
          borderRadius:
              BorderRadius.circular(
            20,
          ),
        ),
        child:
            AnimatedAlign(
          duration:
              const Duration(
            milliseconds:
                250,
          ),
          alignment:
              isDark
                  ? Alignment
                      .centerRight
                  : Alignment
                      .centerLeft,
          child:
              Container(
            width:
                24,
            height:
                24,
            decoration:
                BoxDecoration(
              color:
                  colors.switchThumb,
              shape:
                  BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color:
                      colors.switchThumbShadow,
                  offset:
                      const Offset(
                    0,
                    2,
                  ),
                  blurRadius:
                      4,
                ),
              ],
            ),
            child:
                Center(
              child:
                  Icon(
                isDark
                    ? Icons
                        .dark_mode_outlined
                    : Icons
                        .light_mode_outlined,
                size:
                    14,
                color:
                    colors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}