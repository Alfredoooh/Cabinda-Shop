import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart'
    show
        AppColors,
        AppStyle,
        SoundManager;

class AppSettingsResult {
  final bool isDark;
  final AppStyle style;
  final bool soundEnabled;
  final bool musicEnabled;

  const AppSettingsResult({
    required this.isDark,
    required this.style,
    required this.soundEnabled,
    required this.musicEnabled,
  });
}

class SettingsScreen
    extends StatefulWidget {
  final AppColors colors;
  final bool isDark;
  final AppStyle style;
  final bool soundEnabled;
  final bool musicEnabled;

  const SettingsScreen({
    super.key,
    required this.colors,
    required this.isDark,
    required this.style,
    required this.soundEnabled,
    required this.musicEnabled,
  });

  @override
  State<SettingsScreen>
      createState() =>
          _SettingsScreenState();
}

class _SettingsScreenState
    extends State<SettingsScreen> {
  late bool _dark;
  late AppStyle _style;
  late bool _sound;
  late bool _music;

  @override
  void initState() {
    super.initState();

    _dark =
        widget.isDark;

    _style =
        widget.style;

    _sound =
        widget.soundEnabled;

    _music =
        widget.musicEnabled;

    SystemChrome
        .setEnabledSystemUIMode(
      SystemUiMode
          .edgeToEdge,
    );
  }

  AppColors get colors =>
      AppColors(
        _dark,
        _style,
      );

  void _applyAudioState() {
    final manager =
        SoundManager.instance;

    manager.muted =
        !_sound;

    manager.clickMuted =
        !_sound;

    manager.musicMuted =
        !_music;
  }

  void _closeAndApply() {
    _applyAudioState();

    Navigator.of(context)
        .pop(
      AppSettingsResult(
        isDark:
            _dark,
        style:
            _style,
        soundEnabled:
            _sound,
        musicEnabled:
            _music,
      ),
    );
  }

  void _setSound(
    bool value,
  ) {
    setState(
      () {
        _sound =
            value;
      },
    );

    SoundManager.instance
        .muted = !value;

    SoundManager.instance
        .clickMuted = !value;
  }

  void _setMusic(
    bool value,
  ) {
    setState(
      () {
        _music =
            value;
      },
    );

    SoundManager.instance
        .musicMuted = !value;
  }

  void _setTheme(
    bool value,
  ) {
    setState(
      () {
        _dark =
            value;
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final c =
        colors;

    return AnnotatedRegion<
        SystemUiOverlayStyle>(
      value:
          SystemUiOverlayStyle(
        statusBarColor:
            Colors.transparent,
        systemNavigationBarColor:
            Colors.transparent,
        statusBarIconBrightness:
            _dark
                ? Brightness.light
                : Brightness.dark,
        statusBarBrightness:
            _dark
                ? Brightness.dark
                : Brightness.light,
        systemNavigationBarIconBrightness:
            _dark
                ? Brightness.light
                : Brightness.dark,
      ),
      child:
          Scaffold(
        backgroundColor:
            c.bg,
        body:
            SafeArea(
          child:
              Column(
            children: [
              _SettingsHeader(
                colors:
                    c,
                onBack:
                    _closeAndApply,
              ),

              Expanded(
                child:
                    ListView(
                  physics:
                      const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    28,
                  ),
                  children: [
                    _SectionHeader(
                      colors:
                          c,
                      icon:
                          Icons
                              .volume_up_outlined,
                      title:
                          'Som e reprodução',
                      subtitle:
                          'Controla os sons e a música do ABCtube.',
                    ),

                    const SizedBox(
                      height:
                          10,
                    ),

                    _SettingTile(
                      colors:
                          c,
                      icon:
                          Icons
                              .touch_app_outlined,
                      title:
                          'Sons de clique',
                      subtitle:
                          'Feedback sonoro ao tocar nos botões.',
                      value:
                          _sound,
                      onChanged:
                          _setSound,
                    ),

                    const SizedBox(
                      height:
                          10,
                    ),

                    _SettingTile(
                      colors:
                          c,
                      icon:
                          Icons
                              .music_note_outlined,
                      title:
                          'Música',
                      subtitle:
                          'Música ambiente durante a utilização.',
                      value:
                          _music,
                      onChanged:
                          _setMusic,
                    ),

                    const SizedBox(
                      height:
                          24,
                    ),

                    _SectionHeader(
                      colors:
                          c,
                      icon:
                          Icons
                              .palette_outlined,
                      title:
                          'Aparência',
                      subtitle:
                          'Personaliza o visual do ABCtube.',
                    ),

                    const SizedBox(
                      height:
                          10,
                    ),

                    _SettingTile(
                      colors:
                          c,
                      icon: _dark
                          ? Icons
                              .dark_mode_outlined
                          : Icons
                              .light_mode_outlined,
                      title:
                          'Tema escuro',
                      subtitle:
                          _dark
                              ? 'Tema escuro ativo.'
                              : 'Tema claro ativo.',
                      value:
                          _dark,
                      onChanged:
                          _setTheme,
                    ),

                    const SizedBox(
                      height:
                          18,
                    ),

                    _SubsectionTitle(
                      colors:
                          c,
                      title:
                          'Estilo visual',
                    ),

                    const SizedBox(
                      height:
                          6,
                    ),

                    Text(
                      'Escolhe uma linguagem visual. As cores, os botões e os destaques do app adaptam-se ao estilo selecionado.',
                      style:
                          TextStyle(
                        color:
                            c.textMuted,
                        fontSize:
                            13,
                        height:
                            1.4,
                      ),
                    ),

                    const SizedBox(
                      height:
                          12,
                    ),

                    _StyleGrid(
                      colors:
                          c,
                      selectedStyle:
                          _style,
                      isDark:
                          _dark,
                      onChanged:
                          (
                        style,
                      ) {
                        setState(
                          () {
                            _style =
                                style;
                          },
                        );
                      },
                    ),

                    const SizedBox(
                      height:
                          24,
                    ),

                    _PreviewCard(
                      colors:
                          c,
                      style:
                          _style,
                    ),

                    const SizedBox(
                      height:
                          24,
                    ),

                    _ApplyButton(
                      colors:
                          c,
                      onTap:
                          _closeAndApply,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────

class _SettingsHeader
    extends StatelessWidget {
  final AppColors colors;
  final VoidCallback onBack;

  const _SettingsHeader({
    required this.colors,
    required this.onBack,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return SizedBox(
      height:
          58,
      child:
          Row(
        children: [
          const SizedBox(
            width:
                10,
          ),

          _HeaderIconButton(
            colors:
                colors,
            icon:
                Icons.arrow_back_rounded,
            onTap:
                onBack,
          ),

          const SizedBox(
            width:
                12,
          ),

          Expanded(
            child:
                Text(
              'Definições',
              style:
                  TextStyle(
                fontFamily:
                    'ComicSansMS',
                fontWeight:
                    FontWeight.w700,
                fontSize:
                    20,
                color:
                    colors.textMain,
              ),
            ),
          ),

          Padding(
            padding:
                const EdgeInsets.only(
              right:
                  14,
            ),
            child:
                Icon(
              Icons
                  .settings_outlined,
              size:
                  22,
              color:
                  colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HEADER BUTTON
// ─────────────────────────────────────────────

class _HeaderIconButton
    extends StatelessWidget {
  final AppColors colors;
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.colors,
    required this.icon,
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
              Icon(
            icon,
            size:
                21,
            color:
                colors.textMain,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SECTION HEADER
// ─────────────────────────────────────────────

class _SectionHeader
    extends StatelessWidget {
  final AppColors colors;
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.colors,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment
              .start,
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
            icon,
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
              Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Text(
                title,
                style:
                    TextStyle(
                  fontFamily:
                      'ComicSansMS',
                  fontWeight:
                      FontWeight.w700,
                  fontSize:
                      16,
                  color:
                      colors.textMain,
                ),
              ),

              const SizedBox(
                height:
                    3,
              ),

              Text(
                subtitle,
                style:
                    TextStyle(
                  fontSize:
                      12,
                  height:
                      1.3,
                  color:
                      colors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// SUBSECTION
// ─────────────────────────────────────────────

class _SubsectionTitle
    extends StatelessWidget {
  final AppColors colors;
  final String title;

  const _SubsectionTitle({
    required this.colors,
    required this.title,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Text(
      title,
      style:
          TextStyle(
        fontFamily:
            'ComicSansMS',
        fontWeight:
            FontWeight.w700,
        fontSize:
            15,
        color:
            colors.textMain,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SETTING TILE
// ─────────────────────────────────────────────

class _SettingTile
    extends StatelessWidget {
  final AppColors colors;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>
      onChanged;

  const _SettingTile({
    required this.colors,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return AnimatedContainer(
      duration:
          const Duration(
        milliseconds:
            180,
      ),
      padding:
          const EdgeInsets.symmetric(
        horizontal:
            14,
        vertical:
            13,
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
              value
                  ? colors.primary
                      .withOpacity(
                0.18,
              )
                  : Colors.transparent,
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
                  value
                      ? colors.primary
                          .withOpacity(
                      0.12,
                    )
                      : colors.bg,
              borderRadius:
                  BorderRadius.circular(
                11,
              ),
            ),
            child:
                Icon(
              icon,
              size:
                  21,
              color:
                  value
                      ? colors.primary
                      : colors.textMuted,
            ),
          ),

          const SizedBox(
            width:
                11,
          ),

          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  title,
                  style:
                      TextStyle(
                    fontWeight:
                        FontWeight.w700,
                    color:
                        colors.textMain,
                  ),
                ),

                const SizedBox(
                  height:
                      3,
                ),

                Text(
                  subtitle,
                  style:
                      TextStyle(
                    fontSize:
                        12,
                    height:
                        1.3,
                    color:
                        colors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            width:
                8,
          ),

          Switch.adaptive(
            value:
                value,
            activeTrackColor:
                colors.primary,
            onChanged:
                onChanged,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STYLE GRID
// ─────────────────────────────────────────────

class _StyleGrid
    extends StatelessWidget {
  final AppColors colors;
  final AppStyle selectedStyle;
  final bool isDark;
  final ValueChanged<AppStyle>
      onChanged;

  const _StyleGrid({
    required this.colors,
    required this.selectedStyle,
    required this.isDark,
    required this.onChanged,
  });

  static const List<
      _StyleInfo> _styles = [
    _StyleInfo(
      style:
          AppStyle.classic,
      title:
          'Clássico',
      icon:
          Icons
              .auto_awesome_outlined,
    ),
    _StyleInfo(
      style:
          AppStyle.material,
      title:
          'Material',
      icon:
          Icons
              .layers_outlined,
    ),
    _StyleInfo(
      style:
          AppStyle.playful,
      title:
          'Divertido',
      icon:
          Icons.bolt_outlined,
    ),
    _StyleInfo(
      style:
          AppStyle.ocean,
      title:
          'Oceano',
      icon:
          Icons
              .water_drop_outlined,
    ),
    _StyleInfo(
      style:
          AppStyle.sunset,
      title:
          'Pôr do sol',
      icon:
          Icons
              .wb_sunny_outlined,
    ),
    _StyleInfo(
      style:
          AppStyle.monochrome,
      title:
          'Monocromático',
      icon:
          Icons
              .contrast_outlined,
    ),
  ];

  @override
  Widget build(
    BuildContext context,
  ) {
    return GridView.builder(
      shrinkWrap:
          true,
      physics:
          const NeverScrollableScrollPhysics(),
      itemCount:
          _styles.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:
            2,
        crossAxisSpacing:
            10,
        mainAxisSpacing:
            10,
        childAspectRatio:
            1.35,
      ),
      itemBuilder:
          (
        context,
        index,
      ) {
        final item =
            _styles[index];

        final previewColors =
            AppColors(
          isDark,
          item.style,
        );

        final selected =
            selectedStyle ==
                item.style;

        return _StyleCard(
          colors:
              colors,
          previewColors:
              previewColors,
          title:
              item.title,
          icon:
              item.icon,
          selected:
              selected,
          onTap:
              () => onChanged(
            item.style,
          ),
        );
      },
    );
  }
}

class _StyleInfo {
  final AppStyle style;
  final String title;
  final IconData icon;

  const _StyleInfo({
    required this.style,
    required this.title,
    required this.icon,
  });
}

// ─────────────────────────────────────────────
// STYLE CARD
// ─────────────────────────────────────────────

class _StyleCard
    extends StatelessWidget {
  final AppColors colors;
  final AppColors previewColors;
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _StyleCard({
    required this.colors,
    required this.previewColors,
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final primary =
        previewColors.primary;

    return Material(
      color:
          Colors.transparent,
      child:
          InkWell(
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        onTap:
            onTap,
        child:
            AnimatedContainer(
          duration:
              const Duration(
            milliseconds:
                180,
          ),
          padding:
              const EdgeInsets.all(
            12,
          ),
          decoration:
              BoxDecoration(
            color:
                selected
                    ? primary
                        .withOpacity(
                    0.11,
                  )
                    : colors.bgCardNeutral,
            borderRadius:
                BorderRadius.circular(
              18,
            ),
            border:
                Border.all(
              color:
                  selected
                      ? primary
                      : colors.divider,
              width:
                  selected
                      ? 2
                      : 1,
            ),
          ),
          child:
              Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Row(
                children: [
                  Container(
                    width:
                        36,
                    height:
                        36,
                    decoration:
                        BoxDecoration(
                      color:
                          primary
                              .withOpacity(
                        0.13,
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        11,
                      ),
                    ),
                    child:
                        Icon(
                      icon,
                      size:
                          21,
                      color:
                          primary,
                    ),
                  ),

                  const Spacer(),

                  AnimatedSwitcher(
                    duration:
                        const Duration(
                      milliseconds:
                          180,
                    ),
                    child:
                        selected
                            ? Icon(
                                Icons
                                    .check_circle_rounded,
                                key:
                                    const ValueKey(
                                  'selected',
                                ),
                                size:
                                    20,
                                color:
                                    primary,
                              )
                            : const SizedBox(
                                key:
                                    ValueKey(
                                  'unselected',
                                ),
                                width:
                                    20,
                                height:
                                    20,
                              ),
                  ),
                ],
              ),

              const Spacer(),

              Text(
                title,
                style:
                    TextStyle(
                  fontFamily:
                      'ComicSansMS',
                  fontWeight:
                      FontWeight.w700,
                  color:
                      colors.textMain,
                ),
              ),

              const SizedBox(
                height:
                    8,
              ),

              Row(
                children: [
                  Expanded(
                    child:
                        Container(
                      height:
                          7,
                      decoration:
                          BoxDecoration(
                        color:
                            primary,
                        borderRadius:
                            BorderRadius.circular(
                          6,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    width:
                        5,
                  ),

                  Container(
                    width:
                        28,
                    height:
                        7,
                    decoration:
                        BoxDecoration(
                      color:
                          previewColors.c2Fg,
                      borderRadius:
                          BorderRadius.circular(
                        6,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PREVIEW
// ─────────────────────────────────────────────

class _PreviewCard
    extends StatelessWidget {
  final AppColors colors;
  final AppStyle style;

  const _PreviewCard({
    required this.colors,
    required this.style,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final preview =
        AppColors(
      colors.isDark,
      style,
    );

    return Container(
      padding:
          const EdgeInsets.all(
        16,
      ),
      decoration:
          BoxDecoration(
        color:
            colors.bgCardNeutral,
        borderRadius:
            BorderRadius.circular(
          20,
        ),
        border:
            Border.all(
          color:
              colors.divider,
        ),
      ),
      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          Row(
            children: [
              Icon(
                Icons
                    .preview_outlined,
                size:
                    20,
                color:
                    colors.primary,
              ),
              const SizedBox(
                width:
                    8,
              ),
              Text(
                'Pré-visualização',
                style:
                    TextStyle(
                  fontFamily:
                      'ComicSansMS',
                  fontWeight:
                      FontWeight.w700,
                  color:
                      colors.textMain,
                ),
              ),
            ],
          ),

          const SizedBox(
            height:
                14,
          ),

          Row(
            children: [
              Expanded(
                child:
                    Container(
                  height:
                      46,
                  decoration:
                      BoxDecoration(
                    color:
                        preview.primary,
                    borderRadius:
                        BorderRadius.circular(
                      13,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            preview.primaryShadow,
                        offset:
                            const Offset(
                          0,
                          3,
                        ),
                      ),
                    ],
                  ),
                  child:
                      const Center(
                    child:
                        Text(
                      'Principal',
                      style:
                          TextStyle(
                        color:
                            Colors.white,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(
                width:
                    10,
              ),

              Expanded(
                child:
                    Container(
                  height:
                      46,
                  decoration:
                      BoxDecoration(
                    color:
                        preview.c2Bg,
                    borderRadius:
                        BorderRadius.circular(
                      13,
                    ),
                  ),
                  child:
                      Center(
                    child:
                        Text(
                      'Secundário',
                      style:
                          TextStyle(
                        color:
                            preview.c2Fg,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// APPLY
// ─────────────────────────────────────────────

class _ApplyButton
    extends StatelessWidget {
  final AppColors colors;
  final VoidCallback onTap;

  const _ApplyButton({
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
          16,
        ),
        onTap:
            onTap,
        child:
            Ink(
          width:
              double.infinity,
          padding:
              const EdgeInsets.symmetric(
            vertical:
                15,
          ),
          decoration:
              BoxDecoration(
            color:
                colors.primary,
            borderRadius:
                BorderRadius.circular(
              16,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    colors.primaryShadow,
                offset:
                    const Offset(
                  0,
                  4,
                ),
              ),
            ],
          ),
          child:
              const Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .center,
            children: [
              Icon(
                Icons
                    .check_rounded,
                color:
                    Colors.white,
                size:
                    20,
              ),
              SizedBox(
                width:
                    7,
              ),
              Text(
                'APLICAR DEFINIÇÕES',
                style:
                    TextStyle(
                  color:
                      Colors.white,
                  fontWeight:
                      FontWeight.w800,
                  letterSpacing:
                      0.7,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}