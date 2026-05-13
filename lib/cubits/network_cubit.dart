import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloomie/core/services/network_service.dart';

enum NetworkStatus {
  initializing,
  connected,
  waiting,
  disconnected,
}

class NetworkState {
  final NetworkStatus status;
  const NetworkState(this.status);
}

const _kOfflineDebounce = Duration(seconds: 3);

class NetworkCubit extends Cubit<NetworkState> {
  final NetworkService _networkService;
  StreamSubscription? _subscription;
  Timer? _offlineTimer;

  NetworkCubit(this._networkService)
      : super(const NetworkState(NetworkStatus.initializing)) {
    _init();
  }

  void _init() async {
    final isConnected = await _networkService.isConnected();
    if (isClosed) return;

    if (isConnected) {
      emit(const NetworkState(NetworkStatus.connected));
    }

    _subscription =
        _networkService.connectivityStream.listen(_onConnectivityChanged);
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    if (isClosed) return;
    final hasConnection = NetworkService.hasConnection(results);

    if (hasConnection) {
      _offlineTimer?.cancel();
      _offlineTimer = null;
      if (state.status != NetworkStatus.connected) {
        emit(const NetworkState(NetworkStatus.connected));
      }
    } else {
      if (state.status != NetworkStatus.disconnected &&
          state.status != NetworkStatus.waiting) {
        emit(const NetworkState(NetworkStatus.waiting));

        _offlineTimer?.cancel();
        _offlineTimer = Timer(_kOfflineDebounce, () {
          if (!isClosed) {
            emit(const NetworkState(NetworkStatus.disconnected));
          }
        });
      }
    }
  }

  Future<void> checkConnection() async {
    if (isClosed) return;
    final isConnected = await _networkService.isConnected();
    if (isClosed) return;
    emit(NetworkState(
      isConnected ? NetworkStatus.connected : NetworkStatus.disconnected,
    ));
  }

  @override
  Future<void> close() {
    _offlineTimer?.cancel();
    _subscription?.cancel();
    return super.close();
  }
}
