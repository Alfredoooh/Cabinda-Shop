import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../main.dart'
    show AppColors, AppSettings, AppThemeMode, AppVisualStyle, SoundManager;

class SettingsScreen extends StatefulWidget {
  final AppColors colors;

  const SettingsScreen({
    super.key,
    required this.colors,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AppSettings _settings = AppSettings.instance;

  @override
  void initState() {
    super.initState();
    _settings.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  AppColors get colors => AppColors(
        _settings.isDark,
        _settings.visualStyle,
      );

  Future<void> _setClickSounds(bool value) async {
    await _settings.setClickSounds(value);
  }

  Future<void> _setMusic(bool value) async {
    await _settings.setMusic(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/back.svg',
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(
                colors.textMain,
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
            color: colors.textMain,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
        children: [
          _SettingsSectionTitle(
            colors: colors,
            title: 'Som',
          ),
          const SizedBox(height: 8),
          _SettingsCard(
            colors: colors,
            children: [
              _SettingsTile(
                colors: colors,
                icon: Icons.music_note_rounded,
                title: 'Música',
                subtitle: 'Ativar ou desativar a música dos jogos',
                trailing: _SettingsSwitch(
                  value: _settings.musicEnabled,
                  colors: colors,
                  onChanged: _setMusic,
                ),
              ),
              Divider(
                height: 1,
                color: colors.divider,
              ),
              _SettingsTile(
                colors: colors,
                icon: Icons.touch_app_rounded,
                title: 'Sons de clique',
                subtitle: 'Sons ao tocar em botões e cartas',
                trailing: _SettingsSwitch(
                  value: _settings.clickSoundsEnabled,
                  colors: colors,
                  onChanged: _setClickSounds,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SettingsSectionTitle(
            colors: colors,
            title: 'Tema',
          ),
          const SizedBox(height: 8),
          _SettingsCard(
            colors: colors,
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    _ThemeChoice(
                      colors: colors,
                      label: 'Claro',
                      icon: Icons.light_mode_rounded,
                      active:
                          _settings.themeMode == AppThemeMode.light,
                      onTap: () => _settings.setTheme(
                        AppThemeMode.light,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _ThemeChoice(
                      colors: colors,
                      label: 'Escuro',
                      icon: Icons.dark_mode_rounded,
                      active:
                          _settings.themeMode == AppThemeMode.dark,
                      onTap: () => _settings.setTheme(
                        AppThemeMode.dark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SettingsSectionTitle(
            colors: colors,
            title: 'Estilo do app',
          ),
          const SizedBox(height: 5),
          Text(
            'Escolhe como queres que o Leya apareça.',
            style: TextStyle(
              fontSize: 13,
              color: colors.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          _StyleCard(
            colors: colors,
            title: 'Divertido',
            description: 'Cores vivas, cartões grandes e uma aparência de jogo.',
            icon: Icons.celebration_rounded,
            style: AppVisualStyle.playful,
            selected: _settings.visualStyle == AppVisualStyle.playful,
            onTap: () => _settings.setStyle(
              AppVisualStyle.playful,
            ),
          ),
          const SizedBox(height: 10),
          _StyleCard(
            colors: colors,
            title: 'Limpo',
            description: 'Visual simples, moderno e com menos elementos.',
            icon: Icons.auto_awesome_rounded,
            style: AppVisualStyle.clean,
            selected: _settings.visualStyle == AppVisualStyle.clean,
            onTap: () => _settings.setStyle(
              AppVisualStyle.clean,
            ),
          ),
          const SizedBox(height: 10),
          _StyleCard(
            colors: colors,
            title: 'Calmo',
            description: 'Tons suaves para uma experiência mais tranquila.',
            icon: Icons.spa_rounded,
            style: AppVisualStyle.calm,
            selected: _settings.visualStyle == AppVisualStyle.calm,
            onTap: () => _settings.setStyle(
              AppVisualStyle.calm,
            ),
          ),
          const SizedBox(height: 10),
          _StyleCard(
            colors: colors,
            title: 'Alto contraste',
            description: 'Mais contraste para facilitar a leitura.',
            icon: Icons.contrast_rounded,
            style: AppVisualStyle.contrast,
            selected: _settings.visualStyle == AppVisualStyle.contrast,
            onTap: () => _settings.setStyle(
              AppVisualStyle.contrast,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSectionTitle extends StatelessWidget {
  final AppColors colors;
  final String title;

  const _SettingsSectionTitle({
    required this.colors,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'ComicSansMS',
        fontWeight: FontWeight.w700,
        fontSize: 16,
        color: colors.textMain,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final AppColors colors;
  final List<Widget> children;

  const _SettingsCard({
    required this.colors,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.bgCardNeutral,
        borderRadius: BorderRadius.circular(colors.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: colors.neutralShadow,
            offset: const Offset(0, 3),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final AppColors colors;
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SettingsTile({
    required this.colors,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 13, 10, 13),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.bg,
              borderRadius: BorderRadius.circular(colors.radiusSmall),
            ),
            child: Icon(
              icon,
              size: 21,
              color: colors.textMain,
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
                    fontSize: 14,
                    color: colors.textMain,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  final bool value;
  final AppColors colors;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitch({
    required this.value,
    required this.colors,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 52,
        height: 30,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value
              ? AppColors.green
              : colors.bg,
          borderRadius: BorderRadius.circular(18),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          alignment: value
              ? Alignment.centerRight
              : Alignment.centerLeft,
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

class _ThemeChoice extends StatelessWidget {
  final AppColors colors;
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _ThemeChoice({
    required this.colors,
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            color: active
                ? AppColors.green
                : colors.bg,
            borderRadius: BorderRadius.circular(colors.radiusSmall),
            boxShadow: active
                ? const [
                    BoxShadow(
                      color: AppColors.greenShadow,
                      offset: Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: active
                    ? Colors.white
                    : colors.textMuted,
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'ComicSansMS',
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: active
                      ? Colors.white
                      : colors.textMain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StyleCard extends StatelessWidget {
  final AppColors colors;
  final String title;
  final String description;
  final IconData icon;
  final AppVisualStyle style;
  final bool selected;
  final VoidCallback onTap;

  const _StyleCard({
    required this.colors,
    required this.title,
    required this.description,
    required this.icon,
    required this.style,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.bgCardNeutral,
          borderRadius: BorderRadius.circular(colors.radiusLarge),
          border: Border.all(
            color: selected
                ? AppColors.green
                : colors.divider,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? AppColors.greenShadow.withOpacity(0.25)
                  : colors.neutralShadow,
              offset: const Offset(0, 3),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          children: [
            _StylePreview(
              appColors: AppColors(
                colors.isDark,
                style,
              ),
              icon: icon,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
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
                      if (selected)
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 20,
                          color: AppColors.green,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.25,
                      color: colors.textMuted,
                    ),
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

class _StylePreview extends StatelessWidget {
  final AppColors appColors;
  final IconData icon;

  const _StylePreview({
    required this.appColors,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 66,
      height: 66,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: appColors.bg,
        borderRadius: BorderRadius.circular(appColors.radiusLarge),
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: appColors.c0Bg,
                      borderRadius:
                          BorderRadius.circular(appColors.radiusSmall),
                    ),
                    child: Icon(
                      icon,
                      size: 14,
                      color: appColors.c0Fg,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: appColors.c2Bg,
                      borderRadius:
                          BorderRadius.circular(appColors.radiusSmall),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: appColors.c1Fg,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
