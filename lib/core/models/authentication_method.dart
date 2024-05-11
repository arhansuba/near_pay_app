// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:near_pay_app/core/models/setting_item.dart';
import 'package:near_pay_app/localization.dart';
<<<<<<< HEAD

=======
import 'package:near_pay_app/core/models/setting_item.dart';
>>>>>>> dfa4b98bee355a1c88fba68c63fd3df725aef5d0


enum AuthMethod { PIN, BIOMETRICS }

/// Represent the available authentication methods our app supports
class AuthenticationMethod extends SettingSelectionItem {
  AuthMethod method;

  AuthenticationMethod(this.method);

  @override
  String? getDisplayName(BuildContext context) {
    switch (method) {
      case AuthMethod.BIOMETRICS:
        return AppLocalization.of(context)?.biometricsMethod;
      case AuthMethod.PIN:
        return AppLocalization.of(context)?.pinMethod;
      default:
        return AppLocalization.of(context)?.pinMethod;
    }
  }

  // For saving to shared prefs
  int getIndex() {
    return method.index;
  }
}