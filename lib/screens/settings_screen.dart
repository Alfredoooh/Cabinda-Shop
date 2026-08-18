import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../main.dart' show AppColors, SoundManager;

class AppSettingsResult {
  final bool isDark;
  final bool soundEnabled;
  final bool musicEnabled;
  final bool voiceEnabled;

  const AppSettingsResult({
    required this.isDark,
    required this.soundEnabled,
    required this.musicEnabled,
    required this.voiceEnabled,
  });
}

class SettingsScreen extends StatefulWidget {
  final AppColors colors;
  final bool isDark;
  final bool soundEnabled;
  final bool musicEnabled;
  final bool voiceEnabled;

  const SettingsScreen({
    super.key,
    required this.colors,
    required this.isDark,
    required this.soundEnabled,
    required this.musicEnabled,
    required this.voiceEnabled,
  });

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState
    extends State<SettingsScreen> {
  late bool _isDark;
  late bool _soundEnabled;
  late bool _musicEnabled;
  late bool _voiceEnabled;

  late AppColors _colors;

  @override
  void initState() {
    super.initState();

    _isDark =
        widget.isDark;

    _soundEnabled =
        widget.soundEnabled;

    _musicEnabled =
        widget.musicEnabled;

    _voiceEnabled =
        widget.voiceEnabled;

    _colors =
        AppColors(
      _isDark,
    );

    _updateSystemBars();
  }

  void _updateSystemBars() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor:
            Colors.transparent,
        systemNavigationBarColor:
            Colors.transparent,
        statusBarBrightness:
            _isDark
                ? Brightness.dark
                : Brightness.light,
        statusBarIconBrightness:
            _isDark
                ? Brightness.light
                : Brightness.dark,
        systemNavigationBarIconBrightness:
            _isDark
                ? Brightness.light
                : Brightness.dark,
      ),
    );
  }

  void _updateColors() {
    _colors =
        AppColors(
      _isDark,
    );
  }

  void _toggleSound(
    bool value,
  ) {
    setState(() {
      _soundEnabled =
          value;
    });

    SoundManager
        .instance
        .muted =
        !_soundEnabled;

    SoundManager
        .instance
        .clickMuted =
        !_soundEnabled;

    if (_soundEnabled) {
      SoundManager
          .instance
          .playClick();
    }
  }

  void _toggleMusic(
    bool value,
  ) {
    setState(() {
      _musicEnabled =
          value;
    });

    SoundManager
        .instance
        .musicMuted =
        !_musicEnabled;
  }

  void _toggleVoice(
    bool value,
  ) {
    setState(() {
      _voiceEnabled =
          value;
    });

    // O fallback de voz usa SoundManager.
    // Quando desativado, impedimos o TTS.
    //
    // O estado fica no Settings/Home e os jogos
    // devem verificar voiceEnabled antes de
    // chamar o fallback.
  }

  void _toggleTheme(
    bool value,
  ) {
    setState(() {
      _isDark =
          value;

      _updateColors();
    });

    _updateSystemBars();
  }

  void _close() {
    Navigator.of(
      context,
    ).pop(
      AppSettingsResult(
        isDark:
            _isDark,
        soundEnabled:
            _soundEnabled,
        musicEnabled:
            _musicEnabled,
        voiceEnabled:
            _voiceEnabled,
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final colors =
        _colors;

    return AnnotatedRegion<
        SystemUiOverlayStyle>(
      value:
          SystemUiOverlayStyle(
        statusBarColor:
            Colors.transparent,
        systemNavigationBarColor:
            Colors.transparent,
        statusBarBrightness:
            _isDark
                ? Brightness.dark
                : Brightness.light,
        statusBarIconBrightness:
            _isDark
                ? Brightness.light
                : Brightness.dark,
        systemNavigationBarIconBrightness:
            _isDark
                ? Brightness.light
                : Brightness.dark,
      ),
      child:
          Scaffold(
        backgroundColor:
            colors.bg,
        body:
            SafeArea(
          bottom:
              false,
          child:
              Column(
            children: [
              _buildHeader(
                colors,
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
                    32,
                  ),
                  children: [
                    _buildSection(
                      colors,
                      title:
                          'Som',
                      children: [
                        _buildSetting(
                          colors:
                              colors,
                          title:
                              'Sons de clique',
                          subtitle:
                              'Sons usados ao tocar nos elementos do app.',
                          icon:
                              'assets/icons/speaker-icon.svg',
                          enabled:
                              _soundEnabled,
                          onChanged:
                              _toggleSound,
                        ),
                        const SizedBox(
                          height:
                              10,
                        ),
                        _buildSetting(
                          colors:
                              colors,
                          title:
                              'Música',
                          subtitle:
                              'Música durante jogos e conteúdos.',
                          icon:
                              'assets/icons/music_on.svg',
                          enabled:
                              _musicEnabled,
                          onChanged:
                              _toggleMusic,
                        ),
                      ],
                    ),

                    const SizedBox(
                      height:
                          24,
                    ),

                    _buildSection(
                      colors,
                      title:
                          'Aparência',
                      children: [
                        _buildSetting(
                          colors:
                              colors,
                          title:
                              'Tema escuro',
                          subtitle:
                              _isDark
                                  ? 'Tema escuro ativo.'
                                  : 'Tema claro ativo.',
                          icon:
                              'assets/icons/settings.svg',
                          enabled:
                              _isDark,
                          onChanged:
                              _toggleTheme,
                        ),
                      ],
                    ),

                    const SizedBox(
                      height:
                          24,
                    ),

                    _buildSection(
                      colors,
                      title:
                          'Acessibilidade',
                      children: [
                        _buildSetting(
                          colors:
                              colors,
                          title:
                              'Leitura por voz',
                          subtitle:
                              'Usa voz de fallback quando o áudio não estiver disponível.',
                          icon:
                              'assets/icons/speaker-icon.svg',
                          enabled:
                              _voiceEnabled,
                          onChanged:
                              _toggleVoice,
                        ),
                      ],
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

  Widget _buildHeader(
    AppColors colors,
  ) {
    return SizedBox(
      height:
          62,
      child:
          Row(
        children: [
          const SizedBox(
            width:
                10,
          ),

          _IconButton(
            colors:
                colors,
            asset:
                'assets/icons/back.svg',
            onTap:
                _close,
          ),

          const SizedBox(
            width:
                12,
          ),

          Text(
            'Definições',
            style:
                TextStyle(
              fontFamily:
                  'ComicSansMS',
              fontSize:
                  21,
              fontWeight:
                  FontWeight.w700,
              color:
                  colors.textMain,
            ),
          ),

          const Spacer(),

          Padding(
            padding:
                const EdgeInsets.only(
              right:
                  14,
            ),
            child:
                _LocalIcon(
              asset:
                  'assets/icons/settings.svg',
              size:
                  21,
              color:
                  colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    AppColors colors, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(
            left:
                4,
            bottom:
                10,
          ),
          child:
              Text(
            title,
            style:
                TextStyle(
              fontFamily:
                  'ComicSansMS',
              fontSize:
                  15,
              fontWeight:
                  FontWeight.w700,
              color:
                  colors.textMain,
            ),
          ),
        ),

        ...children,
      ],
    );
  }

  Widget _buildSetting({
    required AppColors colors,
    required String title,
    required String subtitle,
    required String icon,
    required bool enabled,
    required ValueChanged<bool>
        onChanged,
  }) {
    return Container(
      width:
          double.infinity,
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
              colors.divider,
        ),
      ),
      child:
          Row(
        children: [
          Container(
            width:
                40,
            height:
                40,
            decoration:
                BoxDecoration(
              color:
                  enabled
                      ? colors.primary
                          .withOpacity(
                      0.12,
                    )
                      : colors.bg,
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
            child:
                Center(
              child:
                  _LocalIcon(
                asset:
                    icon,
                size:
                    21,
                color:
                    enabled
                        ? colors.primary
                        : colors.textMuted,
              ),
            ),
          ),

          const SizedBox(
            width:
                12,
          ),

          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
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
                        15,
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
                  maxLines:
                      2,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      TextStyle(
                    fontSize:
                        12,
                    height:
                        1.35,
                    color:
                        colors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            width:
                10,
          ),

          _LocalSwitch(
            colors:
                colors,
            value:
                enabled,
            onChanged:
                onChanged,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// LOCAL ICON
// ══════════════════════════════════════════════════════════════

class _LocalIcon
    extends StatelessWidget {
  final String asset;
  final double size;
  final Color color;

  const _LocalIcon({
    required this.asset,
    required this.size,
    required this.color,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return SvgPicture.asset(
      asset,
      width:
          size,
      height:
          size,
      fit:
          BoxFit.contain,
      colorFilter:
          ColorFilter.mode(
        color,
        BlendMode.srcIn,
      ),
      errorBuilder:
          (
        context,
        error,
        stackTrace,
      ) {
        return const SizedBox(
          width:
              1,
          height:
              1,
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════
// ICON BUTTON
// ══════════════════════════════════════════════════════════════

class _IconButton
    extends StatefulWidget {
  final AppColors colors;
  final String asset;
  final VoidCallback onTap;

  const _IconButton({
    required this.colors,
    required this.asset,
    required this.onTap,
  });

  @override
  State<_IconButton>
      createState() =>
          _IconButtonState();
}

class _IconButtonState
    extends State<_IconButton> {
  bool _pressed =
      false;

  @override
  Widget build(
    BuildContext context,
  ) {
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
              90,
        ),
        width:
            42,
        height:
            42,
        transform:
            Matrix4.identity()
              ..translate(
                0.0,
                _pressed
                    ? 2.0
                    : 0.0,
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
                  widget.colors
                      .neutralShadow,
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
            Center(
          child:
              _LocalIcon(
            asset:
                widget.asset,
            size:
                20,
            color:
                widget.colors.textMain,
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// CUSTOM SWITCH
// ══════════════════════════════════════════════════════════════

class _LocalSwitch
    extends StatelessWidget {
  final AppColors colors;
  final bool value;
  final ValueChanged<bool>
      onChanged;

  const _LocalSwitch({
    required this.colors,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
      behavior:
          HitTestBehavior.opaque,
      onTap:
          () => onChanged(
        !value,
      ),
      child:
          AnimatedContainer(
        duration:
            const Duration(
          milliseconds:
              200,
        ),
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
              value
                  ? colors.primary
                  : colors.divider,
          borderRadius:
              BorderRadius.circular(
            18,
          ),
        ),
        child:
            AnimatedAlign(
          duration:
              const Duration(
            milliseconds:
                220,
          ),
          curve:
              Curves.easeOut,
          alignment:
              value
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
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
          ),
        ),
      ),
    );
  }
}