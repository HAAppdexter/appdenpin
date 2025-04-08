import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/ad_provider.dart';
import '../widgets/flashlight_button.dart';
import '../widgets/ad_banner.dart';

class FlashlightScreen extends StatefulWidget {
  const FlashlightScreen({Key? key}) : super(key: key);

  @override
  State<FlashlightScreen> createState() => _FlashlightScreenState();
}

class _FlashlightScreenState extends State<FlashlightScreen> with WidgetsBindingObserver {
  bool _isFlashlightOn = false;
  double _brightness = 1.0;
  DateTime? _pausedTime;
  int _selectedIndex = 0;  // 0: Flashlight, 1: SOS, 2: Disco
  String _direction = "294° NW";  // Mock compass direction
  
  // List of tab names
  final List<String> _tabs = ['Flashlight', 'SOS', 'Disco'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Lưu lại thời điểm ứng dụng bị tạm dừng
      _pausedTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed && _pausedTime != null) {
      // Tính thời gian ứng dụng ở nền
      final pausedDuration = DateTime.now().difference(_pausedTime!).inSeconds;
      _pausedTime = null;
      
      // Hiển thị quảng cáo nếu thời gian ở nền > 30 giây
      if (!kIsWeb && pausedDuration > 30) {
        Future.delayed(const Duration(milliseconds: 500), () {
          final adProvider = Provider.of<AdProvider>(context, listen: false);
          adProvider.showInterstitialAd();
        });
      }
    }
  }
  
  void _toggleFlashlight() {
    setState(() {
      _isFlashlightOn = !_isFlashlightOn;
    });
  }
  
  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildCompass() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Direction text inside a darker container
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            _direction,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Triangle indicator
        Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: Colors.cyan,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 5),
        // Compass image
        Stack(
          alignment: Alignment.center,
          children: [
            Image.asset('assets/images/cross_1.webp', height: 80),
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: const Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 5,
                    child: Text('N', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Positioned(
                    right: 5,
                    child: Text('E', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Positioned(
                    bottom: 5,
                    child: Text('S', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Positioned(
                    left: 5,
                    child: Text('W', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  // Red arrow pointing north
                  Center(
                    child: Icon(
                      Icons.navigation,
                      color: Colors.red,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Status bar time display (mock)
            Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 15),
              child: Text(
                "10:20",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // Tab navigation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: List.generate(_tabs.length, (index) {
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _onTabSelected(index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedIndex == index ? Colors.blue : null,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            _tabs[index],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _selectedIndex == index ? Colors.white : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Compass display
            _buildCompass(),
            
            // Main flashlight button
            Expanded(
              child: Center(
                child: FlashlightButton(
                  size: 180,
                  iconSize: 70,
                  isOn: _isFlashlightOn,
                  onPressed: _toggleFlashlight,
                ),
              ),
            ),
            
            // Bottom toolbar
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildToolbarButton('Shortcut', 'assets/images/ic_shortcut_on.xml'),
                  _buildToolbarButton('Screen light', 'assets/images/ic_screenlight.xml'),
                  _buildToolbarButton('LED text', 'assets/images/ic_ledtext.xml'),
                  _buildToolbarButton('More tools', 'assets/images/ic_tools.xml'),
                ],
              ),
            ),
            
            // Ad banner at the bottom
            if (!kIsWeb) const AdBanner(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildToolbarButton(String label, String iconAsset) {
    // Since we're using XML assets that might not work directly, 
    // we'll use standard icons as fallback
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: _getIconForAsset(iconAsset),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  Widget _getIconForAsset(String iconAsset) {
    // Map XML asset names to appropriate icons
    if (iconAsset.contains('shortcut')) {
      return const Icon(Icons.touch_app, color: Colors.white, size: 24);
    } else if (iconAsset.contains('screenlight')) {
      return const Icon(Icons.phone_android, color: Colors.white, size: 24);
    } else if (iconAsset.contains('ledtext')) {
      return const Icon(Icons.text_fields, color: Colors.white, size: 24);
    } else if (iconAsset.contains('tools')) {
      return const Icon(Icons.add_circle_outline, color: Colors.white, size: 24);
    } else {
      return const Icon(Icons.circle, color: Colors.white, size: 24);
    }
  }
} 