// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:near_pay_app/core/models/setting_item.dart';
import 'package:near_pay_app/localization.dart';
<<<<<<< HEAD

=======
import 'package:near_pay_app/core/models/setting_item.dart';
>>>>>>> dfa4b98bee355a1c88fba68c63fd3df725aef5d0


enum UnlockOption { YES, NO }

/// Represent authenticate to open setting
class UnlockSetting extends SettingSelectionItem {
  UnlockOption setting;

  UnlockSetting(this.setting);

  @override
  String? getDisplayName(BuildContext context) {
    switch (setting) {
      case UnlockOption.YES:
        return AppLocalization.of(context)?.yes;
      case UnlockOption.NO:
      default:
        return AppLocalization.of(context)?.no;
    }
  }

  // For saving to shared prefs
  int getIndex() {
    return setting.index;
  }
}