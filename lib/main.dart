import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF111111),
        fontFamily: 'Roboto',
      ),
      home: const ComponentsPage(),
    );
  }
}

class ComponentsPage extends StatefulWidget {
  const ComponentsPage({super.key});

  @override
  State<ComponentsPage> createState() => _ComponentsPageState();
}

// ---------------------------------------------------------------------------
// Enums e classes auxiliares
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
// State
// ---------------------------------------------------------------------------
class _ComponentsPageState extends State<ComponentsPage> {
  // Segmentado
  int _selectedSegment = 0;

  // Switch
  bool _notificationsEnabled = true;
  bool _weeklyRepeat = false;

  // Checkbox
  bool _emailInvite = true;
  bool _privateEvent = false;

  // Radio
  int _radioSelected = 0;

  // Search
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

  // ---------------------------------------------------------------------------
  // Helpers de estilo
  // ---------------------------------------------------------------------------
  Widget _groupLabel(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF4A4A4A),
          letterSpacing: 0.6,
        ),
      ),
    );
  }

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
        return const _VariantColors(Color(0xFF2E8BC9), Colors.white);
      case BtnVariant.danger:
        return const _VariantColors(Color(0xFFE05E5E), Colors.white);
      case BtnVariant.success:
        return const _VariantColors(Color(0xFF4EC994), Color(0xFF0D1F16));
      case BtnVariant.warning:
        return const _VariantColors(Color(0xFFF0A500), Color(0xFF1F1600));
      case BtnVariant.secondary:
        return const _VariantColors(Color(0xFF232323), Colors.white);
      case BtnVariant.ghost:
        return const _VariantColors(Colors.transparent, Color(0xFF999999));
      case BtnVariant.outline:
        return const _VariantColors(
          Colors.transparent,
          Color(0xFF4FA3D8),
          Color(0xFF2E6F96),
        );
      case BtnVariant.outlineDanger:
        return const _VariantColors(
          Colors.transparent,
          Color(0xFFE08080),
          Color(0xFF96403F),
        );
      case BtnVariant.tintBlue:
        return const _VariantColors(
          Color(0x262E8BC9),
          Color(0xFF6DB4E6),
        );
      case BtnVariant.tintRed:
        return const _VariantColors(
          Color(0x26E05E5E),
          Color(0xFFEF9797),
        );
    }
  }

  // ---------------------------------------------------------------------------
  // Botões
  // ---------------------------------------------------------------------------
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
    final colors = _getVariantColors(variant);
    final borderRadius = BorderRadius.circular(50);
    final side = colors.borderColor != null
        ? BorderSide(color: colors.borderColor!, width: 1.5)
        : BorderSide.none;

    Widget content;
    if (loading) {
      content = const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      );
    } else if (iconOnly && icon != null) {
      content = Icon(icon, size: style.iconSize, color: colors.foreground);
    } else {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: style.iconSize, color: colors.foreground),
            const SizedBox(width: 7),
          ],
          if (label.isNotEmpty)
            Text(
              label,
              style: TextStyle(
                fontSize: style.fontSize,
                fontWeight: FontWeight.w600,
                color: colors.foreground,
                letterSpacing: 0.1,
              ),
            ),
        ],
      );
    }

    Widget button = Material(
      color: colors.background,
      shape: RoundedRectangleBorder(borderRadius: borderRadius, side: side),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: (disabled || loading) ? null : onTap,
        borderRadius: borderRadius,
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

    if (fullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    }
    if (disabled) {
      button = Opacity(opacity: 0.32, child: IgnorePointer(child: button));
    }
    return button;
  }

  Widget _buildSegmentedControl() {
    const items = ['Dia', 'Semana', 'Mês'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(items.length, (i) {
          final selected = _selectedSegment == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedSegment = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF2E8BC9) : Colors.transparent,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                items[i],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : const Color(0xFF777777),
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
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildButton(
              label: 'Eliminar',
              variant: BtnVariant.danger,
              size: ButtonSize.medium,
              onTap: () {},
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildButton(
              label: 'Cancelar',
              variant: BtnVariant.primary,
              size: ButtonSize.medium,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Diálogo
  // ---------------------------------------------------------------------------
  void _showDemoDialog() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFF1C1C1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Eliminar evento?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Esta ação não pode ser desfeita.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF999999),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF252525),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _dialogButton(
                          'Eliminar',
                          bg: const Color(0xFFE05E5E),
                          onTap: () => Navigator.pop(dialogContext),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _dialogButton(
                          'Cancelar',
                          bg: const Color(0xFF2E8BC9),
                          onTap: () => Navigator.pop(dialogContext),
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

  Widget _dialogButton(
    String label, {
    required Color bg,
    required VoidCallback onTap,
  }) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(50),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
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
        color: color ?? const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 16,
            offset: Offset(0, 4),
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
        children: const [
          Text(
            'Sincronização automática',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Os teus eventos são sincronizados com o calendário do dispositivo a cada 15 minutos.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF888888),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListCardWithRows(List<_ListRowData> rows) {
    return Column(
      children: List.generate(rows.length, (i) {
        final isFirst = i == 0;
        final isLast = i == rows.length - 1;
        BorderRadiusGeometry radius;
        if (isFirst && rows.length == 1) {
          radius = const BorderRadius.all(Radius.circular(28));
        } else if (isFirst) {
          radius = const BorderRadius.vertical(top: Radius.circular(28));
        } else if (isLast) {
          radius = const BorderRadius.vertical(bottom: Radius.circular(28));
        } else {
          radius = const BorderRadius.all(Radius.circular(8));
        }
        return Container(
          margin: isLast ? EdgeInsets.zero : const EdgeInsets.only(bottom: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: radius,
            boxShadow: const [
              BoxShadow(
                color: Color(0x4D000000),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: radius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: rows[i].onTap ?? () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
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
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            rows[i].sub,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Color(0xFF444444),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildIconListCard() {
    return _buildListCardWithRows(const [
      _ListRowData(
        icon: Icons.calendar_today,
        color: Color(0xFF5BA9DD),
        title: 'Calendário',
        sub: '3 eventos hoje',
      ),
      _ListRowData(
        icon: Icons.check,
        color: Color(0xFF6FDCAE),
        title: 'Tarefas concluídas',
        sub: '8 de 10 esta semana',
      ),
      _ListRowData(
        icon: Icons.notifications_outlined,
        color: Color(0xFFEF9797),
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
            iconColor: const Color(0xFF5BA9DD),
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
            iconColor: const Color(0xFFEF9797),
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
    final trendColor = trendUp ? const Color(0xFF4EC994) : const Color(0xFFE05E5E);
    return _card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: iconColor),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFF666666),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                trendUp ? Icons.arrow_upward : Icons.arrow_downward,
                size: 11,
                color: trendColor,
              ),
              const SizedBox(width: 4),
              Text(
                trendText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: trendColor,
                ),
              ),
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
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF232325),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '18',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        'Ago',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2E8BC9),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reunião de equipa',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: const [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Color(0xFF777777),
                          ),
                          SizedBox(width: 5),
                          Text(
                            '14:00 — 15:00',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF777777),
                            ),
                          ),
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
              color: const Color(0xFF252525),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _eventActionButton(
                    'Adiar',
                    bg: Colors.transparent,
                    fg: const Color(0xFF999999),
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _eventActionButton(
                    'Entrar',
                    bg: const Color(0xFF2E8BC9),
                    fg: Colors.white,
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _eventActionButton(
    String label, {
    required Color bg,
    required Color fg,
    required VoidCallback onTap,
  }) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(50),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
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
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF2E8BC9), Color(0xFF1F6A9E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            alignment: Alignment.center,
            child: const Text(
              'AF',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alfredo Ferreira',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'alfredo@nexa.app',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF777777),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            size: 20,
            color: Color(0xFF999999),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCards() {
    return Column(
      children: [
        _buildAlertCard(
          icon: Icons.warning_amber_rounded,
          iconColor: const Color(0xFFF0A500),
          bg: const Color(0x1AF0A500),
          title: 'Conflito de horário',
          text: 'Tens dois eventos sobrepostos às 15:00.',
        ),
        const SizedBox(height: 10),
        _buildAlertCard(
          icon: Icons.error_outline,
          iconColor: const Color(0xFFE05E5E),
          bg: const Color(0x1AE05E5E),
          title: 'Falha na sincronização',
          text: 'Não foi possível ligar ao Google Calendar.',
        ),
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
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
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
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFFAAAAAA),
                    height: 1.4,
                  ),
                ),
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
            children: const [
              Text(
                'Armazenamento',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                '68%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF5BA9DD),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: LinearProgressIndicator(
              value: 0.68,
              minHeight: 8,
              backgroundColor: const Color(0xFF262626),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E8BC9)),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '6.8 GB de 10 GB usados',
            style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCard() {
    return CustomPaint(
      painter: DashedBorderPainter(
        color: const Color(0xFF2A2A2A),
        strokeWidth: 1.5,
        radius: 28,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 18, color: Color(0xFF666666)),
              SizedBox(height: 10),
              Text(
                'Adicionar novo evento',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF777777),
                ),
              ),
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
    EdgeInsetsGeometry contentPadding =
        const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
    Color? fillColor = const Color(0xFF1C1C1E),
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
          style: style ??
              const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
          cursorColor: const Color(0xFF2E8BC9),
          decoration: InputDecoration(
            filled: true,
            fillColor: fillColor,
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF5A5A5A),
              fontWeight: FontWeight.w400,
            ),
            counterText: maxLength != null ? '' : null,
            prefixIcon: prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 18, right: 10),
                    child: Icon(
                      prefixIcon,
                      size: 14,
                      color: error
                          ? const Color(0xFFE05E5E)
                          : const Color(0xFF666666),
                    ),
                  )
                : null,
            prefixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: suffix != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: suffix,
                  )
                : null,
            suffixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            contentPadding: contentPadding,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(
                color: error ? const Color(0xFFE05E5E) : Colors.transparent,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(
                color: error ? const Color(0xFFE05E5E) : const Color(0xFF2E8BC9),
                width: 1.5,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabeledField(
    String? label, {
    required Widget input,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFFCCCCCC),
            ),
          ),
          const SizedBox(height: 6),
        ],
        input,
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              errorText,
              style: const TextStyle(fontSize: 12, color: Color(0xFFE08080)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSwitchRow({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ],
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF2E8BC9),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFF333333),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckRow({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(18),
      ),
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
                activeColor: const Color(0xFF2E8BC9),
                checkColor: Colors.white,
                fillColor: WidgetStateProperty.resolveWith<Color?>(
                  (states) => states.contains(WidgetState.selected)
                      ? const Color(0xFF2E8BC9)
                      : const Color(0xFF2A2A2A),
                ),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFDDDDDD),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadioRow({
    required String label,
    required int index,
    required int groupValue,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(18),
      ),
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
                activeColor: const Color(0xFF2E8BC9),
                fillColor: WidgetStateProperty.resolveWith<Color?>(
                  (states) => states.contains(WidgetState.selected)
                      ? const Color(0xFF2E8BC9)
                      : const Color(0xFF2A2A2A),
                ),
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFDDDDDD),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onOtpChanged(int index, String value) {
    if (value.length == 1 && index < 3) {
      _otpFocusNodes[index + 1].requestFocus();
    }
  }

  // ---------------------------------------------------------------------------
  // Modal / Bottom Sheet
  // ---------------------------------------------------------------------------
  void _showDemoSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
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
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A3A3C),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Novo evento',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Preenche os detalhes abaixo para adicionar um novo evento ao teu calendário.',
                style: TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF999999),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 18),
              _buildSheetFieldGroup(),
              const SizedBox(height: 10),
              _buildButton(
                label: 'Guardar evento',
                icon: Icons.check,
                variant: BtnVariant.primary,
                size: ButtonSize.medium,
                fullWidth: true,
                onTap: () => Navigator.pop(sheetContext),
              ),
              const SizedBox(height: 10),
              _buildButton(
                label: 'Cancelar',
                variant: BtnVariant.ghost,
                size: ButtonSize.medium,
                fullWidth: true,
                onTap: () => Navigator.pop(sheetContext),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSheetFieldGroup() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF262626)),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          _buildSheetInputRow(
            icon: Icons.edit,
            hint: 'Título do evento',
            isFirst: true,
            isLast: false,
          ),
          _buildSheetInputRow(
            icon: Icons.calendar_today,
            hint: '18 de agosto',
            isFirst: false,
            isLast: false,
          ),
          _buildSheetInputRow(
            icon: Icons.access_time,
            hint: '14:00 — 15:00',
            isFirst: false,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSheetInputRow({
    required IconData icon,
    required String hint,
    required bool isFirst,
    required bool isLast,
  }) {
    BorderRadius radius;
    if (isFirst) {
      radius = const BorderRadius.vertical(top: Radius.circular(28));
    } else if (isLast) {
      radius = const BorderRadius.vertical(bottom: Radius.circular(28));
    } else {
      radius = const BorderRadius.all(Radius.circular(8));
    }
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: radius,
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(icon, size: 15, color: const Color(0xFF5BA9DD)),
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: const TextStyle(color: Color(0xFF555555)),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalList() {
    return _buildListCardWithRows([
      const _ListRowData(
        icon: Icons.calendar_today,
        color: Color(0xFF5BA9DD),
        title: 'Calendário',
        sub: '3 eventos hoje',
      ),
      _ListRowData(
        icon: Icons.add,
        color: const Color(0xFF5BA9DD),
        title: 'Abrir modal',
        sub: 'Toca aqui para testar',
        onTap: _showDemoSheet,
      ),
      const _ListRowData(
        icon: Icons.notifications_outlined,
        color: Color(0xFFEF9797),
        title: 'Lembretes',
        sub: '2 pendentes',
      ),
    ]);
  }

  // ---------------------------------------------------------------------------
  // Seções
  // ---------------------------------------------------------------------------
  Widget _buildButtonsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _groupLabel('Primary'),
        _buildButton(
          label: 'Novo evento',
          icon: Icons.add,
          variant: BtnVariant.primary,
          size: ButtonSize.medium,
          fullWidth: true,
          onTap: () {},
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildButton(
              label: 'Pequeno',
              variant: BtnVariant.primary,
              size: ButtonSize.small,
              onTap: () {},
            ),
            _buildButton(
              label: 'Médio',
              variant: BtnVariant.primary,
              size: ButtonSize.medium,
              onTap: () {},
            ),
            _buildButton(
              label: 'Grande',
              variant: BtnVariant.primary,
              size: ButtonSize.large,
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 26),
        _groupLabel('Destructive'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildButton(
              label: 'Eliminar',
              icon: Icons.delete,
              variant: BtnVariant.danger,
              size: ButtonSize.medium,
              onTap: () {},
            ),
            _buildButton(
              label: 'Cancelar assinatura',
              variant: BtnVariant.outlineDanger,
              size: ButtonSize.medium,
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 26),
        _groupLabel('Status'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildButton(
              label: 'Aprovado',
              icon: Icons.check,
              variant: BtnVariant.success,
              size: ButtonSize.small,
              onTap: () {},
            ),
            _buildButton(
              label: 'Pendente',
              icon: Icons.warning_amber_rounded,
              variant: BtnVariant.warning,
              size: ButtonSize.small,
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 26),
        _groupLabel('Secondary / Ghost / Outline'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildButton(
              label: 'Secundário',
              variant: BtnVariant.secondary,
              size: ButtonSize.medium,
              onTap: () {},
            ),
            _buildButton(
              label: 'Ghost',
              variant: BtnVariant.ghost,
              size: ButtonSize.medium,
              onTap: () {},
            ),
            _buildButton(
              label: 'Outline azul',
              variant: BtnVariant.outline,
              size: ButtonSize.medium,
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 26),
        _groupLabel('Tint'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildButton(
              label: 'Notificar',
              icon: Icons.notifications_outlined,
              variant: BtnVariant.tintBlue,
              size: ButtonSize.medium,
              onTap: () {},
            ),
            _buildButton(
              label: 'Reportar',
              icon: Icons.flag,
              variant: BtnVariant.tintRed,
              size: ButtonSize.medium,
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 26),
        _groupLabel('Icon only'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildButton(
              label: '',
              icon: Icons.add,
              variant: BtnVariant.primary,
              size: ButtonSize.small,
              iconOnly: true,
              onTap: () {},
            ),
            _buildButton(
              label: '',
              icon: Icons.more_horiz,
              variant: BtnVariant.secondary,
              size: ButtonSize.medium,
              iconOnly: true,
              onTap: () {},
            ),
            _buildButton(
              label: '',
              icon: Icons.close,
              variant: BtnVariant.danger,
              size: ButtonSize.medium,
              iconOnly: true,
              onTap: () {},
            ),
            _buildButton(
              label: '',
              icon: Icons.share,
              variant: BtnVariant.ghost,
              size: ButtonSize.large,
              iconOnly: true,
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 26),
        _groupLabel('Disabled / Loading'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildButton(
              label: 'Indisponível',
              variant: BtnVariant.primary,
              size: ButtonSize.medium,
              disabled: true,
              onTap: () {},
            ),
            _buildButton(
              label: 'A carregar',
              variant: BtnVariant.primary,
              size: ButtonSize.medium,
              loading: true,
              onTap: () {},
            ),
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
        _buildButton(
          label: 'Abrir diálogo',
          variant: BtnVariant.primary,
          size: ButtonSize.medium,
          fullWidth: true,
          onTap: _showDemoDialog,
        ),
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
        _buildLabeledField(
          'Nome do evento',
          input: _buildTextField(hint: 'Reunião de equipa'),
        ),
        const SizedBox(height: 26),
        _groupLabel('Com ícone'),
        _buildTextField(
          hint: 'Email',
          prefixIcon: Icons.mail_outline,
        ),
        const SizedBox(height: 10),
        _buildTextField(
          hint: 'Palavra-passe',
          prefixIcon: Icons.lock_outline,
          suffix: const Icon(
            Icons.visibility,
            size: 13,
            color: Color(0xFF666666),
          ),
        ),
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
              decoration: const BoxDecoration(
                color: Color(0xFF333333),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.close,
                size: 10,
                color: Color(0xFF999999),
              ),
            ),
          ),
        ),
        const SizedBox(height: 26),
        _groupLabel('Estado de erro'),
        _buildLabeledField(
          'Título',
          input: _buildTextField(
            hint: 'Título do evento',
            prefixIcon: Icons.warning_amber_rounded,
            error: true,
          ),
          errorText: 'Este campo é obrigatório',
        ),
        const SizedBox(height: 26),
        _groupLabel('Tamanhos'),
        _buildTextField(hint: 'Pequeno', radius: 50),
        const SizedBox(height: 10),
        _buildTextField(hint: 'Médio', radius: 50),
        const SizedBox(height: 10),
        _buildTextField(hint: 'Grande', radius: 50),
        const SizedBox(height: 26),
        _groupLabel('Desativado'),
        _buildTextField(hint: 'Indisponível', disabled: true),
        const SizedBox(height: 26),
        _groupLabel('Textarea'),
        _buildLabeledField(
          'Notas',
          input: _buildTextField(
            hint: 'Adiciona uma descrição...',
            isTextArea: true,
            radius: 24,
          ),
        ),
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1C1C1E),
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF2E8BC9),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 26),
        _groupLabel('Switch'),
        _buildSwitchRow(
          title: 'Notificações',
          subtitle: 'Alertas antes de cada evento',
          value: _notificationsEnabled,
          onChanged: (v) => setState(() => _notificationsEnabled = v),
        ),
        const SizedBox(height: 10),
        _buildSwitchRow(
          title: 'Repetir semanalmente',
          value: _weeklyRepeat,
          onChanged: (v) => setState(() => _weeklyRepeat = v),
        ),
        const SizedBox(height: 26),
        _groupLabel('Checkbox'),
        _buildCheckRow(
          label: 'Enviar convite por email',
          value: _emailInvite,
          onChanged: (v) => setState(() => _emailInvite = v!),
        ),
        const SizedBox(height: 10),
        _buildCheckRow(
          label: 'Marcar como privado',
          value: _privateEvent,
          onChanged: (v) => setState(() => _privateEvent = v!),
        ),
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
        _buildButton(
          label: 'Abrir modal',
          variant: BtnVariant.primary,
          size: ButtonSize.medium,
          fullWidth: true,
          onTap: _showDemoSheet,
        ),
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
// Painter para borda tracejada (card de adicionar)
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