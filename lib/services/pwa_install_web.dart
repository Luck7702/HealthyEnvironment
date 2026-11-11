import 'dart:js_interop';

import 'package:flutter/foundation.dart';

/// How the app can be added to the home screen in this browser.
enum PwaInstallMode { none, prompt, iosHint }

extension type _LsPwa._(JSObject _) implements JSObject {
  external bool canInstall();
  external bool isStandalone();
  external bool isIos();
  external bool isDismissed();
  external void dismiss();
  external JSPromise<JSString> install();
  external set onChange(JSFunction? callback);
}

@JS('lsPwa')
external _LsPwa? get _lsPwa;

PwaInstallMode _currentMode() {
  final pwa = _lsPwa;
  if (pwa == null || pwa.isStandalone()) return PwaInstallMode.none;
  if (pwa.canInstall()) return PwaInstallMode.prompt;
  if (pwa.isIos()) return PwaInstallMode.iosHint;
  return PwaInstallMode.none;
}

ValueNotifier<PwaInstallMode>? _mode;

/// Whether (and how) the app can be installed right now. Updates when the
/// browser reports install availability (helper script in web/index.html).
/// Shared by the install banner and the header install button.
ValueListenable<PwaInstallMode> get pwaInstallMode {
  final existing = _mode;
  if (existing != null) return existing;
  final notifier = _mode = ValueNotifier(_currentMode());
  _lsPwa?.onChange = (() => notifier.value = _currentMode()).toJS;
  return notifier;
}

/// Shows the browser install dialog; true when the user accepted.
Future<bool> promptPwaInstall() async {
  final pwa = _lsPwa;
  if (pwa == null) return false;
  final outcome = await pwa.install().toDart;
  _mode?.value = _currentMode();
  return outcome.toDart == 'accepted';
}

/// The banner stays hidden after ✕; the header button is always available.
bool pwaBannerDismissed() => _lsPwa?.isDismissed() ?? true;

void dismissPwaBanner() => _lsPwa?.dismiss();
