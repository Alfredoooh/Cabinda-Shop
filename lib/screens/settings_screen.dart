// settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../main.dart' show AppColors, SoundManager, AppPrefs, applySystemUi;
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
    AppPrefs.setSoundEnabled(value);
  }

  void _setMusic(bool value) {
    setState(() => _musicEnabled = value);
    AppPrefs.setMusicEnabled(value);
  }

  void _setVoice(bool value) {
    setState(() => _voiceEnabled = value);
    AppPrefs.setVoiceEnabled(value);
  }

  void _setTheme(bool value) {
    setState(() => _isDark = value);
    applySystemUi(value);
    ThemePrefs.setIsDark(value);
  }

  @override
  Widget build(BuildContext context) {
    final c = colors;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leading: GestureDetector(
          onTap: _saveAndClose,
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/back.svg',
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(c.textMain, BlendMode.srcIn),
            ),
          ),
        ),
        title: Text(
          'Definições',
          style: TextStyle(
            fontFamily: 'ComicSansMS',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: c.textMain,
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
        children: [
          _SettingsGroup(
            colors: c,
            title: 'Som',
            children: [
              _SettingRow(
                colors: c,
                icon: 'assets/icons/speaker-icon.svg',
                title: 'Sons de clique',
                value: _soundEnabled,
                onChanged: _setSound,
                isFirst: true,
              ),
              _SettingRow(
                colors: c,
                icon: 'assets/icons/music_on.svg',
                title: 'Música',
                value: _musicEnabled,
                onChanged: _setMusic,
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: 22),
          _SettingsGroup(
            colors: c,
            title: 'Aparência',
            children: [
              _SettingRow(
                colors: c,
                icon: _isDark
                    ? 'assets/icons/moon-icon.svg'
                    : 'assets/icons/sun-icon.svg',
                title: 'Tema escuro',
                value: _isDark,
                onChanged: _setTheme,
                isFirst: true,
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: 22),
          _SettingsGroup(
            colors: c,
            title: 'Acessibilidade',
            children: [
              _SettingRow(
                colors: c,
                icon: 'assets/icons/speaker-icon.svg',
                title: 'Leitura por voz',
                value: _voiceEnabled,
                onChanged: _setVoice,
                isFirst: true,
                isLast: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final AppColors colors;
  final String title;
  final List<Widget> children;

  const _SettingsGroup({
    required this.colors,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: colors.textMuted,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.bgCardNeutral,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  final AppColors colors;
  final String icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isFirst;
  final bool isLast;

  const _SettingRow({
    required this.colors,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(bottom: BorderSide(color: colors.divider)),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(colors.textMuted, BlendMode.srcIn),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colors.textMain,
                ),
              ),
            ),
            _CustomSwitch(colors: colors, value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

class _CustomSwitch extends StatelessWidget {
  final AppColors colors;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CustomSwitch({
    required this.colors,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 50,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? AppColors.green : colors.divider,
          borderRadius: BorderRadius.circular(16),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: colors.switchThumb,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colors.switchThumbShadow,
                  offset: const Offset(0, 1),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}