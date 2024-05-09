// ignore_for_file: use_build_context_synchronously, unnecessary_null_comparison, library_private_types_in_public_api

import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:near_pay_app/app_icons.dart';
import 'package:near_pay_app/appstate_container.dart';
import 'package:near_pay_app/core/models/authentication_method.dart';
import 'package:near_pay_app/core/models/db/appdb.dart';
import 'package:near_pay_app/core/models/db/contact.dart';
import 'package:near_pay_app/core/models/vault.dart';
import 'package:near_pay_app/data/network/account_service.dart';
import 'package:near_pay_app/data/network/model/response/process_response.dart';

import 'package:near_pay_app/dimens.dart';
import 'package:near_pay_app/localization.dart';
import 'package:near_pay_app/presantation/bus/authenticated_event.dart';
import 'package:near_pay_app/presantation/ui/send/send_complete_sheet.dart';
import 'package:near_pay_app/presantation/ui/util/routes.dart';
import 'package:near_pay_app/presantation/ui/util/ui_util.dart';
import 'package:near_pay_app/presantation/ui/widgets/buttons.dart';
import 'package:near_pay_app/presantation/ui/widgets/dialog.dart';
import 'package:near_pay_app/presantation/ui/widgets/security.dart';
import 'package:near_pay_app/presantation/ui/widgets/sheet_util.dart';
import 'package:near_pay_app/presantation/utils/biometrics.dart';
import 'package:near_pay_app/presantation/utils/caseconverter.dart';
import 'package:near_pay_app/presantation/utils/numberutil.dart';
import 'package:near_pay_app/presantation/utils/sharedprefsutil.dart';

import 'package:near_pay_app/service_locator.dart';
import 'package:near_pay_app/styles.dart';



class SendConfirmSheet extends StatefulWidget {
  final String amountRaw;
  final String destination;
  final String contactName;
  final String localCurrency;
  final bool maxSend;
  final MantaWallet manta;
  final PaymentRequestMessage paymentRequest;
  final int natriconNonce;

  const SendConfirmSheet(
      {super.key, required this.amountRaw,
      required this.destination,
      required this.contactName,
      required this.localCurrency,
      this.manta,
      this.paymentRequest,
      required this.natriconNonce,
      this.maxSend = false, required near});

  @override
  _SendConfirmSheetState createState() => _SendConfirmSheetState();
}

class _SendConfirmSheetState extends State<SendConfirmSheet> {
  late String amount;
  late String destinationAltered;
  late bool animationOpen;
  late bool isMantaTransaction;

  late StreamSubscription<AuthenticatedEvent> _authSub;

  void _registerBus() {
    _authSub = EventTaxiImpl.singleton()
        .registerTo<AuthenticatedEvent>()
        .listen((event) {
      if (event.authType == AUTH_EVENT_TYPE.SEND) {
        _doSend();
      }
    });
  }

  void _destroyBus() {
    _authSub.cancel();
    }

