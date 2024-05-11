import 'package:json_annotation/json_annotation.dart';
import 'package:near_pay_app/data/network/model/response/block_item.dart';
<<<<<<< HEAD

=======
>>>>>>> dfa4b98bee355a1c88fba68c63fd3df725aef5d0



part 'callback_response.g.dart';

/// For running in an isolate, needs to be top-level function
CallbackResponse callbackResponseFromJson(Map<dynamic, dynamic> json) {
  return CallbackResponse.fromJson(json);
} 

/// Represents a callback from the node that belongs to logged in account
@JsonSerializable()
class CallbackResponse {
  @JsonKey(name:"account")
  String account;

  @JsonKey(name:"hash")
  String hash;

  @JsonKey(name:"block")
  BlockItem block;

  @JsonKey(name:"amount")
  String amount;

  @JsonKey(name:"is_send")
  String isSend;

  CallbackResponse({required this.account, required this.hash, required this.block, required this.amount, required this.isSend});

  factory CallbackResponse.fromJson(Map<String, dynamic> json) => _$CallbackResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CallbackResponseToJson(this);
}