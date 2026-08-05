import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

part 'connectivity_event.dart';
part 'connectivity_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final Connectivity _connectivity;
  bool _wasOffline = false;
  StreamSubscription<List<ConnectivityResult>>? _connectionSubscription;
  ConnectivityBloc(this._connectivity) : super(ConnectivityInitial()) {
    on<ConnectivityStarted>((event, emit) async {
      try {
        await _connectionSubscription?.cancel();

        // initial check
        final connected = await InternetConnection().hasInternetAccess;
        emit(connected ? ConnectivityOnline() : ConnectivityOffline());

        _connectionSubscription = _connectivity.onConnectivityChanged.listen(
          (result) async {
            final connection = await InternetConnection().hasInternetAccess;

            add(ConnectivityChanged(isConnected: connection));
          },
        );
      } catch (e) {
        log('connectivity failed to started: $e');
        emit(ConnectivityOffline());
      }
    });

    on<ConnectivityChanged>(
      (event, emit) {
        if (!event.isConnected) {
          _wasOffline = true;
          emit(ConnectivityOffline());
          return;
        }

        if (_wasOffline) {
          _wasOffline = false;
          emit(ConnectivityRestored());
        } else {
          emit(ConnectivityOnline());
        }
      },
    );
  }
  @override
  Future<void> close() {
    _connectionSubscription?.cancel();
    return super.close();
  }
}
