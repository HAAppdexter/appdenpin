# Đèn SOS (Flutter)

## Tổng Quan
Tính năng đèn SOS là chức năng P0 (ưu tiên cao) cho phép điều khiển đèn flash theo mẫu tín hiệu cứu hộ SOS chuẩn Morse (... --- ...), có thể hoạt động kể cả khi ứng dụng chạy nền.

## Package Cần Thiết
```yaml
dependencies:
  camera: ^0.10.5+5  # Truy cập camera và đèn flash
  wakelock: ^0.6.2  # Giữ màn hình sáng
  shared_preferences: ^2.2.2  # Lưu cài đặt
  provider: ^6.1.1  # State management
  flutter_local_notifications: ^16.0.0+1  # Notification khi chạy nền
```

## Mẫu Nháy SOS
- Chuỗi SOS chuẩn Morse:
  - S: Ba nháy ngắn (0.3s mỗi nháy, 0.1s giữa các nháy)
  - O: Ba nháy dài (0.9s mỗi nháy, 0.1s giữa các nháy)
  - Khoảng 0.7s giữa các ký tự S và O
  - Khoảng 3s nghỉ giữa các lần lặp lại

## Cấu Trúc Files

### 1. services/sos_service.dart
```dart
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  // Khởi tạo
  Future<void> initialize(CameraController controller) async {
    _cameraController = controller;
    
    // Khởi tạo notifications
    const AndroidInitializationSettings initializationSettingsAndroid = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    
    const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS);
    
    await _notificationsPlugin.initialize(initializationSettings);
    
    // Khôi phục tốc độ từ preferences
    final prefs = await SharedPreferences.getInstance();
    _speedFactor = prefs.getDouble('sos_speed_factor') ?? 1.0;
  }
  
  // Bắt đầu chuỗi SOS
  Future<bool> startSOS() async {
    if (_cameraController == null) return false;
    
    _isSOSActive = true;
    
    // Hiển thị notification
    _showNotification();
    
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
    _notificationsPlugin.cancel(0);
  }
  
  // Thực hiện chuỗi nhấp nháy SOS
  void _executeSOSSequence() async {
    if (!_isSOSActive) return;
    
    List<_FlashStep> sequence = _generateSOSSequence();
    int currentStep = 0;
    
    _sosTimer = Timer.periodic(Duration(milliseconds: 50), (timer) async {
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
```

### 2. providers/sos_provider.dart
```dart
import 'package:flutter/foundation.dart';
import '../services/sos_service.dart';
import 'flashlight_provider.dart';

class SOSProvider with ChangeNotifier {
  final SOSService _service = SOSService();
  final FlashlightProvider _flashlightProvider;
  
  SOSProvider(this._flashlightProvider);
  
  bool get isSOSActive => _service.isSOSActive;
  double get speedFactor => _service.speedFactor;
  
  Future<void> initialize() async {
    // Lấy controller từ FlashlightProvider
    await _service.initialize(_flashlightProvider.getCameraController());
    notifyListeners();
  }
  
  Future<bool> toggleSOS() async {
    bool result;
    
    if (isSOSActive) {
      _service.stopSOS();
      result = false;
    } else {
      result = await _service.startSOS();
    }
    
    notifyListeners();
    return result;
  }
  
  Future<void> setSpeedFactor(double value) async {
    await _service.setSpeedFactor(value);
    notifyListeners();
  }
  
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
```

### 3. screens/sos_screen.dart
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';
import '../providers/sos_provider.dart';
import '../widgets/speed_slider.dart';

class SOSScreen extends StatefulWidget {
  @override
  _SOSScreenState createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> with WidgetsBindingObserver {
  bool _showWarningDialog = false;
  bool _timerActive = false;
  int _activeSeconds = 0;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Khởi tạo SOS service
    Future.microtask(() => 
      Provider.of<SOSProvider>(context, listen: false).initialize()
    );
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Đảm bảo tắt wakelock khi rời screen
    Wakelock.disable();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Lưu trạng thái khi app vào background
    final sosProvider = Provider.of<SOSProvider>(context, listen: false);
    
    if (state == AppLifecycleState.paused && sosProvider.isSOSActive) {
      // SOS tiếp tục chạy trong background
      // Notification đã được hiển thị bởi service
    }
  }
  
  // Bắt đầu timer đếm thời gian hoạt động
  void _startTimer() {
    setState(() {
      _timerActive = true;
      _activeSeconds = 0;
    });
    
    // Cập nhật timer mỗi giây
    Future.doWhile(() async {
      await Future.delayed(Duration(seconds: 1));
      if (!_timerActive) return false;
      
      setState(() {
        _activeSeconds++;
      });
      
      return true;
    });
  }
  
  // Dừng timer
  void _stopTimer() {
    setState(() {
      _timerActive = false;
    });
  }
  
