import 'package:flutter/material.dart';
import 'empty_view.dart';
import 'error_view.dart';
import 'no_internet_view.dart';
import 'shimmer_loader.dart';

enum ViewState {
  idle,
  loading,
  success,
  empty,
  error,
  noInternet,
}

class StateView extends StatelessWidget {
  final ViewState state;
  final Widget child;
  final Widget? loadingWidget;
  final String? emptyTitle;
  final String? emptyMessage;
  final String? emptyLottie;
  final String? errorTitle;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const StateView({
    super.key,
    required this.state,
    required this.child,
    this.loadingWidget,
    this.emptyTitle,
    this.emptyMessage,
    this.emptyLottie,
    this.errorTitle,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case ViewState.loading:
        return loadingWidget ?? const ShimmerLoader();
      case ViewState.empty:
        return EmptyView(
          title: emptyTitle ?? 'No Data Found',
          message: emptyMessage ?? 'There is nothing to display here yet.',
          lottieAsset: emptyLottie,
        );
      case ViewState.error:
        return ErrorView(
          title: errorTitle ?? 'Something Went Wrong',
          message: errorMessage ?? 'An error occurred while loading data.',
          onRetry: onRetry,
        );
      case ViewState.noInternet:
        return NoInternetView(onRetry: onRetry);
      case ViewState.idle:
      case ViewState.success:
        return child;
    }
  }
}
