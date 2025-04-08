# Tích Hợp AdMob (Flutter)

## Tổng Quan
Tính năng tích hợp Google AdMob là chức năng P0 (ưu tiên cao) cho phép hiển thị quảng cáo trong ứng dụng đèn pin nhằm tạo doanh thu. Hướng dẫn này bao gồm cách tích hợp banner ads, interstitial ads và rewarded ads trong ứng dụng Flutter.

## Package Cần Thiết
```yaml
dependencies:
  google_mobile_ads: ^3.1.0  # SDK chính thức của Google cho AdMob
  provider: ^6.1.1  # State management
  shared_preferences: ^2.2.2  # Lưu trữ cài đặt
```

## Chuẩn Bị
1. Tạo tài khoản AdMob (https://apps.admob.com/)
2. Tạo ứng dụng mới trong AdMob dashboard
3. Lấy App ID và Ad Unit ID cho từng loại quảng cáo
4. Thêm App ID vào file cấu hình của ứng dụng

## Các Loại Quảng Cáo

### 1. Banner Ads
Hiển thị ở dưới cùng màn hình chính và một số màn hình khác.

### 2. Interstitial Ads (Quảng cáo toàn màn hình)
Hiển thị khi:
- Người dùng mở ứng dụng sau mỗi 3 lần
- Người dùng chuyển đổi giữa các tính năng đặc biệt
- Người dùng tắt đèn pin sau khi sử dụng liên tục > 1 phút

### 3. Rewarded Ads (Quảng cáo có thưởng)
Hiển thị khi người dùng muốn:
- Bỏ qua thời gian chờ giữa các tính năng đặc biệt
- Mở khóa theme hoặc hiệu ứng đặc biệt

## Cấu Trúc Files

### 1. services/ad_service.dart
```dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdService {
  // Test IDs khi phát triển
  static const String _testBannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';
  
  static const String _testInterstitialAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';
  
  static const String _testRewardedAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-3940256099942544/1712485313';
  
  // Production IDs (thay thế bằng ID thật khi publish)
  static const String _prodBannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'
      : 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  
  static const String _prodInterstitialAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'
      : 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  
  static const String _prodRewardedAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'
      : 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  
  // Sử dụng test ID trong môi trường dev
  bool _isDebug = !kReleaseMode;
  
  // Các biến lưu trữ quảng cáo
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  
  // Biến theo dõi trạng thái
  bool _isBannerReady = false;
  bool _isInterstitialReady = false;
  bool _isRewardedReady = false;
  int _appOpenCount = 0;
  DateTime? _lastAdShownTime;
  
  // Getter
  bool get isBannerReady => _isBannerReady;
  bool get isInterstitialReady => _isInterstitialReady;
  bool get isRewardedReady => _isRewardedReady;
  
  // Khởi tạo
  Future<void> initialize() async {
    // Khởi tạo MobileAds
    await MobileAds.instance.initialize();
    
    final prefs = await SharedPreferences.getInstance();
    _appOpenCount = prefs.getInt('app_open_count') ?? 0;
    _appOpenCount++;
    await prefs.setInt('app_open_count', _appOpenCount);
    
    String? lastAdTimeStr = prefs.getString('last_ad_shown_time');
    if (lastAdTimeStr != null) {
      _lastAdShownTime = DateTime.parse(lastAdTimeStr);
    }
    
    // Bắt đầu tải quảng cáo
    _loadBannerAd();
    _loadInterstitialAd();
    _loadRewardedAd();
  }
  
  // Lấy Ad Unit ID dựa vào môi trường
  String get _bannerAdUnitId => _isDebug ? _testBannerAdUnitId : _prodBannerAdUnitId;
  String get _interstitialAdUnitId => _isDebug ? _testInterstitialAdUnitId : _prodInterstitialAdUnitId;
  String get _rewardedAdUnitId => _isDebug ? _testRewardedAdUnitId : _prodRewardedAdUnitId;
  
  // Tải Banner Ad
  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _isBannerReady = true;
        },
        onAdFailedToLoad: (ad, error) {
          _isBannerReady = false;
          ad.dispose();
          _bannerAd = null;
          // Thử lại sau 1 phút
          Future.delayed(const Duration(minutes: 1), _loadBannerAd);
        },
      ),
    );
    
    _bannerAd?.load();
  }
  
  // Tải Interstitial Ad
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialReady = true;
          
          // Thiết lập callback khi ad đóng để tải ad mới
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialReady = false;
              _loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialReady = false;
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialReady = false;
          // Thử lại sau 1 phút
          Future.delayed(const Duration(minutes: 1), _loadInterstitialAd);
        },
      ),
    );
  }
  
  // Tải Rewarded Ad
  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedReady = true;
          
          // Thiết lập callback khi ad đóng để tải ad mới
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedAd = null;
              _isRewardedReady = false;
              _loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _rewardedAd = null;
              _isRewardedReady = false;
              _loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isRewardedReady = false;
          // Thử lại sau 1 phút
          Future.delayed(const Duration(minutes: 1), _loadRewardedAd);
        },
      ),
    );
  }
  
  // Hiển thị Banner Ad
  Widget getBannerWidget() {
    if (_bannerAd == null || !_isBannerReady) {
      return Container(height: 50);
    }
    
    return Container(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      alignment: Alignment.center,
      child: AdWidget(ad: _bannerAd!),
    );
  }
  
  // Hiển thị Interstitial Ad nếu đủ điều kiện
  Future<bool> showInterstitialAd() async {
    // Nếu không có ad hoặc ad không sẵn sàng
    if (_interstitialAd == null || !_isInterstitialReady) {
      return false;
    }
    
    // Kiểm tra thời gian giữa các lần hiển thị ad (tối thiểu 60 giây)
    if (_lastAdShownTime != null) {
      final difference = DateTime.now().difference(_lastAdShownTime!);
      if (difference.inSeconds < 60) {
        return false;
      }
    }
    
    // Lưu thời gian hiển thị ad
    _lastAdShownTime = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_ad_shown_time', _lastAdShownTime!.toIso8601String());
    
    // Hiển thị ad
    _interstitialAd!.show();
    return true;
  }
  
  // Kiểm tra xem có nên hiển thị interstitial ad khi mở app
  Future<bool> shouldShowAppOpenAd() async {
    // Hiển thị sau mỗi 3 lần mở app
    return _appOpenCount % 3 == 0 && await showInterstitialAd();
  }
  
  // Kiểm tra xem có nên hiển thị interstitial ad khi tắt đèn
  Future<bool> shouldShowAdAfterFlashlightUse(int usageDurationSeconds) async {
    // Chỉ hiển thị nếu đã sử dụng đèn > 60 giây
    return usageDurationSeconds > 60 && await showInterstitialAd();
  }
  
  // Hiển thị Rewarded Ad và thực hiện callback khi hoàn thành
  Future<bool> showRewardedAd(Function(RewardItem reward) onRewarded) async {
    // Nếu không có ad hoặc ad không sẵn sàng
    if (_rewardedAd == null || !_isRewardedReady) {
      return false;
    }
    
    // Đăng ký callback khi nhận reward
    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(onUserEarnedReward: onRewarded);
    return true;
  }
  
  // Giải phóng tài nguyên
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
```

### 2. providers/ad_provider.dart
```dart
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

class AdProvider with ChangeNotifier {
  final AdService _adService = AdService();
  
  // Getters
  bool get isBannerReady => _adService.isBannerReady;
  bool get isInterstitialReady => _adService.isInterstitialReady;
  bool get isRewardedReady => _adService.isRewardedReady;
  
  // Widget cho banner ad
  Widget get bannerAdWidget => _adService.getBannerWidget();
  
  // Khởi tạo
  Future<void> initialize() async {
    await _adService.initialize();
    
    // Kiểm tra xem có nên hiển thị ad khi mở app
    await _adService.shouldShowAppOpenAd();
    
    notifyListeners();
  }
  
  // Hiển thị interstitial ad khi chuyển đổi tính năng
  Future<bool> showInterstitialAdOnFeatureSwitch() async {
    final result = await _adService.showInterstitialAd();
    notifyListeners();
    return result;
  }
  
  // Hiển thị interstitial ad khi tắt đèn
  Future<bool> showAdAfterFlashlightUse(int usageDurationSeconds) async {
    final result = await _adService.shouldShowAdAfterFlashlightUse(usageDurationSeconds);
    notifyListeners();
    return result;
  }
  
  // Hiển thị rewarded ad và thực hiện callback
  Future<bool> showRewardedAd(Function(RewardItem reward) onRewarded) async {
    final result = await _adService.showRewardedAd(onRewarded);
    notifyListeners();
    return result;
  }
  
  // Giải phóng tài nguyên
  void dispose() {
    _adService.dispose();
    super.dispose();
  }
}
```

### 3. widgets/banner_ad_widget.dart
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ad_provider.dart';

class BannerAdWidget extends StatelessWidget {
  const BannerAdWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AdProvider>(
      builder: (context, adProvider, child) {
        if (!adProvider.isBannerReady) {
          return Container(height: 50); // Placeholder cho ad
        }
        
        return Container(
          width: double.infinity,
          height: 50,
          child: adProvider.bannerAdWidget,
        );
      },
    );
  }
}
```

## Cấu Hình Native

### Android: android/app/src/main/AndroidManifest.xml
```xml
<manifest ...>
    <application ...>
        <!-- AdMob App ID -->
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX"/>
        <!-- ... -->
    </application>
