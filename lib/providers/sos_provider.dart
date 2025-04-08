import 'dart:async';
import 'package:flutter/material.dart';
import '../services/sos_service.dart';

class SOSProvider extends ChangeNotifier {
  final SOSService _sosService;
  DateTime? _startTime;
  int _elapsedTimeInSeconds = 0;
  late Timer _timer;
  bool _isTimerActive = false;

  SOSProvider(this._sosService);

  // Getters
  bool get isSOSActive => _sosService.isSOSActive;
  double get speedFactor => _sosService.speedFactor;
  int get elapsedTimeInSeconds => _elapsedTimeInSeconds;

  // Khởi tạo
  void initialize() {
    // Khởi tạo Timer để theo dõi thời gian
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isTimerActive && _startTime != null) {
        _elapsedTimeInSeconds = DateTime.now().difference(_startTime!).inSeconds;
        notifyListeners();
      }
    });
  }

  // Bật/tắt SOS
  Future<void> toggleSOS() async {
    if (isSOSActive) {
      await stopSOS();
    } else {
      await startSOS();
    }
  }

  // Bắt đầu SOS
  Future<void> startSOS() async {
    if (!isSOSActive) {
      await _sosService.startSOS();
      _startTime = DateTime.now();
      _isTimerActive = true;
      notifyListeners();
    }
  }

  // Dừng SOS
  Future<void> stopSOS() async {
    if (isSOSActive) {
      _sosService.stopSOS();
      _isTimerActive = false;
      _elapsedTimeInSeconds = 0;
      _startTime = null;
      notifyListeners();
    }
  }

  // Điều chỉnh tốc độ nhấp nháy
  Future<void> setSpeedFactor(double value) async {
    await _sosService.setSpeedFactor(value);
    notifyListeners();
  }

  // Chuẩn bị hiển thị đồng hồ đếm
  String getFormattedElapsedTime() {
    final int minutes = _elapsedTimeInSeconds ~/ 60;
    final int seconds = _elapsedTimeInSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Giải phóng tài nguyên
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
} 