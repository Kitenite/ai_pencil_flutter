import 'package:ai_pencil/utils/constants.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class MixPanelAnalyticsManager {
  static final MixPanelAnalyticsManager _instance =
      MixPanelAnalyticsManager._internal();
  late Mixpanel _mixpanel;

  factory MixPanelAnalyticsManager() {
    return _instance;
  }

  MixPanelAnalyticsManager._internal() {
    initMixpanel();
  }

  Future<void> initMixpanel() async {
    _mixpanel = await Mixpanel.init(
      Constants.MIX_PANEL_TOKEN,
      trackAutomaticEvents: true,
    );
  }

  void trackEvent(String eventName, Map<String, dynamic> properties) {
    _mixpanel.track(eventName, properties: properties);
  }
}
