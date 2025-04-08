import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/ad_provider.dart';

void main() async {
  // Đảm bảo Flutter được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo AdProvider
  final adProvider = AdProvider();
  
  // Chỉ khởi tạo AdMob khi không phải web
  if (!kIsWeb) {
    await adProvider.initialize();
  }
  
  runApp(
    ChangeNotifierProvider.value(
      value: adProvider,
      child: const FlashlightApp(),
    ),
  );
}
