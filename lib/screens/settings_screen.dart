import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart'
    show AppColors, AppDesign, AppIcon, AppStyle, SoundManager;

class AppSettingsResult {
  final bool isDark;
  final AppStyle style;
  final AppDesign design;
  final bool soundEnabled;
  final bool musicEnabled;

  const AppSettingsResult({
    required this.isDark,
    required this.style,
    required this.design,
    required this.soundEnabled,
    required this.musicEnabled,
  });
}

class SettingsScreen extends StatefulWidget {
  final AppColors colors;
  final bool isDark;
  final AppStyle style;
  final AppDesign design;
  final bool soundEnabled;
  final bool musicEnabled;

  const SettingsScreen({
    super.key,
    required this.colors,
    required this.isDark,
    required this.style,
    required this.design,
    required this.soundEnabled,
    required this.musicEnabled,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _dark;
  late AppStyle _style;
  late AppDesign _design;
  late bool _sound;
  late bool _music;

  AppColors get colors => AppColors(_dark, _style, _design);

  @override
  void initState() {
    super.initState();
    _dark = widget.isDark;
    _style = widget.style;
    _design = widget.design;
    _sound = widget.soundEnabled;
    _music = widget.musicEnabled;

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _finish() {
    SoundManager.instance
      ..muted = !_sound
      ..clickMuted = !_sound
      ..musicMuted = !_music;

    Navigator.of(context).pop(
      AppSettingsResult(
        isDark: _dark,
        style: _style,
        design: _design,
        soundEnabled: _sound,
        musicEnabled: _music,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final isMaterial = _design == AppDesign.material;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        statusBarIconBrightness:
            _dark ? Brightness.light : Brightness.dark,
        statusBarBrightness:
            _dark ? Brightness.dark : Brightness.light,
        systemNavigationBarIconBrightness:
            _dark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: c.bg,
        body: SafeArea(
          child: Column(
            children: [
              _SettingsHeader(
                colors: c,
                onBack: _finish,
              ),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
                  children: [
                    _SettingsSection(
                      colors: c,
                      icon: Icons.volume_up_outlined,
                      title: 'Som e reprodução',
                      description:
                          'Controla os sons de interação e a música do ABCtube.',
                    ),
                    const SizedBox(height: 10),
                    _SettingTile(
                      colors: c,
                      icon: Icons.touch_app_outlined,
                      title: 'Sons de clique',
                      description: 'Feedback sonoro dos botões.',
                      value: _sound,
                      material: isMaterial,
                      onChanged: (value) {
                        setState(() => _sound = value);
                        SoundManager.instance
                          ..muted = !value
                          ..clickMuted = !value;
                      },
                    ),
                    const SizedBox(height: 10),
                    _SettingTile(
                      colors: c,
                      icon: Icons.music_note_outlined,
                      title: 'Música',
                      description: 'Música ambiente dos jogos.',
                      value: _music,
                      material: isMaterial,
                      onChanged: (value) {
                        setState(() => _music = value);
                        SoundManager.instance.musicMuted = !value;
                      },
                    ),
                    const SizedBox(height: 26),
                    _SettingsSection(
                      colors: c,
                      icon: _dark
                          ? Icons.dark_mode_outlined
                          : Icons.light_mode_outlined,
                      title: 'Tema',
                      description:
                          'Escolhe entre a aparência clara e escura.',
                    ),
                    const SizedBox(height: 10),
                    _SettingTile(
                      colors: c,
                      icon: _dark
                          ? Icons.dark_mode_outlined
                          : Icons.light_mode_outlined,
                      title: 'Tema escuro',
                      description:
                          _dark ? 'Tema escuro ativo.' : 'Tema claro ativo.',
                      value: _dark,
                      material: isMaterial,
                      onChanged: (value) => setState(() => _dark = value),
                    ),
                    const SizedBox(height: 26),
                    _SettingsSection(
                      colors: c,
                      icon: Icons.tune_outlined,
                      title: 'Interface',
                      description:
                          'Escolhe entre os componentes customizados e Material.',
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _ModeCard(
                            colors: c,
                            title: 'Personalizada',
                            subtitle: 'ABCtube',
                            icon: Icons.tune_outlined,
                            selected: !isMaterial,
                            onTap: () => setState(
                              () => _design = AppDesign.custom,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ModeCard(
                            colors: c,
                            title: 'Material',
                            subtitle: 'Material 3',
                            icon: Icons.layers_outlined,
                            selected: isMaterial,
                            onTap: () => setState(
                              () => _design = AppDesign.material,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    _SettingsSection(
                      colors: c,
                      icon: Icons.palette_outlined,
                      title: 'Estilo visual',
                      description:
                          'Mantém todos os estilos anteriores e muda cores, botões e destaques.',
                    ),
                    const SizedBox(height: 12),
                    _StyleGrid(
                      colors: c,
                      isDark: _dark,
                      design: _design,
                      selected: _style,
                      onChanged: (style) => setState(() => _style = style),
                    ),
                    const SizedBox(height: 26),
                    _PreviewCard(colors: c),
                    const SizedBox(height: 20),
                    _ApplyButton(
                      colors: c,
                      material: isMaterial,
                      onTap: _finish,
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

class _SettingsHeader extends StatelessWidget {
  final AppColors colors;
  final VoidCallback onBack;

  const _SettingsHeader({
    required this.colors,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Row(
        children: [
          const SizedBox(width: 10),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onBack,
              child: Ink(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colors.bgCardNeutral,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AppIcon(
                  colors: colors,
                  materialIcon: Icons.arrow_back_rounded,
                  customAsset: 'assets/icons/back.svg',
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Definições',
            style: TextStyle(
              fontFamily: 'ComicSansMS',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: colors.textMain,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Icon(
              Icons.settings_outlined,
              size: 22,
              color: colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final AppColors colors;
  final IconData icon;
  final String title;
  final String description;

  const _SettingsSection({
    required this.colors,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            size: 21,
            color: colors.primary,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'ComicSansMS',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: colors.textMain,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.3,
                  color: colors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  final AppColors colors;
  final IconData icon;
  final String title;
  final String description;
  final bool value;
  final bool material;
  final ValueChanged<bool> onChanged;

  const _SettingTile({
    required this.colors,
    required this.icon,
    required this.title,
    required this.description,
    required this.value,
    required this.material,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: colors.bgCardNeutral,
        borderRadius: BorderRadius.circular(material ? 12 : 16),
        border: Border.all(
          color: value ? colors.primary.withOpacity(0.18) : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: value
                  ? colors.primary.withOpacity(0.12)
                  : colors.bg,
              borderRadius: BorderRadius.circular(material ? 10 : 11),
            ),
            child: Icon(
              icon,
              size: 21,
              color: value ? colors.primary : colors.textMuted,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: colors.textMain,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (material)
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: colors.primary,
            )
          else
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
        duration: const Duration(milliseconds: 220),
        width: 52,
        height: 30,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? colors.primary : colors.divider,
          borderRadius: BorderRadius.circular(20),
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

class _ModeCard extends StatelessWidget {
  final AppColors colors;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.colors,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? colors.primary.withOpacity(0.12)
              : colors.bgCardNeutral,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? colors.primary : colors.divider,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: colors.primary,
                ),
                const Spacer(),
                if (selected)
                  Icon(
                    Icons.check_circle_rounded,
                    size: 19,
                    color: colors.primary,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'ComicSansMS',
                fontWeight: FontWeight.w700,
                color: colors.textMain,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: colors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StyleGrid extends StatelessWidget {
  final AppColors colors;
  final bool isDark;
  final AppDesign design;
  final AppStyle selected;
  final ValueChanged<AppStyle> onChanged;

  const _StyleGrid({
    required this.colors,
    required this.isDark,
    required this.design,
    required this.selected,
    required this.onChanged,
  });

  static const _items = [
    (
      AppStyle.classic,
      'Clássico',
      Icons.auto_awesome_outlined,
    ),
    (
      AppStyle.playful,
      'Divertido',
      Icons.bolt_outlined,
    ),
    (
      AppStyle.ocean,
      'Oceano',
      Icons.water_drop_outlined,
    ),
    (
      AppStyle.sunset,
      'Pôr do sol',
      Icons.wb_sunny_outlined,
    ),
    (
      AppStyle.monochrome,
      'Monocromático',
      Icons.contrast_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.28,
      ),
      itemBuilder: (context, index) {
        final item = _items[index];
        final style = item.$1;
        final preview = AppColors(isDark, style, design);
        final isSelected = selected == style;

        return GestureDetector(
          onTap: () => onChanged(style),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? preview.primary.withOpacity(0.12)
                  : colors.bgCardNeutral,
              borderRadius:
                  BorderRadius.circular(design == AppDesign.material ? 12 : 18),
              border: Border.all(
                color: isSelected ? preview.primary : colors.divider,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      item.$3,
                      size: 22,
                      color: preview.primary,
                    ),
                    const Spacer(),
                    if (isSelected)
                      Icon(
                        Icons.check_circle_rounded,
                        size: 19,
                        color: preview.primary,
                      ),
                  ],
                ),
                const Spacer(),
                Text(
                  item.$2,
                  style: TextStyle(
                    fontFamily: 'ComicSansMS',
                    fontWeight: FontWeight.w700,
                    color: colors.textMain,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 7,
                        decoration: BoxDecoration(
                          color: preview.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      width: 28,
                      height: 7,
                      decoration: BoxDecoration(
                        color: preview.c2Fg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final AppColors colors;

  const _PreviewCard({
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final material = colors.design == AppDesign.material;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.bgCardNeutral,
        borderRadius:
            BorderRadius.circular(material ? 12 : 20),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.preview_outlined,
                color: colors.primary,
                size: 20,
              ),
              const SizedBox(width: 7),
              Text(
                'Pré-visualização',
                style: TextStyle(
                  fontFamily: 'ComicSansMS',
                  fontWeight: FontWeight.w700,
                  color: colors.textMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius:
                        BorderRadius.circular(material ? 8 : 14),
                    boxShadow: material
                        ? const []
                        : [
                            BoxShadow(
                              color: colors.primaryShadow,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: const Center(
                    child: Text(
                      'Principal',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: material
                    ? FilledButton(
                        onPressed: () {},
                        child: const Text('Material'),
                      )
                    : Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: colors.c2Bg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            'Custom',
                            style: TextStyle(
                              color: colors.c2Fg,
                              fontWeight: FontWeight.w700,
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

class _ApplyButton extends StatelessWidget {
  final AppColors colors;
  final bool material;
  final VoidCallback onTap;

  const _ApplyButton({
    required this.colors,
    required this.material,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (material) {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: FilledButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.check_rounded),
          label: const Text('APLICAR DEFINIÇÕES'),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colors.primaryShadow,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'APLICAR DEFINIÇÕES',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
