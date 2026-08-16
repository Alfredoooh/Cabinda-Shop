import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../main.dart'
    show
        AppColors,
        GridMode,
        DrawerSection,
        SoundManager,
        DetailScreen,
        kConsonants;
import 'games_screen.dart';
import 'playlist_covers_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  bool isDark = false;
  GridMode currentMode = GridMode.all;
  DrawerSection currentSection = DrawerSection.alphabet;
  bool soundEnabled = true;

  late AnimationController _drawerController;
  late Animation<Offset> _drawerSlide;
  late Animation<double> _contentPush;
  bool _drawerOpen = false;

  static const double _drawerWidthFactor = 0.78;
  static const double _pushFactor = 0.24;

  @override
  void initState() {
    super.initState();
    _drawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _drawerSlide = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _drawerController,
      curve: const Cubic(0.22, 1, 0.36, 1),
    ));
    _contentPush = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _drawerController,
        curve: const Cubic(0.22, 1, 0.36, 1),
      ),
    );
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
  }

  void toggleSound() {
    setState(() {
      soundEnabled = !soundEnabled;
      SoundManager.instance.muted = !soundEnabled;
    });
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
    final drawerWidth =
        MediaQuery.of(context).size.width * _drawerWidthFactor;

    return Scaffold(
      backgroundColor: colors.bg,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _contentPush,
            builder: (context, child) {
              final dx = drawerWidth * _pushFactor * _contentPush.value;
              return Transform.translate(
                offset: Offset(dx, 0),
                child: child,
              );
            },
            child: SafeArea(
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
                          final inFromRight = Tween<Offset>(
                            begin: const Offset(0.06, 0),
                            end: Offset.zero,
                          ).animate(animation);
                          return ClipRect(
                            child: SlideTransition(
                              position: inFromRight,
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
          ),
          if (_drawerOpen)
            GestureDetector(
              onTap: closeDrawer,
              child: AnimatedBuilder(
                animation: _drawerController,
                builder: (context, child) => Container(
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
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// =====================================================================
// APP BAR - agora com ícone da tab activa sempre no centro
// =====================================================================

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

  String get _iconeAtivo {
    switch (currentSection) {
      case DrawerSection.alphabet:
        return 'assets/icons/alphabet-icon.svg';
      case DrawerSection.games:
        return 'assets/icons/games-icon.svg';
      case DrawerSection.videos:
        return 'assets/icons/videos-icon.svg';
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
          borderRadius: isAlphabet
              ? BorderRadius.zero
              : const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _HamburgerButton(colors: colors, onTap: onMenuTap),
                Expanded(
                  child: Center(
                    child: SvgPicture.asset(
                      _iconeAtivo,
                      width: 22,
                      height: 22,
                      colorFilter: ColorFilter.mode(
                        colors.textMain,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                _SpeakerToggleButton(
                  colors: colors,
                  soundEnabled: soundEnabled,
                  onTap: onSoundToggle,
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

class _HamburgerButton extends StatelessWidget {
  final AppColors colors;
  final VoidCallback onTap;

  const _HamburgerButton({required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(color: colors.bg, shape: BoxShape.circle),
        child: Center(
          child: SvgPicture.asset(
            'assets/icons/menu-icon.svg',
            width: 18,
            height: 18,
            colorFilter: ColorFilter.mode(colors.textMuted, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}

class _SpeakerToggleButton extends StatelessWidget {
  final AppColors colors;
  final bool soundEnabled;
  final VoidCallback onTap;

  const _SpeakerToggleButton({
    required this.colors,
    required this.soundEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(color: colors.bg, shape: BoxShape.circle),
        child: Center(
          child: SvgPicture.asset(
            soundEnabled
                ? 'assets/icons/speaker-icon.svg'
                : 'assets/icons/speaker-off-icon.svg',
            width: 18,
            height: 18,
            colorFilter: ColorFilter.mode(colors.textMuted, BlendMode.srcIn),
          ),
        ),
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
          'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConsonantMode = currentMode == GridMode.consonants;
    final letters = _letters;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: letters.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.05,
            ),
            itemBuilder: (context, index) {
              final letter = letters[index];
              return _LetterCard(
                colors: colors,
                letter: letter,
                onTapDown: () => SoundManager.instance.playLetter(letter),
                onTap: () {
                  if (isConsonantMode) {
                    onConsonantTap(kConsonants.indexOf(letter));
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LetterCard extends StatefulWidget {
  final AppColors colors;
  final String letter;
  final VoidCallback? onTapDown;
  final VoidCallback onTap;

  const _LetterCard({
    required this.colors,
    required this.letter,
    this.onTapDown,
    required this.onTap,
  });

  @override
  State<_LetterCard> createState() => _LetterCardState();
}

class _LetterCardState extends State<_LetterCard> {
  bool _pressed = false;

  Color _generateLetterColor({
    required bool isDark,
    required int letterIndex,
    required bool foreground,
  }) {
    final hue = (letterIndex * 360.0 / 26.0) % 360.0;
    if (foreground) {
      return HSLColor.fromAHSL(
        1, hue, isDark ? 0.55 : 0.70, isDark ? 0.75 : 0.42,
      ).toColor();
    } else {
      return HSLColor.fromAHSL(
        1, hue, isDark ? 0.35 : 0.45, isDark ? 0.24 : 0.92,
      ).toColor();
    }
  }

  @override
  Widget build(BuildContext context) {
    final letterIndex =
        widget.letter.toLowerCase().codeUnitAt(0) - 'a'.codeUnitAt(0);
    final bg = _generateLetterColor(
      isDark: widget.colors.isDark, letterIndex: letterIndex, foreground: false,
    );
    final fg = _generateLetterColor(
      isDark: widget.colors.isDark, letterIndex: letterIndex, foreground: true,
    );
    final shadow = fg.withOpacity(widget.colors.isDark ? 0.35 : 0.25);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) {
        setState(() => _pressed = true);
        widget.onTapDown?.call();
      },
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        transform: Matrix4.identity()..translate(0.0, _pressed ? 4.0 : 0.0),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: shadow, offset: Offset(0, _pressed ? 1 : 4)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              widget.letter.toUpperCase(),
              style: TextStyle(
                fontFamily: 'ComicSansMS',
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
            const SizedBox(width: 6),
            Opacity(
              opacity: 0.85,
              child: Text(
                widget.letter,
                style: TextStyle(
                  fontFamily: 'ComicSansMS',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  final AppColors colors;
  final bool isDark;
  final DrawerSection currentSection;
  final ValueChanged<DrawerSection> onSectionSelected;
  final VoidCallback onThemeToggle;

  const _AppDrawer({
    required this.colors,
    required this.isDark,
    required this.currentSection,
    required this.onSectionSelected,
    required this.onThemeToggle,
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
                    assetPath: 'assets/icons/alphabet-icon.svg',
                    active: currentSection == DrawerSection.alphabet,
                    onTap: () => onSectionSelected(DrawerSection.alphabet),
                  ),
                  const SizedBox(height: 10),
                  _DrawerItem(
                    colors: colors,
                    label: 'Jogos',
                    assetPath: 'assets/icons/games-icon.svg',
                    active: currentSection == DrawerSection.games,
                    onTap: () => onSectionSelected(DrawerSection.games),
                  ),
                  const SizedBox(height: 10),
                  _DrawerItem(
                    colors: colors,
                    label: 'Vídeos',
                    assetPath: 'assets/icons/videos-icon.svg',
                    active: currentSection == DrawerSection.videos,
                    onTap: () => onSectionSelected(DrawerSection.videos),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: colors.divider)),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tema',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colors.textMain,
                      ),
                    ),
                    _ThemeSwitch(
                      colors: colors,
                      isDark: isDark,
                      onTap: onThemeToggle,
                    ),
                  ],
                ),
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
    final labelColor = widget.active ? Colors.white : widget.colors.textMain;
    final iconColor = widget.active ? Colors.white : widget.colors.textMain;

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
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: shadowColor, offset: Offset(0, _pressed ? 1 : 4)),
          ],
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              widget.assetPath,
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
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

class _ThemeSwitch extends StatelessWidget {
  final AppColors colors;
  final bool isDark;
  final VoidCallback onTap;

  const _ThemeSwitch({
    required this.colors,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 30,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: colors.bgCardNeutral,
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: colors.switchThumb,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colors.switchThumbShadow,
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Center(
              child: SvgPicture.asset(
                isDark
                    ? 'assets/icons/moon-icon.svg'
                    : 'assets/icons/sun-icon.svg',
                width: 14,
                height: 14,
                colorFilter:
                    const ColorFilter.mode(AppColors.orange, BlendMode.srcIn),
              ),
            ),
          ),
        ),
      ),
    );
  }
}