import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'exports.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final debounce = Debounce();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SwapBloc()..add(FetchCoins()),
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: BlocConsumer<SwapBloc, SwapState>(
            listener: (context, state) async {
              if (state is SwapError) {
                Fluttertoast.showToast(msg: state.message);
                final bloc = context.read<SwapBloc>();
                bloc.add(LoadCoins());
                try {
                  final url =
                      Uri.parse('https://bscscan.com/address/${bloc.address}');
                  if (!await launchUrl(url)) {}
                } catch (e) {
                  if (kDebugMode) {
                    print('Unable To Lauch url due to :$e');
                  }
                }
              } else if (state is Swapped) {
                Fluttertoast.showToast(msg: state.broadcastResponse);
              } else if (state is TransactionApproved ||
                  (state is AllowanceChecked && state.isAllowed)) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Swap'),
                    content:
                        const Text('Transaction approved. Confirm to swap?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        child: const Text('Yes'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        child: const Text('No'),
                      ),
                    ],
                  ),
                ).then(
                  (proceed) {
                    if (proceed == true) {
                      context.read<SwapBloc>().add(Swap());
                    } else {
                      context.read<SwapBloc>().add(LoadCoins());
                    }
                  },
                );
              } else if (state is AllowanceChecked && !state.isAllowed) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Approve'),
                    content: const Text(
                        'You need to approve the transaction. Confirm to proceed?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        child: const Text('Yes'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        child: const Text('No'),
                      ),
                    ],
                  ),
                ).then(
                  (proceed) {
                    if (proceed == true) {
                      context.read<SwapBloc>().add(ApproveTransaction());
                    } else {
                      context.read<SwapBloc>().add(LoadCoins());
                    }
                  },
                );
              }
            },
            builder: (context, state) {
              if (state is SwapInitial) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is CoinsLoaded) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      30.height,
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            AppImages.inch,
                            fit: BoxFit.fill,
                            height: 50.sp,
                            width: 50.sp,
                          ),
                          5.width,
                          Text('1inch Swap',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20.sp)),
                        ],
                      ),
                      5.height,
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('(BSC Network)',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.sp)),
                          5.width,
                          Image.asset(
                            AppImages.bnb,
                            fit: BoxFit.fill,
                            height: 20.sp,
                            width: 20.sp,
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                            onPressed: () {
                              context.setClipboard(
                                text: context.read<SwapBloc>().address,
                              );
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  context.read<SwapBloc>().address.short(4),
                                ),
                                Icon(
                                  Icons.copy_rounded,
                                  size: 20.sp,
                                )
                              ],
                            )),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child:
                            Text('You Pay', style: TextStyle(fontSize: 14.sp)),
                      ),
                      7.height,
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 5.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFFB999EC).withOpacity(0.4)),
                        ),
                        child: Column(
                          children: [
                            DropdownButtonFormField<CoinModel>(
                              hint: const Text(' Select Coin'),
                              value: context.read<SwapBloc>().selectedFromCoin,
                              items: state.coinsList.map((coin) {
                                return DropdownMenuItem(
                                  value: coin,
                                  enabled: coin.address !=
                                      context
                                          .read<SwapBloc>()
                                          .selectedToCoin
                                          ?.address,
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: CachedNetworkImage(
                                          height: 30.sp,
                                          width: 30.sp,
                                          imageUrl: coin.logoURI,
                                          placeholder: (context, url) =>
                                              const CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                        ),
                                      ),
                                      10.width,
                                      Text('${coin.symbol} (${coin.name})',
                                          style: TextStyle(fontSize: 14.sp)),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  context.read<SwapBloc>().selectedFromCoin =
                                      value;
                                  context.read<SwapBloc>().add(GetQuote());
                                }
                              },
                            ),
                            7.height,
                            TextFormField(
                              controller:
                                  context.read<SwapBloc>().fromController,
                              onChanged: (_) => debounce.run(() =>
                                  context.read<SwapBloc>().add(GetQuote())),
                              decoration: const InputDecoration(
                                  hintText: 'Enter Amount',
                                  border: InputBorder.none),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          context.read<SwapBloc>().add(InterchangeCoins());
                          setState(() {});
                        },
                        icon: Icon(Icons.swap_vert_circle, size: 30.sp),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('You Receive',
                            style: TextStyle(fontSize: 14.sp)),
                      ),
                      7.height,
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 5.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFFB999EC).withOpacity(0.4)),
                        ),
                        child: Column(
                          children: [
                            DropdownButtonFormField<CoinModel>(
                              value: context.read<SwapBloc>().selectedToCoin,
                              hint: const Text(' Select Coin'),
                              items: state.coinsList.map((coin) {
                                return DropdownMenuItem(
                                  enabled: coin.address !=
                                      context
                                          .read<SwapBloc>()
                                          .selectedFromCoin
                                          ?.address,
                                  value: coin,
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: CachedNetworkImage(
                                          height: 30.sp,
                                          width: 30.sp,
                                          imageUrl: coin.logoURI,
                                          placeholder: (context, url) =>
                                              const CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                        ),
                                      ),
                                      10.width,
                                      Text('${coin.symbol} (${coin.name})',
                                          style: TextStyle(fontSize: 14.sp)),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  context.read<SwapBloc>().selectedToCoin =
                                      value;
                                  context.read<SwapBloc>().add(GetQuote());
                                }
                              },
                            ),
                            7.height,
                            TextFormField(
                              enabled: false,
                              controller: context.read<SwapBloc>().toController,
                              decoration: const InputDecoration(
                                  hintText: '0', border: InputBorder.none),
                            ),
                          ],
                        ),
                      ),
                      10.height,
                      Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '(Slippage Tolerance - 1%)',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12.sp,
                                color: Colors.red),
                          )),
                      10.height,
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final swap = context.read<SwapBloc>();
                            if (swap.selectedFromCoin == null ||
                                swap.selectedToCoin == null ||
                                double.tryParse(swap.fromController.text) ==
                                    null) return;
                            context.read<SwapBloc>().add(CheckAllowance());
                          },
                          child: const Text('Swap'),
                        ),
                      ),
                    ],
                  ),
                );
              } else if (state is SwapError) {
                return Center(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Error Occured',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.red,
                        fontSize: 20.sp,
                      ),
                    ),
                    5.height,
                    Text(state.message),
                    ElevatedButton(
                        onPressed: () {
                          context.read<SwapBloc>().add(LoadCoins());
                        },
                        child: const Text('Go Back'))
                  ],
                ));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }
}
