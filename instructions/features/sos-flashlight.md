# Đèn SOS

## Tổng Quan
Tính năng đèn SOS là tính năng P0 (ưu tiên cao) của ứng dụng, cho phép nháy đèn flash theo mẫu tín hiệu cứu hộ SOS quốc tế (... --- ...) theo chuẩn Morse.

## Thành Phần UI
- Nút kích hoạt chế độ SOS rõ ràng, dễ tiếp cận
- Slider điều chỉnh tốc độ nháy
- Bộ đếm thời gian hiển thị thời gian đã kích hoạt
- Nút dừng SOS nổi bật, dễ thấy

## Mẫu Nháy SOS
- Tín hiệu SOS chuẩn Morse:
  - Ba nháy ngắn (S): 0.3s mỗi nháy, 0.1s giữa các nháy
  - Ba nháy dài (O): 0.9s mỗi nháy, 0.1s giữa các nháy
  - Khoảng 0.7s giữa các ký tự S và O
  - Lặp lại sau khoảng 3s

## Yêu Cầu Chức Năng
- Kích hoạt mẫu nháy SOS với một nút bấm
- Tùy chỉnh tốc độ nháy (nhanh/chậm) với hệ số từ 0.5x đến 2.0x
- Tiếp tục nháy kể cả khi ứng dụng chạy nền
- Tự động dừng sau thời gian chờ có thể cấu hình (mặc định: vô hạn)
- Hiển thị thông báo khi chế độ SOS đang hoạt động

## Xử Lý Background
- Sử dụng Foreground Service để duy trì đèn nháy khi ứng dụng ở nền
- Hiển thị notification cho người dùng biết SOS đang hoạt động
- Cung cấp action dừng SOS từ notification
- Sử dụng WakeLock để đảm bảo thiết bị không ngủ khi đang SOS

## Tối Ưu Hóa Timer
- Sử dụng Handler và Runnable để tạo mẫu nháy chính xác
- Đảm bảo timing chính xác ngay cả khi có lag hệ thống
- Sử dụng CountDownTimer nếu có thời gian tự động dừng
- Xử lý các trường hợp điện thoại khóa màn hình

## Xử Lý Lifecycle
- Lưu trạng thái đang SOS khi ứng dụng rời khỏi foreground
- Khôi phục UI đúng trạng thái khi quay lại ứng dụng
- Xử lý các trường hợp system kill service

## Xử Lý Đặc Biệt
- Tự động giảm độ sáng màn hình khi SOS để tiết kiệm pin
- Ưu tiên SOS so với các chức năng đèn flash khác
- Phát âm thanh SOS (tùy chọn) đồng bộ với đèn nháy
- Bật chế độ tiết kiệm pin nhưng vẫn duy trì SOS

## Kiểm Thử
- Kiểm tra độ chính xác của mẫu SOS (sử dụng recording camera)
- Test chạy nền với nhiều điều kiện khác nhau
- Kiểm tra hiệu suất pin khi chạy SOS trong thời gian dài
- Test hoạt động trên nhiều thiết bị khác nhau

## Tiêu Chí Hoàn Thành
- Mẫu SOS chính xác theo chuẩn Morse quốc tế
- Hoạt động liên tục không bị gián đoạn >2 giờ
- Tối ưu pin khi SOS chạy trong thời gian dài
- Điều khiển tốc độ hoạt động chính xác 