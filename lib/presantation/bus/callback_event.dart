import 'package:event_taxi/event_taxi.dart';
import 'package:near_pay_app/data/network/model/response/callback_response.dart';


<<<<<<< HEAD
=======
import 'package:near_pay_app/data/network/model/response/callback_response.dart';
>>>>>>> dfa4b98bee355a1c88fba68c63fd3df725aef5d0

class CallbackEvent implements Event {
  final CallbackResponse response;

  CallbackEvent({required this.response});
}