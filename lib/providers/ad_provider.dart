import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdProvider extends ChangeNotifier {
  bool _isBannerReady = false;
  bool _isInterstitialReady = false;
  // BannerAd? _bannerAd;
  // InterstitialAd? _interstitialAd;
  
  // Getter để kiểm tra trạng thái quảng cáo
  bool get isBannerReady => _isBannerReady;
  bool get isInterstitialReady => _isInterstitialReady;
  
  // Khởi tạo AdMob
  Future<void> initialize() async {
    // await MobileAds.instance.initialize();
    // _loadBannerAd();
    // _loadInterstitialAd();
    // notifyListeners();
    
    // Giả lập quảng cáo sẵn sàng để không gây lỗi
    _isBannerReady = true;
    _isInterstitialReady = true;
    notifyListeners();
  }
  
  // Widget để hiển thị banner ad
  Widget getBannerWidget() {
    // if (_bannerAd == null || !_isBannerReady) {
    //   return Container(height: 50);
    // }
    
    // return Container(
    //   width: _bannerAd!.size.width.toDouble(),
    //   height: _bannerAd!.size.height.toDouble(),
    //   alignment: Alignment.center,
    //   child: AdWidget(ad: _bannerAd!),
    // );
    
    // Hiển thị container giả
    return Container(
      height: 50,
      color: Colors.grey[200],
      alignment: Alignment.center,
      child: const Text('Banner Ad Placeholder', 
        style: TextStyle(color: Colors.grey)
      ),
    );
  }
  
  // Hiển thị interstitial ad
  Future<bool> showInterstitialAd() async {
    // if (_interstitialAd == null || !_isInterstitialReady) {
    //   return false;
    // }
    
    // _interstitialAd!.show();
    // return true;
    
    // Giả lập hiển thị quảng cáo
    debugPrint('Interstitial Ad would show here');
    return true;
  }
  
  // Hiển thị quảng cáo sau khi sử dụng đèn pin
  Future<bool> showAdAfterFlashlightUse(int usageDurationSeconds) async {
    // Chỉ hiển thị nếu đã sử dụng đèn > 60 giây
    return usageDurationSeconds > 60 && await showInterstitialAd();
  }
} 