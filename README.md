# Ứng Dụng Đèn Pin

Ứng dụng đèn pin đa chức năng với giao diện người dùng hiện đại, xây dựng bằng Flutter để chạy trên cả iOS và Android.

## Tính Năng

### P0 (Ưu tiên cao)
- **Đèn Pin Cơ Bản**: Bật/tắt đèn flash, điều chỉnh độ sáng
- **Đèn Pin SOS**: Nhấp nháy theo mã Morse SOS cho tình huống khẩn cấp
- **Tích Hợp AdMob**: Quảng cáo banner, interstitial và rewarded

### P1 (Ưu tiên trung bình)
- **Điều Khiển Nhanh**: Thanh điều khiển nhanh cho các tính năng thường dùng

### P2-P3 (Ưu tiên thấp - sẽ phát triển trong tương lai)
- **Đèn Pin Màu**: Sử dụng màn hình làm đèn pin với nhiều màu sắc
- **Đèn Pin Disco**: Nhấp nháy theo nhịp điệu, hiệu ứng đặc biệt
- **Đèn Pin Mã Morse**: Tạo tín hiệu Morse tùy chỉnh

## Cài Đặt

1. Clone repository này
2. Đảm bảo bạn đã cài đặt Flutter SDK
3. Chạy `flutter pub get` để cài đặt dependencies
4. Chạy `flutter run` để khởi chạy ứng dụng

## Cấu Trúc Dự Án

```
lib/
  ├── main.dart              # Điểm khởi đầu ứng dụng
  ├── app.dart               # Cài đặt theme và routing chính
  ├── screens/               # Các màn hình của ứng dụng
  │   ├── home_screen.dart   # Màn hình chính với bottom nav
  │   ├── flashlight_screen.dart # Màn hình đèn pin cơ bản
  │   ├── sos_screen.dart    # Màn hình tính năng SOS
  │   └── settings_screen.dart # Màn hình cài đặt
  ├── widgets/               # Các widget tái sử dụng
  │   ├── flashlight_button.dart # Nút điều khiển đèn
  │   ├── brightness_slider.dart # Thanh điều chỉnh độ sáng
  │   ├── sos_button.dart    # Nút kích hoạt SOS
  │   ├── speed_slider.dart  # Thanh điều chỉnh tốc độ
  │   └── ad_banner.dart     # Widget hiển thị quảng cáo
  ├── services/              # Các dịch vụ xử lý logic
  │   ├── flashlight_service.dart # Điều khiển đèn flash
  │   ├── sos_service.dart   # Xử lý tính năng SOS
  │   └── ad_service.dart    # Quản lý quảng cáo
  └── providers/             # State management với Provider
      ├── flashlight_provider.dart # Quản lý trạng thái đèn
      ├── sos_provider.dart  # Quản lý trạng thái SOS
      ├── ad_provider.dart   # Quản lý trạng thái quảng cáo
      └── quick_control_provider.dart # Quản lý menu điều khiển nhanh
```

## Quy Định Kỹ Thuật

- **State Management**: Sử dụng Provider cho quản lý trạng thái
- **Thiết Kế**: Material Design 3 với hỗ trợ Dark Mode
- **Quảng Cáo**: Tích hợp Google AdMob

## Yêu Cầu

- Flutter SDK (>= 2.17.0)
- Android: minSdkVersion 21
- iOS: iOS 11.0 hoặc cao hơn

## Cấp Phép

Copyright © 2023 Denpin Team
