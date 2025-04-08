import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sos_provider.dart';

class SOSButton extends StatelessWidget {
  final double size;
  final double iconSize;
  final Function? onConfirmActivation;
  
  const SOSButton({
    Key? key,
    this.size = 200,
    this.iconSize = 80,
    this.onConfirmActivation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SOSProvider>(
      builder: (context, sosProvider, child) {
        final isActive = sosProvider.isSOSActive;
        
        return GestureDetector(
          onTap: () {
            if (isActive) {
              // Dừng SOS nếu đang hoạt động
              sosProvider.stopSOS();
            } else {
              // Hiển thị hộp thoại xác nhận trước khi kích hoạt
              _showConfirmationDialog(context, sosProvider);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.red[700] : Colors.grey[800],
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.6),
                        spreadRadius: 8,
                        blurRadius: 24,
                        offset: const Offset(0, 0),
                      )
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isActive ? Icons.warning_amber : Icons.sos,
                    size: iconSize,
                    color: isActive ? Colors.white : Colors.red[300],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'SOS',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : Colors.red[300],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Future<void> _showConfirmationDialog(BuildContext context, SOSProvider sosProvider) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Kích hoạt SOS'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Tính năng SOS chỉ nên được sử dụng trong trường hợp khẩn cấp.'),
                SizedBox(height: 8),
                Text('Đèn pin sẽ nhấp nháy theo tín hiệu Morse SOS (···−−−···).'),
                SizedBox(height: 8),
                Text('Bạn có chắc chắn muốn kích hoạt tính năng này?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Kích hoạt'),
              onPressed: () {
                sosProvider.startSOS();
                Navigator.of(context).pop();
                if (onConfirmActivation != null) {
                  onConfirmActivation!();
                }
              },
            ),
          ],
        );
      },
    );
  }
} 