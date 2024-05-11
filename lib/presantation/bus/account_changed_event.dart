import 'package:event_taxi/event_taxi.dart';
import 'package:near_pay_app/core/models/db/account.dart';


<<<<<<< HEAD
=======
import 'package:near_pay_app/core/models/db/account.dart';
>>>>>>> dfa4b98bee355a1c88fba68c63fd3df725aef5d0

class AccountChangedEvent implements Event {
  final Account account;
  final bool delayPop;
  final bool noPop;

  AccountChangedEvent({required this.account, this.delayPop = false, this.noPop = false});
}