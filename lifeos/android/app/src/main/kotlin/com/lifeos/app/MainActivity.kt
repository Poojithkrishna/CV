package com.lifeos.app

import io.flutter.embedding.android.FlutterFragmentActivity

// local_auth's biometric prompt requires a FragmentActivity host —
// FlutterFragmentActivity is Flutter's variant of it. Plain
// FlutterActivity (the default template) doesn't support it.
class MainActivity : FlutterFragmentActivity()