  @override
  void initState() {
    super.initState();
    _registerBus();
    animationOpen = false;
    isMantaTransaction = widget.manta != null && widget.paymentRequest != null;
    // Derive amount from raw amount
    if (NumberUtil.getRawAsUsableString(widget.amountRaw).replaceAll(",", "") ==
        NumberUtil.getRawAsUsableDecimal(widget.amountRaw).toString()) {
      amount = NumberUtil.getRawAsUsableString(widget.amountRaw);
    } else {
      amount = "${NumberUtil.truncateDecimal(
                  NumberUtil.getRawAsUsableDecimal(widget.amountRaw),
                  digits: 6)
              .toStringAsFixed(6)}~";
    }
    // Ensure nano_ prefix on destination
    destinationAltered = widget.destination.replaceAll("xrb_", "nano_");
  }

  @override
  void dispose() {
    _destroyBus();
    super.dispose();
  }

  void _showSendingAnimation(BuildContext context) {
    animationOpen = true;
    Navigator.of(context).push(AnimationLoadingOverlay(
        AnimationType.SEND,
        StateContainer.of(context)!.curTheme.animationOverlayStrong,
        StateContainer.of(context)!.curTheme.animationOverlayMedium,
        onPoppedCallback: () => animationOpen = false));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        minimum:
            EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035),
        child: Column(
          children: <Widget>[
            // Sheet handle
            Container(
              margin: const EdgeInsets.only(top: 10),
              height: 5,
              width: MediaQuery.of(context).size.width * 0.15,
              decoration: BoxDecoration(
                color: StateContainer.of(context)!.curTheme.text10,
                borderRadius: BorderRadius.circular(100.0),
              ),
            ),
            //The main widget that holds the text fields, "SENDING" and "TO" texts
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // "SENDING" TEXT
                  Container(
                    margin: const EdgeInsets.only(bottom: 10.0),
                    child: Column(
                      children: <Widget>[
                        Text(
                          CaseChange.toUpperCase(
                              AppLocalization.of(context)!.sending, context),
                          style: AppStyles.textStyleHeader(context),
                        ),
                      ],
                    ),
                  ),
                  // Container for the amount text
                  Container(
                    margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.105,
                        right: MediaQuery.of(context).size.width * 0.105),
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color:
                          StateContainer.of(context)!.curTheme.backgroundDarkest,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    // Amount text
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: '',
                        children: [
                          TextSpan(
                            text: "Ӿ$amount",
                            style: TextStyle(
                              color:
                                  StateContainer.of(context)!.curTheme.primary,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'NunitoSans',
                            ),
                          ),
                          TextSpan(
                            text: widget.localCurrency != null
                                ? " (${widget.localCurrency})"
                                : "",
                            style: TextStyle(
                              color:
                                  StateContainer.of(context)!.curTheme.primary.withOpacity(0.75),
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'NunitoSans',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // "TO" text
                  Container(
                    margin: const EdgeInsets.only(top: 30.0, bottom: 10),
                    child: Column(
                      children: <Widget>[
                        Text(
                          CaseChange.toUpperCase(
                              AppLocalization.of(context)!.to, context),
                          style: AppStyles.textStyleHeader(context),
                        ),
                      ],
                    ),
                  ),
                  // Address text
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25.0, vertical: 15.0),
                      margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.105,
                          right: MediaQuery.of(context).size.width * 0.105),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: StateContainer.of(context)!
                            .curTheme
                            .backgroundDarkest,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: isMantaTransaction
                          ? Column(
                              children: <Widget>[
                                AutoSizeText(
                                  widget.paymentRequest.merchant.name,
                                  minFontSize: 12,
                                  stepGranularity: 0.1,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  style: AppStyles.headerPrimary(context),
                                ),
                                const SizedBox(
                                  height: 2,
                                ),
                                AutoSizeText(
                                  widget.paymentRequest.merchant.address,
                                  minFontSize: 10,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  stepGranularity: 0.1,
                                  style: AppStyles.addressText(context),
                                ),
                                Container(
                                  margin: const EdgeInsetsDirectional.only(
                                      top: 10, bottom: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          height: 1,
                                          color: StateContainer.of(context)!
                                              .curTheme
                                              .text30,
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsetsDirectional.only(
                                            start: 10, end: 20),
                                        child: Icon(
                                          AppIcons.appia,
                                          color: StateContainer.of(context)!
                                              .curTheme
                                              .text30,
                                          size: 20,
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 1,
                                          color: StateContainer.of(context)!
                                              .curTheme
                                              .text30,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                smallScreen(context)
                                    ? UIUtil.oneLineAddressText(
                                        context, destinationAltered)
                                    : UIUtil.threeLineAddressText(
                                        context, destinationAltered, contactName: '')
                              ],
                            )
                          : UIUtil.threeLineAddressText(
                              context, destinationAltered,
                              contactName: widget.contactName)),
                ],
              ),
            ),

            //A container for CONFIRM and CANCEL buttons
            Column(
              children: <Widget>[
                // A row for CONFIRM Button
                Row(
                  children: <Widget>[
                    // CONFIRM Button
                    AppButton.buildAppButton(
                        context,
                        AppButtonType.PRIMARY,
                        CaseChange.toUpperCase(
                            AppLocalization.of(context)!.confirm, context),
                        Dimens.BUTTON_TOP_DIMENS, onPressed: () async {
                      // Authenticate
                      AuthenticationMethod authMethod = await sl.get<SharedPrefsUtil>().getAuthMethod();
                      bool hasBiometrics = await sl.get<BiometricUtil>().hasBiometrics();
                      if (authMethod.method == AuthMethod.BIOMETRICS &&
                          hasBiometrics) {
                            try {
                              bool authenticated = await sl
                                                .get<BiometricUtil>()
                                                .authenticateWithBiometrics(
                                                    context,
                                                    AppLocalization.of(context)!
                                                        .sendAmountConfirm
                                                        .replaceAll("%1", amount));
                              if (authenticated) {
                                sl.get<HapticUtil>().fingerprintSucess();
                                EventTaxiImpl.singleton()
                                          .fire(AuthenticatedEvent(AUTH_EVENT_TYPE.SEND));   
                              }
                            } catch (e) {
                              await authenticateWithPin();
                            }
                          } else {
                            await authenticateWithPin();
                          }
                        }
                    )
                  ],
                ),
                // A row for CANCEL Button
                Row(
                  children: <Widget>[
                    // CANCEL Button
                    AppButton.buildAppButton(
                        context,
                        AppButtonType.PRIMARY_OUTLINE,
                        CaseChange.toUpperCase(
                            AppLocalization.of(context)!.cancel, context),
                        Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                      Navigator.of(context).pop();
                    }),
                  ],
                ),
              ],
            ),
          ],
        ));
  }

  Future<void> _doSend() async {
    try {
      _showSendingAnimation(context);
      ProcessResponse resp = await sl.get<AccountService>().requestSend(
        StateContainer.of(context)!.wallet.representative,
        StateContainer.of(context)!.wallet.frontier,
        widget.amountRaw,
        destinationAltered,
        StateContainer.of(context)!.wallet.address,
        NanoUtil.seedToPrivate(await StateContainer.of(context)!.getSeed(), StateContainer.of(context)!.selectedAccount.index),
        max: widget.maxSend
      );
      if (widget.manta != null) {
        widget.manta.sendPayment(
            transactionHash: resp.hash, cryptoCurrency: "NANO");        
      }
      StateContainer.of(context)!.wallet.frontier = resp.hash;
      StateContainer.of(context)!.wallet.accountBalance += BigInt.parse(widget.amountRaw);
      // Show complete
      Contact? contact = await sl.get<DBHelper>().getContactWithAddress(widget.destination);
      String? contactName = contact.name;
      Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));
      StateContainer.of(context)!.requestUpdate();
      setState(() {
        StateContainer.of(context)!.updateNatriconNonce(StateContainer.of(context)!.selectedAccount.address, widget.natriconNonce);
      });
          Sheets.showAppHeightNineSheet(
          context: context,
          closeOnTap: true,
          removeUntilHome: true,
          widget: SendCompleteSheet(
              amountRaw: widget.amountRaw,
              destination: destinationAltered,
              contactName: contactName,
              localAmount: widget.localCurrency,
              paymentRequest: widget.paymentRequest,
              natriconNonce: widget.natriconNonce), color: null, barrier: null, onDisposed: null);
    } catch (e) {
      // Send failed
      if (animationOpen) {
        Navigator.of(context).pop();
      }
      UIUtil.showSnackbar(AppLocalization.of(context)!.sendError, context);
      Navigator.of(context).pop();
    }
  }

  Future<void> authenticateWithPin() async {
    // PIN Authentication
    String expectedPin = await sl.get<Vault>().getPin();
    bool auth = await Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) {
        return PinScreen(
          PinOverlayType.ENTER_PIN,
          expectedPin: expectedPin,
          description: AppLocalization.of(context)
              !.sendAmountConfirmPin
              .replaceAll("%1", amount), pinScreenBackgroundColor: null,
        );
      }));
    if (auth) {
      await Future.delayed(const Duration(milliseconds: 200));
       EventTaxiImpl.singleton()
          .fire(AuthenticatedEvent(AUTH_EVENT_TYPE.SEND));    
    }
  }
}
