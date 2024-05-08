// ignore_for_file: constant_identifier_names, use_build_context_synchronously, deprecated_member_use

import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:event_taxi/event_taxi.dart';
import 'package:logging/logging.dart';
import 'package:near_pay_app/appstate_container.dart';
import 'package:near_pay_app/data/network/account_service.dart';
import 'package:near_pay_app/data/network/model/response/account_balance_item.dart';
import 'package:near_pay_app/data/network/model/response/accounts_balances_response.dart';

import 'package:near_pay_app/dimens.dart';
import 'package:near_pay_app/localization.dart';
import 'package:near_pay_app/presantation/bus/transfer_confirm_event.dart';
import 'package:near_pay_app/presantation/ui/transfer/transfer_manual_entry_sheet.dart';
import 'package:near_pay_app/presantation/ui/util/ui_util.dart';
import 'package:near_pay_app/presantation/ui/widgets/buttons.dart';
import 'package:near_pay_app/presantation/ui/widgets/dialog.dart';
import 'package:near_pay_app/presantation/ui/widgets/sheet_util.dart';
import 'package:near_pay_app/presantation/ui/widgets/sheets.dart';
import 'package:near_pay_app/presantation/utils/caseconverter.dart';
import 'package:near_pay_app/presantation/utils/walletutil.dart';

import 'package:near_pay_app/service_locator.dart';
import 'package:near_pay_app/styles.dart';




class AppTransferOverviewSheet {
  static const int NUM_SWEEP = 15; // Number of accounts to sweep from a seed


  // accounts to private keys/account balances
  Map<String, AccountBalanceItem> privKeyBalanceMap = {};

  bool _animationOpen = false;

  Future<bool> _onWillPop() async {
    return true;
  }

  AppTransferOverviewSheet();

