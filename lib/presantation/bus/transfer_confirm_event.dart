import 'package:event_taxi/event_taxi.dart';
import 'package:near_pay_app/data/network/model/response/account_balance_item.dart';


<<<<<<< HEAD
=======
import 'package:near_pay_app/data/network/model/response/account_balance_item.dart';
>>>>>>> dfa4b98bee355a1c88fba68c63fd3df725aef5d0

class TransferConfirmEvent implements Event {
  final Map<String, AccountBalanceItem> balMap;

  TransferConfirmEvent({required this.balMap});
}