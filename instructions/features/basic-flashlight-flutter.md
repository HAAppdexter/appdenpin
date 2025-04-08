# Đèn Pin Cơ Bản (Flutter)

## Tổng Quan
Tính năng đèn pin cơ bản là tính năng P0 (ưu tiên cao nhất) của ứng dụng, cho phép người dùng bật/tắt đèn flash của camera bằng Flutter và điều chỉnh độ sáng nếu thiết bị hỗ trợ.

## Package Cần Thiết
```yaml
dependencies:
  camera: ^0.10.5+5  # Để truy cập camera và đèn flash
  permission_handler: ^11.0.1  # Để xử lý quyền truy cập camera
  wakelock: ^0.6.2  # Giữ màn hình sáng khi đèn đang bật
  shared_preferences: ^2.2.2  # Lưu trạng thái đèn
  provider: ^6.1.1  # State management
```

## Thành Phần UI
- Màn hình chính với nút bật/tắt lớn ở giữa (StatefulWidget)
- Slider điều chỉnh độ sáng (nếu thiết bị hỗ trợ)
- Hiệu ứng khi nhấn nút (animation đơn giản)
- Indicator hiển thị trạng thái đèn

## Cấu Trúc Files

### 1. service/flashlight_service.dart
```dart
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlashlightService {
  CameraController? _controller;
  bool _isFlashlightOn = false;
  double _brightness = 1.0; // Với thiết bị hỗ trợ
  
  // Khởi tạo camera
  Future<void> initialize() async {
    // Kiểm tra và yêu cầu quyền camera
    if (await Permission.camera.request().isGranted) {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      
      // Tìm camera sau
      final rear = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      
      _controller = CameraController(
        rear,
        ResolutionPreset.low,
        enableAudio: false,
      );
      
      await _controller!.initialize();
    }
  }
  
  // Bật/tắt đèn flash
  Future<bool> toggleFlashlight() async {
    if (_controller == null) await initialize();
    if (_controller == null) return false;
    
    try {
      _isFlashlightOn = !_isFlashlightOn;
      await _controller!.setFlashMode(
        _isFlashlightOn ? FlashMode.torch : FlashMode.off
      );
      _saveState();
      return _isFlashlightOn;
    } catch (e) {
      print('Không thể điều khiển đèn flash: $e');
      return false;
    }
  }
  
  // Điều chỉnh độ sáng (nếu thiết bị hỗ trợ)
  Future<void> setBrightness(double value) async {
    _brightness = value;
    // Platform-specific code sẽ được thêm vào đây
    // Sử dụng method channel để gọi native code điều chỉnh độ sáng
    _saveState();
  }
  
  // Lưu trạng thái
  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('flashlight_state', _isFlashlightOn);
    await prefs.setDouble('brightness', _brightness);
  }
  
  // Khôi phục trạng thái
  Future<void> restoreState() async {
    final prefs = await SharedPreferences.getInstance();
    _isFlashlightOn = prefs.getBool('flashlight_state') ?? false;
    _brightness = prefs.getDouble('brightness') ?? 1.0;
    
    if (_isFlashlightOn) {
      await initialize();
      if (_controller != null) {
        await _controller!.setFlashMode(FlashMode.torch);
      }
    }
  }
  
  // Giải phóng tài nguyên
  void dispose() {
    _controller?.dispose();
    _controller = null;
  }
  
  // Getters
  bool get isFlashlightOn => _isFlashlightOn;
  double get brightness => _brightness;
}
```

### 2. providers/flashlight_provider.dart
```dart
import 'package:flutter/foundation.dart';
import '../services/flashlight_service.dart';

class FlashlightProvider with ChangeNotifier {
  final FlashlightService _service = FlashlightService();
  
  bool get isFlashlightOn => _service.isFlashlightOn;
  double get brightness => _service.brightness;
  
  Future<void> initialize() async {
    await _service.initialize();
    await _service.restoreState();
    notifyListeners();
  }
  
  Future<void> toggleFlashlight() async {
    await _service.toggleFlashlight();
    notifyListeners();
  }
  
  Future<void> setBrightness(double value) async {
    await _service.setBrightness(value);
    notifyListeners();
  }
  
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
```

### 3. screens/home_screen.dart
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';
import '../providers/flashlight_provider.dart';
import '../widgets/flashlight_button.dart';
import '../widgets/brightness_slider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Khởi tạo flashlight service
    Future.microtask(() => 
      Provider.of<FlashlightProvider>(context, listen: false).initialize()
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final flashlightProvider = Provider.of<FlashlightProvider>(context);
    
    // Cập nhật wakelock khi flashlight được bật/tắt
    if (flashlightProvider.isFlashlightOn) {
      Wakelock.enable();
    } else {
      Wakelock.disable();
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Đèn Pin'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlashlightButton(
              isOn: flashlightProvider.isFlashlightOn,
              onPressed: () => flashlightProvider.toggleFlashlight(),
            ),
            SizedBox(height: 40),
            BrightnessSlider(
              value: flashlightProvider.brightness,
              onChanged: (value) => flashlightProvider.setBrightness(value),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    Wakelock.disable();
    super.dispose();
  }
}
```

### 4. widgets/flashlight_button.dart
```dart
import 'package:flutter/material.dart';

