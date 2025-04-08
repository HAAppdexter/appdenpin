# Tích Hợp Quảng Cáo AdMob

## Tổng Quan
Tích hợp quảng cáo AdMob để tạo doanh thu cho ứng dụng, bao gồm banner ads, interstitial ads và rewarded ads, được triển khai theo cách không làm ảnh hưởng đến trải nghiệm người dùng.

## Loại Quảng Cáo

### 1. Banner Ads
- Hiển thị ở phần dưới màn hình chính
- Kích thước chuẩn (320x50dp)
- Luôn hiển thị khi đang ở màn hình chính
- Không hiển thị trên các màn hình chức năng (SOS, đèn disco)

### 2. Interstitial Ads (Xen kẽ)
- Hiển thị sau khi sử dụng một chế độ đèn trong 30 giây
- Giới hạn tối đa 1 lần/5 phút
- Giới hạn 6 quảng cáo xen kẽ mỗi ngày
- Không hiển thị khi đang ở chế độ SOS

### 3. Rewarded Ads (Phần thưởng)
- Cho phép người dùng xem quảng cáo để mở khóa theme màu đặc biệt
- Theme đặc biệt có hiệu lực 24 giờ sau khi xem quảng cáo
- Nút xem quảng cáo trong phần cài đặt màu sắc

## Cài Đặt

### Thêm Thư Viện
```gradle
dependencies {
    implementation 'com.google.android.gms:play-services-ads:22.0.0'
}
```

### Manifest Configuration
```xml
<manifest>
    <application>
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy"/>
    </application>
</manifest>
```

### Test IDs
- Banner: `ca-app-pub-3940256099942544/6300978111`
- Interstitial: `ca-app-pub-3940256099942544/1033173712`
- Rewarded: `ca-app-pub-3940256099942544/5224354917`

## Triển Khai

### Khởi tạo AdMob
- Khởi tạo MobileAds trong Application.onCreate()
- Cấu hình RequestConfiguration với test device
- Personalized ads consent theo GDPR (EU)

### Banner Ads Implementation
- Đặt AdView trong layout chính
- Load quảng cáo trong onResume()
- Tạm dừng trong onPause()
- Hủy trong onDestroy()

### Interstitial Implementation
- Preload quảng cáo khi ứng dụng khởi động
- Theo dõi thời gian sử dụng đèn
- Kiểm tra các điều kiện (thời gian, giới hạn) trước khi hiển thị
- Reload sau khi hiển thị

### Rewarded Implementation
- Tải sẵn khi vào màn hình cài đặt
- Hiển thị khi người dùng nhấn nút xem quảng cáo
- Cập nhật trạng thái theme đặc biệt khi xem xong
- Lưu trạng thái vào SharedPreferences

## Quản Lý Hiển Thị

### Tracking & Limiting
- Sử dụng SharedPreferences để lưu:
  - Số lượng quảng cáo đã hiển thị mỗi ngày
  - Thời gian hiển thị quảng cáo cuối cùng
  - Thời gian mở khóa theme đặc biệt
- Reset số lượng khi qua ngày mới

### Xử Lý Không Có Mạng
- Hiển thị placeholder ở vị trí banner khi không có mạng
- Cache interstitial ads khi có mạng để dùng khi không có mạng
- Thông báo cho người dùng khi không thể tải rewarded ads

### Xử Lý Lỗi AdMob
- Implement AdListener để xử lý các error
- Retry loading với exponential backoff
- Logging lỗi cho analytics

## Yêu Cầu Hiệu Suất
- Banner ads không gây lag UI (<16ms frame drop)
- Preload interstitial để hiển thị nhanh (<1s)
- Không block main thread khi tải quảng cáo
- Quản lý memory usage (không gây OOM)

## Tuân Thủ Chính Sách

### Google Play Policy
- Không hiển thị quảng cáo quá gần các phần tương tác
- Tuân thủ placement guidelines của Google
- Không hiển thị quảng cáo trong thông báo
- Không hiển thị quảng cáo khi đang sử dụng chức năng SOS

### GDPR Compliance
- Hiển thị consent form cho người dùng EU
- Lưu trữ consent và tuân theo lựa chọn của người dùng
- Sử dụng User Messaging Platform (UMP) SDK

## Kiểm Thử
- Test với test IDs trên nhiều thiết bị
- Kiểm tra cách quảng cáo hiển thị ở các trạng thái ứng dụng khác nhau
- Verify giới hạn hiển thị quảng cáo hoạt động đúng
- Test với điều kiện mạng khác nhau

## Phân Tích
- Theo dõi impression và click metrics
- Tính toán eCPM và doanh thu
- Tối ưu vị trí quảng cáo dựa trên dữ liệu
- Implement A/B testing cho vị trí quảng cáo 