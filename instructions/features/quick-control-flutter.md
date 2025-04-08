# Quick Control (Flutter)

## Tổng Quan
Tính năng Quick Control là chức năng P1 (ưu tiên cao) giúp người dùng truy cập nhanh các chức năng của đèn pin thông qua widget trên màn hình chính, quick settings và thông báo, mà không cần mở ứng dụng.

## Package Cần Thiết
```yaml
dependencies:
  home_widget: ^0.3.0  # Tạo widget cho màn hình chính
  flutter_local_notifications: ^16.0.0+1  # Thông báo với các nút
  shared_preferences: ^2.2.2  # Lưu cài đặt
  provider: ^6.1.1  # State management
  quick_actions: ^1.0.5  # Tạo shortcut khi nhấn giữ app icon
```

## Các Thành Phần

### 1. Home Screen Widget
Widget hiển thị trên màn hình chính của thiết bị với các nút:
- Bật/tắt đèn cơ bản
- Kích hoạt đèn SOS
- Đổi màu đèn (nếu thiết bị hỗ trợ)
- Hiển thị trạng thái đèn và mức pin

### 2. Quick Settings Tile
Tile trong khu vực quick settings (thanh thông báo) để bật/tắt đèn nhanh chóng.

### 3. Notification Controls
Thông báo thường trực với các nút điều khiển khi đèn đang bật.

### 4. App Shortcuts
Shortcut menu khi nhấn giữ icon ứng dụng trên màn hình chính.

## Cấu Trúc Files

