import 'dart:js_interop';

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

PwaInstallMode pwaInstallMode() {
  final pwa = _lsPwa;
  if (pwa == null || pwa.isStandalone() || pwa.isDismissed()) {
    return PwaInstallMode.none;
  }
  if (pwa.canInstall()) return PwaInstallMode.prompt;
  if (pwa.isIos()) return PwaInstallMode.iosHint;
  return PwaInstallMode.none;
}

/// Shows the browser install dialog; true when the user accepted.
Future<bool> promptPwaInstall() async {
  final pwa = _lsPwa;
  if (pwa == null) return false;
  final outcome = await pwa.install().toDart;
  return outcome.toDart == 'accepted';
}

void dismissPwaInstall() => _lsPwa?.dismiss();

/// Calls [callback] when install availability changes.
void onPwaInstallChange(void Function() callback) {
  _lsPwa?.onChange = callback.toJS;
}
