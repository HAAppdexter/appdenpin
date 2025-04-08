import 'package:flutter/material.dart';

class BrightnessSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  
  const BrightnessSlider({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isEnabled = true; // onChanged không thể null vì là required
    
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.brightness_low, size: 24),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: isEnabled ? Colors.amber : Colors.grey,
                    inactiveTrackColor: Colors.grey.shade300,
                    thumbColor: isEnabled ? Colors.amber : Colors.grey,
                    overlayColor: Colors.amber.withAlpha(51), // ~0.2 alpha
                    trackHeight: 4.0,
                  ),
                  child: Slider(
                    value: value,
                    min: 0.0,
                    max: 1.0,
                    onChanged: onChanged,
                  ),
                ),
              ),
              const Icon(Icons.brightness_high, size: 24),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Độ sáng',
            style: TextStyle(
              fontSize: 14,
              color: isEnabled ? Colors.black87 : Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
} 