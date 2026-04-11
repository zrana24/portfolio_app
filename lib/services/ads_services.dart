import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdsService {

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return dotenv.env['ADMOB_BANNER_ANDROID']!;
    } else if (Platform.isIOS) {
      return dotenv.env['ADMOB_BANNER_IOS']!;
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get androidAppId =>
      dotenv.env['ADMOB_APP_ID_ANDROID']!;

  static String get iosAppId =>
      dotenv.env['ADMOB_APP_ID_IOS']!;
}