### 1. services/quick_control_service.dart
```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuickControlService {
  static const String _appWidgetProviderAndroid = 'FlashlightWidgetProvider';
  static const String _clickActionId = 'flashlight_widget_click';
  
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  // Khởi tạo
  Future<void> initialize() async {
    // Khởi tạo notifications
    const AndroidInitializationSettings initializationSettingsAndroid = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );
    
    const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS);
    
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationAction,
    );
    
    // Khởi tạo Home Widget
    HomeWidget.registerBackgroundCallback(_backgroundCallback);
  }
  
  // Background callback cho Home Widget
  @pragma('vm:entry-point')
  static Future<void> _backgroundCallback(Uri? uri) async {
    if (uri?.host == _clickActionId) {
      final sharedPrefs = await SharedPreferences.getInstance();
      
      // Lấy action từ URI
      final action = uri?.queryParameters['action'];
      
      switch (action) {
        case 'toggle':
          final bool isOn = sharedPrefs.getBool('flashlight_on') ?? false;
          await sharedPrefs.setBool('flashlight_on', !isOn);
          // Trong thực tế, cần sử dụng platform channel để điều khiển đèn flash
          break;
        case 'sos':
          final bool sosActive = sharedPrefs.getBool('sos_active') ?? false;
          await sharedPrefs.setBool('sos_active', !sosActive);
          break;
      }
      
      // Cập nhật widget
      await _updateWidget();
    }
  }
  
  // Cập nhật widget trên màn hình chính
  static Future<void> _updateWidget() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    final bool isOn = sharedPrefs.getBool('flashlight_on') ?? false;
    final bool sosActive = sharedPrefs.getBool('sos_active') ?? false;
    
    await HomeWidget.saveWidgetData<bool>('flashlight_on', isOn);
    await HomeWidget.saveWidgetData<bool>('sos_active', sosActive);
    await HomeWidget.updateWidget(
      androidName: _appWidgetProviderAndroid,
      iOSName: 'FlashlightWidget',
    );
  }
  
  // Cập nhật widget từ ứng dụng
  Future<void> updateWidgetFromApp({
    required bool isFlashlightOn,
    required bool isSosActive,
    int? batteryLevel,
  }) async {
    // Lưu trạng thái vào preferences
    final sharedPrefs = await SharedPreferences.getInstance();
    await sharedPrefs.setBool('flashlight_on', isFlashlightOn);
    await sharedPrefs.setBool('sos_active', isSosActive);
    if (batteryLevel != null) {
      await sharedPrefs.setInt('battery_level', batteryLevel);
    }
    
    // Cập nhật data cho widget
    await HomeWidget.saveWidgetData<bool>('flashlight_on', isFlashlightOn);
    await HomeWidget.saveWidgetData<bool>('sos_active', isSosActive);
    if (batteryLevel != null) {
      await HomeWidget.saveWidgetData<int>('battery_level', batteryLevel);
    }
    
    // Yêu cầu widget cập nhật UI
    await HomeWidget.updateWidget(
      androidName: _appWidgetProviderAndroid,
      iOSName: 'FlashlightWidget',
    );
  }
  
  // Hiển thị thông báo có các nút điều khiển
  Future<void> showControlNotification({
    required bool isFlashlightOn,
    required bool isSosActive,
  }) async {
    if (!isFlashlightOn && !isSosActive) {
      // Nếu không có tính năng nào được bật, hủy thông báo
      await _notificationsPlugin.cancel(1);
      return;
    }
    
    // Thiết lập các nút cho thông báo
    final List<AndroidNotificationAction> actions = [
      AndroidNotificationAction(
        'toggle_action',
        isFlashlightOn ? 'Tắt đèn' : 'Bật đèn',
        showsUserInterface: false,
      ),
    ];
    
    // Thêm nút SOS nếu không đang chạy SOS
    if (!isSosActive) {
      actions.add(
        AndroidNotificationAction(
          'sos_action',
          'SOS',
          showsUserInterface: false,
        ),
      );
    } else {
      actions.add(
        AndroidNotificationAction(
          'stop_sos_action',
          'Dừng SOS',
          showsUserInterface: false,
        ),
      );
    }
    
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'control_channel',
      'Điều khiển đèn pin',
      channelDescription: 'Thông báo điều khiển đèn pin',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      actions: actions,
    );
    
    final NotificationDetails details = NotificationDetails(android: androidDetails);
    
    await _notificationsPlugin.show(
      1,
      'Điều khiển đèn pin',
      isFlashlightOn ? 'Đèn đang bật' : (isSosActive ? 'SOS đang hoạt động' : ''),
      details,
    );
  }
  
  // Xử lý khi người dùng nhấn các nút trong thông báo
  Future<void> _onNotificationAction(NotificationResponse response) async {
    switch (response.actionId) {
      case 'toggle_action':
        // Gửi message để bật/tắt đèn
        // Trong thực tế, cần sử dụng platform channel hoặc phương thức khác để kích hoạt
        break;
      case 'sos_action':
        // Gửi message để bật SOS
        break;
      case 'stop_sos_action':
        // Gửi message để tắt SOS
        break;
    }
  }
  
  // Thiết lập app shortcuts
  Future<void> setupAppShortcuts() async {
    // Implement với package quick_actions
  }
}
```

### 2. providers/quick_control_provider.dart
```dart
import 'package:flutter/foundation.dart';
import '../services/quick_control_service.dart';
import '../services/flashlight_service.dart';
import '../services/sos_service.dart';

class QuickControlProvider with ChangeNotifier {
  final QuickControlService _service = QuickControlService();
  final FlashlightService _flashlightService;
  final SOSService _sosService;
  
  QuickControlProvider(this._flashlightService, this._sosService);
  
  // Khởi tạo
  Future<void> initialize() async {
    await _service.initialize();
    await _service.setupAppShortcuts();
    
    // Cập nhật ngay trạng thái ban đầu
    _updateControlsState();
  }
  
  // Cập nhật trạng thái của widget và thông báo
  Future<void> _updateControlsState() async {
    final bool isFlashlightOn = _flashlightService.isFlashlightOn;
    final bool isSosActive = _sosService.isSOSActive;
    
    // Cập nhật widget
    await _service.updateWidgetFromApp(
      isFlashlightOn: isFlashlightOn,
      isSosActive: isSosActive,
      batteryLevel: await _getBatteryLevel(),
    );
    
    // Cập nhật thông báo
    await _service.showControlNotification(
      isFlashlightOn: isFlashlightOn,
      isSosActive: isSosActive,
    );
  }
  
  // Lấy mức pin
  Future<int> _getBatteryLevel() async {
    // Implement logic để lấy mức pin
    // Trong thực tế, sử dụng plugin như battery_plus
    return 80; // Giá trị mẫu
  }
  
  // Callback khi trạng thái đèn thay đổi
  Future<void> onFlashlightStateChanged(bool isOn) async {
    await _updateControlsState();
    notifyListeners();
  }
  
  // Callback khi trạng thái SOS thay đổi
  Future<void> onSOSStateChanged(bool isActive) async {
    await _updateControlsState();
    notifyListeners();
  }
}
```

