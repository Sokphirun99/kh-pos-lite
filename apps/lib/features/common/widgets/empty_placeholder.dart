import 'package:flutter/material.dart';

class EmptyPlaceholder extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final List<Widget>? actions;

  const EmptyPlaceholder({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onActionPressed,
    this.actions,
  }) : assert((actionLabel != null && onActionPressed != null) || actions != null,
         'Either provide actionLabel and onActionPressed, or provide actions');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final muted = colorScheme.onSurfaceVariant;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.surfaceContainerHigh,
              ),
              child: Icon(icon, size: 48, color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(color: muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (actions != null) ...actions!
            else if (actionLabel != null && onActionPressed != null)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onActionPressed,
                  icon: const Icon(Icons.add),
                  label: Text(actionLabel!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
