import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/app_state.dart';
import '../widgets/animated_sky.dart';
import 'forecast_tab.dart';
import 'home_tab.dart';
import 'locations_tab.dart';
import 'settings_tab.dart';

/// App scaffold: living sky behind everything, four tabs, a floating glass
/// bottom bar on phones and a glass navigation rail on wide screens.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  void _go(int i) {
    if (i == _index) return;
    HapticFeedback.selectionClick();
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final wide = MediaQuery.of(context).size.width >= 840;

    final tabs = <Widget>[
      HomeTab(onSearchTap: () => _go(1)),
      LocationsTab(onLocationSelected: () => _go(0)),
      const ForecastTab(),
      const SettingsTab(),
    ];

    final body = AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.02), end: Offset.zero)
              .animate(anim),
          child: child,
        ),
      ),
      child: KeyedSubtree(key: ValueKey(_index), child: tabs[_index]),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0B1026),
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedSky(weather: app.current, darkMode: app.darkMode),
          ),
          SafeArea(
            bottom: false,
            child: wide
                ? Row(
                    children: [
                      _NavRail(index: _index, onTap: _go),
                      Expanded(child: body),
                    ],
                  )
                : body,
          ),
        ],
      ),
      bottomNavigationBar: wide ? null : _GlassNavBar(index: _index, onTap: _go),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String labelKey;

  const _NavItem(this.icon, this.activeIcon, this.labelKey);
}

const _items = [
  _NavItem(Icons.home_outlined, Icons.home_rounded, 'tab.home'),
  _NavItem(Icons.search_rounded, Icons.search_rounded, 'tab.search'),
  _NavItem(
      Icons.calendar_month_outlined, Icons.calendar_month_rounded,
      'tab.forecast'),
  _NavItem(Icons.settings_outlined, Icons.settings_rounded, 'tab.settings'),
];

class _GlassNavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;

  const _GlassNavBar({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 0, 16, 10 + MediaQuery.of(context).padding.bottom),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              color: const Color(0xFF0B1026).withValues(alpha: 0.55),
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
              children: [
                for (var i = 0; i < _items.length; i++)
                  Expanded(
                    child: _BarButton(
                      item: _items[i],
                      label: app.tr(_items[i].labelKey),
                      active: i == index,
                      onTap: () => onTap(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BarButton extends StatelessWidget {
  final _NavItem item;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _BarButton({
    required this.item,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF7DD3FC);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: active
                  ? accent.withValues(alpha: 0.18)
                  : Colors.transparent,
              // Keep a shadow in both states (transparent when inactive) so
              // the list length stays constant. Otherwise BoxDecoration.lerp
              // interpolates toward an empty list and the easeOutBack overshoot
              // drives blurRadius negative, tripping a non-negative assertion.
              boxShadow: [
                BoxShadow(
                  color: active
                      ? accent.withValues(alpha: 0.25)
                      : Colors.transparent,
                  blurRadius: 16,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: AnimatedScale(
              scale: active ? 1.12 : 1.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              child: Icon(
                active ? item.activeIcon : item.icon,
                size: 24,
                color:
                    active ? accent : Colors.white.withValues(alpha: 0.55),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child: active
                ? Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(label,
                        style: const TextStyle(
                            color: accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  )
                : const SizedBox(height: 0),
          ),
        ],
      ),
    );
  }
}

class _NavRail extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;

  const _NavRail({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    const accent = Color(0xFF7DD3FC);
    return Container(
      width: 96,
      margin: const EdgeInsets.fromLTRB(14, 14, 0, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: const Color(0xFF0B1026).withValues(alpha: 0.45),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _items.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutBack,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == index
                              ? accent.withValues(alpha: 0.18)
                              : Colors.transparent,
                          boxShadow: i == index
                              ? [
                                  BoxShadow(
                                    color: accent.withValues(alpha: 0.3),
                                    blurRadius: 18,
                                    spreadRadius: -2,
                                  )
                                ]
                              : const [],
                        ),
                        child: Icon(
                          i == index ? _items[i].activeIcon : _items[i].icon,
                          color: i == index
                              ? accent
                              : Colors.white.withValues(alpha: 0.55),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        app.tr(_items[i].labelKey),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: i == index
                              ? accent
                              : Colors.white.withValues(alpha: 0.45),
                          fontSize: 11,
                          fontWeight:
                              i == index ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
