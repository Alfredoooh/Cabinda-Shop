import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../main.dart'
    show
        AppColors,
        SoundManager,
        kVowels,
        kConsonants,
        buildSyllable,
        vowelsForConsonant,
        displayConsonant;

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

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );

    _slideAnim = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOutCubicEmphasized,
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  // ÚNICO ponto de reprodução de áudio.
  // Não existe TTS aqui.
  void playSound(String value) {
    final sound = value.trim().toLowerCase();

    if (sound.isEmpty) return;

    SoundManager.instance.play(sound);
  }

  void switchCase(bool upper) {
    if (isUpperCase == upper) {
      final consonant = kConsonants[currentConsonantIndex];
      playSound(consonant);
      return;
    }

    setState(() => isUpperCase = upper);

    final consonant = kConsonants[currentConsonantIndex];
    playSound(consonant);

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

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final consonant = kConsonants[currentConsonantIndex];

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Row(
                children: List.generate(kConsonants.length, (i) {
                  final filled = i <= currentConsonantIndex;

                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOutCubic,
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
                              label: consonant.toLowerCase() == 'q'
                                  ? 'Q+u+a'
                                  : '${displayConsonant(consonant, upper: true)}+a',
                              active: isUpperCase,
                              onTap: () => switchCase(true),
                            ),
                            const SizedBox(width: 4),
                            _CaseTab(
                              colors: colors,
                              label: consonant.toLowerCase() == 'q'
                                  ? 'q+u+a'
                                  : '${displayConsonant(consonant, upper: false)}+a',
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
                    enabled:
                        currentConsonantIndex < kConsonants.length - 1,
                    onTap: goNext,
                  ),
                ],
              ),
            ),

            Expanded(
              child: ClipRect(
                child: AnimatedBuilder(
                  animation: _slideAnim,
                  builder: (context, child) {
                    final width = MediaQuery.of(context).size.width;
                    final curved = _slideAnim.value;

                    return Stack(
                      children: [
                        // MAIÚSCULA
                        Positioned.fill(
                          child: Transform.translate(
                            offset: Offset(-width * curved, 0),
                            child: SizedBox(
                              width: width,
                              child: IgnorePointer(
                                ignoring: curved > 0.5,
                                child: Opacity(
                                  opacity:
                                      (1 - curved).clamp(0.0, 1.0),
                                  child: _SyllablePane(
                                    colors: colors,
                                    consonant: consonant,
                                    isUpper: true,
                                    onPlaySound: playSound,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // MINÚSCULA
                        Positioned.fill(
                          child: Transform.translate(
                            offset: Offset(width * (1 - curved), 0),
                            child: SizedBox(
                              width: width,
                              child: IgnorePointer(
                                ignoring: curved <= 0.5,
                                child: Opacity(
                                  opacity: curved.clamp(0.0, 1.0),
                                  child: _SyllablePane(
                                    colors: colors,
                                    consonant: consonant,
                                    isUpper: false,
                                    onPlaySound: playSound,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            Container(
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                16 + MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: colors.bg,
                border: Border(
                  top: BorderSide(color: colors.divider),
                ),
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
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      opacity: enabled ? 1.0 : 0.35,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: colors.bgCardNeutral,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: SvgPicture.asset(
              icon == _NavIconType.forward
                  ? 'assets/icons/chevron-right.svg'
                  : 'assets/icons/chevron-left.svg',
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(
                colors.textMuted,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeInOutCubic,
          padding: const EdgeInsets.symmetric(
            vertical: 9,
            horizontal: 4,
          ),
          decoration: BoxDecoration(
            color: active
                ? AppColors.green
                : Colors.transparent,
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
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeInOutCubic,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: active
                  ? Colors.white
                  : colors.textMuted,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

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
    final displayLetter = displayConsonant(
      consonant,
      upper: isUpper,
    );

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // LETRA PRINCIPAL
                GestureDetector(
                  onTap: () => onPlaySound(consonant),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 4,
                      bottom: 24,
                    ),
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

                for (final vowel
                    in vowelsForConsonant(consonant))
                  _SyllableRow(
                    colors: colors,
                    consonantDisplay: displayLetter,
                    consonantSound: consonant,
                    middleVowel:
                        consonant.toLowerCase() == 'q'
                            ? 'u'
                            : null,
                    vowel: vowel,
                    syllable: buildSyllable(
                      consonant,
                      vowel,
                      isUpper,
                    ),
                    isLast:
                        vowel ==
                        vowelsForConsonant(consonant).last,
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

class _SyllableRow extends StatelessWidget {
  final AppColors colors;
  final String consonantDisplay;
  final String consonantSound;
  final String? middleVowel;
  final String vowel;
  final String syllable;
  final bool isLast;
  final ValueChanged<String> onPlaySound;

  const _SyllableRow({
    required this.colors,
    required this.consonantDisplay,
    required this.consonantSound,
    this.middleVowel,
    required this.vowel,
    required this.syllable,
    required this.isLast,
    required this.onPlaySound,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 2,
      ),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: colors.divider,
                ),
              ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SmallLetterButton(
                  colors: colors,
                  label: consonantDisplay,
                  onTap: () => onPlaySound(
                    consonantSound,
                  ),
                ),

                _Operator(
                  colors: colors,
                  symbol: '+',
                ),

                if (middleVowel != null) ...[
                  _SmallLetterButton(
                    colors: colors,
                    label: middleVowel!,
                    onTap: () => onPlaySound(
                      middleVowel!,
                    ),
                  ),
                  _Operator(
                    colors: colors,
                    symbol: '+',
                  ),
                ],

                _SmallLetterButton(
                  colors: colors,
                  label: vowel,
                  onTap: () => onPlaySound(vowel),
                ),

                _Operator(
                  colors: colors,
                  symbol: '=',
                ),

                _SyllableButton(
                  colors: colors,
                  label: syllable,
                  onTap: () => onPlaySound(syllable),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

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
  State<_SmallLetterButton> createState() =>
      _SmallLetterButtonState();
}

class _SmallLetterButtonState
    extends State<_SmallLetterButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(
        () => _pressed = true,
      ),
      onTapUp: (_) => setState(
        () => _pressed = false,
      ),
      onTapCancel: () => setState(
        () => _pressed = false,
      ),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        scale: _pressed ? 0.92 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..translate(
              0.0,
              _pressed ? 2.0 : 0.0,
            ),
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 18,
          ),
          decoration: BoxDecoration(
            color: widget.colors.bgCardNeutral,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.colors.neutralShadow,
                offset: Offset(
                  0,
                  _pressed ? 1 : 3,
                ),
              ),
            ],
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontFamily: 'ComicSansMS',
              fontWeight: FontWeight.w700,
              fontSize: 30,
              color: widget.colors.textMain,
            ),
          ),
        ),
      ),
    );
  }
}

class _Operator extends StatelessWidget {
  final AppColors colors;
  final String symbol;

  const _Operator({
    required this.colors,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      child: Opacity(
        opacity: 0.4,
        child: Text(
          symbol,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: colors.textMain,
          ),
        ),
      ),
    );
  }
}

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
  State<_SyllableButton> createState() =>
      _SyllableButtonState();
}

class _SyllableButtonState
    extends State<_SyllableButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(
        () => _pressed = true,
      ),
      onTapUp: (_) => setState(
        () => _pressed = false,
      ),
      onTapCancel: () => setState(
        () => _pressed = false,
      ),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        scale: _pressed ? 0.92 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..translate(
              0.0,
              _pressed ? 2.0 : 0.0,
            ),
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 22,
          ),
          decoration: BoxDecoration(
            color: AppColors.green,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.greenShadow,
                offset: Offset(
                  0,
                  _pressed ? 1 : 3,
                ),
              ),
            ],
          ),
          child: Text(
            widget.label,
            style: const TextStyle(
              fontFamily: 'ComicSansMS',
              fontWeight: FontWeight.w700,
              fontSize: 34,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _CloseButton extends StatefulWidget {
  final AppColors colors;
  final VoidCallback onTap;

  const _CloseButton({
    required this.colors,
    required this.onTap,
  });

  @override
  State<_CloseButton> createState() =>
      _CloseButtonState();
}

class _CloseButtonState
    extends State<_CloseButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(
        () => _pressed = true,
      ),
      onTapUp: (_) => setState(
        () => _pressed = false,
      ),
      onTapCancel: () => setState(
        () => _pressed = false,
      ),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        scale: _pressed ? 0.97 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          transform: Matrix4.identity()
            ..translate(
              0.0,
              _pressed ? 3.0 : 0.0,
            ),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColors.red,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.redShadow,
                offset: Offset(
                  0,
                  _pressed ? 1 : 4,
                ),
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
      ),
    );
  }
}