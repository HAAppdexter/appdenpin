# Đèn Pin App - Hướng Dẫn Tính Năng

Thư mục này chứa hướng dẫn chi tiết cho từng tính năng của ứng dụng Đèn Pin sử dụng Flutter.

## Danh Sách Tính Năng

### Nhóm P0 (Ưu tiên cao nhất)
1. [Đèn Pin Cơ Bản](./basic-flashlight-flutter.md) - Tính năng đèn pin cơ bản với điều khiển độ sáng
2. [Đèn SOS](./sos-flashlight-flutter.md) - Tính năng đèn SOS theo chuẩn Morse code (... --- ...)
3. [Tích Hợp AdMob](./admob-integration-flutter.md) - Hiển thị quảng cáo banner, interstitial và rewarded

### Nhóm P1 (Ưu tiên cao)
1. [Quick Control](./quick-control-flutter.md) - Điều khiển nhanh qua widget, quick settings và thông báo

### Nhóm P2 (Ưu tiên trung bình)
1. [Đèn Màu](./color-flashlight-flutter.md) - Điều chỉnh màu sắc màn hình để tạo đèn màu

### Nhóm P3 (Ưu tiên thấp)
1. [Đèn Disco](./disco-flashlight-flutter.md) - Hiệu ứng nhấp nháy theo nhạc
2. [Đèn Morse](./morse-code-flashlight-flutter.md) - Chuyển đổi văn bản thành tín hiệu Morse

## Cách Sử Dụng

Mỗi tài liệu hướng dẫn bao gồm:
- Tổng quan tính năng
- Package cần thiết
- Cấu trúc file và code mẫu
- Cách tối ưu hóa
- Các trường hợp đặc biệt cần xử lý
- Tiêu chí hoàn thành

## Tiêu Chuẩn Kỹ Thuật Chung

Tất cả các tính năng đều được phát triển theo những tiêu chuẩn sau:
- Sử dụng Provider pattern cho state management
- Tối ưu hóa sử dụng pin
- Thiết kế responsive cho nhiều kích thước màn hình
- Hỗ trợ cả Android và iOS
- Sử dụng theme nhất quán
- Có đầy đủ xử lý lỗi và trạng thái loading

## Các Tính Năng Ưu Tiên P0 (Cần thiết)

- [**Đèn Pin Cơ Bản**](basic-flashlight.md): Chức năng đèn pin chính với điều khiển đèn flash và độ sáng.
- [**Đèn SOS**](sos-flashlight.md): Chế độ nháy đèn theo tín hiệu SOS chuẩn Morse.
- [**Điều Khiển Một Chạm**](quick-control.md): Widget, Quick Settings Tile và App Shortcuts.

## Các Tính Năng Ưu Tiên P1 (Quan trọng)

- **Đèn Thông Báo**: Nháy đèn khi có cuộc gọi/SMS/thông báo.
- **Đèn Pin Màn Hình Màu**: Sử dụng màn hình làm đèn pin với màu sắc tùy chỉnh.
- **Banner Quảng Cáo**: Hiển thị quảng cáo banner ở dưới màn hình chính.

## Các Tính Năng Ưu Tiên P2 (Tăng cường)

- **Đèn Disco**: Chế độ nháy đèn với nhiều hiệu ứng khác nhau.
- **Điều Chỉnh Tốc Độ Nháy**: Tùy chỉnh tốc độ nháy cho tất cả các chế độ.
- [**Quảng Cáo Nâng Cao**](admob-integration.md): Tích hợp đầy đủ quảng cáo AdMob (banner, interstitial, rewarded).

## Hướng Dẫn Sử Dụng

1. Mỗi file tính năng có cấu trúc tương tự nhau:
   - Tổng quan
   - Thành phần UI
   - Yêu cầu chức năng
   - Kỹ thuật triển khai
   - Tiêu chí hoàn thành

2. Thứ tự triển khai nên theo mức độ ưu tiên: P0 → P1 → P2

3. Sau khi hoàn thành một tính năng, cập nhật trạng thái trong [Instruction.md](../../Instruction.md)

## Quy Trình Đánh Dấu Trạng Thái

- ❌ Chưa làm
- ⏳ Đang làm
- ✅ Hoàn thành

## Lưu Ý Quan Trọng

- Tất cả tính năng cần tối ưu sử dụng pin
- Camera API cần được xử lý cẩn thận để tránh xung đột giữa các tính năng
- Xử lý Service là yếu tố then chốt để các tính năng hoạt động liên tục
- Quảng cáo không được làm ảnh hưởng đến UX 