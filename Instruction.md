# Instruction: Ứng Dụng Đèn Pin (Flutter)

## Tổng Quan
- Ứng dụng đèn pin đa chức năng sử dụng Flutter
- UI đơn giản, trực quan, material design
- Doanh thu từ quảng cáo
- Cross-platform (Android ưu tiên, iOS nếu khả thi)

## Tech Stack
- Flutter (Latest stable)
- Dart SDK
- flutter_camera package hoặc camera_plus
- google_mobile_ads package cho AdMob
- shared_preferences cho lưu cài đặt
- provider hoặc bloc cho state management

## Tính Năng (❌=chưa làm, ⏳=đang làm, ✅=hoàn thành)

### P0 (Cần thiết)
1. **Đèn Pin Cơ Bản** ❌
   - Bật/tắt đèn flash, điều chỉnh độ sáng
   - Sử dụng camera plugin để truy cập đèn flash

2. **Đèn SOS** ❌
   - Mẫu SOS chuẩn Morse
   - Sử dụng async để xử lý timing chính xác

3. **Điều Khiển Một Chạm** ❌
   - Widget với home_screen_widget plugin
   - Quick Settings Tile (Android)
   - Xử lý background tasks

### P1 (Quan trọng)
4. **Đèn Thông Báo** ❌
   - Notification listener với flutter_local_notifications
   - Xử lý foreground service

5. **Đèn Pin Màn Hình Màu** ❌
   - Sử dụng màn hình làm đèn
   - Color picker, lưu màu đã dùng

6. **Banner Quảng Cáo** ❌
   - Hiển thị dưới màn hình chính

### P2 (Tăng cường)
7. **Đèn Disco** ❌
   - Animations và Timer để tạo hiệu ứng
   - Nhiều mẫu nháy khác nhau

8. **Điều Chỉnh Tốc Độ Nháy** ❌
   - Flutter sliders cho điều chỉnh
   - Lưu trữ cài đặt

9. **Quảng Cáo Nâng Cao** ❌
   - Interstitial và Rewarded ads
   - Quản lý hiển thị hợp lý

## Package Chính
- camera: ^0.10.5+5 (cho đèn flash)
- wakelock: ^0.6.2 (giữ màn hình sáng)
- shared_preferences: ^2.2.2 (lưu cài đặt)
- google_mobile_ads: ^3.1.0 (quảng cáo)
- home_widget: ^0.3.0 (widget tùy chỉnh)
- provider: ^6.1.1 (state management)
- flutter_local_notifications: ^16.0.0+1

## Cấu Trúc Dự Án
```
lib/
├── main.dart
├── app.dart
├── services/
│   ├── flashlight_service.dart
│   ├── notification_service.dart
│   ├── ad_service.dart
│   └── preferences_service.dart
├── screens/
│   ├── home_screen.dart
│   ├── sos_screen.dart
│   ├── color_screen.dart
│   └── settings_screen.dart
├── widgets/
│   ├── flashlight_button.dart
│   ├── sos_controls.dart
│   └── brightness_slider.dart
└── utils/
    ├── constants.dart
    └── helpers.dart
```

## Quyền Hạn
- Camera (đèn flash)
- Thông báo (Android)
- Đọc/ghi bộ nhớ (cài đặt)
- Internet (quảng cáo)
- Chạy nền (foreground service)

## Quy Trình Làm Việc
1. Cài đặt Flutter và dependencies
2. Tạo cấu trúc dự án cơ bản
3. Triển khai các tính năng theo thứ tự P0 → P1 → P2
4. Chuyển đổi giữa các nền tảng cần cẩn thận (đặc biệt với camera và background services)
5. Đặt platform channels cho các tính năng native-specific

## Lưu Ý Flutter
- Các plugin camera có thể không hoạt động đồng nhất trên tất cả thiết bị
- Sử dụng platform-specific code (method channels) cho một số tính năng không được hỗ trợ trực tiếp bởi Flutter
- Có thể cần xây dựng plugins tùy chỉnh cho các tính năng đặc biệt (ví dụ: quick settings tile)
- Tối ưu hóa battery usage rất quan trọng với ứng dụng đèn pin

## AdMob
- Banner: dưới màn hình chính
- Interstitial: sau khi dùng 30s
- Rewarded: cho theme màu đặc biệt
- Tuân thủ quy định của Google
