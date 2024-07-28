import 'package:equatable/equatable.dart';
import '../models/coin_model.dart';

abstract class SwapState extends Equatable {
  const SwapState();
  
  @override
  List<Object?> get props => [];
}

class SwapInitial extends SwapState {}

class CoinsLoaded extends SwapState {
  final List<CoinModel> coinsList;
  const CoinsLoaded(this.coinsList);

  @override
  List<Object?> get props => [coinsList];
}

// class QuoteFetched extends SwapState {
//   final double quoteAmount;
//   const QuoteFetched(this.quoteAmount);

//   @override
//   List<Object?> get props => [quoteAmount];
// }

class AllowanceChecked extends SwapState {
  final bool isAllowed;
  const AllowanceChecked(this.isAllowed);

  @override
  List<Object?> get props => [isAllowed];
}

class TransactionApproved extends SwapState {}

class Swapped extends SwapState {
  final String broadcastResponse;
  const Swapped(this.broadcastResponse);

  @override
  List<Object?> get props => [broadcastResponse];
}

class SwapError extends SwapState {
  final String message;
  const SwapError(this.message);

  @override
  List<Object?> get props => [message];
}