</manifest>
```

### iOS: ios/Runner/Info.plist
```xml
<dict>
    <!-- ... -->
    <key>GADApplicationIdentifier</key>
    <string>ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX</string>
    <key>SKAdNetworkItems</key>
    <array>
        <dict>
            <key>SKAdNetworkIdentifier</key>
            <string>cstr6suwn9.skadnetwork</string>
        </dict>
    </array>
    <!-- ... -->
</dict>
```

## Sử Dụng Trong UI

### 1. Màn Hình Chính
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ad_provider.dart';
import '../widgets/banner_ad_widget.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? _flashlightStartTime;
  
  @override
  void initState() {
    super.initState();
  }
  
  // Ghi lại thời gian bắt đầu sử dụng đèn
  void _recordFlashlightStartTime() {
    setState(() {
      _flashlightStartTime = DateTime.now();
    });
  }
  
  // Hiển thị quảng cáo khi tắt đèn nếu đã sử dụng đủ lâu
  Future<void> _handleFlashlightOff() async {
    if (_flashlightStartTime != null) {
      final usageDuration = DateTime.now().difference(_flashlightStartTime!);
      final adProvider = Provider.of<AdProvider>(context, listen: false);
      
      await adProvider.showAdAfterFlashlightUse(usageDuration.inSeconds);
      
      setState(() {
        _flashlightStartTime = null;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flashlight App'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              // UI chính của ứng dụng
            ),
          ),
          
          // Banner ad ở dưới cùng
          BannerAdWidget(),
        ],
      ),
    );
  }
}
```

