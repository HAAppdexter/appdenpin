import 'package:flutter/material.dart';

class FlashlightButton extends StatelessWidget {
  final double size;
  final double iconSize;
  final bool isOn;
  final VoidCallback onPressed;
  
  const FlashlightButton({
    Key? key,
    this.size = 200,
    this.iconSize = 80,
    required this.isOn,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black,
          boxShadow: isOn
              ? [
                  BoxShadow(
                    color: Colors.blue.withAlpha(100),
                    spreadRadius: 120,
                    blurRadius: 30,
                    offset: const Offset(0, 0),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(77),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  )
                ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Inner circle with power symbol
            Container(
              width: size * 0.9,
              height: size * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
                border: Border.all(
                  color: isOn ? Colors.blue : Colors.grey[800]!,
                  width: 3,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.power_settings_new,
                  size: iconSize,
                  color: isOn ? Colors.blue : Colors.grey[400],
                ),
              ),
            ),
            // Outer glow ring
            if (isOn)
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.blue.withAlpha(150),
                    width: 4,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 