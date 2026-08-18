import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../main.dart'
    show
        AppColors,
        SoundManager,
        kVowels,
        kConsonants,
        buildSyllable,
        AssetUtils;

class DetailScreen extends StatefulWidget {
  final AppColors colors;
  final int initialConsonantIndex;

  const DetailScreen({
    super.key,
    required this.colors,
    required this.initialConsonantIndex,
  });

  @override
  State<DetailScreen> createState() =>
      _DetailScreenState();
}

class _DetailScreenState
    extends State<DetailScreen>
    with SingleTickerProviderStateMixin {
  late int currentConsonantIndex;

  bool isUpperCase = true;

  late AnimationController _slideController;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();

    currentConsonantIndex =
        widget.initialConsonantIndex;

    _slideController =
        AnimationController(
      vsync: this,
      duration:
          const Duration(
        milliseconds: 320,
      ),
    );

    _slideAnim =
        CurvedAnimation(
      parent:
          _slideController,
      curve:
          const Cubic(
        0.22,
        1,
        0.36,
        1,
      ),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void switchCase(
    bool upper,
  ) {
    if (isUpperCase ==
        upper) {
      return;
    }

    setState(() {
      isUpperCase =
          upper;
    });

    if (upper) {
      _slideController.reverse();
    } else {
      _slideController.forward();
    }
  }

  void goPrev() {
    if (currentConsonantIndex <=
        0) {
      return;
    }

    setState(() {
      currentConsonantIndex--;

      isUpperCase =
          true;
    });

    _slideController.reverse();
  }

  void goNext() {
    if (currentConsonantIndex >=
        kConsonants.length -
            1) {
      return;
    }

    setState(() {
      currentConsonantIndex++;

      isUpperCase =
          true;
    });

    _slideController.reverse();
  }

  void playSound(
    String letterOrSyllable,
  ) {
    SoundManager.instance
        .play(
      letterOrSyllable,
    );
  }

  void playExampleSound(
    String syllable,
  ) {
    SoundManager.instance
        .playExample(
      syllable,
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final colors =
        widget.colors;

    final consonant =
        kConsonants[
            currentConsonantIndex];

    return Scaffold(
      backgroundColor:
          colors.bg,
      body:
          SafeArea(
        child:
            Column(
          children: [
            // ──────────────────────────────────────────
            // PROGRESSO
            // ──────────────────────────────────────────

            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                14,
                10,
                14,
                0,
              ),
              child:
                  Row(
                children:
                    List.generate(
                  kConsonants.length,
                  (i) {
                    final filled =
                        i <=
                            currentConsonantIndex;

                    return Expanded(
                      child:
                          Container(
                        margin:
                            EdgeInsets.only(
                          right:
                              i ==
                                      kConsonants
                                              .length -
                                          1
                                  ? 0
                                  : 4,
                        ),
                        height:
                            4,
                        decoration:
                            BoxDecoration(
                          color:
                              filled
                                  ? AppColors
                                      .green
                                  : colors
                                      .divider,
                          borderRadius:
                              BorderRadius.circular(
                            3,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ──────────────────────────────────────────
            // HEADER
            // ──────────────────────────────────────────

            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                12,
                12,
                12,
                8,
              ),
              child:
                  Row(
                children: [
                  _NavButton(
                    colors:
                        colors,
                    icon:
                        _NavIconType.back,
                    enabled:
                        currentConsonantIndex >
                            0,
                    onTap:
                        goPrev,
                  ),

                  const SizedBox(
                    width:
                        8,
                  ),

                  Expanded(
                    child:
                        ConstrainedBox(
                      constraints:
                          const BoxConstraints(
                        maxWidth:
                            220,
                      ),
                      child:
                          Container(
                        padding:
                            const EdgeInsets.all(
                          4,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              colors
                                  .bgCardNeutral,
                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),
                        ),
                        child:
                            Row(
                          children: [
                            _CaseTab(
                              colors:
                                  colors,
                              label:
                                  '${consonant.toUpperCase()}+a',
                              active:
                                  isUpperCase,
                              onTap:
                                  () =>
                                      switchCase(
                                true,
                              ),
                            ),

                            const SizedBox(
                              width:
                                  4,
                            ),

                            _CaseTab(
                              colors:
                                  colors,
                              label:
                                  '$consonant+a',
                              active:
                                  !isUpperCase,
                              onTap:
                                  () =>
                                      switchCase(
                                false,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    width:
                        8,
                  ),

                  _NavButton(
                    colors:
                        colors,
                    icon:
                        _NavIconType.forward,
                    enabled:
                        currentConsonantIndex <
                            kConsonants
                                    .length -
                                1,
                    onTap:
                        goNext,
                  ),
                ],
              ),
            ),

            // ──────────────────────────────────────────
            // CONTEÚDO
            // ──────────────────────────────────────────

            Expanded(
              child:
                  ClipRect(
                child:
                    AnimatedBuilder(
                  animation:
                      _slideAnim,
                  builder:
                      (
                    context,
                    child,
                  ) {
                    final width =
                        MediaQuery.of(
                      context,
                    ).size.width;

                    return Transform
                        .translate(
                      offset:
                          Offset(
                        -width *
                            _slideAnim
                                .value,
                        0,
                      ),
                      child:
                          SizedBox(
                        width:
                            width *
                                2,
                        child:
                            Row(
                          children: [
                            SizedBox(
                              width:
                                  width,
                              child:
                                  _SyllablePane(
                                colors:
                                    colors,
                                consonant:
                                    consonant,
                                isUpper:
                                    true,
                                onPlaySound:
                                    playSound,
                                onPlayExampleSound:
                                    playExampleSound,
                              ),
                            ),
                            SizedBox(
                              width:
                                  width,
                              child:
                                  _SyllablePane(
                                colors:
                                    colors,
                                consonant:
                                    consonant,
                                isUpper:
                                    false,
                                onPlaySound:
                                    playSound,
                                onPlayExampleSound:
                                    playExampleSound,
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

            // ──────────────────────────────────────────
            // FECHAR
            // ──────────────────────────────────────────

            Container(
              padding:
                  EdgeInsets.fromLTRB(
                16,
                12,
                16,
                16 +
                    MediaQuery.of(
                      context,
                    ).padding.bottom,
              ),
              decoration:
                  BoxDecoration(
                color:
                    colors.bg,
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
                  Center(
                child:
                    ConstrainedBox(
                  constraints:
                      const BoxConstraints(
                    maxWidth:
                        480,
                  ),
                  child:
                      _CloseButton(
                    colors:
                        colors,
                    onTap:
                        () =>
                            Navigator
                                .of(
                      context,
                    ).pop(),
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

// ══════════════════════════════════════════════════════════════
// NAVEGAÇÃO
// ══════════════════════════════════════════════════════════════

enum _NavIconType {
  back,
  forward,
}

class _NavButton
    extends StatelessWidget {
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
  Widget build(
    BuildContext context,
  ) {
    final asset =
        icon ==
                _NavIconType.back
            ? 'assets/icons/back.svg'
            : 'assets/icons/arrow-right.svg';

    return GestureDetector(
      onTap:
          enabled
              ? onTap
              : null,
      child:
          AnimatedOpacity(
        duration:
            const Duration(
          milliseconds:
              160,
        ),
        opacity:
            enabled
                ? 1
                : 0.35,
        child:
            Container(
          width:
              42,
          height:
              42,
          decoration:
              BoxDecoration(
            color:
                colors.bgCardNeutral,
            borderRadius:
                BorderRadius.circular(
              12,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    colors.divider,
                offset:
                    const Offset(
                  0,
                  3,
                ),
              ),
            ],
          ),
          child:
              Center(
            child:
                SvgPicture.asset(
              asset,
              width:
                  19,
              height:
                  19,
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

// ══════════════════════════════════════════════════════════════
// CASE TAB
// ══════════════════════════════════════════════════════════════

class _CaseTab
    extends StatelessWidget {
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
          padding:
              const EdgeInsets.symmetric(
            vertical:
                10,
          ),
          decoration:
              BoxDecoration(
            color:
                active
                    ? AppColors.green
                    : Colors.transparent,
            borderRadius:
                BorderRadius.circular(
              10,
            ),
          ),
          child:
              Text(
            label,
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              fontFamily:
                  'ComicSansMS',
              fontWeight:
                  FontWeight.w700,
              fontSize:
                  14,
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

// ══════════════════════════════════════════════════════════════
// PAINEL DE SÍLABAS
// ══════════════════════════════════════════════════════════════

class _SyllablePane
    extends StatelessWidget {
  final AppColors colors;
  final String consonant;
  final bool isUpper;
  final ValueChanged<String>
      onPlaySound;
  final ValueChanged<String>
      onPlayExampleSound;

  const _SyllablePane({
    required this.colors,
    required this.consonant,
    required this.isUpper,
    required this.onPlaySound,
    required this.onPlayExampleSound,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final consonantDisplay =
        isUpper
            ? consonant
                .toUpperCase()
            : consonant
                .toLowerCase();

    return ListView.separated(
      padding:
          const EdgeInsets.fromLTRB(
        14,
        8,
        14,
        24,
      ),
      physics:
          const BouncingScrollPhysics(),
      itemCount:
          kVowels.length,
      separatorBuilder:
          (
        context,
        index,
      ) =>
              const SizedBox(
        height:
            10,
      ),
      itemBuilder:
          (
        context,
        index,
      ) {
        final vowel =
            kVowels[index];

        final syllable =
            buildSyllable(
          consonant,
          vowel,
          isUpper,
        );

        final folderPath =
            'assets/images/'
            '${consonant.toLowerCase()}'
            '/$syllable';

        final consonantSound =
            consonant
                .toLowerCase();

        return _SyllableRow(
          colors:
              colors,
          consonantDisplay:
              consonantDisplay,
          consonantSound:
              consonantSound,
          vowel:
              vowel,
          syllable:
              syllable,
          folderPath:
              folderPath,
          onPlaySound:
              onPlaySound,
          onPlayExampleSound:
              onPlayExampleSound,
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SYLLABLE ROW
// ══════════════════════════════════════════════════════════════

class _SyllableRow
    extends StatelessWidget {
  final AppColors colors;
  final String consonantDisplay;
  final String consonantSound;
  final String vowel;
  final String syllable;
  final String folderPath;
  final ValueChanged<String>
      onPlaySound;
  final ValueChanged<String>
      onPlayExampleSound;

  const _SyllableRow({
    required this.colors,
    required this.consonantDisplay,
    required this.consonantSound,
    required this.vowel,
    required this.syllable,
    required this.folderPath,
    required this.onPlaySound,
    required this.onPlayExampleSound,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal:
            10,
        vertical:
            10,
      ),
      decoration:
          BoxDecoration(
        color:
            colors.bgCardNeutral,
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        border:
            Border.all(
          color:
              colors.divider,
        ),
      ),
      child:
          Row(
        children: [
          _SmallLetterButton(
            colors:
                colors,
            label:
                consonantDisplay,
            onTap:
                () =>
                    onPlaySound(
              consonantSound,
            ),
          ),

          _Operator(
            colors:
                colors,
            symbol:
                '+',
          ),

          _SmallLetterButton(
            colors:
                colors,
            label:
                vowel,
            onTap:
                () =>
                    onPlaySound(
              vowel,
            ),
          ),

          _Operator(
            colors:
                colors,
            symbol:
                '=',
          ),

          _SyllableButton(
            colors:
                colors,
            label:
                syllable,
            onTap:
                () =>
                    onPlaySound(
              syllable,
            ),
          ),

          const SizedBox(
            width:
                8,
          ),

          _SyllableImageThumbnail(
            colors:
                colors,
            folderPath:
                folderPath,
            syllable:
                syllable,
          ),

          const Spacer(),

          _SpeakerButton(
            colors:
                colors,
            onTap:
                () =>
                    onPlayExampleSound(
              syllable,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// THUMBNAIL
// ══════════════════════════════════════════════════════════════

class _SyllableImageThumbnail
    extends StatelessWidget {
  final AppColors colors;
  final String folderPath;
  final String syllable;

  const _SyllableImageThumbnail({
    required this.colors,
    required this.folderPath,
    required this.syllable,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return FutureBuilder<
        List<String>>(
      future:
          AssetUtils.getAssetsInFolder(
        folderPath,
      ),
      builder:
          (
        context,
        snapshot,
      ) {
        final images =
            snapshot.data ??
                const <String>[];

        final hasImages =
            images.isNotEmpty;

        return GestureDetector(
          onTap:
              hasImages
                  ? () {
                      Navigator.of(
                        context,
                      ).push(
                        MaterialPageRoute(
                          builder:
                              (_) =>
                                  SyllableImagesScreen(
                            colors:
                                colors,
                            title:
                                syllable,
                            images:
                                images,
                          ),
                        ),
                      );
                    }
                  : null,
          child:
              Container(
            width:
                30,
            height:
                30,
            decoration:
                BoxDecoration(
              color:
                  colors.bgCardNeutral,
              shape:
                  BoxShape.circle,
              border:
                  Border.all(
                color:
                    colors.divider,
              ),
            ),
            child:
                ClipOval(
              child:
                  hasImages
                      ? Image.asset(
                          images.first,
                          fit:
                              BoxFit.cover,
                          errorBuilder:
                              (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return Icon(
                              Icons
                                  .image_outlined,
                              size:
                                  14,
                              color:
                                  colors.textMuted,
                            );
                          },
                        )
                      : Icon(
                          Icons
                              .image_outlined,
                          size:
                              14,
                          color:
                              colors.textMuted,
                        ),
            ),
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════
// IMAGENS DA SÍLABA
// ══════════════════════════════════════════════════════════════

class SyllableImagesScreen
    extends StatelessWidget {
  final AppColors colors;
  final String title;
  final List<String> images;

  const SyllableImagesScreen({
    super.key,
    required this.colors,
    required this.title,
    required this.images,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          colors.bg,
      appBar:
          AppBar(
        backgroundColor:
            colors.bg,
        elevation:
            0,
        title:
            Text(
          title,
          style:
              TextStyle(
            color:
                colors.textMain,
            fontWeight:
                FontWeight.w700,
          ),
        ),
        leading:
            IconButton(
          icon:
              SvgPicture.asset(
            'assets/icons/chevron-left.svg',
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
          onPressed:
              () =>
                  Navigator.of(
            context,
          ).pop(),
        ),
      ),
      body:
          GridView.builder(
        padding:
            const EdgeInsets.all(
          16,
        ),
        physics:
            const BouncingScrollPhysics(),
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:
              2,
          mainAxisSpacing:
              12,
          crossAxisSpacing:
              12,
          childAspectRatio:
              1,
        ),
        itemCount:
            images.length,
        itemBuilder:
            (
          context,
          index,
        ) {
          return Container(
            decoration:
                BoxDecoration(
              color:
                  colors.bgCardNeutral,
              borderRadius:
                  BorderRadius.circular(
                16,
              ),
            ),
            clipBehavior:
                Clip.antiAlias,
            child:
                Image.asset(
              images[index],
              fit:
                  BoxFit.contain,
              errorBuilder:
                  (
                context,
                error,
                stackTrace,
              ) {
                return Icon(
                  Icons
                      .broken_image_outlined,
                  color:
                      colors.textMuted,
                  size:
                      32,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// LETRA PEQUENA
// ══════════════════════════════════════════════════════════════

class _SmallLetterButton
    extends StatefulWidget {
  final AppColors colors;
  final String label;
  final VoidCallback onTap;

  const _SmallLetterButton({
    required this.colors,
    required this.label,
    required this.onTap,
  });

  @override
  State<_SmallLetterButton>
      createState() =>
          _SmallLetterButtonState();
}

class _SmallLetterButtonState
    extends State<
        _SmallLetterButton> {
  bool _pressed =
      false;

  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
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
        transform:
            Matrix4.identity()
              ..translate(
                0.0,
                _pressed
                    ? 2.0
                    : 0.0,
              ),
        padding:
            const EdgeInsets.symmetric(
          vertical:
              8,
          horizontal:
              12,
        ),
        decoration:
            BoxDecoration(
          color:
              widget.colors.bgCardNeutral,
          borderRadius:
              BorderRadius.circular(
            12,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  widget.colors.neutralShadow,
              offset:
                  Offset(
                0,
                _pressed
                    ? 1
                    : 3,
              ),
            ),
          ],
        ),
        child:
            Text(
          widget.label,
          style:
              TextStyle(
            fontFamily:
                'ComicSansMS',
            fontWeight:
                FontWeight.w700,
            fontSize:
                24,
            color:
                widget.colors.textMain,
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// OPERADOR
// ══════════════════════════════════════════════════════════════

class _Operator
    extends StatelessWidget {
  final AppColors colors;
  final String symbol;

  const _Operator({
    required this.colors,
    required this.symbol,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal:
            10,
      ),
      child:
          Opacity(
        opacity:
            0.4,
        child:
            Text(
          symbol,
          style:
              TextStyle(
            fontWeight:
                FontWeight.w700,
            fontSize:
                18,
            color:
                colors.textMain,
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SÍLABA
// ══════════════════════════════════════════════════════════════

class _SyllableButton
    extends StatefulWidget {
  final AppColors colors;
  final String label;
  final VoidCallback onTap;

  const _SyllableButton({
    required this.colors,
    required this.label,
    required this.onTap,
  });

  @override
  State<_SyllableButton>
      createState() =>
          _SyllableButtonState();
}

class _SyllableButtonState
    extends State<
        _SyllableButton> {
  bool _pressed =
      false;

  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
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
        transform:
            Matrix4.identity()
              ..translate(
                0.0,
                _pressed
                    ? 2.0
                    : 0.0,
              ),
        padding:
            const EdgeInsets.symmetric(
          vertical:
              8,
          horizontal:
              16,
        ),
        decoration:
            BoxDecoration(
          color:
              AppColors.green,
          borderRadius:
              BorderRadius.circular(
            12,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  AppColors.greenShadow,
              offset:
                  Offset(
                0,
                _pressed
                    ? 1
                    : 3,
              ),
            ),
          ],
        ),
        child:
            Text(
          widget.label,
          style:
              const TextStyle(
            fontFamily:
                'ComicSansMS',
            fontWeight:
                FontWeight.w700,
            fontSize:
                28,
            color:
                Colors.white,
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SPEAKER
// ══════════════════════════════════════════════════════════════

class _SpeakerButton
    extends StatelessWidget {
  final AppColors colors;
  final VoidCallback onTap;

  const _SpeakerButton({
    required this.colors,
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
            40,
        height:
            40,
        decoration:
            const BoxDecoration(
          shape:
              BoxShape.circle,
        ),
        child:
            Center(
          child:
              SvgPicture.asset(
            'assets/icons/speaker-icon.svg',
            width:
                22,
            height:
                22,
            colorFilter:
                ColorFilter.mode(
              colors.textMuted,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// FECHAR
// ══════════════════════════════════════════════════════════════

class _CloseButton
    extends StatefulWidget {
  final AppColors colors;
  final VoidCallback onTap;

  const _CloseButton({
    required this.colors,
    required this.onTap,
  });

  @override
  State<_CloseButton>
      createState() =>
          _CloseButtonState();
}

class _CloseButtonState
    extends State<
        _CloseButton> {
  bool _pressed =
      false;

  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
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
            Matrix4.identity()
              ..translate(
                0.0,
                _pressed
                    ? 3.0
                    : 0.0,
              ),
        padding:
            const EdgeInsets.all(
          15,
        ),
        decoration:
            BoxDecoration(
          color:
              AppColors.red,
          borderRadius:
              BorderRadius.circular(
            16,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  AppColors.redShadow,
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
            const Center(
          child:
              Text(
            'Fechar',
            style:
                TextStyle(
              fontSize:
                  16,
              fontWeight:
                  FontWeight.w700,
              color:
                  Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}