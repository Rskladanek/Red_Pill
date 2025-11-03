import 'package:flutter/material.dart';

class PowerTriangle extends StatelessWidget {
  final int mind;
  final int body;
  final int soul;

  const PowerTriangle({
    super.key,
    required this.mind,
    required this.body,
    required this.soul,
  });

  @override
  Widget build(BuildContext context) {
    final total = (mind + body + soul).clamp(1, 1 << 31);
    double ratio(int v) => v / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildBar(context, 'MIND', ratio(mind)),
        const SizedBox(height: 8),
        _buildBar(context, 'BODY', ratio(body)),
        const SizedBox(height: 8),
        _buildBar(context, 'SOUL', ratio(soul)),
      ],
    );
  }

  Widget _buildBar(BuildContext context, String label, double value) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.grey.shade400,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

