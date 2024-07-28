import 'package:equatable/equatable.dart';

abstract class SwapEvent extends Equatable {
  const SwapEvent();

  @override
  List<Object?> get props => [];
}

class FetchCoins extends SwapEvent {}

class LoadCoins extends SwapEvent {}

class GetQuote extends SwapEvent {}

class InterchangeCoins extends SwapEvent {}

class CheckAllowance extends SwapEvent {}

class ApproveTransaction extends SwapEvent {}

class Swap extends SwapEvent {}