  mainBottomSheet(BuildContext context) {
    void manualEntryCallback(String seed) {
      Navigator.of(context).pop();
      startTransfer(context, seed, manualEntry: true);
    }

    AppSheets.showAppHeightNineSheet(
        context: context,
        onDisposed: _onWillPop,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return WillPopScope(
              onWillPop: _onWillPop,
              child: SafeArea(
                minimum: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.035,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      // A container for the header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Emtpy SizedBox
                          const SizedBox(
                            height: 60,
                            width: 60,
                          ),
                          Column(
                            children: <Widget>[
                              // Sheet handle
                              Container(
                                margin: const EdgeInsets.only(top: 10),
                                height: 5,
                                width: MediaQuery.of(context).size.width * 0.15,
                                decoration: BoxDecoration(
                                  color: StateContainer.of(context)!
                                      .curTheme
                                      .text10,
                                  borderRadius: BorderRadius.circular(100.0),
                                ),
                              ),
                              // The header
                              Container(
                                margin: const EdgeInsets.only(top: 15.0),
                                constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width -
                                            140),
                                child: AutoSizeText(
                                  CaseChange.toUpperCase(
                                      AppLocalization.of(context)!
                                          .transferHeader,
                                      context),
                                  style: AppStyles.textStyleHeader(context),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  stepGranularity: 0.1,
                                ),
                              ),
                            ],
                          ),
                          // Emtpy SizedBox
                          const SizedBox(
                            height: 60,
                            width: 60,
                          ),
                        ],
                      ),

                      // A container for the illustration and paragraphs
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height * 0.2,
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.6),
                              child: Stack(
                                children: <Widget>[
                                  Center(
                                    child: SvgPicture.asset(
                                        'assets/transferfunds_illustration_start_paperwalletonly.svg',
                                        color: StateContainer.of(context)!
                                            .curTheme
                                            .text45,
                                        width:
                                            MediaQuery.of(context).size.width),
                                  ),
                                  Center(
                                    child: SvgPicture.asset(
                                        'assets/transferfunds_illustration_start_natriumwalletonly.svg',
                                        color: StateContainer.of(context)!
                                            .curTheme
                                            .primary,
                                        width:
                                            MediaQuery.of(context).size.width),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              alignment: const AlignmentDirectional(-1, 0),
                              margin: EdgeInsets.symmetric(
                                  horizontal: smallScreen(context) ? 35 : 50,
                                  vertical: 20),
                              child: AutoSizeText(
                                AppLocalization.of(context)!
                                    .transferIntro
                                    .replaceAll("%1",
                                        AppLocalization.of(context)!.scanQrCode),
                                style: AppStyles.textStyleParagraph(context),
                                textAlign: TextAlign.start,
                                maxLines: 6,
                                stepGranularity: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Row(
                        children: <Widget>[
                          AppButton.buildAppButton(
                            context,
                            AppButtonType.PRIMARY,
                            AppLocalization.of(context)!.scanQrCode,
                            Dimens.BUTTON_TOP_DIMENS,
                            onPressed: () {
                              UIUtil.cancelLockEvent();
                              BarcodeScanner.scan(StateContainer.of(context)!
                                      .curTheme
                                      .qrScanTheme)
                                  .then((value) {
                                if (!NanoSeeds.isValidSeed(value)) {
                                  UIUtil.showSnackbar(
                                      AppLocalization.of(context)!.qrInvalidSeed,
                                      context);
                                  return;
                                }
                                startTransfer(context, value);
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          AppButton.buildAppButton(
                            context,
                            AppButtonType.PRIMARY_OUTLINE,
                            AppLocalization.of(context)!.manualEntry,
                            Dimens.BUTTON_BOTTOM_DIMENS,
                            onPressed: () {
                              Sheets.showAppHeightNineSheet(
                                  context: context,
                                  widget: TransferManualEntrySheet(
                                    validSeedCallback: manualEntryCallback,
                                  ), barrier: null, onDisposed: null, color: null);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
        }, color: null, barrier: null);
  }

  Future<void> startTransfer(BuildContext context, String seed,
      {bool manualEntry = false}) async {
    // Show loading overlay
    _animationOpen = true;
    AnimationType animation = manualEntry
        ? AnimationType.TRANSFER_SEARCHING_MANUAL
        : AnimationType.TRANSFER_SEARCHING_QR;
    Navigator.of(context).push(AnimationLoadingOverlay(
        animation,
        StateContainer.of(context)!.curTheme.animationOverlayStrong,
        StateContainer.of(context)!.curTheme.animationOverlayMedium,
        onPoppedCallback: () {
      _animationOpen = false;
    }));
    // Get accounts from seed
    List<String> accounts = await getAccountsFromSeed(context, seed);
    try {
      AccountsBalancesResponse resp =
          await sl.get<AccountService>().requestAccountsBalances(accounts);
      if (_animationOpen) {
        Navigator.of(context).pop();
      }
      List<String> accountsToRemove = List();
      resp.balances.forEach((String account, AccountBalanceItem balItem) {
        BigInt balance = BigInt.parse(balItem.balance);
        BigInt pending = BigInt.parse(balItem.pending);
        if (balance + pending == BigInt.zero) {
          accountsToRemove.add(account);
        } else {
          // Update balance of this item
          privKeyBalanceMap[account]!.balance = balItem.balance;
          privKeyBalanceMap[account]!.pending = balItem.pending;
        }
      });
      for (var account in accountsToRemove) {
        privKeyBalanceMap.remove(account);
      }
      if (privKeyBalanceMap.isEmpty) {
        UIUtil.showSnackbar(
            AppLocalization.of(context)!.transferNoFunds, context);
        return;
      }
      // Go to confirmation screen
      EventTaxiImpl.singleton()
          .fire(TransferConfirmEvent(balMap: privKeyBalanceMap));
      Navigator.of(context).pop();
    } catch (e) {
      sl.get<Logger>().e("error", error: e);
      if (_animationOpen) {
        Navigator.of(context).pop();
      }
      UIUtil.showSnackbar(AppLocalization.of(context)!.sendError, context);
    }
  }

  /// Get NUM_SWEEP accounts from seed to request balances for
  Future<List<String>> getAccountsFromSeed(
      BuildContext context, String seed) async {
    List<String> accountsToRequest = List();
    String privKey;
    String address;
    // Get NUM_SWEEP private keys + accounts from seed
    for (int i = 0; i < NUM_SWEEP; i++) {
      privKey = NearUtil.seedToPrivate(seed, i);
      address = NearUtil.seedToAddress(seed, i);
      // Don't add this if it is the currently logged in account
      if (address != StateContainer.of(context)!.wallet.address) {
        privKeyBalanceMap.putIfAbsent(
            address, () => AccountBalanceItem(privKey: privKey, balance: '', pending: '', frontier: '', pendingResponse: null));
        accountsToRequest.add(address);
      }
    }
    // Also treat this seed as a private key
    address = NearAccounts.createAccount(
        NearAccountType.NANO, NearKeys.createPublicKey(seed));
    if (address != StateContainer.of(context)!.wallet.address) {
      privKeyBalanceMap.putIfAbsent(
          address, () => AccountBalanceItem(privKey: seed, balance: '', pending: '', frontier: '', pendingResponse: null));
      accountsToRequest.add(address);
    }
    return accountsToRequest;
  }
}
