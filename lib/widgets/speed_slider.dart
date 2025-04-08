import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sos_provider.dart';

class SpeedSlider extends StatelessWidget {
  const SpeedSlider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SOSProvider>(
      builder: (context, sosProvider, child) {
        final isActive = sosProvider.isSOSActive;
        final speedFactor = sosProvider.speedFactor;
        
        return Opacity(
          opacity: isActive ? 1.0 : 0.5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.speed, size: 24),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: isActive ? Colors.red : Colors.grey,
                        inactiveTrackColor: Colors.grey.shade300,
                        thumbColor: isActive ? Colors.red : Colors.grey,
                        overlayColor: Colors.red.withOpacity(0.2),
                        trackHeight: 4.0,
                      ),
                      child: Slider(
                        value: speedFactor,
                        min: 0.5,
                        max: 2.0,
                        divisions: 6,
                        label: _getSpeedLabel(speedFactor),
                        onChanged: (value) {
                          sosProvider.setSpeedFactor(value);
                        },
                      ),
                    ),
                  ),
                  const Icon(Icons.shutter_speed, size: 24),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Tốc độ nhấp nháy',
                style: TextStyle(
                  fontSize: 14,
                  color: isActive ? Colors.black87 : Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  String _getSpeedLabel(double value) {
    if (value <= 0.5) return 'Rất chậm';
    if (value <= 0.75) return 'Chậm';
    if (value < 1.25) return 'Bình thường';
    if (value < 1.75) return 'Nhanh';
    return 'Rất nhanh';
  }
} 