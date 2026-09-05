import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/widgets/mizan_brand_logo.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'brand master is square, transparent and above Full HD resolution',
    () async {
      final bytes = await File(mizanBrandLogoAsset).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final pixels = await frame.image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      addTearDown(codec.dispose);
      addTearDown(frame.image.dispose);

      expect(frame.image.width, 2048);
      expect(frame.image.height, 2048);
      expect(pixels, isNotNull);
      expect(pixels!.getUint8(3), 0);
      expect(bytes.length, greaterThan(100000));
    },
  );

  test(
    'Android launcher uses a dedicated transparent adaptive foreground',
    () async {
      const foregroundPath =
          'assets/brand/lefferion-prime-logo-v3-foreground.png';
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(
        pubspec,
        contains('image_path: assets/brand/lefferion-prime-logo-v3.png'),
      );
      expect(pubspec, contains('adaptive_icon_foreground: $foregroundPath'));
      expect(pubspec, contains('adaptive_icon_background: "#FFFFFF"'));

      final bytes = await File(foregroundPath).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final pixels = await frame.image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      addTearDown(codec.dispose);
      addTearDown(frame.image.dispose);

      expect(frame.image.width, 2048);
      expect(frame.image.height, 2048);
      expect(pixels, isNotNull);
      expect(pixels!.getUint8(3), 0);
    },
  );

  testWidgets('shared logo keeps exact square bounds on compact and wide UI', (
    tester,
  ) async {
    for (final size in <double>[42, 58, 88, 112, 152]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: MizanBrandLogo(
              key: const ValueKey('brand-logo'),
              size: size,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byKey(const ValueKey('brand-logo'))),
        Size.square(size),
      );
      final image = tester.widget<Image>(find.byType(Image));
      expect(image.fit, BoxFit.contain);
      expect(image.filterQuality, FilterQuality.high);
      expect(image.image, isA<ResizeImage>());
      final resized = image.image as ResizeImage;
      expect(resized.width, greaterThanOrEqualTo(size.ceil()));
      expect(resized.height, resized.width);
    }
  });

  test('every in-app logo surface uses the shared responsive widget', () {
    final directAssetUsers = <String>[];
    for (final directory in <Directory>[
      Directory('lib/screens'),
      Directory('lib/widgets'),
    ]) {
      for (final entity in directory.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        if (entity.path.endsWith('mizan_brand_logo.dart')) continue;
        if (entity.readAsStringSync().contains(mizanBrandLogoAsset)) {
          directAssetUsers.add(entity.path);
        }
      }
    }
    final main = File('lib/main.dart').readAsStringSync();
    expect(main, isNot(contains(mizanBrandLogoAsset)));
    expect(directAssetUsers, isEmpty);
    expect(main, contains('MizanBrandLogo('));
    expect(
      File('lib/widgets/mizan_cards.dart').readAsStringSync(),
      contains('MizanBrandLogo('),
    );
    expect(
      File('lib/widgets/responsive_scaffold.dart').readAsStringSync(),
      contains('MizanBrandLogo('),
    );
  });
}
