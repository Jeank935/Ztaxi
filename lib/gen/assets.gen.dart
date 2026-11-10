// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class Assets {
  const Assets._();

  static const String aber = 'assets/Aber.svg';
  static const String logo = 'assets/Logo.svg';
  static const AssetGenImage maskGroup2 =
      AssetGenImage('assets/Mask Group 2.png');
  static const AssetGenImage rectangle9 =
      AssetGenImage('assets/Rectangle 9.png');
  static const AssetGenImage customer = AssetGenImage('assets/customer.png');
  static const AssetGenImage dest = AssetGenImage('assets/dest.gif');
  static const AssetGenImage destMarker =
      AssetGenImage('assets/dest_marker.png');
  static const AssetGenImage driver = AssetGenImage('assets/driver.png');
  static const String mapStyle = 'assets/map_style.txt';
  static const AssetGenImage mask = AssetGenImage('assets/mask.png');
  static const AssetGenImage person = AssetGenImage('assets/person.png');
  static const AssetGenImage source = AssetGenImage('assets/source.gif');
  static const AssetGenImage visa = AssetGenImage('assets/visa.png');

  /// List of all assets
  static List<dynamic> get values => [
        aber,
        logo,
        maskGroup2,
        rectangle9,
        customer,
        dest,
        destMarker,
        driver,
        mapStyle,
        mask,
        person,
        source,
        visa
      ];
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
