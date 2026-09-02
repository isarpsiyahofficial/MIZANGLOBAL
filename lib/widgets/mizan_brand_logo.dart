import 'package:flutter/material.dart';

const String mizanBrandLogoAsset = 'assets/brand/lefferion-prime-logo-v3.png';

class MizanBrandLogo extends StatelessWidget {
  const MizanBrandLogo({
    required this.size,
    this.semanticLabel = 'LEFFERION PRIME',
    super.key,
  });

  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final safeSize = size.clamp(24.0, 320.0).toDouble();
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final cachePixels = (safeSize * devicePixelRatio)
        .ceil()
        .clamp(64, 2048)
        .toInt();

    return SizedBox.square(
      dimension: safeSize,
      child: Image.asset(
        mizanBrandLogoAsset,
        width: safeSize,
        height: safeSize,
        fit: BoxFit.contain,
        alignment: Alignment.center,
        filterQuality: FilterQuality.high,
        isAntiAlias: true,
        gaplessPlayback: true,
        cacheWidth: cachePixels,
        cacheHeight: cachePixels,
        semanticLabel: semanticLabel,
      ),
    );
  }
}
