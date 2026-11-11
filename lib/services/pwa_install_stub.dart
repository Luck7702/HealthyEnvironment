/// Non-web platforms: installing as a PWA does not apply.
enum PwaInstallMode { none, prompt, iosHint }

PwaInstallMode pwaInstallMode() => PwaInstallMode.none;

Future<bool> promptPwaInstall() async => false;

void dismissPwaInstall() {}

void onPwaInstallChange(void Function() callback) {}
