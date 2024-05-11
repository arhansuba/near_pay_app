

import 'package:collection/collection.dart';
import 'package:flutterchain/flutterchain_lib.dart';
import 'package:flutterchain/flutterchain_lib/constants/core/supported_blockchains.dart';

import 'package:flutterchain/flutterchain_lib/models/core/blockchain_response.dart';
import 'package:flutterchain/flutterchain_lib/models/core/wallet.dart';
import 'package:near_pay_app/data/chains/bitcoin/bitcoin_transfer_request.dart';
import 'package:near_pay_app/presantation/modules/home/services/helper_service.dart';
import 'package:near_pay_app/presantation/modules/home/stores/chains/bitcoin_blockchain_store.dart';
import 'package:near_pay_app/presantation/modules/home/stores/core/user_store.dart';
import 'package:near_pay_app/presantation/modules/home/vms/chains/bitcoin/ui_state_bitcoin.dart';
<<<<<<< HEAD

=======
>>>>>>> dfa4b98bee355a1c88fba68c63fd3df725aef5d0

import 'package:rxdart/rxdart.dart';

class BitcoinVM {
  final FlutterChainLibrary cryptoLibrary;
  final BitcoinBlockchainStore bitcoinBlockchainStore;
  final NearHelperService bitcoinHelperService;
  final UserStore userStore;
  final BehaviorSubject<BitcoinState> bitcoinState =
      BehaviorSubject<BitcoinState>()..add(SuccessBitcoinBlockchainState());
  BitcoinVM(
    this.cryptoLibrary,
    this.bitcoinBlockchainStore,
    this.bitcoinHelperService,
    this.userStore,
  );

  Future<BlockChainData> addBlockChainDataByDerivationPath({
    required DerivationPath derivationPath,
    required String walletID,
  }) async {
    return cryptoLibrary.addBlockChainDataByDerivationPath(
      derivationPath: derivationPath,
      blockchainType: BlockChains.bitcoin,
      walletID: walletID,
    );
  }

  Future<dynamic> getBalanceByDerivationPath({
    required BitcoinTransferRequest bitcoinTransferRequest,
  }) async =>
      cryptoLibrary.getBalanceOfAddressOnSpecificBlockchain(
          transferRequest: bitcoinTransferRequest, walletId: '', blockchainType: '', currentDerivationPath: null);

  Future<String> getWalletPublicKeyAddressByWalletId(
          String walletName, DerivationPath currentDerivationPath) async =>
      cryptoLibrary.walletsStream.value
          .firstWhere((element) => element.name == walletName)
          .blockchainsData?[BlockChains.bitcoin]!
          .firstWhereOrNull(
              (element) => element.derivationPath == currentDerivationPath)
          ?.publicKey ??
      'not founded';

  Future<String> getMnemonicPhraseByWalletName(
    String walletName,
  ) async =>
      cryptoLibrary.walletsStream.value
          .firstWhere((element) => element.name == walletName)
          .mnemonic;

  Future<BlockchainResponse> sendNativeCoinTransferByWalletId(
      {required BitcoinTransferRequest bitcoinTransferRequest}) async {
    final response = cryptoLibrary.sendTransferNativeCoin(
        transferRequest: bitcoinTransferRequest, walletId: '', typeOfBlockchain: '', toAddress: '', transferAmount: '', currentDerivationPath: null);
    return response;
  }
}
