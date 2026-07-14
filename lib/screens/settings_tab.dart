import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/app_state.dart';
import '../widgets/glass_card.dart';
import '../widgets/ui.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      child: MaxWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Entrance(
              child: Text(app.tr('tab.settings'),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5)),
            ),
            const SizedBox(height: 22),
            Entrance(delay: 60, child: SectionLabel(app.tr('section.units'))),
            const SizedBox(height: 10),
            Entrance(
              delay: 100,
              child: _Group(children: [
                _Row(
                  icon: Icons.device_thermostat_rounded,
                  title: app.tr('settings.temperature'),
                  subtitle: app.tr('settings.temperatureSub'),
                  trailing: _unitSwitch(
                    value: app.useFahrenheit,
                    label: app.useFahrenheit ? '°F' : '°C',
                    onChanged: app.setFahrenheit,
                  ),
                ),
                _Row(
                  icon: Icons.speed_rounded,
                  title: app.tr('settings.windSpeed'),
                  subtitle: app.tr('settings.windSpeedSub'),
                  trailing: _unitSwitch(
                    value: app.useMph,
                    label: app.useMph ? 'mph' : 'km/h',
                    onChanged: app.setMph,
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 24),
            Entrance(
                delay: 140,
                child: SectionLabel(app.tr('section.notifications'))),
            const SizedBox(height: 10),
            Entrance(
              delay: 180,
              child: _Group(children: [
                _Row(
                  icon: Icons.notifications_none_rounded,
                  title: app.tr('settings.push'),
                  subtitle: app.tr('settings.pushSub'),
                  trailing: GlowSwitch(
                      value: app.pushNotifications,
                      onChanged: app.setPushNotifications),
                ),
                _Row(
                  icon: Icons.umbrella_rounded,
                  title: app.tr('settings.rainAlerts'),
                  subtitle: app.tr('settings.rainAlertsSub'),
                  trailing: GlowSwitch(
                      value: app.rainAlerts, onChanged: app.setRainAlerts),
                ),
              ]),
            ),
            const SizedBox(height: 24),
            Entrance(
                delay: 220, child: SectionLabel(app.tr('section.appearance'))),
            const SizedBox(height: 10),
            Entrance(
              delay: 260,
              child: _Group(children: [
                _Row(
                  icon: Icons.dark_mode_outlined,
                  title: app.tr('settings.darkMode'),
                  subtitle: app.tr('settings.darkModeSub'),
                  trailing: GlowSwitch(
                      value: app.darkMode, onChanged: app.setDarkMode),
                ),
                _Row(
                  icon: Icons.translate_rounded,
                  title: app.tr('select.language'),
                  subtitle: app.languages.firstWhere(
                        (l) => l['code'] == app.lang,
                        orElse: () => const {'name': 'English'},
                      )['name'] ??
                      'English',
                  trailing: Icon(Icons.chevron_right_rounded,
                      color: Colors.white.withValues(alpha: 0.5)),
                  onTap: () => _pickLanguage(context, app),
                ),
              ]),
            ),
            const SizedBox(height: 24),
            Entrance(delay: 300, child: SectionLabel(app.tr('section.about'))),
            const SizedBox(height: 10),
            Entrance(
              delay: 340,
              child: _Group(children: [
                _Row(
                  title: app.tr('about.privacy'),
                  trailing: Icon(Icons.chevron_right_rounded,
                      color: Colors.white.withValues(alpha: 0.5)),
                  onTap: () {},
                ),
                _Row(
                  title: app.tr('about.terms'),
                  trailing: Icon(Icons.chevron_right_rounded,
                      color: Colors.white.withValues(alpha: 0.5)),
                  onTap: () {},
                ),
                _Row(
                  title: app.tr('about.version'),
                  trailing: Text('1.0.0',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 14)),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _unitSwitch({
    required bool value,
    required String label,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: Text(label,
              key: ValueKey(label),
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 10),
        GlowSwitch(value: value, onChanged: onChanged),
      ],
    );
  }

  void _pickLanguage(BuildContext context, AppState app) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141A3C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            for (final l in app.languages)
              ListTile(
                title: Text(l['name'] ?? l['code']!,
                    style: const TextStyle(color: Colors.white)),
                trailing: l['code'] == app.lang
                    ? const Icon(Icons.check_circle_rounded,
                        color: Color(0xFF7DD3FC))
                    : null,
                onTap: () {
                  app.setLang(l['code']!);
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  final List<Widget> children;

  const _Group({required this.children});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 34,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Divider(
                  height: 1,
                  indent: 64,
                  color: Colors.white.withValues(alpha: 0.08)),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _Row({
    this.icon,
    required this.title,
    this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.10)),
                ),
                child: Icon(icon,
                    size: 19, color: Colors.white.withValues(alpha: 0.85)),
              ),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  if (subtitle != null && subtitle!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(subtitle!,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.55),
                              fontSize: 13)),
                    ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