class FlashlightButton extends StatelessWidget {
  final bool isOn;
  final VoidCallback onPressed;
  
  const FlashlightButton({
    Key? key,
    required this.isOn,
    required this.onPressed,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isOn ? Colors.yellow : Colors.grey[300],
          boxShadow: isOn
            ? [
                BoxShadow(
                  color: Colors.yellow.withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 10,
                )
              ]
            : [],
        ),
        child: Icon(
          isOn ? Icons.flash_on : Icons.flash_off,
          size: 60,
          color: isOn ? Colors.black87 : Colors.black54,
        ),
      ),
    );
  }
}
```

### 5. widgets/brightness_slider.dart
```dart
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
    return Column(
      children: [
        Text(
          'Độ sáng',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 8),
        Container(
          width: 250,
          child: Slider(
            value: value,
            min: 0.1,
            max: 1.0,
            divisions: 9,
            onChanged: onChanged,
            activeColor: Colors.yellow,
            inactiveColor: Colors.grey[300],
          ),
        ),
      ],
    );
  }
}
```

## Method Channel cho Điều chỉnh Độ Sáng (Android)

Vì Flutter không có API trực tiếp để điều chỉnh độ sáng đèn flash, chúng ta cần tạo method channel để gọi native code:

### android/app/src/main/kotlin/.../FlashlightPlugin.kt
```kotlin
package com.example.flashlight_app

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import android.hardware.camera2.CameraManager
import android.content.Context

class FlashlightPlugin(private val context: Context) : MethodChannel.MethodCallHandler {
    private val CHANNEL = "com.example.flashlight_app/flashlight"
    private var cameraManager: CameraManager? = null
    private var cameraId: String? = null
    
    fun init(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler(this)
        cameraManager = context.getSystemService(Context.CAMERA_SERVICE) as CameraManager
        try {
            cameraId = cameraManager?.cameraIdList?.firstOrNull { 
                cameraManager?.getCameraCharacteristics(it)?.get(
                    CameraCharacteristics.LENS_FACING
                ) == CameraMetadata.LENS_FACING_BACK 
            }
        } catch (e: Exception) {
            // Handle exception
        }
    }
    
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "setBrightness" -> {
                val brightness = call.argument<Double>("brightness") ?: 1.0
                try {
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
                        cameraManager?.turnOnTorchWithStrengthLevel(cameraId!!, (brightness * 100).toInt())
                        result.success(true)
                    } else {
                        // API cũ không hỗ trợ điều chỉnh độ sáng
                        result.success(false)
                    }
                } catch (e: Exception) {
                    result.error("BRIGHTNESS_ERROR", e.message, null)
                }
            }
            else -> result.notImplemented()
        }
    }
}
```

## Xử Lý Lifecycle
- Lưu và khôi phục trạng thái đèn khi ứng dụng đi vào background và quay lại
- Tự động tắt đèn khi ứng dụng tắt để tránh tiêu tốn pin
- Sử dụng WidgetsBindingObserver để lắng nghe các sự kiện lifecycle

## Xử lý Thiết bị Không Hỗ Trợ
- Kiểm tra khả năng hỗ trợ đèn flash
- Fallback UI khi thiết bị không có đèn flash
- Thông báo cho người dùng khi tính năng không được hỗ trợ

## Tối Ưu Hóa Pin
- Đóng kết nối camera khi không sử dụng
- Sử dụng ResolutionPreset.low để giảm tài nguyên sử dụng
- Tự động tắt đèn sau khoảng thời gian không hoạt động

## Kiểm Thử
- Test trên nhiều thiết bị Android và iOS khác nhau
- Kiểm tra việc xử lý quyền truy cập camera
- Test với các phiên bản Flutter và OS khác nhau
- Kiểm tra tính năng điều chỉnh độ sáng trên thiết bị hỗ trợ

## Tiêu Chí Hoàn Thành
- Đèn flash hoạt động chính xác trên đa dạng thiết bị
- UI phản hồi mượt mà, không lag
- Độ trễ phản hồi khi bật/tắt đèn dưới 500ms
- Điều chỉnh độ sáng hoạt động trên thiết bị hỗ trợ
- Lưu và khôi phục trạng thái đèn chính xác 