  // Format thời gian (MM:SS)
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  @override
  Widget build(BuildContext context) {
    final sosProvider = Provider.of<SOSProvider>(context);
    
    // Cập nhật wakelock khi SOS được bật/tắt
    if (sosProvider.isSOSActive) {
      Wakelock.enable();
      if (!_timerActive) _startTimer();
    } else {
      // Wakelock.disable();  // Giữ màn hình sáng khi đang ở màn hình này
      if (_timerActive) _stopTimer();
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('SOS'),
        backgroundColor: sosProvider.isSOSActive ? Colors.red : null,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hiển thị thời gian hoạt động
            if (_timerActive)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Thời gian: ${_formatTime(_activeSeconds)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            
            SizedBox(height: 40),
            
            // SOS Button
            GestureDetector(
              onTap: () {
                if (!sosProvider.isSOSActive && !_showWarningDialog) {
                  // Hiển thị thông báo xác nhận trước khi bật
                  setState(() => _showWarningDialog = true);
                  
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Xác nhận SOS'),
                      content: Text(
                        'Chức năng này chỉ nên sử dụng trong trường hợp khẩn cấp. '
                        'Tiếp tục?'
                      ),
                      actions: [
                        TextButton(
                          child: Text('HỦY'),
                          onPressed: () {
                            setState(() => _showWarningDialog = false);
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text('BẬT SOS'),
                          onPressed: () {
                            sosProvider.toggleSOS();
                            setState(() => _showWarningDialog = false);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  );
                } else if (sosProvider.isSOSActive) {
                  // Tắt SOS
                  sosProvider.toggleSOS();
                }
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: sosProvider.isSOSActive ? Colors.red : Colors.red[100],
                  boxShadow: sosProvider.isSOSActive
                    ? [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.6),
                          blurRadius: 20,
                          spreadRadius: 10,
                        )
                      ]
                    : [],
                ),
                child: Center(
                  child: Text(
                    sosProvider.isSOSActive ? 'DỪNG' : 'SOS',
                    style: TextStyle(
                      color: sosProvider.isSOSActive ? Colors.white : Colors.red,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 40),
            
            // Speed control
            if (!sosProvider.isSOSActive)
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Tốc độ nháy',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Chậm'),
                        Container(
                          width: 200,
                          child: Slider(
                            value: sosProvider.speedFactor,
                            min: 0.5,
                            max: 2.0,
                            divisions: 6,
                            onChanged: (value) => sosProvider.setSpeedFactor(value),
                            activeColor: Colors.red,
                          ),
                        ),
                        Text('Nhanh'),
                      ],
                    ),
                  ],
                ),
              ),
            
            // Thông tin SOS Morse
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Tín hiệu SOS chuẩn Morse:\n• • •   — — —   • • •\nS = Ba nháy ngắn\nO = Ba nháy dài',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Xử Lý Background

### ios/Runner/AppDelegate.swift
```swift
import UIKit
import Flutter
import AVFoundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Thiết lập background
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Xử lý background task
  override func applicationDidEnterBackground(_ application: UIApplication) {
    let taskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
    if taskIdentifier != .invalid {
      // Cho phép tiếp tục chạy trong background
    }
  }
}
```

### android/app/src/main/AndroidManifest.xml
```xml
<manifest ...>
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    
    <application ...>
        <service
            android:name=".SOSForegroundService"
            android:exported="false"
            android:foregroundServiceType="camera" />
    </application>
</manifest>
```

### android/app/src/main/kotlin/.../SOSForegroundService.kt
```kotlin
package com.example.flashlight_app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.IBinder
import androidx.core.app.NotificationCompat

class SOSForegroundService : Service() {
    companion object {
        private const val CHANNEL_ID = "sos_service_channel"
        private const val NOTIFICATION_ID = 1
    }
    
    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, notificationIntent, PendingIntent.FLAG_IMMUTABLE
        )
        
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("SOS Đang Hoạt Động")
            .setContentText("Nhấn để mở ứng dụng và dừng SOS")
            .setSmallIcon(R.drawable.ic_sos)
            .setContentIntent(pendingIntent)
            .build()
        
        startForeground(NOTIFICATION_ID, notification)
        
        return START_STICKY
    }
    
    override fun onBind(intent: Intent?): IBinder? {
        return null
    }
    
    private fun createNotificationChannel() {
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            val name = "SOS Service Channel"
            val descriptionText = "Channel for SOS Service notifications"
            val importance = NotificationManager.IMPORTANCE_HIGH
            val channel = NotificationChannel(CHANNEL_ID, name, importance).apply {
                description = descriptionText
            }
            
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
}
```

## Tối Ưu Hóa

### Battery Optimization
- Sử dụng foreground service để tiếp tục hoạt động khi màn hình tắt
- Giảm tần suất kiểm tra timer bằng cách sử dụng Future.delayed thay vì liên tục polling
- Tự động tắt SOS sau thời gian xác định (tùy chọn) để tiết kiệm pin

### UI/UX
- Cung cấp phản hồi thị giác rõ ràng khi SOS đang hoạt động (màu đỏ, animation)
- Hiển thị thời gian đã hoạt động để người dùng biết đèn đã nhấp nháy bao lâu
- Nút dừng lớn, rõ ràng để dễ dàng tắt SOS trong trường hợp khẩn cấp

## Các Trường Hợp Đặc Biệt
- Camera bị chiếm bởi ứng dụng khác: Hiển thị thông báo và hướng dẫn người dùng đóng ứng dụng khác
- Pin yếu: Cảnh báo người dùng khi pin dưới 15% và đề xuất giảm tốc độ nháy
- Chế độ tiết kiệm pin của hệ thống: Cảnh báo người dùng rằng chế độ này có thể ảnh hưởng đến hoạt động của SOS

## Kiểm Thử
- Kiểm tra mẫu nháy SOS so với chuẩn Morse quốc tế
- Test thời gian hoạt động liên tục trên nhiều thiết bị khác nhau
- Kiểm tra hoạt động trong background và khi màn hình tắt
- Test với điều kiện pin yếu và chế độ tiết kiệm pin

## Tiêu Chí Hoàn Thành
- Mẫu nháy SOS chính xác theo chuẩn Morse quốc tế
- Hoạt động liên tục không bị gián đoạn >2 giờ
- Cơ chế điều chỉnh tốc độ hoạt động chính xác
- Tiếp tục hoạt động khi ứng dụng ở background
- UI/UX rõ ràng, dễ sử dụng trong trường hợp khẩn cấp 