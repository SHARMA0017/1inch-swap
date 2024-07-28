import 'dart:math';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import '../exports.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class SwapBloc extends Bloc<SwapEvent, SwapState> {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.1inch.dev',
      headers: {
        "Authorization": "Bearer ${dotenv.env['API_KEY']}",
        "accept": "application/json",
      },
    ),
  );

  final Web3Client ethClient =
      Web3Client('https://bsc-dataseed1.binance.org/', Client());
  final Credentials credentials =
      EthPrivateKey.fromHex('${dotenv.env['PRIVATE_KEY']}');
  final Debounce debounce = Debounce();

  List<CoinModel> coinsList = [];
  CoinModel? selectedFromCoin;
  CoinModel? selectedToCoin;
  String get address => credentials.address.hex;
  final TextEditingController fromController = TextEditingController(text: '1');
  final TextEditingController toController = TextEditingController();
  int chainId = 56;

  SwapBloc() : super(SwapInitial()) {
    on<GetQuote>(_onGetQuote);
    on<FetchCoins>(_onFetchCoins);
    on<LoadCoins>(_onLoadCoins);
    on<InterchangeCoins>(_onInterchangeCoins);
    on<CheckAllowance>(_onCheckAllowance);
    on<ApproveTransaction>(_onApproveTransaction);
    on<Swap>(_onSwap);
  }

  Future<void> _onFetchCoins(FetchCoins event, Emitter<SwapState> emit) async {
    try {
      final resp = await dio.get('/token/v1.2/$chainId');
      if (resp.statusCode == 200) {
        final Map<String, dynamic> coinsMap = resp.data;
        coinsList =
            coinsMap.entries.map((e) => CoinModel.fromJson(e.value)).toList();
        selectedFromCoin = coinsList
            .firstWhereOrNull((coin) => coin.symbol.toLowerCase() == 'bnb');
        emit(CoinsLoaded(coinsList));
      } else {
        emit(const SwapError('Failed to fetch coins'));
      }
    } catch (e) {
      emit(SwapError('Error: $e'));
    }
  }

  void _onLoadCoins(LoadCoins event, Emitter<SwapState> emit) {
    emit(CoinsLoaded(coinsList));
  }

  Future<void> _onGetQuote(GetQuote event, Emitter<SwapState> emit) async {
    if (selectedFromCoin == null ||
        selectedToCoin == null ||
        double.tryParse(fromController.text) == null) {
      emit(CoinsLoaded(coinsList));
      return;
    }

    final params = {
      'src': selectedFromCoin?.address,
      'dst': selectedToCoin?.address,
      'amount': BigInt.from(double.parse(fromController.text) *
          pow(10, selectedFromCoin!.decimals))
    };
    try {
      final resp =
          await dio.get('/swap/v6.0/$chainId/quote', queryParameters: params);
      if (resp.statusCode == 200) {
        final val = resp.data['dstAmount'];
        final quoteAmount =
            double.parse(val.toString()) / pow(10, selectedToCoin!.decimals);
        toController.text = quoteAmount.toString();
        emit(CoinsLoaded(coinsList));
      } else {
        emit(const SwapError('Failed to get quote'));
      }
    } catch (e) {
      emit(SwapError('Error: $e'));
    }
  }

  Future<void> _onInterchangeCoins(
      InterchangeCoins event, Emitter<SwapState> emit) async {
    dynamic temp = selectedFromCoin;
    selectedFromCoin = selectedToCoin;
    selectedToCoin = temp;

    temp = toController.text;
    toController.text = fromController.text;
    fromController.text = temp;
    emit(CoinsLoaded(coinsList));
    add(GetQuote());
  }

  Future<void> _onCheckAllowance(
      CheckAllowance event, Emitter<SwapState> emit) async {
    final params = {
      'tokenAddress': selectedFromCoin?.address,
      'walletAddress': credentials.address.hex,
    };

    try {
      final resp = await dio.get('/swap/v6.0/$chainId/approve/allowance',
          queryParameters: params);
      if (resp.statusCode == 200) {
        final isAllowed = resp.data['allowance'].toString() != "0";
        emit(AllowanceChecked(isAllowed));
      } else {
        emit(const SwapError('Failed to check allowance'));
      }
    } catch (e) {
      emit(SwapError('Error: $e'));
    }
  }

  Future<void> _onApproveTransaction(
      ApproveTransaction event, Emitter<SwapState> emit) async {
    final params = {
      'tokenAddress': selectedFromCoin!.address,
      'amount': BigInt.from(double.parse(fromController.text) *
              pow(10, selectedFromCoin!.decimals))
          .toString()
    };

    try {
      final resp = await dio.get('/swap/v6.0/$chainId/approve/transaction',
          queryParameters: params);
      if (resp.statusCode == 200) {
        final data = resp.data;
        final payload = data['data'];
        final txn = Transaction(
          data: hexToBytes(payload),
          gasPrice: EtherAmount.inWei(BigInt.from(num.parse(data['gasPrice']))),
          to: EthereumAddress.fromHex(data['to']),
          value: EtherAmount.inWei(BigInt.from(num.parse(data['value']))),
        );
        final signedTxn =
            await ethClient.signTransaction(credentials, txn, chainId: chainId);
        await broadcast(signedTxn);
        emit(TransactionApproved());
      } else {
        emit(const SwapError('Failed to approve transaction'));
      }
    } catch (e) {
      emit(SwapError('Error: $e'));
    }
  }

  Future<void> _onSwap(Swap event, Emitter<SwapState> emit) async {
    final swapParams = {
      "src": selectedFromCoin?.address,
      "dst": selectedToCoin?.address,
      "amount": BigInt.from(double.parse(fromController.text) *
              pow(10, selectedFromCoin!.decimals))
          .toInt(),
      "from": credentials.address.hex,
      "slippage": 1,
      "disableEstimate": false,
      "allowPartialFill": false,
    };

    try {
      final resp = await dio.get('/swap/v6.0/$chainId/swap',
          queryParameters: swapParams);
      if (resp.statusCode == 200) {
        final data = resp.data['tx'];
        final txn = Transaction(
          from: EthereumAddress.fromHex(data['from']),
          to: EthereumAddress.fromHex(data['to']),
          data: hexToBytes(data['data']),
          gasPrice: EtherAmount.inWei(BigInt.from(num.parse(data['gasPrice']))),
          value: EtherAmount.inWei(BigInt.from(num.parse(data['value']))),
        );
        final signedTxn =
            await ethClient.signTransaction(credentials, txn, chainId: chainId);
        await broadcast(signedTxn);
        fromController.clear();
        toController.clear();
        emit(const Swapped('Swap successful and transaction broadcasted'));
      } else {
        emit(const SwapError('Failed to swap'));
      }
    } catch (e) {
      emit(SwapError('Error: $e'));
    }
  }

  Future<void> broadcast(Uint8List signedTxn) async {
    final params = {"rawTransaction": bytesToHex(signedTxn, include0x: true)};
    await dio.post('/tx-gateway/v1.1/$chainId/broadcast', data: params);
  }
}