## Các File Native

### Android: android/app/src/main/kotlin/.../FlashlightWidgetProvider.kt
```kotlin
package com.example.flashlight_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin

class FlashlightWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context, 
        appWidgetManager: AppWidgetManager, 
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            // Lấy dữ liệu từ SharedPreferences
            val widgetData = HomeWidgetPlugin.getData(context)
            val isFlashlightOn = widgetData.getBoolean("flashlight_on", false)
            val isSosActive = widgetData.getBoolean("sos_active", false)
            val batteryLevel = widgetData.getInt("battery_level", 0)
            
            // Tạo RemoteViews
            val views = RemoteViews(context.packageName, R.layout.flashlight_widget_layout)
            
            // Cập nhật trạng thái đèn pin
            val flashlightText = if (isFlashlightOn) "TẮT ĐÈN" else "BẬT ĐÈN"
            views.setTextViewText(R.id.btn_toggle_flashlight, flashlightText)
            
            // Cập nhật SOS
            val sosText = if (isSosActive) "DỪNG SOS" else "SOS"
            views.setTextViewText(R.id.btn_sos, sosText)
            
            // Cập nhật mức pin
            views.setTextViewText(R.id.text_battery, "Pin: $batteryLevel%")
            
            // Thiết lập pending intent cho nút bật/tắt đèn
            val toggleIntent = HomeWidgetBackgroundIntent.getBackgroundIntent(
                context,
                Uri.parse("flashlight_widget_click://toggle?action=toggle")
            )
            views.setOnClickPendingIntent(R.id.btn_toggle_flashlight, toggleIntent)
            
            // Thiết lập pending intent cho nút SOS
            val sosIntent = HomeWidgetBackgroundIntent.getBackgroundIntent(
                context,
                Uri.parse("flashlight_widget_click://sos?action=sos")
            )
            views.setOnClickPendingIntent(R.id.btn_sos, sosIntent)
            
            // Thiết lập pending intent để mở ứng dụng khi nhấn vào widget
            val launchIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java
            )
            views.setOnClickPendingIntent(R.id.widget_container, launchIntent)
            
            // Cập nhật widget
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
```

### Android: android/app/src/main/res/layout/flashlight_widget_layout.xml
```xml
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:id="@+id/widget_container"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="@drawable/widget_background"
    android:orientation="vertical"
    android:padding="8dp">

    <TextView
        android:id="@+id/text_battery"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:gravity="center"
        android:padding="4dp"
        android:text="Pin: 80%"
        android:textColor="#FFFFFF"
        android:textSize="12sp" />

    <Button
        android:id="@+id/btn_toggle_flashlight"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_margin="4dp"
        android:backgroundTint="#3498DB"
        android:text="BẬT ĐÈN"
        android:textColor="#FFFFFF" />

    <Button
        android:id="@+id/btn_sos"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_margin="4dp"
        android:backgroundTint="#E74C3C"
        android:text="SOS"
        android:textColor="#FFFFFF" />

</LinearLayout>
```

### Android: android/app/src/main/res/drawable/widget_background.xml
```xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="#333333" />
    <corners android:radius="8dp" />
</shape>
```

### Android: android/app/src/main/res/xml/flashlight_widget_info.xml
```xml
<?xml version="1.0" encoding="utf-8"?>
<appwidget-provider xmlns:android="http://schemas.android.com/apk/res/android"
    android:initialLayout="@layout/flashlight_widget_layout"
    android:minWidth="180dp"
    android:minHeight="110dp"
    android:previewImage="@drawable/widget_preview"
    android:resizeMode="horizontal|vertical"
    android:updatePeriodMillis="1800000"
    android:widgetCategory="home_screen" />
```

