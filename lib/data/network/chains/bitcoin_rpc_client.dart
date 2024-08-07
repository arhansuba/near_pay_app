import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutterchain/flutterchain_lib/constants/core/blockchain_response.dart';

import 'package:flutterchain/flutterchain_lib/models/core/blockchain_response.dart';
import 'package:flutterchain/flutterchain_lib/network/core/network_core.dart';
import 'dart:async';

import 'package:near_pay_app/core/constants/chains/bitcoin_blockchain_network_urls.dart';
import 'package:near_pay_app/core/formaters/chains/bitcoin_formater.dart';
import 'package:near_pay_app/data/chains/bitcoin/bitcoin_transaction_info.dart';




class BitcoinRpcClient {
  final BitcoinNetworkClient networkClient;

  factory BitcoinRpcClient.defaultInstance() {
    return BitcoinRpcClient(
      networkClient: BitcoinNetworkClient(
        baseUrl: BitcoinBlockChainNetworkUrls.listOfUrls.first,
        dio: Dio(),
      ),
    );
  }
  BitcoinRpcClient({required this.networkClient});

  Future<BitcoinTransactionInfoModel> getTransactionInfo(
      String accountID, String transferAmount, int actuelFees) async {
    final res = await networkClient.getRequest(
      '${BitcoinBlockChainNetworkUrls.listOfUrls.first}/addrs/$accountID?unspentOnly=true',
    );
    if (res.isSuccess) {
      num currentSum = 0;
      var indexWhithBigestSum = 0;
      List<dynamic> listWithTXrefs = res.data['txrefs'];
      for (int i = 0; i < listWithTXrefs.length; i++) {
        if (currentSum < listWithTXrefs[i]['value']) {
          currentSum = listWithTXrefs[i]['value'];
          indexWhithBigestSum = i;
        }
      }
      if (currentSum > num.parse(transferAmount) + actuelFees * 200) {
        final txHash =
            listWithTXrefs[indexWhithBigestSum]['tx_hash'].toString();
        final refBalance =
            listWithTXrefs[indexWhithBigestSum]['value'].toString();
        final txOutput = int.tryParse(listWithTXrefs[indexWhithBigestSum]
                    ['tx_output_n']
                .toString()) ??
            0;
        final data = {
          "tx_hash": txHash,
          "ref_balance": num.parse(refBalance),
          "tx_output": txOutput
        };
        List<dynamic> listData = [data];
        return BitcoinTransactionInfoModel(data: listData);
      } else {
        List<dynamic> listData = [];
        for (int i = 0; i < listWithTXrefs.length; i++) {
          final txHash = listWithTXrefs[i]['tx_hash'].toString();
          final refBalance = listWithTXrefs[i]['value'].toString();
          final txOutput =
              int.tryParse(listWithTXrefs[i]['tx_output_n'].toString()) ?? 0;
          final data = {
            "tx_hash": txHash,
            "ref_balance": num.parse(refBalance),
            "tx_output": txOutput
          };
          listData.add(data);
        }
        return BitcoinTransactionInfoModel(data: listData);
      }
    } else {
      return BitcoinTransactionInfoModel(data: [
        {'tx_hash': '', 'ref_balance': '', 'tx_output': 0}
      ]);
    }
  }

  Future<String> getAccountBalance(
    String adressId,
  ) async {
    final res = await networkClient.getRequest(
      '${BitcoinBlockChainNetworkUrls.listOfUrls.first}/addrs/$adressId/balance',
    );
    if (res.isSuccess) {
      final amount = res.data['balance'].toString();
      if (int.parse(amount) == 0) {
        return amount;
      }
      final bitcoinAmount = BitcoinFormatter.satoshiToBitcoin(amount);
      return bitcoinAmount;
    } else {
      return "Error while getting balance";
    }
  }

  Future<BlockchainResponse> sendTransferNativeCoinTest(String txhex) async {
    final res = await networkClient.postHTTP(
        '${BitcoinBlockChainNetworkUrls.listOfUrls.first}/txs/decode',
        {'tx': txhex});
    if (res.data['error'] != null) {
      return BlockchainResponse(
        data: res.data['error'],
        status: BlockchainResponses.error,
      );
    }
    return BlockchainResponse(
      data: {"data": res.data},
      status: BlockchainResponses.success,
    );
  }

  Future<BlockchainResponse> getActualPricesFeeSAll() async {
    final res = await networkClient
        .getRequest('https://mempool.space/api/v1/fees/recommended');
    if (res.data['error'] != null) {
      return BlockchainResponse(
        data: res.data['error'],
        status: BlockchainResponses.error,
      );
    }
    return BlockchainResponse(
      data: {"data": res.data},
      status: BlockchainResponses.success,
    );
  }

  Future<int> getActualPricesFeeSHigher() async {
    final res = await networkClient
        .getRequest('https://mempool.space/api/v1/fees/recommended');
    if (res.isSuccess) {
      final txHash = res.data['fastestFee'] + 7;
      return txHash!;
    } else {
      return 0;
    }
  }

  Future<BlockchainResponse> sendTransferNativeCoin(String txhex) async {
    final res = await networkClient.postHTTP(
        '${BitcoinBlockChainNetworkUrls.listOfUrls.first}/txs/push',
        {'tx': txhex});
    if (kDebugMode) {
      print(res.data);
    }
    if (res.data['error'] != null || res.data == null) {
      return BlockchainResponse(
        data: res.data['error'],
        status: BlockchainResponses.error,
      );
    }
    return BlockchainResponse(
      data: {"data": res.data},
      status: BlockchainResponses.success,
    );
  }
}

class BitcoinNetworkClient extends NetworkClient {
  BitcoinNetworkClient({required super.baseUrl, required super.dio}) {
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        logPrint: log,
        retries: 5,
        retryDelays: const [
          Duration(seconds: 2),
          Duration(seconds: 1),
          Duration(seconds: 1),
          Duration(seconds: 1),
          Duration(seconds: 1),
        ],
      ),
    );
  }
}
