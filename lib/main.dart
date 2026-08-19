import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDark = true;

  void _toggleTheme() => setState(() => _isDark = !_isDark);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: ComponentsPage(
        isDark: _isDark,
        onThemeToggle: _toggleTheme,
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final base = ThemeData(
      brightness: brightness,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: isDark ? const Color(0xFF1C1D1F) : const Color(0xFFF2F2F7),
    );
    return base.copyWith(
      extensions: <ThemeExtension<dynamic>>[
        AppColors(isDark: isDark),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Theme Extension
// ---------------------------------------------------------------------------
// PALETA — valores de referência (hex ao lado de cada token)
//
// ACCENT (substituiu o azul): um teal dessaturado, funciona bem em ambos os modos
//   light  -> 0xFF3D8B7D  (teal médio, pouco saturado)
//   dark   -> 0xFF6FB3A3  (teal claro suave, sem neon)
//
// DARK MODE — base neutra "limpa": nada de preto AMOLED (0xFF000000/0xFF111111)
// nem cinza claro demais. Usa-se um cinza-carvão médio como fundo, com camadas
// de superfície subindo em passos pequenos e consistentes:
//   background        -> 0xFF1C1D1F
//   surface (cards)   -> 0xFF26282B
//   surface elevated  -> 0xFF2E3134  (dialogs, sheets, segmented bg)
//   surface sunken    -> 0xFF232527  (inputs, track de switch/progress)
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final bool isDark;

  AppColors({required this.isDark});

  // Base
  Color get background => isDark ? const Color(0xFF1C1D1F) : const Color(0xFFF2F2F7);
  Color get groupLabel => isDark ? const Color(0xFF8A8D91) : const Color(0xFF8E8E93);
  Color get cardBg => isDark ? const Color(0xFF26282B) : Colors.white;
  Color get cardShadow => isDark ? const Color(0x33000000) : const Color(0x1A000000);
  Color get textPrimary => isDark ? const Color(0xFFF2F2F0) : Colors.black;
  Color get textSecondary => isDark ? const Color(0xFFB4B6B9) : const Color(0xFF3C3C43);
  Color get textTertiary => isDark ? const Color(0xFF8F9194) : const Color(0xFF8E8E93);
  Color get textQuaternary => isDark ? const Color(0xFF96989B) : const Color(0xFF8E8E93);

  // Icons
  Color get iconBlue => isDark ? const Color(0xFF6FB3A3) : const Color(0xFF3D8B7D); // accent (teal)
  Color get iconGreen => isDark ? const Color(0xFF6FDCAE) : const Color(0xFF34C759);
  Color get iconRed => isDark ? const Color(0xFFEF9797) : const Color(0xFFFF3B30);
  Color get iconGray => isDark ? const Color(0xFF9A9C9F) : const Color(0xFF8E8E93);
  Color get chevron => isDark ? const Color(0xFF55585B) : const Color(0xFFC7C7CC);

  // Inputs
  Color get inputBg => isDark ? const Color(0xFF232527) : Colors.white;
  Color get inputHint => isDark ? const Color(0xFF74767A) : const Color(0xFFC7C7CC);
  Color get inputIcon => isDark ? const Color(0xFF86888B) : const Color(0xFF8E8E93);
  Color get inputFocusBorder => isDark ? const Color(0xFF6FB3A3) : const Color(0xFF3D8B7D); // accent
  Color get inputErrorBorder => isDark ? const Color(0xFFE05E5E) : const Color(0xFFFF3B30);
  Color get clearBtnBg => isDark ? const Color(0xFF3A3D40) : const Color(0xFFD1D1D6);
  Color get clearBtnFg => isDark ? const Color(0xFFAEB0B3) : const Color(0xFF8E8E93);

  // Segmented
  Color get segmentedBg => isDark ? const Color(0xFF232527) : const Color(0xFFE5E5EA);
  Color get segmentedActiveBg => isDark ? const Color(0xFF6FB3A3) : const Color(0xFF3D8B7D); // accent
  Color get segmentedInactiveText => isDark ? const Color(0xFF8F9194) : const Color(0xFF8E8E93);

  // Switches, Checkboxes, Radios
  Color get switchTrackInactive => isDark ? const Color(0xFF3A3D40) : const Color(0xFFE5E5EA);
  Color get switchThumb => Colors.white;
  Color get checkboxUnchecked => isDark ? const Color(0xFF35373A) : const Color(0xFFE5E5EA);
  Color get radioUnchecked => isDark ? const Color(0xFF35373A) : const Color(0xFFE5E5EA);

  // Buttons
  Color get btnPrimary => isDark ? const Color(0xFF6FB3A3) : const Color(0xFF3D8B7D); // accent
  Color get btnDanger => isDark ? const Color(0xFFE05E5E) : const Color(0xFFFF3B30);
  Color get btnSuccess => isDark ? const Color(0xFF4EC994) : const Color(0xFF34C759);
  Color get btnWarning => isDark ? const Color(0xFFF0A500) : const Color(0xFFFF9500);
  Color get btnSecondary => isDark ? const Color(0xFF2E3134) : const Color(0xFFF2F2F7);
  Color get btnGhostText => isDark ? const Color(0xFFA0A2A5) : const Color(0xFF8E8E93);
  Color get btnOutlineBlueFg => isDark ? const Color(0xFF86C4B6) : const Color(0xFF3D8B7D); // accent fg
  Color get btnOutlineBlueBorder => isDark ? const Color(0xFF4C7C71) : const Color(0xFF3D8B7D); // accent border
  Color get btnOutlineDangerFg => isDark ? const Color(0xFFE08080) : const Color(0xFFFF3B30);
  Color get btnOutlineDangerBorder => isDark ? const Color(0xFF96403F) : const Color(0xFFFF3B30);
  Color get tintBlueBg => isDark ? const Color(0x266FB3A3) : const Color(0x1A3D8B7D); // accent tint bg
  Color get tintBlueFg => isDark ? const Color(0xFF8BC7BA) : const Color(0xFF3D8B7D); // accent tint fg
  Color get tintRedBg => isDark ? const Color(0x26E05E5E) : const Color(0x1AFF3B30);
  Color get tintRedFg => isDark ? const Color(0xFFEF9797) : const Color(0xFFFF3B30);

  // Dialog
  Color get dialogActionsBg => isDark ? const Color(0xFF2E3134) : const Color(0xFFF2F2F7);

  // Cards extras
  Color get eventPreviewBg => isDark ? const Color(0xFF232527) : const Color(0xFFF2F2F7);
  Color get eventDateBg => isDark ? const Color(0xFF2E3134) : Colors.white;
  Color get eventActionsBg => isDark ? const Color(0xFF2E3134) : const Color(0xFFF2F2F7);
  Color get alertWarningBg => isDark ? const Color(0x1AF0A500) : const Color(0x1AFF9500);
  Color get alertDangerBg => isDark ? const Color(0x1AE05E5E) : const Color(0x1AFF3B30);
  Color get progressTrack => isDark ? const Color(0xFF35373A) : const Color(0xFFE5E5EA);
  Color get progressFill => isDark ? const Color(0xFF6FB3A3) : const Color(0xFF3D8B7D); // accent
  Color get addCardBorder => isDark ? const Color(0xFF3E4144) : const Color(0xFFC7C7CC);
  Color get addCardText => isDark ? const Color(0xFF8F9194) : const Color(0xFF8E8E93);
  Color get addCardIcon => isDark ? const Color(0xFF86888B) : const Color(0xFF8E8E93);
  Color get sheetHandle => isDark ? const Color(0xFF4A4D50) : const Color(0xFFD1D1D6);
  Color get sheetFieldBorder => isDark ? const Color(0xFF35373A) : const Color(0xFFE5E5EA);

  @override
  AppColors copyWith({bool? isDark}) => AppColors(isDark: isDark ?? this.isDark);

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(isDark: t < 0.5 ? isDark : other.isDark);
  }
}

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------
class ComponentsPage extends StatefulWidget {
  final bool isDark;
  final VoidCallback onThemeToggle;

  const ComponentsPage({
    super.key,
    required this.isDark,
    required this.onThemeToggle,
  });

  @override
  State<ComponentsPage> createState() => _ComponentsPageState();
}

class _ComponentsPageState extends State<ComponentsPage> {
  int _selectedSegment = 0;
  bool _notificationsEnabled = true;
  bool _weeklyRepeat = false;
  bool _emailInvite = true;
  bool _privateEvent = false;
  int _radioSelected = 0;

  late final TextEditingController _searchController;
  late final List<FocusNode> _otpFocusNodes;
  late final List<TextEditingController> _otpControllers;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: 'Reunião');
    _otpFocusNodes = List.generate(4, (_) => FocusNode());
    _otpControllers = List.generate(
      4,
      (i) => TextEditingController(text: i < 2 ? (i == 0 ? '4' : '2') : ''),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    for (final node in _otpFocusNodes) {
      node.dispose();
    }
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  AppColors get colors => Theme.of(context).extension<AppColors>()!;

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  Widget _groupLabel(String label) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: colors.groupLabel,
            letterSpacing: 0.6,
          ),
        ),
      );

  _BtnStyleData _getButtonStyle(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return const _BtnStyleData(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          fontSize: 12.5,
          iconSize: 12,
          iconOnlySize: 34,
        );
      case ButtonSize.medium:
        return const _BtnStyleData(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          fontSize: 14,
          iconSize: 14,
          iconOnlySize: 42,
        );
      case ButtonSize.large:
        return const _BtnStyleData(
          padding: EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          fontSize: 15,
          iconSize: 16,
          iconOnlySize: 50,
        );
    }
  }

  _VariantColors _getVariantColors(BtnVariant variant) {
    switch (variant) {
      case BtnVariant.primary:
        return _VariantColors(colors.btnPrimary, Colors.white);
      case BtnVariant.danger:
        return _VariantColors(colors.btnDanger, Colors.white);
      case BtnVariant.success:
        return _VariantColors(colors.btnSuccess, colors.textPrimary);
      case BtnVariant.warning:
        return _VariantColors(colors.btnWarning, colors.textPrimary);
      case BtnVariant.secondary:
        return _VariantColors(colors.btnSecondary, colors.textPrimary);
      case BtnVariant.ghost:
        return _VariantColors(Colors.transparent, colors.btnGhostText);
      case BtnVariant.outline:
        return _VariantColors(
          Colors.transparent,
          colors.btnOutlineBlueFg,
          colors.btnOutlineBlueBorder,
        );
      case BtnVariant.outlineDanger:
        return _VariantColors(
          Colors.transparent,
          colors.btnOutlineDangerFg,
          colors.btnOutlineDangerBorder,
        );
      case BtnVariant.tintBlue:
        return _VariantColors(colors.tintBlueBg, colors.tintBlueFg);
      case BtnVariant.tintRed:
        return _VariantColors(colors.tintRedBg, colors.tintRedFg);
    }
  }

  Widget _buildButton({
    required String label,
    BtnVariant variant = BtnVariant.primary,
    ButtonSize size = ButtonSize.medium,
    IconData? icon,
    bool fullWidth = false,
    bool iconOnly = false,
    bool loading = false,
    bool disabled = false,
    VoidCallback? onTap,
  }) {
    final style = _getButtonStyle(size);
    final vColors = _getVariantColors(variant);
    final radius = BorderRadius.circular(50);
    final side = vColors.borderColor != null
        ? BorderSide(color: vColors.borderColor!, width: 1.5)
        : BorderSide.none;

    Widget content;
    if (loading) {
      content = const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    } else if (iconOnly && icon != null) {
      content = Icon(icon, size: style.iconSize, color: vColors.foreground);
    } else {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: style.iconSize, color: vColors.foreground),
            const SizedBox(width: 7),
          ],
          if (label.isNotEmpty)
            Text(
              label,
              style: TextStyle(
                fontSize: style.fontSize,
                fontWeight: FontWeight.w600,
                color: vColors.foreground,
                letterSpacing: 0.1,
              ),
            ),
        ],
      );
    }

    Widget button = Material(
      color: vColors.background,
      shape: RoundedRectangleBorder(borderRadius: radius, side: side),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: (disabled || loading) ? null : onTap,
        borderRadius: radius,
        splashColor: Colors.white10,
        highlightColor: Colors.white24,
        child: Container(
          padding: iconOnly ? EdgeInsets.zero : style.padding,
          alignment: Alignment.center,
          constraints: iconOnly
              ? BoxConstraints.tightFor(
                  width: style.iconOnlySize,
                  height: style.iconOnlySize,
                )
              : null,
          child: content,
        ),
      ),
    );

    if (fullWidth) button = SizedBox(width: double.infinity, child: button);
    if (disabled) button = Opacity(opacity: 0.32, child: IgnorePointer(child: button));
    return button;
  }

  Widget _buildSegmentedControl() {
    const items = ['Dia', 'Semana', 'Mês'];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.segmentedBg,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(items.length, (i) {
          final selected = _selectedSegment == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedSegment = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: selected ? colors.segmentedActiveBg : Colors.transparent,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                items[i],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : colors.segmentedInactiveText,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSplitActions() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: colors.segmentedBg,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildButton(
              label: 'Eliminar',
              variant: BtnVariant.danger,
              onTap: () {},
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildButton(
              label: 'Cancelar',
              variant: BtnVariant.primary,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Dialog
  // ---------------------------------------------------------------------------
  void _showDemoDialog() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        final dColors = Theme.of(dialogContext).extension<AppColors>()!;
        return Dialog(
          backgroundColor: dColors.cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Eliminar evento?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: dColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Esta ação não pode ser desfeita.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: dColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: dColors.dialogActionsBg,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _dialogButton(
                          dialogContext,
                          'Eliminar',
                          bg: dColors.btnDanger,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _dialogButton(
                          dialogContext,
                          'Cancelar',
                          bg: dColors.btnPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _dialogButton(BuildContext context, String label, {required Color bg}) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(50),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.pop(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Cards
  // ---------------------------------------------------------------------------
  Widget _card({
    required Widget child,
    EdgeInsetsGeometry? padding,
    Color? color,
    double radius = 28,
    Border? border,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? colors.cardBg,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: border,
      ),
      child: child,
    );
  }

  Widget _buildSimpleCard() {
    return _card(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sincronização automática',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Os teus eventos são sincronizados com o calendário do dispositivo a cada 15 minutos.',
            style: TextStyle(
              fontSize: 13,
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // Lista pixel-perfect: container pai com shadow, overflow hidden, gap de 3px.
  // Radius por item:
  //  - único item          -> 28 em todos os cantos
  //  - primeiro item (topo) -> topo 28 (inalterado) / fundo 10 (levemente curvo)
  //  - último item (fundo)  -> topo 10 (levemente curvo) / fundo 28 (inalterado)
  //  - itens do meio         -> 8 em todos os cantos (já era assim)
  Widget _buildListCardWithRows(List<_ListRowData> rows) {
    const bigRadius = Radius.circular(28);
    const softRadius = Radius.circular(10); // curvatura leve pedida para o cantos internos do 1º/último
    const midRadius = Radius.circular(8);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(rows.length, (i) {
          final isFirst = i == 0;
          final isLast = i == rows.length - 1;
          BorderRadius radius;
          if (isFirst && rows.length == 1) {
            radius = BorderRadius.all(bigRadius);
          } else if (isFirst) {
            radius = BorderRadius.only(
              topLeft: bigRadius,
              topRight: bigRadius,
              bottomLeft: softRadius,
              bottomRight: softRadius,
            );
          } else if (isLast) {
            radius = BorderRadius.only(
              topLeft: softRadius,
              topRight: softRadius,
              bottomLeft: bigRadius,
              bottomRight: bigRadius,
            );
          } else {
            radius = BorderRadius.all(midRadius);
          }
          return Column(
            children: [
              Material(
                color: colors.cardBg,
                borderRadius: radius,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: rows[i].onTap ?? () {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Icon(rows[i].icon, size: 17, color: rows[i].color),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rows[i].title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                rows[i].sub,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, size: 20, color: colors.chevron),
                      ],
                    ),
                  ),
                ),
              ),
              if (!isLast) const SizedBox(height: 3),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildIconListCard() {
    return _buildListCardWithRows([
      _ListRowData(
        icon: Icons.calendar_today,
        color: colors.iconBlue,
        title: 'Calendário',
        sub: '3 eventos hoje',
      ),
      _ListRowData(
        icon: Icons.check,
        color: colors.iconGreen,
        title: 'Tarefas concluídas',
        sub: '8 de 10 esta semana',
      ),
      _ListRowData(
        icon: Icons.notifications_outlined,
        color: colors.iconRed,
        title: 'Lembretes',
        sub: '2 pendentes',
      ),
    ]);
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.event_available,
            iconColor: colors.iconBlue,
            value: '24',
            label: 'Eventos este mês',
            trendUp: true,
            trendText: '12%',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            icon: Icons.access_time,
            iconColor: colors.iconRed,
            value: '3.2h',
            label: 'Tempo em reuniões',
            trendUp: false,
            trendText: '4%',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required bool trendUp,
    required String trendText,
  }) {
    final trendColor = trendUp ? colors.btnSuccess : colors.btnDanger;
    return _card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: iconColor),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: colors.textPrimary, height: 1.1),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(fontSize: 11.5, color: colors.textTertiary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(trendUp ? Icons.arrow_upward : Icons.arrow_downward, size: 11, color: trendColor),
              const SizedBox(width: 4),
              Text(trendText, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: trendColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard() {
    return _card(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.eventPreviewBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colors.eventDateBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('18', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textPrimary, height: 1.1)),
                      Text('Ago', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: colors.btnPrimary, letterSpacing: 0.4)),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reunião de equipa', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: colors.textPrimary, overflow: TextOverflow.ellipsis)),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 12, color: colors.textQuaternary),
                          const SizedBox(width: 5),
                          Text('14:00 — 15:00', style: TextStyle(fontSize: 12, color: colors.textQuaternary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: colors.eventActionsBg,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _eventActionButton('Adiar', bg: Colors.transparent, fg: colors.btnGhostText),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _eventActionButton('Entrar', bg: colors.btnPrimary, fg: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _eventActionButton(String label, {required Color bg, required Color fg}) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(50),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Center(
            child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: fg)),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return _card(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [colors.btnPrimary, colors.btnOutlineBlueBorder],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            alignment: Alignment.center,
            child: Text('AF', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Alfredo Ferreira', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                const SizedBox(height: 2),
                Text('alfredo@nexa.app', style: TextStyle(fontSize: 12.5, color: colors.textQuaternary)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 20, color: colors.iconGray),
        ],
      ),
    );
  }

  Widget _buildAlertCards() {
    return Column(
      children: [
        _buildAlertCard(icon: Icons.warning_amber_rounded, iconColor: colors.btnWarning, bg: colors.alertWarningBg, title: 'Conflito de horário', text: 'Tens dois eventos sobrepostos às 15:00.'),
        const SizedBox(height: 10),
        _buildAlertCard(icon: Icons.error_outline, iconColor: colors.btnDanger, bg: colors.alertDangerBg, title: 'Falha na sincronização', text: 'Não foi possível ligar ao Google Calendar.'),
      ],
    );
  }

  Widget _buildAlertCard({
    required IconData icon,
    required Color iconColor,
    required Color bg,
    required String title,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: colors.cardShadow, blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                const SizedBox(height: 3),
                Text(text, style: TextStyle(fontSize: 12.5, color: colors.textSecondary, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return _card(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Armazenamento', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: colors.textPrimary)),
              Text('68%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colors.iconBlue)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: LinearProgressIndicator(
              value: 0.68,
              minHeight: 8,
              backgroundColor: colors.progressTrack,
              valueColor: AlwaysStoppedAnimation<Color>(colors.progressFill),
            ),
          ),
          const SizedBox(height: 12),
          Text('6.8 GB de 10 GB usados', style: TextStyle(fontSize: 12, color: colors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildAddCard() {
    return CustomPaint(
      painter: DashedBorderPainter(color: colors.addCardBorder, strokeWidth: 1.5, radius: 28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 18, color: colors.addCardIcon),
              const SizedBox(height: 10),
              Text('Adicionar novo evento', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.addCardText)),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Inputs
  // ---------------------------------------------------------------------------
  Widget _buildTextField({
    String? hint,
    IconData? prefixIcon,
    Widget? suffix,
    bool error = false,
    bool disabled = false,
    double radius = 50,
    EdgeInsetsGeometry contentPadding = const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
    Color? fillColor,
    TextStyle? style,
    TextEditingController? controller,
    FocusNode? focusNode,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
    int? maxLength,
    bool isTextArea = false,
  }) {
    return Opacity(
      opacity: disabled ? 0.4 : 1,
      child: IgnorePointer(
        ignoring: disabled,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          keyboardType: keyboardType,
          maxLength: maxLength,
          minLines: isTextArea ? 3 : null,
          maxLines: isTextArea ? null : 1,
          style: style ?? TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colors.textPrimary),
          cursorColor: colors.inputFocusBorder,
          decoration: InputDecoration(
            filled: true,
            fillColor: fillColor ?? colors.inputBg,
            hintText: hint,
            hintStyle: TextStyle(color: colors.inputHint, fontWeight: FontWeight.w400),
            counterText: maxLength != null ? '' : null,
            prefixIcon: prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 18, right: 10),
                    child: Icon(prefixIcon, size: 14, color: error ? colors.inputErrorBorder : colors.inputIcon),
                  )
                : null,
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: suffix != null ? Padding(padding: const EdgeInsets.only(right: 16), child: suffix) : null,
            suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            contentPadding: contentPadding,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(color: error ? colors.inputErrorBorder : Colors.transparent, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(color: error ? colors.inputErrorBorder : colors.inputFocusBorder, width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radius), borderSide: BorderSide.none),
          ),
        ),
      ),
    );
  }

  Widget _buildLabeledField(String? label, {required Widget input, String? errorText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary)),
          const SizedBox(height: 6),
        ],
        input,
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(errorText, style: TextStyle(fontSize: 12, color: colors.inputErrorBorder)),
          ),
        ],
      ],
    );
  }

  Widget _buildSwitchRow({required String title, String? subtitle, required bool value, required ValueChanged<bool> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(color: colors.cardBg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 12, color: colors.textTertiary)),
              ],
            ],
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: colors.switchThumb,
            activeTrackColor: colors.segmentedActiveBg,
            inactiveThumbColor: colors.switchThumb,
            inactiveTrackColor: colors.switchTrackInactive,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckRow({required String label, required bool value, required ValueChanged<bool?> onChanged}) {
    return Container(
      decoration: BoxDecoration(color: colors.cardBg, borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: colors.segmentedActiveBg,
                checkColor: Colors.white,
                fillColor: WidgetStateProperty.resolveWith<Color?>(
                  (states) => states.contains(WidgetState.selected) ? colors.segmentedActiveBg : colors.checkboxUnchecked,
                ),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const SizedBox(width: 12),
              Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadioRow({required String label, required int index, required int groupValue}) {
    return Container(
      decoration: BoxDecoration(color: colors.cardBg, borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => setState(() => _radioSelected = index),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Radio<int>(
                value: index,
                groupValue: groupValue,
                onChanged: (v) => setState(() => _radioSelected = v!),
                activeColor: colors.segmentedActiveBg,
                fillColor: WidgetStateProperty.resolveWith<Color?>(
                  (states) => states.contains(WidgetState.selected) ? colors.segmentedActiveBg : colors.radioUnchecked,
                ),
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const SizedBox(width: 12),
              Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  void _onOtpChanged(int index, String value) {
    if (value.length == 1 && index < 3) _otpFocusNodes[index + 1].requestFocus();
  }

  // ---------------------------------------------------------------------------
  // Modal / Bottom Sheet
  // ---------------------------------------------------------------------------
  void _showDemoSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.cardBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (sheetContext) {
        final sheetColors = Theme.of(sheetContext).extension<AppColors>()!;
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(color: sheetColors.sheetHandle, borderRadius: BorderRadius.circular(9999)),
                ),
              ),
              const SizedBox(height: 18),
              Text('Novo evento', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: sheetColors.textPrimary)),
              const SizedBox(height: 18),
              Text('Preenche os detalhes abaixo para adicionar um novo evento ao teu calendário.',
                  style: TextStyle(fontSize: 13.5, color: sheetColors.textSecondary, height: 1.6)),
              const SizedBox(height: 18),
              _buildSheetFieldGroup(sheetColors),
              const SizedBox(height: 10),
              _buildButton(label: 'Guardar evento', icon: Icons.check, variant: BtnVariant.primary, size: ButtonSize.medium, fullWidth: true, onTap: () => Navigator.pop(sheetContext)),
              const SizedBox(height: 10),
              _buildButton(label: 'Cancelar', variant: BtnVariant.ghost, size: ButtonSize.medium, fullWidth: true, onTap: () => Navigator.pop(sheetContext)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSheetFieldGroup(AppColors sheetColors) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: sheetColors.sheetFieldBorder), borderRadius: BorderRadius.circular(28)),
      child: Column(
        children: [
          _buildSheetInputRow(sheetColors, icon: Icons.edit, hint: 'Título do evento', isFirst: true, isLast: false),
          _buildSheetInputRow(sheetColors, icon: Icons.calendar_today, hint: '18 de agosto', isFirst: false, isLast: false),
          _buildSheetInputRow(sheetColors, icon: Icons.access_time, hint: '14:00 — 15:00', isFirst: false, isLast: true),
        ],
      ),
    );
  }

  Widget _buildSheetInputRow(AppColors sheetColors, {required IconData icon, required String hint, required bool isFirst, required bool isLast}) {
    BorderRadius radius;
    if (isFirst) {
      radius = const BorderRadius.vertical(top: Radius.circular(28));
    } else if (isLast) {
      radius = const BorderRadius.vertical(bottom: Radius.circular(28));
    } else {
      radius = const BorderRadius.all(Radius.circular(8));
    }

    return Container(
      decoration: BoxDecoration(color: sheetColors.cardBg, borderRadius: radius),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(icon, size: 15, color: sheetColors.iconBlue),
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: TextStyle(color: sheetColors.inputHint),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              style: TextStyle(fontSize: 14, color: sheetColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalList() {
    return _buildListCardWithRows([
      _ListRowData(icon: Icons.calendar_today, color: colors.iconBlue, title: 'Calendário', sub: '3 eventos hoje'),
      _ListRowData(icon: Icons.add, color: colors.iconBlue, title: 'Abrir modal', sub: 'Toca aqui para testar', onTap: _showDemoSheet),
      _ListRowData(icon: Icons.notifications_outlined, color: colors.iconRed, title: 'Lembretes', sub: '2 pendentes'),
    ]);
  }

  // ---------------------------------------------------------------------------
  // Seções
  // ---------------------------------------------------------------------------
  Widget _buildThemeSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Tema claro', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary)),
        Switch(
          value: !widget.isDark,
          onChanged: (_) => widget.onThemeToggle(),
          activeColor: colors.switchThumb,
          activeTrackColor: colors.segmentedActiveBg,
          inactiveThumbColor: colors.switchThumb,
          inactiveTrackColor: colors.switchTrackInactive,
        ),
      ],
    );
  }

  Widget _buildButtonsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _groupLabel('Primary'),
        _buildButton(label: 'Novo evento', icon: Icons.add, variant: BtnVariant.primary, size: ButtonSize.medium, fullWidth: true, onTap: () {}),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildButton(label: 'Pequeno', variant: BtnVariant.primary, size: ButtonSize.small, onTap: () {}),
            _buildButton(label: 'Médio', variant: BtnVariant.primary, size: ButtonSize.medium, onTap: () {}),
            _buildButton(label: 'Grande', variant: BtnVariant.primary, size: ButtonSize.large, onTap: () {}),
          ],
        ),
        const SizedBox(height: 26),
        _groupLabel('Destructive'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildButton(label: 'Eliminar', icon: Icons.delete, variant: BtnVariant.danger, size: ButtonSize.medium, onTap: () {}),
            _buildButton(label: 'Cancelar assinatura', variant: BtnVariant.outlineDanger, size: ButtonSize.medium, onTap: () {}),
          ],
        ),
        const SizedBox(height: 26),
        _groupLabel('Status'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildButton(label: 'Aprovado', icon: Icons.check, variant: BtnVariant.success, size: ButtonSize.small, onTap: () {}),
            _buildButton(label: 'Pendente', icon: Icons.warning_amber_rounded, variant: BtnVariant.warning, size: ButtonSize.small, onTap: () {}),
          ],
        ),
        const SizedBox(height: 26),
        _groupLabel('Secondary / Ghost / Outline'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildButton(label: 'Secundário', variant: BtnVariant.secondary, size: ButtonSize.medium, onTap: () {}),
            _buildButton(label: 'Ghost', variant: BtnVariant.ghost, size: ButtonSize.medium, onTap: () {}),
            _buildButton(label: 'Outline', variant: BtnVariant.outline, size: ButtonSize.medium, onTap: () {}),
          ],
        ),
        const SizedBox(height: 26),
        _groupLabel('Tint'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildButton(label: 'Notificar', icon: Icons.notifications_outlined, variant: BtnVariant.tintBlue, size: ButtonSize.medium, onTap: () {}),
            _buildButton(label: 'Reportar', icon: Icons.flag, variant: BtnVariant.tintRed, size: ButtonSize.medium, onTap: () {}),
          ],
        ),
        const SizedBox(height: 26),
        _groupLabel('Icon only'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildButton(label: '', icon: Icons.add, variant: BtnVariant.primary, size: ButtonSize.small, iconOnly: true, onTap: () {}),
            _buildButton(label: '', icon: Icons.more_horiz, variant: BtnVariant.secondary, size: ButtonSize.medium, iconOnly: true, onTap: () {}),
            _buildButton(label: '', icon: Icons.close, variant: BtnVariant.danger, size: ButtonSize.medium, iconOnly: true, onTap: () {}),
            _buildButton(label: '', icon: Icons.share, variant: BtnVariant.ghost, size: ButtonSize.large, iconOnly: true, onTap: () {}),
          ],
        ),
        const SizedBox(height: 26),
        _groupLabel('Disabled / Loading'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildButton(label: 'Indisponível', variant: BtnVariant.primary, size: ButtonSize.medium, disabled: true, onTap: () {}),
            _buildButton(label: 'A carregar', variant: BtnVariant.primary, size: ButtonSize.medium, loading: true, onTap: () {}),
          ],
        ),
        const SizedBox(height: 26),
        _groupLabel('Segmented control'),
        _buildSegmentedControl(),
        const SizedBox(height: 26),
        _groupLabel('Split action'),
        _buildSplitActions(),
      ],
    );
  }

  Widget _buildDialogSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _groupLabel('Dialog'),
        _buildButton(label: 'Abrir diálogo', variant: BtnVariant.primary, size: ButtonSize.medium, fullWidth: true, onTap: _showDemoDialog),
      ],
    );
  }

  Widget _buildCardsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _groupLabel('Simples'),
        _buildSimpleCard(),
        const SizedBox(height: 26),
        _groupLabel('Lista com ícones'),
        _buildIconListCard(),
        const SizedBox(height: 26),
        _groupLabel('Estatísticas'),
        _buildStatsRow(),
        const SizedBox(height: 26),
        _groupLabel('Evento (com preview + ações)'),
        _buildEventCard(),
        const SizedBox(height: 26),
        _groupLabel('Perfil'),
        _buildProfileCard(),
        const SizedBox(height: 26),
        _groupLabel('Alertas'),
        _buildAlertCards(),
        const SizedBox(height: 26),
        _groupLabel('Progresso'),
        _buildProgressCard(),
        const SizedBox(height: 26),
        _groupLabel('Adicionar / vazio'),
        _buildAddCard(),
      ],
    );
  }

  Widget _buildInputsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _groupLabel('Texto simples'),
        _buildLabeledField('Nome do evento', input: _buildTextField(hint: 'Reunião de equipa')),
        const SizedBox(height: 26),
        _groupLabel('Com ícone'),
        _buildTextField(hint: 'Email', prefixIcon: Icons.mail_outline),
        const SizedBox(height: 10),
        _buildTextField(hint: 'Palavra-passe', prefixIcon: Icons.lock_outline, suffix: Icon(Icons.visibility, size: 13, color: colors.inputIcon)),
        const SizedBox(height: 26),
        _groupLabel('Search com clear'),
        _buildTextField(
          hint: 'Pesquisar eventos',
          prefixIcon: Icons.search,
          controller: _searchController,
          suffix: GestureDetector(
            onTap: () => _searchController.clear(),
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(color: colors.clearBtnBg, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Icon(Icons.close, size: 10, color: colors.clearBtnFg),
            ),
          ),
        ),
        const SizedBox(height: 26),
        _groupLabel('Estado de erro'),
        _buildLabeledField(
          'Título',
          input: _buildTextField(hint: 'Título do evento', prefixIcon: Icons.warning_amber_rounded, error: true),
          errorText: 'Este campo é obrigatório',
        ),
        const SizedBox(height: 26),
        _groupLabel('Tamanhos'),
        _buildTextField(hint: 'Pequeno'),
        const SizedBox(height: 10),
        _buildTextField(hint: 'Médio'),
        const SizedBox(height: 10),
        _buildTextField(hint: 'Grande'),
        const SizedBox(height: 26),
        _groupLabel('Desativado'),
        _buildTextField(hint: 'Indisponível', disabled: true),
        const SizedBox(height: 26),
        _groupLabel('Textarea'),
        _buildLabeledField('Notas', input: _buildTextField(hint: 'Adiciona uma descrição...', isTextArea: true, radius: 24)),
        const SizedBox(height: 26),
        _groupLabel('Código OTP'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (i) {
            return SizedBox(
              width: 46,
              height: 54,
              child: TextField(
                controller: _otpControllers[i],
                focusNode: _otpFocusNodes[i],
                onChanged: (value) => _onOtpChanged(i, value),
                textAlign: TextAlign.center,
                maxLength: 1,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(1),
                ],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textPrimary),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: colors.inputBg,
                  counterText: '',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: colors.inputFocusBorder, width: 1.5)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 26),
        _groupLabel('Switch'),
        _buildSwitchRow(title: 'Notificações', subtitle: 'Alertas antes de cada evento', value: _notificationsEnabled, onChanged: (v) => setState(() => _notificationsEnabled = v)),
        const SizedBox(height: 10),
        _buildSwitchRow(title: 'Repetir semanalmente', value: _weeklyRepeat, onChanged: (v) => setState(() => _weeklyRepeat = v)),
        const SizedBox(height: 26),
        _groupLabel('Checkbox'),
        _buildCheckRow(label: 'Enviar convite por email', value: _emailInvite, onChanged: (v) => setState(() => _emailInvite = v!)),
        const SizedBox(height: 10),
        _buildCheckRow(label: 'Marcar como privado', value: _privateEvent, onChanged: (v) => setState(() => _privateEvent = v!)),
        const SizedBox(height: 26),
        _groupLabel('Radio'),
        _buildRadioRow(label: 'Não repetir', index: 0, groupValue: _radioSelected),
        const SizedBox(height: 8),
        _buildRadioRow(label: 'Todos os dias', index: 1, groupValue: _radioSelected),
        const SizedBox(height: 8),
        _buildRadioRow(label: 'Todas as semanas', index: 2, groupValue: _radioSelected),
      ],
    );
  }

  Widget _buildModalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _groupLabel('Lista com ícones'),
        _buildModalList(),
        const SizedBox(height: 26),
        _groupLabel('Gatilho'),
        _buildButton(label: 'Abrir modal', variant: BtnVariant.primary, size: ButtonSize.medium, fullWidth: true, onTap: _showDemoSheet),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildThemeSwitch(),
                  const SizedBox(height: 30),
                  _buildButtonsSection(),
                  const SizedBox(height: 26),
                  _buildDialogSection(),
                  const SizedBox(height: 26),
                  _buildCardsSection(),
                  const SizedBox(height: 26),
                  _buildInputsSection(),
                  const SizedBox(height: 26),
                  _buildModalSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Classes auxiliares
