import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'connectivity_state.dart';

class ConnectivityCubit extends Cubit<ConnectivityState> {
  ConnectivityCubit() : super(const ConnectivityState.initial()) {
    _init();
  }

  final _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Future<void> _init() async {
    final results = await _connectivity.checkConnectivity();
    _emitFromResults(results);
    _subscription = _connectivity.onConnectivityChanged.listen(_emitFromResults);
  }

  void _emitFromResults(List<ConnectivityResult> results) {
    final isOnline = results.any((r) => r == ConnectivityResult.mobile || r == ConnectivityResult.wifi || r == ConnectivityResult.ethernet || r == ConnectivityResult.vpn);
    emit(state.copyWith(isOnline: isOnline));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
