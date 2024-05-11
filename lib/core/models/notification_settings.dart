// ignore_for_file: annotate_overrides, constant_identifier_names

import 'package:flutter/material.dart';
import 'package:near_pay_app/core/models/setting_item.dart';
import 'package:near_pay_app/localization.dart';
<<<<<<< HEAD
=======
import 'package:near_pay_app/core/models/setting_item.dart';
>>>>>>> dfa4b98bee355a1c88fba68c63fd3df725aef5d0


enum NotificationOptions { ON, OFF }

/// Represent notification on/off setting
class NotificationSetting extends SettingSelectionItem {
  NotificationOptions setting;

  NotificationSetting(this.setting);

  String? getDisplayName(BuildContext context) {
    switch (setting) {
      case NotificationOptions.ON:
        return AppLocalization.of(context)?.onStr;
      case NotificationOptions.OFF:
      default:
        return AppLocalization.of(context)?.off;
    }
  }

  // For saving to shared prefs
  int getIndex() {
    return setting.index;
  }
}