// ---------------------------------------------------------------------------
enum ButtonSize { small, medium, large }

enum BtnVariant {
  primary,
  danger,
  success,
  warning,
  secondary,
  ghost,
  outline,
  outlineDanger,
  tintBlue,
  tintRed,
}

class _VariantColors {
  final Color background;
  final Color foreground;
  final Color? borderColor;
  const _VariantColors(this.background, this.foreground, [this.borderColor]);
}

class _BtnStyleData {
  final EdgeInsetsGeometry padding;
  final double fontSize;
  final double iconSize;
  final double iconOnlySize;
  const _BtnStyleData({
    required this.padding,
    required this.fontSize,
    required this.iconSize,
    required this.iconOnlySize,
  });
}

class _ListRowData {
  final IconData icon;
  final Color color;
  final String title;
  final String sub;
  final VoidCallback? onTap;
  const _ListRowData({
    required this.icon,
    required this.color,
    required this.title,
    required this.sub,
    this.onTap,
  });
}

// ---------------------------------------------------------------------------
// Painter para borda tracejada
// ---------------------------------------------------------------------------
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.radius = 28,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    const dashWidth = 5.0;
    const dashSpace = 5.0;
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(
            distance,
            next > metric.length ? metric.length : next,
          ),
          paint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) => false;
}