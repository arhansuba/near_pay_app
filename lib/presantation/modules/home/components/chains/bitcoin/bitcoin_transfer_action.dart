import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutterchain/flutterchain_lib/constants/core/blockchain_response.dart';
import 'package:near_pay_app/data/chains/bitcoin/bitcoin_transfer_request.dart';
import 'package:near_pay_app/presantation/modules/home/components/chains/near/near_action_text_field.dart';
import 'package:near_pay_app/presantation/modules/home/components/core/crypto_actions_card.dart';
import 'package:near_pay_app/presantation/modules/home/vms/chains/bitcoin/bitcoin_vm.dart';
import 'package:near_pay_app/presantation/modules/home/vms/chains/bitcoin/ui_state_bitcoin.dart';
import 'package:near_pay_app/presantation/theme/app_theme.dart';



class BitcoinTransferAction extends StatefulWidget {
  const BitcoinTransferAction({super.key});

  @override
  State<BitcoinTransferAction> createState() => _BitcoinTransferActionState();
}

class _BitcoinTransferActionState extends State<BitcoinTransferAction> {
  final TextEditingController recipientEditingController =
      TextEditingController();
  final TextEditingController transferDepositController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    recipientEditingController.text =
        "bc1qtstyjv5uyt5kcsy0ru4h8m6a67f0xa9jy8z3gx";
    transferDepositController.text = "0";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Modular.get<AppTheme>();
    final nearColors = theme.getTheme().extension<NearColors>()!;
    final bitcoinVM = Modular.get<BitcoinVM>();
    final currentState =
        bitcoinVM.bitcoinState.value as SuccessBitcoinBlockchainState;
    return CryptoActionCard(
      title: 'Transfer',
      height: 450,
      icon: Icons.send,
      color: nearColors.nearGreen,
      onTap: () {
        final recipient = recipientEditingController.text;
        final amount = transferDepositController.text;
        final walletID = bitcoinVM.userStore.walletIdStream.value;
        final derivationPath =
            bitcoinVM.bitcoinBlockchainStore.currentDerivationPath.value;
        bitcoinVM
            .sendNativeCoinTransferByWalletId(
                bitcoinTransferRequest: BitcoinTransferRequest(
                    currentDerivationPath: derivationPath,
                    toAddress: recipient,
                    transferAmount: amount,
                    walletId: walletID))
            .then(
          (value) {
            bitcoinVM.bitcoinState.add(
              currentState.copyWith(transferResult: value.data),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  value.status == BlockchainResponses.success
                      ? 'Success transfer'
                      : 'Failed transfer',
                ),
              ),
            );
            
            log("Result of transfer $value");
          },
        );
      },
      child: Form(
        child: Column(
          children: [
            const SizedBox(height: 20),
            NearActionTextField(
              labelText: 'Recipient',
              textEditingController: recipientEditingController,
            ),
            const SizedBox(height: 20),
            NearActionTextField(
              labelText: 'Amount',
              textEditingController: transferDepositController,
            ),
            const SizedBox(height: 20),
            if (currentState.transferResult != null) ...[
              if (currentState.transferResult?['data']['hash'] != null) ...[
                SelectableText(
                    '${currentState.transferResult?['data']['hash'].toString()}'),
              ] else if (currentState.transferResult?['data']['tx']['hash'] !=
                  null) ...[
                SelectableText(
                    '${currentState.transferResult?['data']['tx']['hash'].toString()}'),
              ]
            ]

            // SeeTransactionInfoBitcoinBlockchain(
            //   tx: currentState.transferResult?['tx']['hash'].toString(),
            // ),
          ],
        ),
      ),
    );
  }
}
