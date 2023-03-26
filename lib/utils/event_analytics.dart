import 'package:ai_pencil/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class MixPanelAnalyticsManager {
  static final MixPanelAnalyticsManager _instance =
      MixPanelAnalyticsManager._internal();
  late Mixpanel _mixpanel;

  factory MixPanelAnalyticsManager() {
    return _instance;
  }

  MixPanelAnalyticsManager._internal() {
    if (kDebugMode) {
      return;
    }
    initMixpanel();
  }

  Future<void> initMixpanel() async {
    _mixpanel = await Mixpanel.init(
      Constants.MIX_PANEL_TOKEN,
      trackAutomaticEvents: true,
    );
  }

  void trackEvent(String eventName, Map<String, dynamic> properties) {
    if (kDebugMode) {
      Logger("MixPanelAnalyticsManager::trackEvent")
          .info('MixPanel: $eventName, $properties');
      return;
    }
    _mixpanel.track(eventName, properties: properties);
  }
}
