import 'package:event_taxi/event_taxi.dart';
import 'package:near_pay_app/data/network/model/response/account_history_response_item.dart';
<<<<<<< HEAD

=======
>>>>>>> dfa4b98bee355a1c88fba68c63fd3df725aef5d0


class HistoryHomeEvent implements Event {
  final List<AccountHistoryResponseItem> items;

  HistoryHomeEvent({required this.items});
}