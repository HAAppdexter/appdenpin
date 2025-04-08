# Điều Khiển Một Chạm

## Tổng Quan
Tính năng Điều Khiển Một Chạm là tính năng P0 (ưu tiên cao) cho phép người dùng bật/tắt đèn flash nhanh chóng từ bên ngoài ứng dụng chính, bao gồm widget, quick settings tile và shortcuts.

## Thành Phần

### 1. Widget
- Widget đơn giản với nút bật/tắt đèn pin
- Kích thước tùy chỉnh (1x1, 2x1)
- Hiển thị trạng thái đèn (bật/tắt)
- Hỗ trợ theme sáng/tối

### 2. Quick Settings Tile
- Tile trong thanh quick settings
- Hiển thị trạng thái đèn rõ ràng
- Hỗ trợ long-press để mở ứng dụng
- Icon rõ ràng, dễ nhận biết

### 3. App Shortcuts
- Static shortcuts khi long-press icon ứng dụng
- Shortcuts cho đèn pin, SOS và đèn màn hình
- Bật/tắt nhanh không cần mở ứng dụng
- Hỗ trợ từ Android 7.1 trở lên

## Yêu Cầu Chức Năng

### Widget
- Hoạt động khi màn hình khóa (nếu thiết bị hỗ trợ)
- Cập nhật trạng thái real-time
- Tiết kiệm pin (không polling liên tục)
- Hỗ trợ nhiều instance cùng lúc

### Quick Settings Tile
- Cập nhật trạng thái ngay khi thay đổi
- Thay đổi icon/màu sắc theo trạng thái đèn
- Xử lý các trường hợp service bị kill
- Hoạt động khi màn hình khóa

### App Shortcuts
- Định nghĩa các shortcut tĩnh trong AndroidManifest
- Xử lý intent từ shortcut
- Thực hiện hành động tương ứng không cần mở UI
- Hỗ trợ icon adaptive

## Kỹ Thuật Triển Khai

### Widget Implementation
- Sử dụng AppWidgetProvider
- Lập lịch cập nhật thông qua AppWidgetManager
- Broadcast changes đến tất cả instance
- Sử dụng PendingIntent để xử lý click action

### Quick Settings Implementation
- Extend TileService (API 24+)
- Xử lý các sự kiện onClick, onTileAdded, onStartListening
- Cập nhật trạng thái qua tile.setState()
- Fallback cho thiết bị dưới API 24

### Shortcuts Implementation
- Định nghĩa trong res/xml/shortcuts.xml
- Xử lý intent-filter tương ứng
- Thiết lập PendingIntent cho mỗi shortcut
- Ưu tiên launch time nhanh (cold start <1s)

## Tương Tác Với Service

- Các component điều khiển một chạm cần tương tác với cùng một service
- Sử dụng FlashlightService làm trung tâm điều khiển
- Broadcast trạng thái thay đổi đến tất cả component
- Bảo vệ quyền truy cập đến service (permission)

## Xử Lý Đồng Bộ Trạng Thái

- Sử dụng BroadcastReceiver để đồng bộ trạng thái
- Lưu trạng thái trong SharedPreferences
- Kiểm tra trạng thái thực tế của đèn, không chỉ dựa vào giá trị lưu
- Cơ chế phục hồi nếu phát hiện trạng thái không đồng bộ

## Tối Ưu Hóa

- Khởi động nhanh service khi được gọi từ widget/tile
- Xử lý các trường hợp permission bị thu hồi
- Fallback cho các thiết bị không hỗ trợ đầy đủ
- Cập nhật UI ngay lập tức khi trạng thái thay đổi

## Kiểm Thử

- Test trên nhiều phiên bản Android khác nhau
- Kiểm tra hoạt động khi màn hình khóa
- Test các trường hợp service bị kill
- Kiểm tra hiệu suất và thời gian phản hồi (<200ms)

## Tiêu Chí Hoàn Thành

- Tất cả phương thức điều khiển một chạm hoạt động đúng
- Widget cập nhật trạng thái chính xác
- Quick Settings Tile hiển thị đúng trạng thái
- Shortcuts khởi động nhanh các chức năng
- Đồng bộ trạng thái giữa tất cả điểm truy cập 