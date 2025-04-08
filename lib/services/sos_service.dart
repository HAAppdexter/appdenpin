import 'dart:async';
import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SOSService {
  // Các thông số timing
  final double _shortFlashDuration = 0.3;  // S: nháy ngắn (giây)
  final double _longFlashDuration = 0.9;   // O: nháy dài (giây)
  final double _intervalBetweenFlashes = 0.1;  // Giữa các nháy
  final double _intervalBetweenLetters = 0.7;  // Giữa S và O
  final double _intervalBetweenSequences = 3.0;  // Giữa các chuỗi SOS
  
  // Tốc độ nhân tố (cho phép điều chỉnh tốc độ)
  double _speedFactor = 1.0;  // 0.5 = chậm, 2.0 = nhanh
  
  // Các biến trạng thái
  bool _isSOSActive = false;
  Timer? _sosTimer;
  CameraController? _cameraController;
  // final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  // Khởi tạo
  Future<void> initialize(CameraController? controller) async {
    _cameraController = controller;
    
    // Khởi tạo notifications
    /*
    const AndroidInitializationSettings initializationSettingsAndroid = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    
    const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS);
    
    await _notificationsPlugin.initialize(initializationSettings);
    */
    
    // Khôi phục tốc độ từ preferences
    final prefs = await SharedPreferences.getInstance();
    _speedFactor = prefs.getDouble('sos_speed_factor') ?? 1.0;
  }
  
  // Bắt đầu chuỗi SOS
  Future<bool> startSOS() async {
    if (_cameraController == null) return false;
    
    _isSOSActive = true;
    
    // Hiển thị notification
    // _showNotification();
    
    // Bắt đầu chuỗi SOS
    _executeSOSSequence();
    
    return true;
  }
  
  // Dừng SOS
  void stopSOS() {
    _isSOSActive = false;
    _sosTimer?.cancel();
    _sosTimer = null;
    
    // Đảm bảo đèn tắt khi dừng
    _turnFlashOff();
    
    // Hủy notification
    // _notificationsPlugin.cancel(0);
  }
  
  // Thực hiện chuỗi nhấp nháy SOS
  void _executeSOSSequence() async {
    if (!_isSOSActive) return;
    
    List<_FlashStep> sequence = _generateSOSSequence();
    int currentStep = 0;
    
    _sosTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) async {
      if (!_isSOSActive) {
        timer.cancel();
        return;
      }
      
      if (currentStep < sequence.length) {
        final step = sequence[currentStep];
        
        if (step.isFlashOn) {
          await _turnFlashOn();
        } else {
          await _turnFlashOff();
        }
        
        // Đợi đến step tiếp theo
        await Future.delayed(Duration(milliseconds: (step.duration * 1000 * (1 / _speedFactor)).round()));
        currentStep++;
      } else {
        // Hoàn thành một chuỗi, bắt đầu lại
        currentStep = 0;
      }
    });
  }
  
  // Tạo ra chuỗi các bước nhấp nháy SOS
  List<_FlashStep> _generateSOSSequence() {
    List<_FlashStep> sequence = [];
    
    // S: ...
    for (int i = 0; i < 3; i++) {
      sequence.add(_FlashStep(true, _shortFlashDuration));  // Bật (S)
      sequence.add(_FlashStep(false, _intervalBetweenFlashes)); // Tắt
    }
    
    // Khoảng giữa S và O
    sequence.add(_FlashStep(false, _intervalBetweenLetters));
    
    // O: ---
    for (int i = 0; i < 3; i++) {
      sequence.add(_FlashStep(true, _longFlashDuration));  // Bật (O)
      sequence.add(_FlashStep(false, _intervalBetweenFlashes)); // Tắt
    }
    
    // Khoảng giữa O và S
    sequence.add(_FlashStep(false, _intervalBetweenLetters));
    
    // S: ...
    for (int i = 0; i < 3; i++) {
      sequence.add(_FlashStep(true, _shortFlashDuration));  // Bật (S)
      if (i < 2) {
        sequence.add(_FlashStep(false, _intervalBetweenFlashes)); // Tắt
      }
    }
    
    // Khoảng nghỉ giữa các chuỗi SOS
    sequence.add(_FlashStep(false, _intervalBetweenSequences));
    
    return sequence;
  }
  
  // Điều khiển đèn flash
  Future<void> _turnFlashOn() async {
    try {
      await _cameraController?.setFlashMode(FlashMode.torch);
    } catch (e) {
      print('Không thể bật đèn flash: $e');
    }
  }
  
  Future<void> _turnFlashOff() async {
    try {
      await _cameraController?.setFlashMode(FlashMode.off);
    } catch (e) {
      print('Không thể tắt đèn flash: $e');
    }
  }
  
  // Hiển thị notification khi SOS đang chạy
  /*
  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'sos_channel', 
        'SOS Notifications',
        importance: Importance.high,
        priority: Priority.high,
        ongoing: true,
        autoCancel: false
      );
      
    const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
      
    await _notificationsPlugin.show(
      0,
      'SOS Đang Hoạt Động',
      'Nhấn để mở ứng dụng và dừng SOS',
      platformChannelSpecifics,
    );
  }
  */
  
  // Đặt tốc độ nháy
  Future<void> setSpeedFactor(double value) async {
    _speedFactor = value;
    
    // Lưu vào preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('sos_speed_factor', value);
    
    // Nếu đang chạy SOS, khởi động lại để áp dụng tốc độ mới
    if (_isSOSActive) {
      stopSOS();
      startSOS();
    }
  }
  
  // Getters
  bool get isSOSActive => _isSOSActive;
  double get speedFactor => _speedFactor;
  
  // Giải phóng tài nguyên
  void dispose() {
    stopSOS();
    _cameraController = null;
  }
}

// Class hỗ trợ cho từng bước trong chuỗi nhấp nháy
class _FlashStep {
  final bool isFlashOn;
  final double duration;
  
  _FlashStep(this.isFlashOn, this.duration);
} 