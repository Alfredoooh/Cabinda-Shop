import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../main.dart' show AppColors, AppStyle, SoundManager;

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

class SettingsScreen extends StatefulWidget {
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
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _dark;
  late AppStyle _style;
  late bool _sound;
  late bool _music;

  @override
  void initState() {
    super.initState();
    _dark = widget.isDark;
    _style = widget.style;
    _sound = widget.soundEnabled;
    _music = widget.musicEnabled;
  }

  AppColors get colors => AppColors(_dark, _style);

  void _finish() {
    SoundManager.instance.muted = !_sound;
    SoundManager.instance.clickMuted = !_sound;
    SoundManager.instance.musicMuted = !_music;
    Navigator.of(context).pop(
      AppSettingsResult(
        isDark: _dark,
        style: _style,
        soundEnabled: _sound,
        musicEnabled: _music,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = colors;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 58,
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _finish,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: c.bgCardNeutral,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/icons/back.svg',
                          width: 20,
                          height: 20,
                          colorFilter: ColorFilter.mode(c.textMain, BlendMode.srcIn),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Definições', style: TextStyle(
                    fontFamily: 'ComicSansMS',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: c.textMain,
                  )),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
                children: [
                  _SectionTitle(c, 'Som'),
                  _SettingTile(
                    c: c,
                    icon: _icon('assets/icons/speaker-icon.svg', c.textMain),
                    title: 'Sons de clique',
                    subtitle: 'Sons ao tocar nos botões',
                    value: _sound,
                    onChanged: (v) => setState(() => _sound = v),
                  ),
                  const SizedBox(height: 10),
                  _SettingTile(
                    c: c,
                    icon: _icon('assets/icons/music_on.svg', c.textMain),
                    title: 'Música',
                    subtitle: 'Música ambiente dos jogos',
                    value: _music,
                    onChanged: (v) => setState(() => _music = v),
                  ),
                  const SizedBox(height: 22),
                  _SectionTitle(c, 'Aparência'),
                  _SettingTile(
                    c: c,
                    icon: Icon(Icons.dark_mode_rounded, color: c.textMain),
                    title: 'Tema escuro',
                    subtitle: 'Alterna entre claro e escuro',
                    value: _dark,
                    onChanged: (v) => setState(() => _dark = v),
                  ),
                  const SizedBox(height: 16),
                  _SectionTitle(c, 'Estilo do app'),
                  Text(
                    'Escolhe como o ABCtube deve parecer. O estilo altera cores principais, botões e destaques.',
                    style: TextStyle(color: c.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.35,
                    children: [
                      _StyleCard(c: c, style: AppStyle.classic, title: 'Clássico', emoji: '🟢'),
                      _StyleCard(c: c, style: AppStyle.material, title: 'Material', emoji: '🔵'),
                      _StyleCard(c: c, style: AppStyle.playful, title: 'Divertido', emoji: '🩷'),
                      _StyleCard(c: c, style: AppStyle.ocean, title: 'Oceano', emoji: '🌊'),
                      _StyleCard(c: c, style: AppStyle.sunset, title: 'Pôr do sol', emoji: '🟠'),
                      _StyleCard(c: c, style: AppStyle.monochrome, title: 'Monocromático', emoji: '⚫'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: c.bgCardNeutral,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: c.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'As alterações são aplicadas quando voltares ao app.',
                            style: TextStyle(color: c.textMain, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  GestureDetector(
                    onTap: _finish,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: c.primary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: c.primaryShadow, offset: const Offset(0, 4))],
                      ),
                      child: const Center(
                        child: Text('APLICAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1)),
                      ),
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

  Widget _icon(String path, Color color) => SvgPicture.asset(path, width: 22, height: 22, colorFilter: ColorFilter.mode(color, BlendMode.srcIn));

  Widget _SectionTitle(AppColors c, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Text(text, style: TextStyle(fontFamily: 'ComicSansMS', fontWeight: FontWeight.w700, fontSize: 16, color: c.textMain)),
  );

  Widget _SettingTile({
    required AppColors c,
    required Widget icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(color: c.bgCardNeutral, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          SizedBox(width: 28, height: 28, child: Center(child: icon)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: c.textMain)),
            const SizedBox(height: 3),
            Text(subtitle, style: TextStyle(fontSize: 12, color: c.textMuted)),
          ])),
          Switch.adaptive(value: value, activeTrackColor: c.primary, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _StyleCard({required AppColors c, required AppStyle style, required String title, required String emoji}) {
    final selected = _style == style;
    final preview = AppColors(_dark, style).primary;
    return GestureDetector(
      onTap: () => setState(() => _style = style),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? preview.withOpacity(0.14) : c.bgCardNeutral,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? preview : Colors.transparent, width: 2),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Text(emoji, style: const TextStyle(fontSize: 23)), const Spacer(), if (selected) Icon(Icons.check_circle_rounded, color: preview, size: 20)]),
          const Spacer(),
          Text(title, style: TextStyle(fontFamily: 'ComicSansMS', fontWeight: FontWeight.w700, color: c.textMain)),
          const SizedBox(height: 8),
          Container(height: 8, decoration: BoxDecoration(color: preview, borderRadius: BorderRadius.circular(6))),
        ]),
      ),
    );
  }
}
