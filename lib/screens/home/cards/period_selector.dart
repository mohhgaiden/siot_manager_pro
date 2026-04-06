import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class PeriodSelector extends StatefulWidget {
  const PeriodSelector({super.key});

  @override
  State<PeriodSelector> createState() => PeriodSelectorState();
}

class PeriodSelectorState extends State<PeriodSelector> {
  int _selected = 0;
  final _labels = ['24h', '7j', '30j', 'Tout'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_labels.length, (i) {
        final active = _selected == i;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: GestureDetector(
            onTap: () => setState(() => _selected = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: active ? AppTheme.primary : const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _labels[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : AppTheme.textMuted,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
