// ╔══════════════════════════════════════════════════════════════════╗
// ║         FocusGuard – Smart Focus & Drowsiness Monitor           ║
// ║         Version 2.0 — Premium Production Build                  ║
// ║         Architecture: Clean Widget Separation + setState        ║
// ║         Designer notes: Obsidian + Aurora aesthetic             ║
// ╚══════════════════════════════════════════════════════════════════╝

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────
//  ENTRY POINT
// ─────────────────────────────────────────────────────────────────
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF07090F),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const FocusGuardApp());
}

// ─────────────────────────────────────────────────────────────────
//  DESIGN TOKENS  ·  "Obsidian Aurora" palette
// ─────────────────────────────────────────────────────────────────
class FG {
  // Surfaces
  static const Color void_    = Color(0xFF07090F); // deepest bg
  static const Color obsidian = Color(0xFF0D1117); // scaffold
  static const Color carbon   = Color(0xFF161B26); // card base
  static const Color graphite = Color(0xFF1E2535); // card elevated
  static const Color slate    = Color(0xFF2A3347); // borders
  static const Color fog      = Color(0xFF3D4F6B); // disabled/muted

  // Aurora accents
  static const Color aurora   = Color(0xFF00D4FF); // primary cyan
  static const Color plasma   = Color(0xFF7B5EA7); // purple mid
  static const Color ember    = Color(0xFFFF6B35); // danger/warning
  static const Color jade     = Color(0xFF00C896); // success/focus

  // Semantic
  static const Color danger   = Color(0xFFFF4757);
  static const Color caution  = Color(0xFFFFD166);
  static const Color ok       = Color(0xFF06D6A0);

  // Text
  static const Color textHigh = Color(0xFFECF0FF);
  static const Color textMid  = Color(0xFF8090B0);
  static const Color textLow  = Color(0xFF3D4F6B);

  // Gradients
  static const LinearGradient auroraGrad = LinearGradient(
    colors: [Color(0xFF00D4FF), Color(0xFF7B5EA7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient jadeGrad = LinearGradient(
    colors: [Color(0xFF00C896), Color(0xFF00A8E0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient emberGrad = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF4757)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient bgGrad = LinearGradient(
    colors: [Color(0xFF07090F), Color(0xFF0D1117), Color(0xFF111827)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Typography scale
  static TextStyle display(double size, {Color? color, double? spacing}) =>
      TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w900,
        color: color ?? textHigh,
        letterSpacing: spacing ?? -1.5,
        height: 1.05,
      );

  static TextStyle heading(double size, {Color? color}) => TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color ?? textHigh,
        letterSpacing: -0.5,
      );

  static TextStyle body(double size, {Color? color, double? height}) =>
      TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: color ?? textMid,
        height: height ?? 1.55,
      );

  static TextStyle label(double size, {Color? color}) => TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color ?? textMid,
        letterSpacing: 0.8,
      );
}

// ─────────────────────────────────────────────────────────────────
//  APP ROOT
// ─────────────────────────────────────────────────────────────────
class FocusGuardApp extends StatelessWidget {
  const FocusGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FocusGuard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: FG.obsidian,
        fontFamily: 'SF Pro Display',
        colorScheme: const ColorScheme.dark(
          background: FG.obsidian,
          surface: FG.carbon,
          primary: FG.aurora,
          secondary: FG.jade,
          error: FG.danger,
        ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      home: const HomeScreen(),
    );
  }
}

// ╔══════════════════════════════════════════════════════════════════╗
// ║                    SHARED COMPONENTS                            ║
// ╚══════════════════════════════════════════════════════════════════╝

// ── Gradient text ──────────────────────────────────────────────────
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;

  const GradientText(this.text,
      {super.key, required this.style, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
          Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(text, style: style),
    );
  }
}

// ── Aurora card (layered glassy surface) ───────────────────────────
class AuroraCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final double radius;
  final List<BoxShadow>? shadows;

  const AuroraCard({
    super.key,
    required this.child,
    this.padding,
    this.borderColor,
    this.radius = 20,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FG.carbon,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
            color: borderColor ?? FG.slate.withOpacity(0.6), width: 1),
        boxShadow: shadows ??
            [
              BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 8)),
            ],
      ),
      child: child,
    );
  }
}

// ── Ripple-press button ────────────────────────────────────────────
class FGButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final Gradient? gradient;
  final Color? solidColor;
  final IconData? icon;
  final double height;
  final double? width;
  final TextStyle? labelStyle;
  final bool outlined;
  final Color? outlineColor;

  const FGButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.gradient,
    this.solidColor,
    this.icon,
    this.height = 54,
    this.width,
    this.labelStyle,
    this.outlined = false,
    this.outlineColor,
  });

  @override
  State<FGButton> createState() => _FGButtonState();
}