### iOS: ios/Runner/FlashlightWidget.swift
```swift
import WidgetKit
import SwiftUI
import Intents

struct FlashlightWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> FlashlightWidgetEntry {
        FlashlightWidgetEntry(date: Date(), isFlashlightOn: false, isSosActive: false, batteryLevel: 80)
    }

    func getSnapshot(in context: Context, completion: @escaping (FlashlightWidgetEntry) -> ()) {
        let entry = FlashlightWidgetEntry(date: Date(), isFlashlightOn: false, isSosActive: false, batteryLevel: 80)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let userDefaults = UserDefaults(suiteName: "group.com.example.flashlightApp")
        
        let isFlashlightOn = userDefaults?.bool(forKey: "flashlight_on") ?? false
        let isSosActive = userDefaults?.bool(forKey: "sos_active") ?? false
        let batteryLevel = userDefaults?.integer(forKey: "battery_level") ?? 80
        
        let entry = FlashlightWidgetEntry(
            date: Date(),
            isFlashlightOn: isFlashlightOn,
            isSosActive: isSosActive,
            batteryLevel: batteryLevel
        )
        
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct FlashlightWidgetEntry: TimelineEntry {
    let date: Date
    let isFlashlightOn: Bool
    let isSosActive: Bool
    let batteryLevel: Int
}

struct FlashlightWidgetEntryView : View {
    var entry: FlashlightWidgetProvider.Entry
    
    var body: some View {
        VStack {
            Text("Pin: \(entry.batteryLevel)%")
                .font(.caption)
                .padding(.top, 4)
            
            Button(action: {
                if let url = URL(string: "flashlightapp://toggle") {
                    UIApplication.shared.open(url)
                }
            }) {
                Text(entry.isFlashlightOn ? "TẮT ĐÈN" : "BẬT ĐÈN")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            
            Button(action: {
                if let url = URL(string: "flashlightapp://sos") {
                    UIApplication.shared.open(url)
                }
            }) {
                Text(entry.isSosActive ? "DỪNG SOS" : "SOS")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color(UIColor.darkGray))
        .cornerRadius(8)
    }
}

@main
struct FlashlightWidget: Widget {
    let kind: String = "FlashlightWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FlashlightWidgetProvider()) { entry in
            FlashlightWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Đèn Pin")
        .description("Điều khiển đèn pin nhanh chóng")
        .supportedFamilies([.systemSmall])
    }
}
```

## Quick Settings Tile (Chỉ áp dụng cho Android)

### Android: android/app/src/main/kotlin/.../FlashlightTileService.kt
```kotlin
package com.example.flashlight_app

import android.content.SharedPreferences
import android.graphics.drawable.Icon
import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import androidx.annotation.RequiresApi

@RequiresApi(Build.VERSION_CODES.N)
class FlashlightTileService : TileService() {
    
    override fun onStartListening() {
        super.onStartListening()
        updateTile()
    }
    
    override fun onClick() {
        super.onClick()
        
        // Lấy trạng thái hiện tại
        val sharedPreferences = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
        val currentState = sharedPreferences.getBoolean("flutter.flashlight_on", false)
        
        // Đảo trạng thái
        val editor = sharedPreferences.edit()
        editor.putBoolean("flutter.flashlight_on", !currentState)
        editor.apply()
        
        // Cập nhật tile
        updateTile()
        
        // Gửi broadcast để thông báo cho Flutter app
        val intent = Intent("com.example.flashlight_app.FLASHLIGHT_TOGGLED")
        intent.putExtra("isOn", !currentState)
        sendBroadcast(intent)
    }
    
    private fun updateTile() {
        val tile = qsTile ?: return
        
        // Lấy trạng thái từ shared preferences
        val sharedPreferences = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
        val isFlashlightOn = sharedPreferences.getBoolean("flutter.flashlight_on", false)
        
        // Cập nhật state và icon
        if (isFlashlightOn) {
            tile.state = Tile.STATE_ACTIVE
            tile.icon = Icon.createWithResource(this, R.drawable.ic_flashlight_on)
        } else {
            tile.state = Tile.STATE_INACTIVE
            tile.icon = Icon.createWithResource(this, R.drawable.ic_flashlight_off)
        }
        
        tile.label = "Đèn pin"
        tile.updateTile()
    }
}
```

