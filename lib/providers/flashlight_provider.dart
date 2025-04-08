import 'package:flutter/material.dart';
import '../services/flashlight_service.dart';

class FlashlightProvider extends ChangeNotifier {
  final FlashlightService _flashlightService;
  DateTime? _startTime;
  int _totalUsageTime = 0; // Tổng thời gian sử dụng tính bằng giây

  FlashlightProvider(this._flashlightService);

  // Getters
  bool get isFlashlightOn => _flashlightService.isFlashlightOn;
  double get brightness => _flashlightService.brightness;
  int get totalUsageTime => _totalUsageTime;
  DateTime? get startTime => _startTime;

  // Bật/tắt đèn pin
  Future<void> toggleFlashlight() async {
    await _flashlightService.toggleFlashlight();
    
    if (isFlashlightOn) {
      _startTime = DateTime.now();
    } else if (_startTime != null) {
      // Tính thời gian sử dụng và cộng vào tổng
      final usageTime = DateTime.now().difference(_startTime!).inSeconds;
      _totalUsageTime += usageTime;
      _startTime = null;
    }
    
    notifyListeners();
  }

  // Điều chỉnh độ sáng
  Future<void> setBrightness(double value) async {
    await _flashlightService.setBrightness(value);
    notifyListeners();
  }

  // Tính thời gian sử dụng hiện tại (nếu đèn đang bật)
  int getCurrentUsageTimeInSeconds() {
    if (!isFlashlightOn || _startTime == null) {
      return 0;
    }
    
    return DateTime.now().difference(_startTime!).inSeconds;
  }

  // Tính tổng thời gian sử dụng
  int getTotalUsageTimeInSeconds() {
    final current = getCurrentUsageTimeInSeconds();
    return _totalUsageTime + current;
  }

  // Đặt lại thời gian sử dụng
  void resetUsageTime() {
    _totalUsageTime = 0;
    if (isFlashlightOn) {
      _startTime = DateTime.now();
    }
    notifyListeners();
  }
} 