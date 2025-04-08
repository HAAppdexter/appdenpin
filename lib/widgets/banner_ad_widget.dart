import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ad_provider.dart';

class BannerAdWidget extends StatelessWidget {
  const BannerAdWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AdProvider>(
      builder: (context, adProvider, _) {
        return Container(
          alignment: Alignment.center,
          child: adProvider.getBannerWidget(),
        );
      },
    );
  }
} 