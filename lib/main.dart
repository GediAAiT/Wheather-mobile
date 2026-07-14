import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/root_shell.dart';
import 'state/app_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );
  final state = AppState();
  state.init();
  runApp(WeatherApp(state: state));
}

class WeatherApp extends StatelessWidget {
  final AppState state;

  const WeatherApp({super.key, required this.state});

  static const Color _bgDeep = Color(0xFF0B1026);
  static const Color _surface = Color(0xFF141A3C);
  static const Color _cyan = Color(0xFF7DD3FC);
  static const Color _amber = Color(0xFFF2B441);
  static const Color _ink = Color(0xFFE8EAF2);

  @override
  Widget build(BuildContext context) {
    final base = ThemeData.dark(useMaterial3: true);

    return AppScope(
      state: state,
      child: MaterialApp(
        title: 'Atlas Weather',
        debugShowCheckedModeBanner: false,
        theme: base.copyWith(
          scaffoldBackgroundColor: _bgDeep,
          colorScheme: const ColorScheme.dark(
            primary: _cyan,
            secondary: _amber,
            surface: _surface,
            onPrimary: Color(0xFF06243A),
            onSecondary: Color(0xFF1A1205),
            onSurface: _ink,
          ),
          textTheme: base.textTheme.apply(
            bodyColor: _ink,
            displayColor: _ink,
          ),
          splashColor: _cyan.withValues(alpha: 0.10),
          highlightColor: _cyan.withValues(alpha: 0.05),
        ),
        home: const RootShell(),
      ),
    );
  }
}