### 2. Hiển Thị Rewarded Ad
```dart
Future<void> _showRewardedAdForFeature() async {
  final adProvider = Provider.of<AdProvider>(context, listen: false);
  
  if (!adProvider.isRewardedReady) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Quảng cáo chưa sẵn sàng. Vui lòng thử lại sau.')),
    );
    return;
  }
  
  await adProvider.showRewardedAd((RewardItem reward) {
    // Người dùng đã hoàn thành xem quảng cáo
    // Cấp quyền truy cập tính năng đặc biệt
    setState(() {
      _isSpecialFeatureUnlocked = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tính năng đã được mở khóa!')),
    );
  });
}
```

## Tối Ưu Hóa

### 1. Giảm Thiểu Phiền Nhiễu
- Không hiển thị interstitial ad quá thường xuyên (tối thiểu 60 giây giữa các lần)
- Không hiển thị ad khi người dùng đang trong trường hợp khẩn cấp (ví dụ: khi chức năng SOS đang hoạt động)

### 2. Compliance
- Đảm bảo tuân thủ chính sách của Google Play và App Store
- Cung cấp thông tin về quảng cáo và quyền riêng tư trong ứng dụng

### 3. Pre-loading
- Tải sẵn quảng cáo để người dùng không phải chờ đợi
- Tải lại quảng cáo ngay sau khi hiển thị

### 4. Tracking và Analytics
- Theo dõi hiệu suất của quảng cáo để tối ưu hóa doanh thu
- Đo lường tỷ lệ hiển thị và nhấp chuột

## Các Trường Hợp Đặc Biệt
- Xử lý khi không có kết nối internet
- Fallback khi không thể tải quảng cáo
- Xử lý khi người dùng bật ad blocker

## Kiểm Thử
- Test với cả test ID và production ID
- Kiểm tra hiệu suất khi có nhiều quảng cáo
- Đảm bảo quảng cáo không làm gián đoạn trải nghiệm người dùng

## Tuân Thủ Pháp Luật
- Cung cấp tùy chọn GDPR (Quy định Bảo vệ Dữ liệu Chung) cho người dùng châu Âu
- Thêm tùy chọn cho CCPA (Đạo luật Bảo vệ Quyền riêng tư Người tiêu dùng California)
- Implement User Messaging Platform (UMP) của Google để quản lý consent

## Mẫu Chính Sách Quyền Riêng Tư
```
CHÍNH SÁCH QUYỀN RIÊNG TƯ
Ứng dụng của chúng tôi sử dụng dịch vụ quảng cáo của Google AdMob.
AdMob có thể thu thập thông tin giới hạn bao gồm:
- ID quảng cáo của thiết bị
- Thông tin về ứng dụng đang sử dụng
- Vị trí địa lý tổng quát (nếu được cho phép)

Chúng tôi không thu thập hoặc chia sẻ thông tin cá nhân khác.
```

## Tiêu Chí Hoàn Thành
- Banner ad hiển thị đúng vị trí và kích thước
- Interstitial ad hiển thị đúng thời điểm và tần suất
- Rewarded ad hoạt động và người dùng nhận được phần thưởng
- Thông báo về quảng cáo và quyền riêng tư được hiển thị rõ ràng