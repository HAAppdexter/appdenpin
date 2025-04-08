# Đèn Pin Cơ Bản

## Tổng Quan
Tính năng đèn pin cơ bản là tính năng P0 (ưu tiên cao nhất) của ứng dụng, cho phép người dùng bật/tắt đèn flash của camera và điều chỉnh độ sáng.

## Thành Phần UI
- Màn hình chính với nút bật/tắt lớn ở giữa
- Slider điều chỉnh độ sáng (nếu thiết bị hỗ trợ)
- Toggle switch chuyển đổi nhanh
- Indicator hiển thị trạng thái đèn

## Yêu Cầu Chức Năng
- Bật/tắt đèn flash thông qua Camera2 API
- Lưu trạng thái hiện tại của đèn trong SharedPreferences
- Điều chỉnh độ sáng nếu thiết bị hỗ trợ
- Tối ưu sử dụng pin bằng cách đóng kết nối camera khi không cần thiết
- Khôi phục trạng thái đèn khi mở lại ứng dụng

## Xử Lý Camera API
- Sử dụng Camera2 API để truy cập đèn flash
- Kiểm tra thiết bị có hỗ trợ đèn flash không
- Xử lý các trường hợp ngoại lệ (thiết bị không có đèn flash, camera đang được sử dụng bởi ứng dụng khác)
- Triển khai cơ chế fallback cho thiết bị không hỗ trợ Camera2 API

## Lưu Trữ Cài Đặt
- Sử dụng SharedPreferences để lưu:
  - Trạng thái đèn (bật/tắt)
  - Độ sáng đèn
  - Tùy chọn người dùng (tự động bật khi mở app)

## Xử Lý Permissions
- REQUEST_CAMERA permission
- Hiển thị dialog giải thích lý do cần quyền truy cập camera
- Xử lý trường hợp người dùng từ chối cấp quyền

## Tối Ưu Hóa
- Sử dụng Service để duy trì đèn khi ứng dụng chạy nền
- Tự động tắt đèn sau một khoảng thời gian không hoạt động (tùy chọn)
- Phát hiện và xử lý trường hợp pin yếu

## Xử Lý Lifecycle
- OnPause: lưu trạng thái hiện tại
- OnResume: khôi phục trạng thái
- OnDestroy: giải phóng tài nguyên, đóng kết nối camera

## Kiểm Thử
- Test trên nhiều thiết bị khác nhau (min API 21+)
- Kiểm tra các trường hợp đặc biệt:
  - Cuộc gọi đến khi đèn đang bật
  - Điện thoại khóa màn hình khi đèn đang bật
  - Ứng dụng khác truy cập camera

## Tiêu Chí Hoàn Thành
- Đèn flash hoạt động chính xác trên đa dạng thiết bị
- Không bị crash khi xử lý các trường hợp ngoại lệ
- Độ trễ phản hồi khi bật/tắt đèn dưới 500ms
- Hiệu suất pin được tối ưu (tăng không quá 5%/giờ khi đèn bật) 