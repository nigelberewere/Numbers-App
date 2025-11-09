import 'dart:async';

import 'package:flutter/material.dart';

/// A simple splash screen that shows the app logo and name then
/// navigates to the given `next` page builder.
class SplashPage extends StatefulWidget {
  const SplashPage({
    super.key,
    required this.next,
    this.duration = const Duration(milliseconds: 1500),
  });

  final Widget Function() next;
  final Duration duration;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();

    // Auto-navigate after the configured duration
    Timer(widget.duration, () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => widget.next()),
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        color: colorScheme.surface,
        alignment: Alignment.center,
        child: FadeTransition(
          opacity: _anim,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App icon
              Image.asset(
                'lib/assets/icon/logo.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 18),
              Text(
                'NUMBERS',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
