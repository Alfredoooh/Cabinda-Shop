import 'package:flutter/material.dart';
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

  void _setVoice(bool value) {
    setState(() => _voiceEnabled = value);
    SoundManager.instance.voiceEnabled = value;
  }

  void _setTheme(bool value) {
    setState(() => _isDark = value);
    _updateSystemBars();
  }

  void _updateSystemBars() {
    // A HomeScreen faz a sincronização definitiva quando esta página fecha.
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
              colorFilter: ColorFilter.mode(
                c.textMain,
                BlendMode.srcIn,
              ),
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
          _Section(
            colors: c,
            title: 'Som',
            children: [
              _SettingTile(
                colors: c,
                icon: 'assets/icons/speaker-icon.svg',
                title: 'Sons de clique',
                subtitle: 'Sons ao tocar nos elementos do app.',
                value: _soundEnabled,
                onChanged: _setSound,
              ),
              const SizedBox(height: 10),
              _SettingTile(
                colors: c,
                icon: 'assets/icons/music_on.svg',
                title: 'Música',
                subtitle: 'Música dos jogos e conteúdos.',
                value: _musicEnabled,
                onChanged: (value) {
                  setState(() => _musicEnabled = value);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _Section(
            colors: c,
            title: 'Aparência',
            children: [
              _SettingTile(
                colors: c,
                icon: _isDark
                    ? 'assets/icons/moon-icon.svg'
                    : 'assets/icons/sun-icon.svg',
                title: 'Tema escuro',
                subtitle: _isDark
                    ? 'Tema escuro ativo.'
                    : 'Tema claro ativo.',
                value: _isDark,
                onChanged: _setTheme,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _Section(
            colors: c,
            title: 'Acessibilidade',
            children: [
              _SettingTile(
                colors: c,
                icon: 'assets/icons/speaker-icon.svg',
                title: 'Leitura por voz',
                subtitle:
                    'Usar voz automática quando um áudio não existir.',
                value: _voiceEnabled,
                onChanged: _setVoice,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final AppColors colors;
  final String title;
  final List<Widget> children;

  const _Section({
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
          padding: const EdgeInsets.only(left: 4, bottom: 9),
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'ComicSansMS',
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: colors.textMain,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  final AppColors colors;
  final String icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingTile({
    required this.colors,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: colors.bgCardNeutral,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.divider,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: value
                  ? colors.primary.withOpacity(0.12)
                  : colors.bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: SvgPicture.asset(
                icon,
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  value ? colors.primary : colors.textMuted,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
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
            value: value,
            onChanged: onChanged,
          ),
        ],
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
        width: 52,
        height: 30,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? colors.primary : colors.divider,
          borderRadius: BorderRadius.circular(18),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          alignment:
              value ? Alignment.centerRight : Alignment.centerLeft,
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
