import 'package:event_taxi/event_taxi.dart';
import 'package:near_pay_app/core/models/db/account.dart';
<<<<<<< HEAD

=======
>>>>>>> dfa4b98bee355a1c88fba68c63fd3df725aef5d0


class AccountModifiedEvent implements Event {
  final Account account;
  final bool deleted;

  AccountModifiedEvent({required this.account, this.deleted = false});
}