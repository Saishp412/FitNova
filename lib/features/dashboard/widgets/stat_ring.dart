import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class StatRing extends StatelessWidget {
  final double current;
  final double max;
  final String label;
  final String valueText;
  final Color color;

  StatRing({
    super.key,
    required this.current,
    required this.max,
    required this.label,
    required this.valueText,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (current / max).clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 120,
          width: 120,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 8,
                color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.1),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: progress),
                duration: Duration(milliseconds: 1500),
                curve: Curves.easeOutBack,
                builder: (context, value, _) {
                  return CircularProgressIndicator(
                    value: value,
                    strokeWidth: 8,
                    strokeCap: StrokeCap.round,
                    color: color,
                  );
                },
              ),
              Center(
                child: Text(
                  valueText,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge!.color!,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyMedium!.color!,
          ),
        ),
      ],
    );
  }
}
