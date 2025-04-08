import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class QuickControlProvider extends ChangeNotifier {
  final CameraController? _cameraController;
  bool _isFlashlightOn = false;
  bool _isSOSActive = false;

  QuickControlProvider(this._cameraController);

  // Getter
  bool get isFlashlightOn => _isFlashlightOn;
  bool get isSOSActive => _isSOSActive;
  CameraController? get cameraController => _cameraController;

  // Cập nhật trạng thái đèn pin
  void onFlashlightStateChanged(bool isOn) {
    _isFlashlightOn = isOn;
    notifyListeners();
  }

  // Cập nhật trạng thái SOS
  void onSOSStateChanged(bool isActive) {
    _isSOSActive = isActive;
    notifyListeners();
  }
} 