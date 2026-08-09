import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uangin/blocs/connectivity/connectivity_bloc.dart';
import 'package:uangin/core/theme/colors.dart';
import 'package:uangin/core/widgets/no_internet_banner.dart';

class AppConnectivityWrapper extends StatefulWidget {
  final Widget child;
  const AppConnectivityWrapper({required this.child, super.key});

  @override
  State<AppConnectivityWrapper> createState() => _AppConnectivityWrapperState();
}

class _AppConnectivityWrapperState extends State<AppConnectivityWrapper> {
  bool _showOnlineBanner = false;
  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityBloc, ConnectivityState>(
      listener: (context, state) {
        if (state is ConnectivityRestored) {
          setState(() {
            _showOnlineBanner = true;
          });

          Future.delayed(
            const Duration(seconds: 2),
            () {
              if (!mounted) return;

              setState(() {
                _showOnlineBanner = false;
              });

              context
                  .read<ConnectivityBloc>()
                  .add(const ConnectivityChanged(isConnected: true));
            },
          );
        }
      },
      child: BlocBuilder<ConnectivityBloc, ConnectivityState>(
        builder: (context, state) {
          return Stack(
            children: [
              widget.child,
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: context.watch<ConnectivityBloc>().state
                          is ConnectivityOffline
                      ? const NoInternetBanner(
                          color: MyColors.red,
                          message: 'No internet connection',
                          icon: 'lib/assets/icons/no-internet.svg')
                      : _showOnlineBanner
                          ? const NoInternetBanner(
                              color: MyColors.green,
                              message: 'Back online',
                              icon: 'lib/assets/icons/wifi.svg')
                          : const SizedBox.shrink(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
