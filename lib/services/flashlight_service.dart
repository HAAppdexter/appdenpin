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
    // Trong thực tế, sử dụng method channel để gọi native code điều chỉnh độ sáng
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
  
  // Lấy controller cho các service khác sử dụng
  CameraController? getCameraController() {
    return _controller;
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