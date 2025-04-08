import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../providers/flashlight_provider.dart';
import '../providers/ad_provider.dart';
import '../widgets/flashlight_button.dart';
import '../widgets/brightness_slider.dart';
import '../widgets/banner_ad_widget.dart';
import 'sos_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  DateTime? _flashlightStartTime;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Khởi tạo AdMob
    Future.microtask(() => 
      Provider.of<AdProvider>(context, listen: false).initialize()
    );
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    final flashlightProvider = Provider.of<FlashlightProvider>(context, listen: false);
    
    if (state == AppLifecycleState.paused) {
      // Ghi nhớ thời gian khi ứng dụng vào background
      if (flashlightProvider.isFlashlightOn && _flashlightStartTime == null) {
        _flashlightStartTime = DateTime.now();
      }
    } else if (state == AppLifecycleState.resumed) {
      // Hiển thị quảng cáo khi trở lại từ background nếu đã sử dụng đèn đủ lâu
      _checkAndShowAdAfterUsage();
    }
  }
  
  // Ghi lại thời gian khi bật đèn
  void _recordFlashlightStartTime() {
    if (_flashlightStartTime == null) {
      setState(() {
        _flashlightStartTime = DateTime.now();
      });
    }
  }
  
  // Kiểm tra và hiển thị quảng cáo khi tắt đèn sau khi sử dụng đủ lâu
  Future<void> _checkAndShowAdAfterUsage() async {
    if (_flashlightStartTime != null) {
      final usageDuration = DateTime.now().difference(_flashlightStartTime!);
      
      if (usageDuration.inSeconds > 60) {
        final adProvider = Provider.of<AdProvider>(context, listen: false);
        await adProvider.showAdAfterFlashlightUse(usageDuration.inSeconds);
      }
      
      setState(() {
        _flashlightStartTime = null;
      });
    }
  }
  
  // Xử lý khi chuyển tab
  void _onTabSelected(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
    }
  }
  
  // Hiển thị màn hình theo tab đang chọn
  Widget _buildScreen() {
    switch (_currentIndex) {
      case 0:
        return _buildFlashlightScreen();
      case 1: 
        return const SOSScreen();
      case 2:
        return _buildSettingsScreen();
      default:
        return _buildFlashlightScreen();
    }
  }
  
  // Màn hình đèn pin cơ bản
  Widget _buildFlashlightScreen() {
    final flashlightProvider = Provider.of<FlashlightProvider>(context);
    
    // Cập nhật wakelock khi flashlight được bật/tắt
    if (flashlightProvider.isFlashlightOn) {
      WakelockPlus.enable();
      _recordFlashlightStartTime();
    } else {
      WakelockPlus.disable();
      if (_flashlightStartTime != null) {
        _checkAndShowAdAfterUsage();
      }
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FlashlightButton(
            isOn: flashlightProvider.isFlashlightOn,
            onPressed: () => flashlightProvider.toggleFlashlight(),
          ),
          const SizedBox(height: 40),
          BrightnessSlider(
            value: flashlightProvider.brightness,
            onChanged: (value) => flashlightProvider.setBrightness(value),
          ),
        ],
      ),
    );
  }
  
  // Màn hình cài đặt
  Widget _buildSettingsScreen() {
    return Center(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Về ứng dụng'),
              subtitle: const Text('Phiên bản 1.0.0'),
              onTap: () {
                // Hiển thị dialog thông tin
                showAboutDialog(
                  context: context,
                  applicationName: 'Đèn Pin',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2023 Flutter App',
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Chính sách quyền riêng tư'),
              onTap: () {
                // Hiển thị privacy policy
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Chính sách quyền riêng tư'),
                    content: const SingleChildScrollView(
                      child: Text(
                        'Ứng dụng của chúng tôi sử dụng dịch vụ quảng cáo của Google AdMob.\n\n'
                        'AdMob có thể thu thập thông tin giới hạn bao gồm:\n'
                        '- ID quảng cáo của thiết bị\n'
                        '- Thông tin về ứng dụng đang sử dụng\n'
                        '- Vị trí địa lý tổng quát (nếu được cho phép)\n\n'
                        'Chúng tôi không thu thập hoặc chia sẻ thông tin cá nhân khác.',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Đóng'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đèn Pin'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Màn hình chính
          Expanded(
            child: _buildScreen(),
          ),
          
          // Banner ad
          const BannerAdWidget(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.flashlight_on),
            label: 'Đèn Pin',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sos),
            label: 'SOS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Cài Đặt',
          ),
        ],
      ),
    );
  }
} 