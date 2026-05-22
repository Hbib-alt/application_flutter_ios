import 'package:flutter/material.dart';

class RoleGuard extends StatelessWidget {

  final bool allowed;

  final Widget child;

  const RoleGuard({
    super.key,
    required this.allowed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {

    if (!allowed) {
      return const SizedBox.shrink();
    }

    return child;
  }
}