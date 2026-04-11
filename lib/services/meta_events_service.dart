import 'dart:io';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

class MetaEventsService {
  MetaEventsService._();
  static final MetaEventsService instance = MetaEventsService._();

  final FacebookAppEvents _fbAppEvents = FacebookAppEvents();

  Future<void> initialize() async {
    if (Platform.isIOS) {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    }

    // Uygulama açılışını logla
    await logActivateApp();
    await _fbAppEvents.logEvent(name: "app_open");
  }

  Future<void> logActivateApp() async {
    await _fbAppEvents.logEvent(
      name: 'fb_mobile_activate_app',
    );
  }

  Future<void> logCompleteRegistration({
    required String method,
  }) async {
    await _fbAppEvents.logEvent(
      name: 'fb_mobile_complete_registration',
      parameters: {
        'fb_registration_method': method,
      },
    );
  }

  Future<void> logPurchase({
    required double amount,
    required String currency,
  }) async {
    await _fbAppEvents.logPurchase(
      amount: amount,
      currency: currency,
    );
  }

  Future<void> logCustomEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    await _fbAppEvents.logEvent(
      name: name,
      parameters: parameters,
    );
  }
}