## Cập Nhật AndroidManifest.xml
```xml
<manifest ...>
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    
    <application ...>
        <!-- Khai báo Widget Provider -->
        <receiver android:name=".FlashlightWidgetProvider"
            android:exported="true">
            <intent-filter>
                <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
            </intent-filter>
            <meta-data
                android:name="android.appwidget.provider"
                android:resource="@xml/flashlight_widget_info" />
        </receiver>
        
        <!-- Khai báo Quick Settings Tile Service (Android N+) -->
        <service
            android:name=".FlashlightTileService"
            android:icon="@drawable/ic_flashlight_off"
            android:label="Đèn pin"
            android:permission="android.permission.BIND_QUICK_SETTINGS_TILE"
            android:exported="true">
            <intent-filter>
                <action android:name="android.service.quicksettings.action.QS_TILE" />
            </intent-filter>
            <meta-data
                android:name="android.service.quicksettings.ACTIVE_TILE"
                android:value="false" />
        </service>
    </application>
</manifest>
```

## Sử Dụng trong Main App

### lib/main.dart hoặc một file khởi tạo
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final flashlightService = FlashlightService();
  await flashlightService.initialize();
  
  final sosService = SOSService();
  await sosService.initialize(flashlightService.getCameraController());
  
  final flashlightProvider = FlashlightProvider(flashlightService);
  final sosProvider = SOSProvider(flashlightProvider);
  
  // Khởi tạo quick control provider
  final quickControlProvider = QuickControlProvider(flashlightService, sosService);
  await quickControlProvider.initialize();
  
  // Thiết lập listeners
  flashlightProvider.addListener(() {
    quickControlProvider.onFlashlightStateChanged(flashlightProvider.isFlashlightOn);
  });
  
  sosProvider.addListener(() {
    quickControlProvider.onSOSStateChanged(sosProvider.isSOSActive);
  });
  
  // Khởi chạy app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: flashlightProvider),
        ChangeNotifierProvider.value(value: sosProvider),
        ChangeNotifierProvider.value(value: quickControlProvider),
      ],
      child: MyApp(),
    ),
  );
}
```

## Tối Ưu Hóa

### 1. Battery Optimization
- Đảm bảo widget không tự cập nhật quá thường xuyên (mặc định là 30 phút)
- Nếu bật đèn từ widget, cần có cơ chế tự động tắt sau khoảng thời gian nhất định
- Xử lý gracefully khi không thể truy cập camera từ background

### 2. Giao Diện
- Widget có 2 kích cỡ: small (chỉ nút bật/tắt) và medium (đầy đủ các nút)
- Màu sắc và icon thay đổi theo trạng thái (sáng/tối, bật/tắt)
- Hiển thị thông tin pin để người dùng biết còn bao nhiêu thời gian sử dụng

### 3. Xử Lý Đồng Bộ
- Đảm bảo trạng thái đồng bộ giữa ứng dụng, widget và quick settings
- Sử dụng SharedPreferences hoặc tương tự để lưu trữ và đồng bộ dữ liệu

## Các Trường Hợp Đặc Biệt
- Thiết bị không hỗ trợ quick settings tiles (Android < 7.0)
- iOS không hỗ trợ quick settings tile (tập trung vào widget cho iOS)
- Xử lý khi camera đang bị chiếm bởi ứng dụng khác

## Kiểm Thử
- Test trên nhiều thiết bị Android và iOS khác nhau
- Kiểm tra cơ chế đồng bộ sau khi khởi động lại thiết bị
- Test trong điều kiện pin yếu và chế độ tiết kiệm pin

## Tiêu Chí Hoàn Thành
- Widget hiển thị và hoạt động đúng trên cả Android và iOS
- Quick Settings Tile hoạt động trên Android 7.0+
- Thông báo điều khiển hiển thị khi đèn được bật
- Trạng thái đồng bộ giữa tất cả điểm truy cập