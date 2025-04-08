import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../providers/sos_provider.dart';

class SOSScreen extends StatefulWidget {
  const SOSScreen({Key? key}) : super(key: key);

  @override
  State<SOSScreen> createState() => _SOSScreenState();
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
    WakelockPlus.disable();
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
      await Future.delayed(const Duration(seconds: 1));
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
      WakelockPlus.enable();
      if (!_timerActive) _startTimer();
    } else {
      if (_timerActive) _stopTimer();
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hiển thị thời gian hoạt động
          if (_timerActive)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Thời gian: ${_formatTime(_activeSeconds)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          
          const SizedBox(height: 40),
          
          // SOS Button
          GestureDetector(
            onTap: () {
              if (!sosProvider.isSOSActive && !_showWarningDialog) {
                // Hiển thị thông báo xác nhận trước khi bật
                setState(() => _showWarningDialog = true);
                
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Xác nhận SOS'),
                    content: const Text(
                      'Chức năng này chỉ nên sử dụng trong trường hợp khẩn cấp. '
                      'Tiếp tục?'
                    ),
                    actions: [
                      TextButton(
                        child: const Text('HỦY'),
                        onPressed: () {
                          setState(() => _showWarningDialog = false);
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('BẬT SOS'),
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
              duration: const Duration(milliseconds: 300),
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
          
          const SizedBox(height: 40),
          
          // Speed control
          if (!sosProvider.isSOSActive)
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Tốc độ nháy',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Chậm'),
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
                      const Text('Nhanh'),
                    ],
                  ),
                ],
              ),
            ),
          
          // Thông tin SOS Morse
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Tín hiệu SOS chuẩn Morse:\n• • •   — — —   • • •\nS = Ba nháy ngắn\nO = Ba nháy dài',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 