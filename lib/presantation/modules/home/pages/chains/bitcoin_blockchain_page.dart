import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutterchain/flutterchain_lib/constants/core/supported_blockchains.dart';
import 'package:near_pay_app/presantation/modules/home/components/chains/bitcoin/bitcoin_crypto_action_header.dart';
import 'package:near_pay_app/presantation/modules/home/components/chains/bitcoin/bitcoin_transfer_action.dart';
import 'package:near_pay_app/presantation/modules/home/vms/chains/bitcoin/bitcoin_vm.dart';
import 'package:near_pay_app/presantation/modules/home/vms/chains/bitcoin/ui_state_bitcoin.dart';
import 'package:near_pay_app/presantation/services/chains/bitcoin_blockchain_service.dart';
<<<<<<< HEAD

=======
>>>>>>> dfa4b98bee355a1c88fba68c63fd3df725aef5d0


class BitcoinBlockchainPage extends StatefulWidget {
  const BitcoinBlockchainPage({super.key});

  @override
  State<BitcoinBlockchainPage> createState() => _BitcoinBlockchainPageState();
}

class _BitcoinBlockchainPageState extends State<BitcoinBlockchainPage>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    final nearVM = Modular.get<BitcoinVM>();
    String? accountId = (nearVM.cryptoLibrary.blockchainService
                    .blockchainServices[BlockChains.bitcoin]
                as BitcoinBlockChainService)
            .getAccountIdFromWalletRedirectOnTheWeb() ??
        '';

    if (accountId.isNotEmpty) {
      log("accountId was sucsessfuly added $accountId from The Flutter WEB Enviroment");
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bitcoinVM = Modular.get<BitcoinVM>();

    return StreamBuilder<BitcoinState>(
      stream: bitcoinVM.bitcoinState,
      builder: (context, snapshot) {
        final state = snapshot.data;

        if (state is ErrorBitcoinBlockchainState) {
          return Text('Error, error message ${state.message}');
        }
        if (state is SuccessBitcoinBlockchainState) {
          final isPortrait =
              MediaQuery.of(context).orientation == Orientation.portrait;
          log("isPortrait $isPortrait");
          return isPortrait
              ? const SingleChildScrollView(
                  child: Column(
                    // key: UniqueKey(),
                    children: [
                      BitcoinCryptoActionHeader(),
                      BitcoinTransferAction(),
                    ],
                  ),
                )
              : SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 1,
                  child: GridView.count(
                    crossAxisCount: isPortrait ? 1 : 2,
                    children: const [
                      BitcoinCryptoActionHeader(),
                      BitcoinTransferAction(),
                    ],
                  ),
                );
        }
        return const Text("Undefined  state");
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
