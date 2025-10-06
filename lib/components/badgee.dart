import 'package:flutter/material.dart';

class Badgee extends StatelessWidget {
  const Badgee({
    super.key,
    required this.child,
    required this.value,
    this.color,
  });

  final Widget child;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            constraints: const BoxConstraints(
              minHeight: 16,
              minWidth: 16,
            ),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.red,
            ),
            child: Text(
              textAlign: TextAlign.center,
              value,
              style: const TextStyle(fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }
}
