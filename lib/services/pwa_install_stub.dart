import 'package:flutter/foundation.dart';

/// How the app can be added to the home screen in this browser.
enum PwaInstallMode { none, prompt, iosHint }

/// Non-web platforms: installing as a PWA does not apply.
final ValueListenable<PwaInstallMode> pwaInstallMode = ValueNotifier(
  PwaInstallMode.none,
);

Future<bool> promptPwaInstall() async => false;

bool pwaBannerDismissed() => true;

void dismissPwaBanner() {}
