import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:puntossmart/application/profile/profile_notifier.dart';
import 'package:puntossmart/application/profile/profile_provider.dart';
import 'package:puntossmart/application/profile/profile_state.dart';
import 'package:puntossmart/infrastructure/services/app_helpers.dart';
import 'package:puntossmart/infrastructure/services/local_storage.dart';
import 'package:puntossmart/infrastructure/services/tr_keys.dart';
import 'package:puntossmart/presentation/components/app_bars/common_app_bar.dart';
import 'package:intl/intl.dart' as intl;
import 'package:puntossmart/presentation/components/buttons/pop_button.dart';
import 'package:puntossmart/presentation/components/loading.dart';
import '../../theme/app_style.dart';

@RoutePage()
class WalletHistoryPage extends ConsumerStatefulWidget {
  const WalletHistoryPage({super.key});

  @override
  ConsumerState<WalletHistoryPage> createState() => _WalletHistoryState();
}

class _WalletHistoryState extends ConsumerState<WalletHistoryPage> {
  late RefreshController controller;
  late ProfileState state;
  late ProfileNotifier event;
  final bool isLtr = LocalStorage.getLangLtr();

  @override
  void initState() {
    controller = RefreshController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).getWallet(context);
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    event = ref.read(profileProvider.notifier);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    state = ref.watch(profileProvider);
    return Directionality(
      textDirection: isLtr ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppStyle.bgGrey,
        body: Column(
          children: [
            CommonAppBar(
              child: Text(
                AppHelpers.getTranslation(TrKeys.transactions),
                style: AppStyle.interNoSemi(
                  size: 18,
                  color: AppStyle.black,
                ),
              ),
            ),
            state.isLoadingHistory
                ? Padding(
                    padding: EdgeInsets.only(top: 56.h),
                    child: const Loading(),
                  )
                : Expanded(
                    child: SmartRefresher(
                      enablePullDown: true,
                      enablePullUp: true,
                      physics: const BouncingScrollPhysics(),
                      controller: controller,
                      onLoading: () {
                        event.getWalletPage(context, controller);
                      },
                      onRefresh: () {
                        event.getWallet(context, refreshController: controller);
                      },
                      child: ListView.builder(
                        padding: EdgeInsets.all(16.r),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemCount: state.walletHistory?.length ?? 0,
                        itemBuilder: (context, index) => Container(
                          margin: EdgeInsets.only(bottom: 16.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            color: AppStyle.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 16.r, right: 16.r, left: 16.r),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      intl.DateFormat("MMM dd,yyyy h:mm a")
                                          .format(
                                        DateTime.tryParse(state
                                                        .walletHistory?[index]
                                                        .createdAt ??
                                                    "")
                                                ?.toLocal() ??
                                            DateTime.now(),
                                      ),
                                      style: AppStyle.interRegular(
                                        size: 12.sp,
                                        color: AppStyle.textGrey,
                                      ),
                                    ),
                                    4.verticalSpace,
                                    Text(
                                      state.walletHistory?[index].note ?? "",
                                      style: AppStyle.interRegular(
                                        size: 16.sp,
                                        color: AppStyle.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(
                                color: AppStyle.textGrey,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    bottom: 16.r, right: 16.r, left: 16.r),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          AppHelpers.getTranslation(
                                              TrKeys.paymentDate),
                                          style: AppStyle.interRegular(
                                            size: 12.sp,
                                            color: AppStyle.textGrey,
                                          ),
                                        ),
                                        Text(
                                          intl.DateFormat("MM/dd/yyyy").format(
                                            DateTime.tryParse(state
                                                            .walletHistory?[
                                                                index]
                                                            .createdAt ??
                                                        "")
                                                    ?.toLocal() ??
                                                DateTime.now(),
                                          ),
                                          style: AppStyle.interRegular(
                                            size: 16.sp,
                                            color: AppStyle.black,
                                          ),
                                        )
                                      ],
                                    ),
                                    16.verticalSpace,
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          AppHelpers.getTranslation(
                                              TrKeys.sender),
                                          style: AppStyle.interRegular(
                                            size: 12.sp,
                                            color: AppStyle.textGrey,
                                          ),
                                        ),
                                        Text(
                                          state.walletHistory?[index].author
                                                  ?.firstname ??
                                              "",
                                          style: AppStyle.interRegular(
                                            size: 16.sp,
                                            color: AppStyle.black,
                                          ),
                                        )
                                      ],
                                    ),
                                    16.verticalSpace,
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          AppHelpers.getTranslation(
                                              TrKeys.deposit),
                                          style: AppStyle.interRegular(
                                            size: 12.sp,
                                            color: AppStyle.textGrey,
                                          ),
                                        ),
                                        Text(
                                          AppHelpers.numberFormat(
                                              number: state
                                                  .walletHistory?[index].price),
                                          style: AppStyle.interRegular(
                                            size: 16.sp,
                                            color: AppStyle.black,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: const PopButton(),
        ),
      ),
    );
  }
}
