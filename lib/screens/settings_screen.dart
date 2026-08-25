// settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../main.dart' show AppColors, SoundManager;
import 'home_screen.dart' show ThemePrefs;

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
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _isDark;
  late bool _soundEnabled;
  late bool _musicEnabled;
  late bool _voiceEnabled;

  AppColors get colors => AppColors(_isDark);

  @override
  void initState() {
    super.initState();
    _isDark = widget.isDark;
    _soundEnabled = widget.soundEnabled;
    _musicEnabled = widget.musicEnabled;
    _voiceEnabled = widget.voiceEnabled;
  }

  void _saveAndClose() {
    Navigator.of(context).pop(
      AppSettingsResult(
        isDark: _isDark,
        soundEnabled: _soundEnabled,
        musicEnabled: _musicEnabled,
        voiceEnabled: _voiceEnabled,
      ),
    );
  }

  void _setSound(bool value) {
    setState(() => _soundEnabled = value);
    SoundManager.instance.muted = !value;
  }

  void _setMusic(bool value) {
    setState(() => _musicEnabled = value);
  }

  void _setVoice(bool value) {
    setState(() => _voiceEnabled = value);
    SoundManager.instance.voiceEnabled = value;
  }

  void _setTheme(bool value) {
    setState(() => _isDark = value);
    // Persiste de imediato, para o tema sobreviver mesmo que
    // o utilizador saia sem "guardar" via pop.
    ThemePrefs.setIsDark(value);
  }

  @override
  Widget build(BuildContext context) {
    final c = colors;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            Row(
              children: [
                _PressableCircleButton(
                  colors: c,
                  onTap: _saveAndClose,
                  child: SvgPicture.asset(
                    'assets/icons/back.svg',
                    width: 18,
                    height: 18,
                    colorFilter: ColorFilter.mode(c.textMain, BlendMode.srcIn),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Definições',
                  style: TextStyle(
                    fontFamily: 'ComicSansMS',
                    fontWeight: FontWeight.w700,
                    fontSize: 26,
                    color: c.textMain,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 54),
              child: Text(
                'Ajusta o app do teu jeitinho',
                style: TextStyle(
                  fontSize: 14,
                  color: c.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 28),
            _FunSection(
              colors: c,
              title: 'Som',
              icon: 'assets/icons/speaker-icon.svg',
              accent: AppColors.green,
              children: [
                _FunTile(
                  colors: c,
                  icon: 'assets/icons/speaker-icon.svg',
                  title: 'Sons de clique',
                  subtitle: 'Sons ao tocar nos elementos do ecrã.',
                  accent: AppColors.green,
                  value: _soundEnabled,
                  onChanged: _setSound,
                ),
                const SizedBox(height: 12),
                _FunTile(
                  colors: c,
                  icon: 'assets/icons/music_on.svg',
                  title: 'Música',
                  subtitle: 'Melodias nos jogos e conteúdos.',
                  accent: AppColors.green,
                  value: _musicEnabled,
                  onChanged: _setMusic,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _FunSection(
              colors: c,
              title: 'Aparência',
              icon: _isDark
                  ? 'assets/icons/moon-icon.svg'
                  : 'assets/icons/sun-icon.svg',
              accent: AppColors.orange,
              children: [
                _FunTile(
                  colors: c,
                  icon: _isDark
                      ? 'assets/icons/moon-icon.svg'
                      : 'assets/icons/sun-icon.svg',
                  title: 'Tema escuro',
                  subtitle: _isDark
                      ? 'Modo escuro ativado.'
                      : 'Modo claro ativado.',
                  accent: AppColors.orange,
                  value: _isDark,
                  onChanged: _setTheme,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _FunSection(
              colors: c,
              title: 'Acessibilidade',
              icon: 'assets/icons/speaker-icon.svg',
              accent: AppColors.red,
              children: [
                _FunTile(
                  colors: c,
                  icon: 'assets/icons/speaker-icon.svg',
                  title: 'Leitura por voz',
                  subtitle: 'Voz automática quando não há áudio.',
                  accent: AppColors.red,
                  value: _voiceEnabled,
                  onChanged: _setVoice,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PressableCircleButton extends StatefulWidget {
  final AppColors colors;
  final Widget child;
  final VoidCallback onTap;

  const _PressableCircleButton({
    required this.colors,
    required this.child,
    required this.onTap,
  });

  @override
  State<_PressableCircleButton> createState() =>
      _PressableCircleButtonState();
}

class _PressableCircleButtonState extends State<_PressableCircleButton> {
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
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: widget.colors.bgCardNeutral,
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

class _FunSection extends StatelessWidget {
  final AppColors colors;
  final String title;
  final String icon;
  final Color accent;
  final List<Widget> children;

  const _FunSection({
    required this.colors,
    required this.title,
    required this.icon,
    required this.accent,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  icon,
                  width: 15,
                  height: 15,
                  colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'ComicSansMS',
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: colors.textMain,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

class _FunTile extends StatelessWidget {
  final AppColors colors;
  final String icon;
  final String title;
  final String subtitle;
  final Color accent;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _FunTile({
    required this.colors,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: value ? accent.withOpacity(0.12) : colors.bgCardNeutral,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: value ? accent.withOpacity(0.5) : colors.divider,
            width: value ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: value ? accent : colors.bg,
                borderRadius: BorderRadius.circular(14),
                boxShadow: value
                    ? [
                        BoxShadow(
                          color: accent.withOpacity(0.35),
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: SvgPicture.asset(
                  icon,
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    value ? Colors.white : colors.textMuted,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'ComicSansMS',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: colors.textMain,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _CustomSwitch(
              colors: colors,
              accent: accent,
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomSwitch extends StatelessWidget {
  final AppColors colors;
  final Color accent;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CustomSwitch({
    required this.colors,
    required this.accent,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 30,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? accent : colors.divider,
          borderRadius: BorderRadius.circular(18),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
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
          ),
        ),
      ),
    );
  }
}