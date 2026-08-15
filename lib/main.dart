import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

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

// =====================================================================
// TEMA - equivalente às variáveis CSS :root / body.dark do HTML
// =====================================================================

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

  // Sombra neutra usada em botões pequenos e speaker/close (dependente do tema)
  Color get neutralShadow =>
      isDark ? const Color(0x40000000) : const Color(0x1A000000);
  // Sombra do drawer (dependente do tema, evita "preto puro" no dark)
  Color get drawerShadow =>
      isDark ? const Color(0x66000000) : const Color(0x33000000);
  // Fundo do polegar do theme switch (branco no claro, tom mais suave no escuro)
  Color get switchThumb =>
      isDark ? const Color(0xFFF5EEDD) : const Color(0xFFFFFFFF);
  Color get switchThumbShadow =>
      isDark ? const Color(0x40000000) : const Color(0x33000000);

  // Cores dos cards do grid (c0-c5), claro e escuro
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

// =====================================================================
// DADOS - equivalente às constantes VOWELS / ALL_LETTERS / CONSONANTS
// =====================================================================

const List<String> kVowels = ['a', 'e', 'i', 'o', 'u'];
const List<String> kAllLetters = [
  'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o',
  'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
];
final List<String> kConsonants =
    kAllLetters.where((l) => !kVowels.contains(l)).toList();

// equivalente à função buildSyllable(consonant, vowel, consonantUpper)
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

// =====================================================================
// SOUND MANAGER - organiza sozinho os sons a partir das pastas
// assets/audios/vowels/<letra>.mp3
// assets/audios/consonants/<letra>.mp3
// assets/audios/syllables/<consoante>/<silaba>.mp3
// =====================================================================

class SoundManager {
  SoundManager._();
  static final SoundManager instance = SoundManager._();

  final AudioPlayer _player = AudioPlayer();

  // Toca o som de uma única letra (vogal ou consoante), minúscula ou não.
  Future<void> playLetter(String letter) async {
    final l = letter.toLowerCase();
    if (l.isEmpty || l.length != 1) return;

    final path = kVowels.contains(l)
        ? 'audios/vowels/$l.mp3'
        : 'audios/consonants/$l.mp3';

    await _play(path);
  }

  // Toca o som de uma sílaba (ex: "ba", "que", "gui"), a partir da
  // pasta da sua consoante inicial: assets/audios/syllables/<consoante>/<silaba>.mp3
  Future<void> playSyllable(String syllable) async {
    final s = syllable.toLowerCase();
    if (s.isEmpty) return;

    final firstConsonant = s[0];
    if (!kConsonants.contains(firstConsonant)) {
      // fallback de segurança: se por algum motivo não começar por
      // consoante conhecida, tenta tocar como letra simples.
      await playLetter(firstConsonant);
      return;
    }

    final path = 'audios/syllables/$firstConsonant/$s.mp3';
    await _play(path);
  }

  // Decide automaticamente se o texto é uma letra única ou uma sílaba.
  Future<void> play(String text) async {
    final t = text.toLowerCase();
    if (t.length == 1) {
      await playLetter(t);
    } else {
      await playSyllable(t);
    }
  }

  Future<void> _play(String assetPath) async {
    try {
      await _player.stop();
      await _player.play(AssetSource(assetPath));
    } catch (_) {
      // Áudio ausente ou falha de reprodução: falha silenciosamente,
      // igual ao comportamento original (playSound ainda "não implementado").
    }
  }
}

