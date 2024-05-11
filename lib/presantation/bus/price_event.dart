import 'package:event_taxi/event_taxi.dart';
import 'package:near_pay_app/data/network/model/response/price_response.dart';
<<<<<<< HEAD

=======
>>>>>>> dfa4b98bee355a1c88fba68c63fd3df725aef5d0


class PriceEvent implements Event {
  final PriceResponse response;

  PriceEvent({required this.response});
}