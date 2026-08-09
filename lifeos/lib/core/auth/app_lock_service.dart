import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Thin wrapper around `local_auth` — biometrics (fingerprint/face) with
/// a fallback to whatever device credential (PIN/pattern/password) the
/// user already has set up, since restricting to biometrics only would
/// lock out anyone whose fingerprint sensor is having a bad day.
class AppLockService {
  AppLockService() : _auth = LocalAuthentication();

  final LocalAuthentication _auth;

  /// Whether this device can authenticate at all — no biometrics
  /// enrolled and no device lock (PIN/pattern) set means there's nothing
  /// to check against, so the Settings toggle should refuse to enable.
  Future<bool> isSupported() async {
    final bool canCheckBiometrics = await _auth.canCheckBiometrics;
    final bool isDeviceSupported = await _auth.isDeviceSupported();
    return canCheckBiometrics || isDeviceSupported;
  }

  /// Prompts the system biometric/device-credential UI. Returns `false`
  /// (rather than throwing) on any failure — a cancelled prompt, no
  /// enrolled credential, or a locked-out sensor should all just mean
  /// "not authenticated," not crash the caller.
  Future<bool> authenticate({required String reason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(biometricOnly: false, stickyAuth: true),
      );
    } on PlatformException {
      return false;
    }
  }
}