// =====================================================================
// HOME SCREEN - equivalente a #app com top-bar, toggles, sections e drawer
// =====================================================================

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

  late AnimationController _drawerController;
  late Animation<Offset> _drawerSlide;
  // Deslocamento "push" do conteúdo principal, estilo iOS: só um pouquinho,
  // não empurra a tela toda.
  late Animation<double> _contentPush;
  bool _drawerOpen = false;

  static const double _drawerWidthFactor = 0.78;
  static const double _pushFactor = 0.24; // quanto do drawer "empurra" o corpo

  @override
  void initState() {
    super.initState();
    // equivalente ao transition: transform 0.32s cubic-bezier(0.22,1,0.36,1) do CSS
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

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(isDark);
    final drawerWidth =
        MediaQuery.of(context).size.width * _drawerWidthFactor;

    return Scaffold(
      backgroundColor: colors.bg,
      body: Stack(
        children: [
          // CONTEÚDO PRINCIPAL - recebe o efeito "push" quando o drawer abre
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
              child: Column(
                children: [
                  // APP BAR - bordas curvadas em baixo, cor do container de toggles
                  _AppBarWidget(colors: colors, onMenuTap: openDrawer),

                  // SECTIONS - com slide suave entre tabs
                  Expanded(
                    child: _AnimatedSection(
                      colors: colors,
                      currentSection: currentSection,
                      currentMode: currentMode,
                      onModeChange: (m) => setState(() => currentMode = m),
                      onConsonantTap: openDetail,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // DRAWER OVERLAY + DRAWER
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
// APP BAR - cor do container de toggles, bordas curvadas só em baixo,
// botão de menu circular e menor
// =====================================================================

class _AppBarWidget extends StatelessWidget {
  final AppColors colors;
  final VoidCallback onMenuTap;

  const _AppBarWidget({required this.colors, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: colors.bgCardNeutral,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          _HamburgerButton(colors: colors, onTap: onMenuTap),
        ],
      ),
    );
  }
}

// =====================================================================
// HAMBURGER BUTTON - agora circular e mais pequeno, equivalente a
// .hamburger-btn
// =====================================================================

class _HamburgerButton extends StatelessWidget {
  final AppColors colors;
  final VoidCallback onTap;

  const _HamburgerButton({required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _PressableScale(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: colors.bg,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: CustomPaint(
            size: const Size(18, 18),
            painter: _LinesIconPainter(color: colors.textMuted),
          ),
        ),
      ),
    );
  }
}

// SVG do hambúrguer (3 linhas) redesenhado como CustomPainter
class _LinesIconPainter extends CustomPainter {
  final Color color;
  _LinesIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final ys = [size.height * 0.29, size.height * 0.5, size.height * 0.71];
    for (final y in ys) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LinesIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

// helper genérico de "pressionar" -> scale, usado em vários botões pequenos
class _PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double scaleDown;

  const _PressableScale({
    required this.child,
    required this.onTap,
    this.scaleDown = 0.92,
  });

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? widget.scaleDown : 1.0,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}

// =====================================================================
// ANIMATED SECTION - equivalente ao IndexedStack, mas com slide suave
// entre tabs (alfabeto / jogos / vídeos)
// =====================================================================

class _AnimatedSection extends StatelessWidget {
  final AppColors colors;
  final DrawerSection currentSection;
  final GridMode currentMode;
  final ValueChanged<GridMode> onModeChange;
  final ValueChanged<int> onConsonantTap;

  const _AnimatedSection({
    required this.colors,
    required this.currentSection,
    required this.currentMode,
    required this.onModeChange,
    required this.onConsonantTap,
  });

  Widget _buildSection(DrawerSection section) {
    switch (section) {
      case DrawerSection.alphabet:
        return _AlphabetSection(
          key: const ValueKey(DrawerSection.alphabet),
          colors: colors,
          currentMode: currentMode,
          onModeChange: onModeChange,
          onConsonantTap: onConsonantTap,
        );
      case DrawerSection.games:
        return _PlaceholderSection(
          key: const ValueKey(DrawerSection.games),
          colors: colors,
          iconBg: colors.c1Bg,
          assetPath: 'assets/icons/games-icon.png',
        );
      case DrawerSection.videos:
        return _PlaceholderSection(
          key: const ValueKey(DrawerSection.videos),
          colors: colors,
          iconBg: colors.c4Bg,
          assetPath: 'assets/icons/videos-icon.png',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
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
      child: _buildSection(currentSection),
    );
  }
}

// =====================================================================
// ALPHABET SECTION - equivalente a #section-alphabet (toggles + grid)
// =====================================================================

class _AlphabetSection extends StatelessWidget {
  final AppColors colors;
  final GridMode currentMode;
  final ValueChanged<GridMode> onModeChange;
  final ValueChanged<int> onConsonantTap;

  const _AlphabetSection({
    super.key,
    required this.colors,
    required this.currentMode,
    required this.onModeChange,
    required this.onConsonantTap,
  });

  List<String> get _letters {
    switch (currentMode) {
      case GridMode.vowels:
        return kVowels;
      case GridMode.consonants:
        return kConsonants;
      case GridMode.all:
        return kAllLetters;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConsonantMode = currentMode == GridMode.consonants;
    final letters = _letters;

    return Column(
      children: [
        // TOGGLES ROW - agora com a cor do corpo (bg), afastado do limite do appbar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(
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
        ),

        // GRID SCROLL
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: letters.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.05,
                  ),
                  itemBuilder: (context, index) {
                    final letter = letters[index];
                    final colorIndex = index % 6;
                    return _LetterCard(
                      colors: colors,
                      letter: letter,
                      colorIndex: colorIndex,
                      onTap: () {
                        if (isConsonantMode) {
                          final consonantIndex = kConsonants.indexOf(letter);
                          onConsonantTap(consonantIndex);
                        } else {
                          SoundManager.instance.playLetter(letter);
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// TOGGLE BUTTON - equivalente a .toggle-btn / .toggle-btn.active
// Sem fonte personalizada - usa a fonte padrão do tema.
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
      child: _PressableScale(
        scaleDown: 0.96,
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

// LETTER CARD - equivalente a .card / .card.c0..c5 (botão real via GestureDetector)
class _LetterCard extends StatefulWidget {
  final AppColors colors;
  final String letter;
  final int colorIndex;
  final VoidCallback onTap;

  const _LetterCard({
    required this.colors,
    required this.letter,
    required this.colorIndex,
    required this.onTap,
  });

  @override
  State<_LetterCard> createState() => _LetterCardState();
}

class _LetterCardState extends State<_LetterCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.colors.cardBgList[widget.colorIndex];
    final fg = widget.colors.cardFgList[widget.colorIndex];
    final shadow = widget.colors.cardShadowList[widget.colorIndex];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.identity()..translate(0.0, _pressed ? 4.0 : 0.0),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: shadow,
              offset: Offset(0, _pressed ? 1 : 4),
            ),
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

// =====================================================================
// PLACEHOLDER SECTION - equivalente a #section-games / #section-videos
// =====================================================================

class _PlaceholderSection extends StatelessWidget {
  final AppColors colors;
  final Color iconBg;
  final String assetPath;

  const _PlaceholderSection({
    super.key,
    required this.colors,
    required this.iconBg,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(28),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Center(
                child: Image.asset(
                  assetPath,
                  width: 56,
                  height: 56,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox(width: 56, height: 56),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: 120,
            height: 10,
            decoration: BoxDecoration(
              color: colors.bgCardNeutral,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: 70,
            height: 10,
            decoration: BoxDecoration(
              color: colors.bgCardNeutral,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// APP DRAWER - equivalente a .drawer / .drawer-item / .theme-switch
// =====================================================================

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

// DRAWER ITEM - botão real com box-shadow, igual ao toggle/card
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
            BoxShadow(
              color: shadowColor,
              offset: Offset(0, _pressed ? 1 : 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset(
              widget.assetPath,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
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

// THEME SWITCH - equivalente a .theme-switch, troca ícone sol/lua
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
              child: CustomPaint(
                size: const Size(14, 14),
                painter: isDark
                    ? _MoonIconPainter(color: AppColors.orange)
                    : _SunIconPainter(color: AppColors.orange),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// SVG do sol redesenhado como CustomPainter (stroke, vazado)
class _SunIconPainter extends CustomPainter {
  final Color color;
  _SunIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, size.width * 0.28, paint);

    final rayLen = size.width * 0.16;
    final positions = [
      [Offset(center.dx, 0), Offset(center.dx, rayLen)],
      [Offset(center.dx, size.height), Offset(center.dx, size.height - rayLen)],
      [Offset(0, center.dy), Offset(rayLen, center.dy)],
      [Offset(size.width, center.dy), Offset(size.width - rayLen, center.dy)],
    ];
    for (final p in positions) {
      canvas.drawLine(p[0], p[1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SunIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

// SVG da lua redesenhado como CustomPainter (fill, cheia)
class _MoonIconPainter extends CustomPainter {
  final Color color;
  _MoonIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final fullCircle = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(size.width * 0.42, size.height * 0.5),
        radius: size.width * 0.42,
      ));
    final cutoutCircle = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(size.width * 0.62, size.height * 0.38),
        radius: size.width * 0.36,
      ));

    final crescent = Path.combine(
      PathOperation.difference,
      fullCircle,
      cutoutCircle,
    );
    canvas.drawPath(crescent, paint);
  }

  @override
  bool shouldRepaint(covariant _MoonIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

// =====================================================================
// DETAIL SCREEN - equivalente a #detailScreen (progress, tabs, sílabas)
// =====================================================================

class DetailScreen extends StatefulWidget {
  final AppColors colors;
  final int initialConsonantIndex;

  const DetailScreen({
    super.key,
    required this.colors,
    required this.initialConsonantIndex,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with SingleTickerProviderStateMixin {
  late int currentConsonantIndex;
  bool isUpperCase = true;

  late AnimationController _slideController;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    currentConsonantIndex = widget.initialConsonantIndex;
    // equivalente ao .slide-track { transition: transform 0.32s cubic-bezier(...) }
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _slideAnim = CurvedAnimation(
      parent: _slideController,
      curve: const Cubic(0.22, 1, 0.36, 1),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void switchCase(bool upper) {
    if (isUpperCase == upper) return;
    setState(() => isUpperCase = upper);
    if (upper) {
      _slideController.reverse();
    } else {
      _slideController.forward();
    }
  }

  void goPrev() {
    if (currentConsonantIndex > 0) {
      setState(() {
        currentConsonantIndex--;
        isUpperCase = true;
      });
      _slideController.reverse();
    }
  }

  void goNext() {
    if (currentConsonantIndex < kConsonants.length - 1) {
      setState(() {
        currentConsonantIndex++;
        isUpperCase = true;
      });
      _slideController.reverse();
    }
  }

  void playSound(String letterOrSyllable) {
    SoundManager.instance.play(letterOrSyllable);
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final consonant = kConsonants[currentConsonantIndex];

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // PROGRESS ROW
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Row(
                children: List.generate(kConsonants.length, (i) {
                  final filled = i <= currentConsonantIndex;
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                        right: i == kConsonants.length - 1 ? 0 : 4,
                      ),
                      height: 4,
                      decoration: BoxDecoration(
                        color: filled ? AppColors.green : colors.divider,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // NAV ROW
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                children: [
                  _NavButton(
                    colors: colors,
                    icon: _NavIconType.back,
                    enabled: currentConsonantIndex > 0,
                    onTap: goPrev,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 220),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colors.bgCardNeutral,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            _CaseTab(
                              colors: colors,
                              label: '${consonant.toUpperCase()}+a',
                              active: isUpperCase,
                              onTap: () => switchCase(true),
                            ),
                            const SizedBox(width: 4),
                            _CaseTab(
                              colors: colors,
                              label: '$consonant+a',
                              active: !isUpperCase,
                              onTap: () => switchCase(false),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _NavButton(
                    colors: colors,
                    icon: _NavIconType.forward,
                    enabled: currentConsonantIndex < kConsonants.length - 1,
                    onTap: goNext,
                  ),
                ],
              ),
            ),

            // BODY - slide track entre maiúscula/minúscula
            Expanded(
              child: ClipRect(
                child: AnimatedBuilder(
                  animation: _slideAnim,
                  builder: (context, child) {
                    final width = MediaQuery.of(context).size.width;
                    return Transform.translate(
                      offset: Offset(-width * _slideAnim.value, 0),
                      child: SizedBox(
                        width: width * 2,
                        child: Row(
                          children: [
                            SizedBox(
                              width: width,
                              child: _SyllablePane(
                                colors: colors,
                                consonant: consonant,
                                isUpper: true,
                                onPlaySound: playSound,
                              ),
                            ),
                            SizedBox(
                              width: width,
                              child: _SyllablePane(
                                colors: colors,
                                consonant: consonant,
                                isUpper: false,
                                onPlaySound: playSound,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // BOTTOM BAR - fechar
            Container(
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                16 + MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: colors.bg,
                border: Border(top: BorderSide(color: colors.divider)),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: _CloseButton(
                    colors: colors,
                    onTap: () => Navigator.of(context).pop(),
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

enum _NavIconType { back, forward }

// NAV BUTTON - equivalente a .nav-btn (prev/next)
class _NavButton extends StatelessWidget {
  final AppColors colors;
  final _NavIconType icon;
  final bool enabled;
  final VoidCallback onTap;

  const _NavButton({
    required this.colors,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.35,
      child: _PressableScale(
        onTap: enabled ? onTap : () {},
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: colors.bgCardNeutral,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: CustomPaint(
              size: const Size(22, 22),
              painter: _ChevronPainter(
                color: colors.textMuted,
                pointRight: icon == _NavIconType.forward,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// SVG das setas prev/next redesenhado como CustomPainter
class _ChevronPainter extends CustomPainter {
  final Color color;
  final bool pointRight;
  _ChevronPainter({required this.color, required this.pointRight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    if (pointRight) {
      path.moveTo(size.width * 0.37, size.height * 0.16);
      path.lineTo(size.width * 0.75, size.height * 0.5);
      path.lineTo(size.width * 0.37, size.height * 0.84);
    } else {
      path.moveTo(size.width * 0.63, size.height * 0.16);
      path.lineTo(size.width * 0.25, size.height * 0.5);
      path.lineTo(size.width * 0.63, size.height * 0.84);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ChevronPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.pointRight != pointRight;
}

// CASE TAB - equivalente a .case-tab / .case-tab.active
class _CaseTab extends StatelessWidget {
  final AppColors colors;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _CaseTab({
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
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
          decoration: BoxDecoration(
            color: active ? AppColors.green : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: active
                ? [
                    const BoxShadow(
                      color: AppColors.greenShadow,
                      offset: Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: active ? Colors.white : colors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

// SYLLABLE PANE - equivalente a .slide-pane > .detail-inner (uma face maiúscula/minúscula)
class _SyllablePane extends StatelessWidget {
  final AppColors colors;
  final String consonant;
  final bool isUpper;
  final ValueChanged<String> onPlaySound;

  const _SyllablePane({
    required this.colors,
    required this.consonant,
    required this.isUpper,
    required this.onPlaySound,
  });

  @override
  Widget build(BuildContext context) {
    final displayLetter = isUpper ? consonant.toUpperCase() : consonant;
    // A letra grande do topo usa sempre a consoante em minúscula para
    // referência sonora (o texto exibido mantém maiúscula/minúscula).
    final soundLetter = consonant.toLowerCase();

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: () => onPlaySound(soundLetter),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 20),
                    child: Text(
                      displayLetter,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'ComicSansMS',
                        fontSize: 64,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                        color: colors.textMain,
                      ),
                    ),
                  ),
                ),
                for (final vowel in kVowels)
                  _SyllableRow(
                    colors: colors,
                    consonantDisplay: displayLetter,
                    consonantSound: soundLetter,
                    vowel: vowel,
                    syllable: buildSyllable(consonant, vowel, isUpper),
                    isLast: vowel == kVowels.last,
                    onPlaySound: onPlaySound,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// SYLLABLE ROW - equivalente a .syllable-row (consoante + vogal = sílaba + speaker)
class _SyllableRow extends StatelessWidget {
  final AppColors colors;
  final String consonantDisplay;
  final String consonantSound;
  final String vowel;
  final String syllable;
  final bool isLast;
  final ValueChanged<String> onPlaySound;

  const _SyllableRow({
    required this.colors,
    required this.consonantDisplay,
    required this.consonantSound,
    required this.vowel,
    required this.syllable,
    required this.isLast,
    required this.onPlaySound,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 2),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: colors.divider)),
      ),
      child: Row(
        children: [
          _SmallLetterButton(
            colors: colors,
            label: consonantDisplay,
            onTap: () => onPlaySound(consonantSound),
          ),
          _Operator(colors: colors, symbol: '+'),
          _SmallLetterButton(
            colors: colors,
            label: vowel,
            onTap: () => onPlaySound(vowel),
          ),
          _Operator(colors: colors, symbol: '='),
          _SyllableButton(
            colors: colors,
            label: syllable,
            onTap: () => onPlaySound(syllable),
          ),
          const Spacer(),
          _SpeakerButton(
            colors: colors,
            onTap: () => onPlaySound(syllable),
          ),
        ],
      ),
    );
  }
}

// LETTER BUTTON pequeno - equivalente a .letter-btn
class _SmallLetterButton extends StatefulWidget {
  final AppColors colors;
  final String label;
  final VoidCallback onTap;

  const _SmallLetterButton({
    required this.colors,
    required this.label,
    required this.onTap,
  });

  @override
  State<_SmallLetterButton> createState() => _SmallLetterButtonState();
}

class _SmallLetterButtonState extends State<_SmallLetterButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.identity()..translate(0.0, _pressed ? 2.0 : 0.0),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: widget.colors.bgCardNeutral,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: widget.colors.neutralShadow,
              offset: Offset(0, _pressed ? 1 : 3),
            ),
          ],
        ),
        child: Text(
          widget.label,
          style: TextStyle(
            fontFamily: 'ComicSansMS',
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: widget.colors.textMain,
          ),
        ),
      ),
    );
  }
}

// OPERADOR - equivalente a .syl-op ( + e = ) - sem fonte personalizada
class _Operator extends StatelessWidget {
  final AppColors colors;
  final String symbol;

  const _Operator({required this.colors, required this.symbol});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Opacity(
        opacity: 0.4,
        child: Text(
          symbol,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: colors.textMain,
          ),
        ),
      ),
    );
  }
}

// SYLLABLE BUTTON - equivalente a .syllable-btn (verde, resultado da soma)
class _SyllableButton extends StatefulWidget {
  final AppColors colors;
  final String label;
  final VoidCallback onTap;

  const _SyllableButton({
    required this.colors,
    required this.label,
    required this.onTap,
  });

  @override
  State<_SyllableButton> createState() => _SyllableButtonState();
}

class _SyllableButtonState extends State<_SyllableButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.identity()..translate(0.0, _pressed ? 2.0 : 0.0),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.green,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.greenShadow,
              offset: Offset(0, _pressed ? 1 : 3),
            ),
          ],
        ),
        child: Text(
          widget.label,
          style: const TextStyle(
            fontFamily: 'ComicSansMS',
            fontWeight: FontWeight.w700,
            fontSize: 28,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// SPEAKER BUTTON - equivalente a .speaker-btn
class _SpeakerButton extends StatelessWidget {
  final AppColors colors;
  final VoidCallback onTap;

  const _SpeakerButton({required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _PressableScale(
      scaleDown: 1.0,
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: Center(
          child: CustomPaint(
            size: const Size(22, 22),
            painter: _SpeakerIconPainter(color: colors.textMuted),
          ),
        ),
      ),
    );
  }
}

// SVG do speaker redesenhado como CustomPainter
class _SpeakerIconPainter extends CustomPainter {
  final Color color;
  _SpeakerIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    final speaker = Path()
      ..moveTo(w * 0.46, h * 0.21)
      ..lineTo(w * 0.25, h * 0.375)
      ..lineTo(w * 0.08, h * 0.375)
      ..lineTo(w * 0.08, h * 0.625)
      ..lineTo(w * 0.25, h * 0.625)
      ..lineTo(w * 0.46, h * 0.79)
      ..close();
    canvas.drawPath(speaker, paint);

    final wave1 = Path()
      ..moveTo(w * 0.645, h * 0.354)
      ..quadraticBezierTo(w * 0.85, h * 0.5, w * 0.645, h * 0.646);
    canvas.drawPath(wave1, paint);

    final wave2 = Path()
      ..moveTo(w * 0.77, h * 0.25)
      ..quadraticBezierTo(w * 1.02, h * 0.5, w * 0.77, h * 0.75);
    canvas.drawPath(wave2, paint);
  }

  @override
  bool shouldRepaint(covariant _SpeakerIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

// CLOSE BUTTON - equivalente a .close-btn (vermelho, fecha o detail)
// Sem fonte personalizada.
class _CloseButton extends StatefulWidget {
  final AppColors colors;
  final VoidCallback onTap;

  const _CloseButton({required this.colors, required this.onTap});

  @override
  State<_CloseButton> createState() => _CloseButtonState();
}

class _CloseButtonState extends State<_CloseButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: double.infinity,
        transform: Matrix4.identity()..translate(0.0, _pressed ? 3.0 : 0.0),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.red,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.redShadow,
              offset: Offset(0, _pressed ? 1 : 4),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Fechar',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}