class _FGButtonState extends State<FGButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1, end: 0.96)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        HapticFeedback.lightImpact();
        widget.onPressed();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            gradient: widget.outlined ? null : widget.gradient,
            color: widget.outlined
                ? Colors.transparent
                : (widget.gradient == null ? widget.solidColor : null),
            borderRadius: BorderRadius.circular(14),
            border: widget.outlined
                ? Border.all(
                    color:
                        widget.outlineColor ?? FG.slate.withOpacity(0.8),
                    width: 1.5)
                : null,
            boxShadow: widget.outlined
                ? null
                : [
                    BoxShadow(
                      color: (widget.solidColor ?? FG.aurora)
                          .withOpacity(0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon,
                    color: Colors.white,
                    size: 18),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: widget.labelStyle ??
                    FG.label(15, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Animated dot indicator ─────────────────────────────────────────
class PulsingDot extends StatefulWidget {
  final Color color;
  final double size;
  const PulsingDot({super.key, required this.color, this.size = 8});

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color.withOpacity(_anim.value),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: widget.color.withOpacity(_anim.value * 0.6),
                blurRadius: 6,
                spreadRadius: 1),
          ],
        ),
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════════════════╗
// ║                       HOME SCREEN                               ║
// ╚══════════════════════════════════════════════════════════════════╝
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  int _selectedDuration = 25;
  final List<_DurationOption> _durations = const [
    _DurationOption(15, 'Quick Sprint', Icons.flash_on_rounded),
    _DurationOption(25, 'Deep Work',   Icons.psychology_rounded),
    _DurationOption(45, 'Flow State',  Icons.auto_awesome_rounded),
  ];

  // Staggered entrance animations
  late AnimationController _entranceCtrl;
  late List<Animation<double>> _fadeAnims;
  late List<Animation<Offset>> _slideAnims;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));

    // 5 staggered elements: header, hero, stats, picker, button
    _fadeAnims = List.generate(5, (i) {
      final start = i * 0.12;
      return Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _entranceCtrl,
        curve: Interval(start, (start + 0.4).clamp(0, 1), curve: Curves.easeOut),
      ));
    });
    _slideAnims = List.generate(5, (i) {
      final start = i * 0.12;
      return Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
          .animate(CurvedAnimation(
        parent: _entranceCtrl,
        curve: Interval(start, (start + 0.4).clamp(0, 1), curve: Curves.easeOut),
      ));
    });

    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  void _startSession() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(_createRoute(
        SessionScreen(durationMinutes: _selectedDuration)));
  }

  /// Custom page transition: slide up + fade
  PageRouteBuilder _createRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: SlideTransition(
            position: Tween<Offset>(
                    begin: const Offset(0, 0.06), end: Offset.zero)
                .animate(CurvedAnimation(
                    parent: animation, curve: Curves.easeOut)),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: FG.bgGrad),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.06, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStaggered(0, _buildTopBar()),
                SizedBox(height: size.height * 0.045),
                _buildStaggered(1, _buildHero()),
                SizedBox(height: size.height * 0.04),
                _buildStaggered(2, _buildWeeklyStreak()),
                SizedBox(height: size.height * 0.04),
                _buildStaggered(3, _buildDurationPicker()),
                SizedBox(height: size.height * 0.04),
                _buildStaggered(4, _buildStartButton()),
                const SizedBox(height: 32),
                _buildStaggered(4, _buildCoachTip()),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStaggered(int index, Widget child) {
    return FadeTransition(
      opacity: _fadeAnims[index],
      child: SlideTransition(
          position: _slideAnims[index], child: child),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        // Logo mark
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: FG.auroraGrad,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: FG.aurora.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: const Icon(Icons.shield_rounded, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GradientText(
              'FocusGuard',
              style: FG.heading(18),
              gradient: FG.auroraGrad,
            ),
            Text('v2.0 Pro', style: FG.body(11, color: FG.textLow)),
          ],
        ),
        const Spacer(),
        // Notification bell
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
              color: FG.carbon,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: FG.slate, width: 1)),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.notifications_outlined,
                  color: FG.textMid, size: 20),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                      color: FG.ember, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Eyebrow
        Row(
          children: [
            PulsingDot(color: FG.jade),
            const SizedBox(width: 8),
            Text('Ready to focus', style: FG.label(12, color: FG.jade)),
          ],
        ),
        const SizedBox(height: 14),
        RichText(
          text: TextSpan(children: [
            TextSpan(
                text: 'Train Your\n',
                style: FG.display(38, spacing: -1.8)),
            WidgetSpan(
              child: GradientText(
                'Focus Muscle.',
                style: FG.display(38, spacing: -1.8),
                gradient: FG.auroraGrad,
              ),
            ),
          ]),
        ),
        const SizedBox(height: 14),
        Text(
          'Science-backed focus sessions with\nreal-time distraction monitoring.',
          style: FG.body(15, height: 1.65),
        ),
      ],
    );
  }

  Widget _buildWeeklyStreak() {
    // Full unique abbreviations shown BELOW each tile — no ambiguous "T" vs "T"
    final dayLabels  = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    // Single-letter shown INSIDE the incomplete tile (kept short for space)
    final dayLetters = ['M',   'Tu',  'W',   'Th',  'F',   'Sa',  'Su'];
    // Mock completion data — replace with your persistence layer later
    final completed  = [true, true, true, false, true, false, false];

    // ── Dynamically calculate current streak ──
    // Walk backwards from today (index 6 = Sun) to find the longest
    // unbroken run of completed days ending at or before "today".
    // For this mock we treat Friday (index 4) as "today".
    const todayIndex = 4; // 0=Mon … 6=Sun
    int streak = 0;
    for (int i = todayIndex; i >= 0; i--) {
      if (completed[i]) {
        streak++;
      } else {
        break; // chain broken — stop counting
      }
    }

    return AuroraCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Weekly Streak', style: FG.heading(14)),
              // Badge shows REAL computed streak
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: FG.ember.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: FG.ember.withOpacity(0.35), width: 1)),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department_rounded,
                        color: FG.ember, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '$streak day${streak == 1 ? '' : 's'} streak',
                      style: FG.label(11, color: FG.ember),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final done    = completed[i];
              final isToday = i == todayIndex;
              return Column(
                children: [
                  // Tile
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300 + i * 60),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: done ? FG.auroraGrad : null,
                      color: done ? null : FG.graphite,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        // Today's incomplete tile gets an aurora outline
                        color: isToday && !done
                            ? FG.aurora.withOpacity(0.5)
                            : done
                                ? Colors.transparent
                                : FG.slate,
                        width: isToday && !done ? 1.5 : 1,
                      ),
                      boxShadow: done
                          ? [
                              BoxShadow(
                                  color: FG.aurora.withOpacity(0.3),
                                  blurRadius: 8)
                            ]
                          : null,
                    ),
                    child: Center(
                      child: done
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 16)
                          // Show the 2-letter abbreviation so Thu ≠ Tue
                          : Text(
                              dayLetters[i],
                              style: FG.label(
                                10,
                                color: isToday ? FG.aurora : FG.textLow,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Label below tile — full 3-letter abbreviation
                  Text(
                    dayLabels[i],
                    style: FG.body(
                      10,
                      color: isToday ? FG.aurora : FG.textLow,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            children: [
              Text('Session Duration', style: FG.heading(16)),
              const Spacer(),
              Text('Choose wisely', style: FG.body(12, color: FG.textLow)),
            ],
          ),
        ),
        Row(
          children: _durations.map((opt) {
            final selected = opt.minutes == _selectedDuration;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    right: opt == _durations.last ? 0 : 10),
                child: _DurationTile(
                  option: opt,
                  selected: selected,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedDuration = opt.minutes);
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStartButton() {
    return Column(
      children: [
        // Main CTA
        SizedBox(
          width: double.infinity,
          child: FGButton(
            label: 'Begin Focus Session',
            icon: Icons.play_arrow_rounded,
            gradient: FG.auroraGrad,
            height: 62,
            onPressed: _startSession,
            labelStyle: FG.label(16, color: Colors.white),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.info_outline_rounded,
                color: FG.textLow, size: 13),
            const SizedBox(width: 6),
            Text(
              'Focus checks every 40s · Auto-alerts on inactivity',
              style: FG.body(11, color: FG.textLow),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCoachTip() {
    return AuroraCard(
      borderColor: FG.jade.withOpacity(0.3),
      shadows: [
        BoxShadow(
            color: FG.jade.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 6)),
      ],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: FG.jade.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.tips_and_updates_rounded,
                color: FG.jade, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Coach\'s Tip',
                    style: FG.label(12, color: FG.jade)),
                const SizedBox(height: 5),
                Text(
                  '"Deep work requires undivided attention. Even one distraction can cost 23 minutes of recovery time."',
                  style: FG.body(13, height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Duration tile with animated selection ─────────────────────────
@immutable
class _DurationOption {
  final int minutes;
  final String label;
  final IconData icon;
  const _DurationOption(this.minutes, this.label, this.icon);
}

class _DurationTile extends StatefulWidget {
  final _DurationOption option;
  final bool selected;
  final VoidCallback onTap;

  const _DurationTile(
      {super.key,
      required this.option,
      required this.selected,
      required this.onTap});

  @override
  State<_DurationTile> createState() => _DurationTileState();
}

class _DurationTileState extends State<_DurationTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _scale = Tween<double>(begin: 1, end: 0.94)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          decoration: BoxDecoration(
            gradient: widget.selected ? FG.auroraGrad : null,
            color: widget.selected ? null : FG.carbon,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color:
                  widget.selected ? Colors.transparent : FG.slate,
              width: 1,
            ),
            boxShadow: widget.selected
                ? [
                    BoxShadow(
                        color: FG.aurora.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 6))
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                widget.option.icon,
                color: widget.selected ? Colors.white : FG.textMid,
                size: 22,
              ),
              const SizedBox(height: 10),
              Text(
                '${widget.option.minutes}',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: widget.selected ? Colors.white : FG.textHigh,
                  height: 1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'min',
                style: FG.body(11,
                    color:
                        widget.selected ? Colors.white70 : FG.textMid),
              ),
              const SizedBox(height: 8),
              Text(
                widget.option.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: widget.selected ? Colors.white70 : FG.textLow,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════════════════╗
// ║                     SESSION SCREEN                              ║
// ╚══════════════════════════════════════════════════════════════════╝
class SessionScreen extends StatefulWidget {
  final int durationMinutes;
  const SessionScreen({super.key, required this.durationMinutes});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen>
    with TickerProviderStateMixin {

  // ── Core state ──
  late int _totalSeconds;
  late int _remaining;
  bool _paused = false;
  bool _dialogOpen = false;
  int _distractions = 0;
  int _checkins = 0;
  int _successfulCheckins = 0;

  // ── Timers ──
  Timer? _countdown;
  Timer? _checkTimer;
  Timer? _autoMiss;

  // ── Ring glow colour (changes with focus state) ──
  Color _ringColor = FG.aurora;
  Color _bgAccent  = const Color(0xFF00D4FF);

  // ── Animations ──
  late AnimationController _pulseCtrl;   // timer ring glow
  late AnimationController _bgCtrl;      // background colour shift
  late AnimationController _waveCtrl;    // ambient wave
  late AnimationController _entranceCtrl;
  late Animation<double> _entranceFade;
  late Animation<Offset> _entranceSlide;

  // For animated bg colour
  Color _currentBg  = FG.obsidian;
  Color _targetBg   = FG.obsidian;

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.durationMinutes * 60;
    _remaining    = _totalSeconds;

    // Pulse – rings breathe
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);

    // Wave – ambient bg animation
    _waveCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 8))
      ..repeat();

    // Background accent shift
    _bgCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));

    // Entrance
    _entranceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _entranceFade = CurvedAnimation(
        parent: _entranceCtrl, curve: Curves.easeOut);
    _entranceSlide = Tween<Offset>(
            begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _entranceCtrl, curve: Curves.easeOut));
    _entranceCtrl.forward();

    _startCountdown();
    _scheduleCheckin();
  }

  @override
  void dispose() {
    _countdown?.cancel();
    _checkTimer?.cancel();
    _autoMiss?.cancel();
    _pulseCtrl.dispose();
    _bgCtrl.dispose();
    _waveCtrl.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  // ── Timer logic ────────────────────────────────────────────────
  void _startCountdown() {
    _countdown = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_paused || _dialogOpen) return;
      if (_remaining <= 0) {
        _countdown?.cancel();
        _checkTimer?.cancel();
        _navigateSummary();
        return;
      }
      setState(() => _remaining--);
    });
  }

  void _scheduleCheckin() {
    // Check-in every 40 seconds
    _checkTimer =
        Timer.periodic(const Duration(seconds: 40), (_) {
      if (!_paused && !_dialogOpen && mounted) {
        _showCheckinDialog();
      }
    });
  }

  void _togglePause() {
    HapticFeedback.lightImpact();
    setState(() => _paused = !_paused);
    _shiftRingColor(_paused ? FG.caution : FG.aurora);
  }

  void _endSession() {
    _countdown?.cancel();
    _checkTimer?.cancel();
    _autoMiss?.cancel();
    HapticFeedback.heavyImpact();
    _navigateSummary();
  }

  // ── Focus check-in dialog ──────────────────────────────────────
  void _showCheckinDialog() {
    if (!mounted) return;
    setState(() {
      _dialogOpen = true;
      _checkins++;
    });
    // Auto-miss after 6 seconds
    _autoMiss = Timer(const Duration(seconds: 6), () {
      if (_dialogOpen && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        _onMissed();
      }
    });

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.75),
      transitionDuration: const Duration(milliseconds: 320),
      transitionBuilder: (_, anim, __, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.elasticOut),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
      pageBuilder: (_, __, ___) => _CheckinDialog(
        onFocused: () {
          _autoMiss?.cancel();
          Navigator.of(context, rootNavigator: true).pop();
          _onFocused();
        },
        onDistracted: () {
          _autoMiss?.cancel();
          Navigator.of(context, rootNavigator: true).pop();
          _onDistracted();
        },
      ),
    ).then((_) {
      if (mounted) setState(() => _dialogOpen = false);
    });
  }

  void _onFocused() {
    setState(() {
      _successfulCheckins++;
    });
    _shiftRingColor(FG.jade);
    _showToast('⚡ Sharp as ever. Keep the momentum!', FG.jade);
    Future.delayed(const Duration(seconds: 3),
        () => _shiftRingColor(FG.aurora));
  }

  void _onDistracted() {
    setState(() => _distractions++);
    _shiftRingColor(FG.danger);
    _showToast('🎯 Refocus — reclaim your session!', FG.ember);
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(seconds: 3),
        () => _shiftRingColor(FG.aurora));
  }

  void _onMissed() {
    setState(() => _distractions++);
    _shiftRingColor(FG.danger);
    _showToast('⚠️ Inactivity detected. Stay focused!', FG.danger);
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(seconds: 3),
        () => _shiftRingColor(FG.aurora));
  }

  void _shiftRingColor(Color color) {
    if (mounted) setState(() => _ringColor = color);
  }

  void _showToast(String msg, Color color) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Expanded(
              child: Text(msg,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        elevation: 10,
      ),
    );
  }

  void _navigateSummary() {
    final elapsed = _totalSeconds - _remaining;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => SummaryScreen(
          elapsedSeconds: elapsed,
          plannedSeconds: _totalSeconds,
          distractions: _distractions,
          checkins: _checkins,
          successfulCheckins: _successfulCheckins,
        ),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(
              parent: animation, curve: Curves.easeOut),
          child: child,
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────
  String get _timeStr {
    final m = _remaining ~/ 60;
    final s = _remaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get _progress => _remaining / _totalSeconds;
  int get _elapsed => _totalSeconds - _remaining;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: AnimatedBuilder(
        animation: _pulseCtrl,
        builder: (_, __) {
          final pulse = _pulseCtrl.value;
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  FG.void_,
                  FG.obsidian,
                  Color.lerp(FG.obsidian, _ringColor.withOpacity(0.08),
                          pulse * 0.5) ??
                      FG.obsidian,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: FadeTransition(
                opacity: _entranceFade,
                child: SlideTransition(
                  position: _entranceSlide,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.06, vertical: 16),
                    child: Column(
                      children: [
                        _buildSessionHeader(),
                        const Spacer(flex: 1),
                        _buildTimerSection(pulse),
                        const Spacer(flex: 1),
                        _buildSessionMini(),
                        const SizedBox(height: 28),
                        _buildControls(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSessionHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => showDialog(
            context: context,
            builder: (_) => _ConfirmEndDialog(onEnd: _endSession),
          ),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: FG.carbon,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: FG.slate, width: 1)),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: FG.textMid, size: 16),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Focus Session',
                  style: FG.heading(16)),
              Text('${widget.durationMinutes} min · Deep Work mode',
                  style: FG.body(12)),
            ],
          ),
        ),
        // Status pill
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: (_paused ? FG.caution : _ringColor)
                .withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: (_paused ? FG.caution : _ringColor)
                  .withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PulsingDot(
                  color: _paused ? FG.caution : _ringColor, size: 7),
              const SizedBox(width: 6),
              Text(
                _paused ? 'Paused' : 'Focusing',
                style: FG.label(11,
                    color: _paused ? FG.caution : _ringColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimerSection(double pulse) {
    const ringSize = 250.0;
    return Column(
      children: [
        SizedBox(
          width: ringSize,
          height: ringSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow ring
              Container(
                width: ringSize,
                height: ringSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _ringColor
                          .withOpacity(0.08 + pulse * 0.12),
                      blurRadius: 50 + pulse * 30,
                      spreadRadius: 5 + pulse * 8,
                    ),
                  ],
                ),
              ),
              // Custom painted ring
              SizedBox(
                width: ringSize,
                height: ringSize,
                child: CustomPaint(
                  painter: _RingPainter(
                    progress: _progress,
                    ringColor: _ringColor,
                    bgColor: FG.graphite,
                    strokeWidth: 12,
                    glowOpacity: 0.3 + pulse * 0.3,
                  ),
                ),
              ),
              // Inner content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 400),
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      color: _paused ? FG.caution : FG.textHigh,
                      letterSpacing: -2,
                      height: 1,
                    ),
                    child: Text(_timeStr),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _paused ? '— paused —' : 'remaining',
                    style: FG.body(12, color: FG.textLow),
                  ),
                  const SizedBox(height: 12),
                  // Progress label
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _ringColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${((_progress) * 100).toStringAsFixed(0)}% left',
                      style: FG.label(11, color: _ringColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSessionMini() {
    final m = _elapsed ~/ 60;
    final s = _elapsed % 60;
    return Row(
      children: [
        Expanded(
          child: _MiniStat(
            icon: Icons.timer_outlined,
            value:
                '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}',
            label: 'Elapsed',
            color: FG.aurora,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStat(
            icon: Icons.check_circle_outline_rounded,
            value: '$_successfulCheckins',
            label: 'On Track',
            color: FG.jade,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStat(
            icon: Icons.warning_amber_rounded,
            value: '$_distractions',
            label: 'Missed',
            color: FG.danger,
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Row(
      children: [
        Expanded(
          child: FGButton(
            label: _paused ? 'Resume' : 'Pause',
            icon: _paused
                ? Icons.play_arrow_rounded
                : Icons.pause_rounded,
            outlined: true,
            outlineColor: (_paused ? FG.jade : FG.caution).withOpacity(0.5),
            labelStyle:
                FG.label(14, color: _paused ? FG.jade : FG.caution),
            onPressed: _togglePause,
            height: 52,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: FGButton(
            label: 'End Session',
            icon: Icons.stop_rounded,
            gradient: FG.emberGrad,
            height: 52,
            onPressed: _endSession,
          ),
        ),
      ],
    );
  }
}

// ── Mini stat tile ─────────────────────────────────────────────────
class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color;

  const _MiniStat(
      {required this.icon,
      required this.value,
      required this.label,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: color,
                  height: 1)),
          const SizedBox(height: 3),
          Text(label,
              style: FG.body(10,
                  color: FG.textLow)),
        ],
      ),
    );
  }
}

// ── Custom ring painter ────────────────────────────────────────────
class _RingPainter extends CustomPainter {
  final double progress;
  final Color ringColor, bgColor;
  final double strokeWidth, glowOpacity;

  _RingPainter({
    required this.progress,
    required this.ringColor,
    required this.bgColor,
    required this.strokeWidth,
    required this.glowOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: c, radius: r);

    // Track
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = bgColor
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);

    // Glow layer
    canvas.drawArc(
        rect,
        -pi / 2,
        2 * pi * progress,
        false,
        Paint()
          ..color = ringColor.withOpacity(glowOpacity)
          ..strokeWidth = strokeWidth + 6
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..maskFilter =
              const MaskFilter.blur(BlurStyle.normal, 8));

    // Main progress arc
    canvas.drawArc(
        rect,
        -pi / 2,
        2 * pi * progress,
        false,
        Paint()
          ..shader = LinearGradient(
            colors: [ringColor, ringColor.withOpacity(0.5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(rect)
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);

    // Leading dot
    if (progress > 0.01) {
      final angle = -pi / 2 + 2 * pi * progress;
      final dotX = c.dx + r * cos(angle);
      final dotY = c.dy + r * sin(angle);
      canvas.drawCircle(
          Offset(dotX, dotY),
          strokeWidth / 2 + 1,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill);
      canvas.drawCircle(
          Offset(dotX, dotY),
          strokeWidth / 2 + 3,
          Paint()
            ..color = ringColor.withOpacity(0.4)
            ..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.ringColor != ringColor ||
      old.glowOpacity != glowOpacity;
}

// ── Check-in dialog ────────────────────────────────────────────────
class _CheckinDialog extends StatefulWidget {
  final VoidCallback onFocused, onDistracted;
  const _CheckinDialog(
      {required this.onFocused, required this.onDistracted});

  @override
  State<_CheckinDialog> createState() => _CheckinDialogState();
}

class _CheckinDialogState extends State<_CheckinDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  int _countdown = 6;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 6))
      ..forward();
    _t = Timer.periodic(const Duration(seconds: 1),
        (_) { if (mounted) setState(() => _countdown--); });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: FG.carbon,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
                color: FG.aurora.withOpacity(0.25), width: 1.5),
            boxShadow: [
              BoxShadow(
                  color: FG.aurora.withOpacity(0.15),
                  blurRadius: 50,
                  spreadRadius: 5),
              BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 30),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Countdown ring
              SizedBox(
                width: 72,
                height: 72,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _ctrl,
                      builder: (_, __) => CircularProgressIndicator(
                        value: 1 - _ctrl.value,
                        strokeWidth: 4,
                        backgroundColor: FG.graphite,
                        color: _countdown > 2 ? FG.aurora : FG.danger,
                      ),
                    ),
                    Text(
                      '$_countdown',
                      style: FG.display(24, spacing: 0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: FG.aurora.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.remove_red_eye_outlined,
                    color: FG.aurora, size: 22),
              ),
              const SizedBox(height: 16),
              Text('Focus Check-in',
                  style: FG.heading(20)),
              const SizedBox(height: 8),
              Text(
                '⚠️ We noticed inactivity.\nAre you still focused?',
                style: FG.body(14, height: 1.6),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              // Yes button
              SizedBox(
                width: double.infinity,
                child: FGButton(
                  label: 'Yes, still focused!',
                  icon: Icons.check_rounded,
                  gradient: FG.jadeGrad,
                  height: 50,
                  onPressed: widget.onFocused,
                ),
              ),
              const SizedBox(height: 10),
              // No button
              SizedBox(
                width: double.infinity,
                child: FGButton(
                  label: 'Got distracted',
                  icon: Icons.close_rounded,
                  outlined: true,
                  outlineColor: FG.danger.withOpacity(0.4),
                  labelStyle: FG.label(14, color: FG.danger),
                  height: 50,
                  onPressed: widget.onDistracted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Confirm end dialog ─────────────────────────────────────────────
class _ConfirmEndDialog extends StatelessWidget {
  final VoidCallback onEnd;
  const _ConfirmEndDialog({required this.onEnd});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: FG.carbon,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22)),
      title: Text('End Session?', style: FG.heading(18)),
      content: Text(
        'Your current progress will be saved to the summary.',
        style: FG.body(14),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Keep Going',
              style: FG.label(14, color: FG.aurora)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onEnd();
          },
          child:
              Text('End', style: FG.label(14, color: FG.danger)),
        ),
      ],
    );
  }
}

// ╔══════════════════════════════════════════════════════════════════╗
// ║                    SUMMARY SCREEN                               ║
// ╚══════════════════════════════════════════════════════════════════╝
class SummaryScreen extends StatefulWidget {
  final int elapsedSeconds, plannedSeconds;
  final int distractions, checkins, successfulCheckins;

  const SummaryScreen({
    super.key,
    required this.elapsedSeconds,
    required this.plannedSeconds,
    required this.distractions,
    required this.checkins,
    required this.successfulCheckins,
  });

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen>
    with TickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<Animation<double>> _fades;
  late List<Animation<Offset>> _slides;

  // Score bar animation
  late AnimationController _barCtrl;
  late Animation<double> _barAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _fades = List.generate(6, (i) {
      final s = i * 0.1;
      return Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
              parent: _ctrl,
              curve: Interval(s, (s + 0.4).clamp(0, 1),
                  curve: Curves.easeOut)));
    });
    _slides = List.generate(6, (i) {
      final s = i * 0.1;
      return Tween<Offset>(
              begin: const Offset(0, 0.2), end: Offset.zero)
          .animate(CurvedAnimation(
              parent: _ctrl,
              curve: Interval(s, (s + 0.4).clamp(0, 1),
                  curve: Curves.easeOut)));
    });

    _barCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _barAnim = Tween<double>(begin: 0, end: _focusScore / 100)
        .animate(CurvedAnimation(
            parent: _barCtrl, curve: Curves.easeOutCubic));

    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 400),
        () => _barCtrl.forward());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _barCtrl.dispose();
    super.dispose();
  }

  // ── Score maths ────────────────────────────────────────────────
  double get _focusScore {
    final timeScore =
        (widget.elapsedSeconds / widget.plannedSeconds) * 50;
    final checkScore = widget.checkins == 0
        ? 50.0
        : (widget.successfulCheckins / widget.checkins) * 50;
    return (timeScore + checkScore).clamp(0, 100);
  }

  String get _grade {
    final s = _focusScore;
    if (s >= 90) return 'S+';
    if (s >= 80) return 'A';
    if (s >= 65) return 'B';
    if (s >= 50) return 'C';
    return 'D';
  }

  Color get _gradeColor {
    final s = _focusScore;
    if (s >= 80) return FG.jade;
    if (s >= 60) return FG.aurora;
    if (s >= 40) return FG.caution;
    return FG.danger;
  }

  String get _verdict {
    final s = _focusScore;
    if (s >= 90)
      return '🏆 Legendary. Elite-tier focus. You\'re operating at peak cognitive performance.';
    if (s >= 80)
      return '⭐ Outstanding! Your focus is your competitive advantage.';
    if (s >= 65)
      return '💪 Solid session. Fine-tune your environment to eliminate distractions.';
    if (s >= 50)
      return '🌱 Decent effort. Consistency compounds — keep showing up.';
    return '🔥 Tough session. Every dip is data. Identify your distraction triggers.';
  }

  String _fmt(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    if (m == 0) return '${s}s';
    if (s == 0) return '${m}m';
    return '${m}m ${s}s';
  }

  Widget _staggered(int i, Widget child) => FadeTransition(
      opacity: _fades[i],
      child: SlideTransition(position: _slides[i], child: child));

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: FG.bgGrad),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.06, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _staggered(0, _buildHeader()),
                const SizedBox(height: 28),
                _staggered(1, _buildScoreHero()),
                const SizedBox(height: 20),
                _staggered(2, _buildStatsRow()),
                const SizedBox(height: 20),
                _staggered(3, _buildCheckinBreakdown()),
                const SizedBox(height: 20),
                _staggered(4, _buildVerdictCard()),
                const SizedBox(height: 32),
                _staggered(5, _buildActions()),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Session Complete',
                  style: FG.display(26, spacing: -1)),
              const SizedBox(height: 6),
              Text('Here\'s your performance breakdown',
                  style: FG.body(14)),
            ],
          ),
        ),
        // Grade badge
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [_gradeColor, _gradeColor.withOpacity(0.5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: _gradeColor.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Center(
            child: Text(_grade,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreHero() {
    return AuroraCard(
      borderColor: _gradeColor.withOpacity(0.3),
      shadows: [
        BoxShadow(
            color: _gradeColor.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 8)),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Focus Score', style: FG.label(13, color: FG.textLow)),
              Text(
                '${_focusScore.toStringAsFixed(0)}%',
                style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: _gradeColor,
                    height: 1),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Animated progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: AnimatedBuilder(
              animation: _barAnim,
              builder: (_, __) => LinearProgressIndicator(
                value: _barAnim.value,
                minHeight: 8,
                backgroundColor: FG.graphite,
                valueColor: AlwaysStoppedAnimation(_gradeColor),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _ScoreRung(label: 'Needs work', color: FG.danger),
              const Spacer(),
              _ScoreRung(label: 'Good', color: FG.caution),
              const Spacer(),
              _ScoreRung(label: 'Excellent', color: FG.jade),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
              icon: Icons.timer_rounded,
              value: _fmt(widget.elapsedSeconds),
              label: 'Time Focused',
              color: FG.aurora),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
              icon: Icons.flag_rounded,
              value: _fmt(widget.plannedSeconds),
              label: 'Goal Set',
              color: FG.textMid),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
              icon: Icons.warning_amber_rounded,
              value: '${widget.distractions}',
              label: 'Distractions',
              color: FG.danger),
        ),
      ],
    );
  }

  Widget _buildCheckinBreakdown() {
    final missed = widget.checkins - widget.successfulCheckins;
    return AuroraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.checklist_rounded,
                  color: FG.aurora, size: 18),
              const SizedBox(width: 8),
              Text('Check-in Breakdown',
                  style: FG.heading(15)),
            ],
          ),
          const SizedBox(height: 18),
          _CheckinBar(
            label: 'Focused',
            count: widget.successfulCheckins,
            total: widget.checkins.clamp(1, 999),
            color: FG.jade,
          ),
          const SizedBox(height: 12),
          _CheckinBar(
            label: 'Distracted',
            count: missed,
            total: widget.checkins.clamp(1, 999),
            color: FG.danger,
          ),
          const SizedBox(height: 12),
          Divider(color: FG.slate.withOpacity(0.5)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total check-ins', style: FG.body(13)),
              Text('${widget.checkins}',
                  style: FG.heading(13, color: FG.textHigh)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerdictCard() {
    return AuroraCard(
      borderColor: _gradeColor.withOpacity(0.25),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🧠', style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FocusGuard Verdict',
                    style: FG.label(12, color: _gradeColor)),
                const SizedBox(height: 6),
                Text(_verdict,
                    style: FG.body(14, height: 1.65)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FGButton(
            label: 'Start New Session',
            icon: Icons.refresh_rounded,
            gradient: FG.auroraGrad,
            height: 60,
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (_) => const HomeScreen()),
                  (_) => false);
            },
            labelStyle: FG.label(16, color: Colors.white),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FGButton(
            label: 'Back to Home',
            icon: Icons.home_outlined,
            outlined: true,
            height: 52,
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (_) => const HomeScreen()),
                  (_) => false);
            },
          ),
        ),
      ],
    );
  }
}

// ── Small score rung label ─────────────────────────────────────────
class _ScoreRung extends StatelessWidget {
  final String label;
  final Color color;
  const _ScoreRung({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 6,
            height: 6,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: FG.body(10, color: FG.textLow)),
      ],
    );
  }
}

// ── Stat card ─────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color;

  const _StatCard(
      {required this.icon,
      required this.value,
      required this.label,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: color,
                  height: 1)),
          const SizedBox(height: 4),
          Text(label,
              style: FG.body(10,
                  color: FG.textLow)),
        ],
      ),
    );
  }
}

// ── Check-in bar ──────────────────────────────────────────────────
class _CheckinBar extends StatelessWidget {
  final String label;
  final int count, total;
  final Color color;

  const _CheckinBar(
      {required this.label,
      required this.count,
      required this.total,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : count / total;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: FG.body(13)),
            Text('$count / $total',
                style: FG.label(12, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 6,
            backgroundColor: FG.graphite,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}