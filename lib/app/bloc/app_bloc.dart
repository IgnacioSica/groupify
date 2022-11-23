import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:groupify/auth/auth.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc({required AuthRepository authenticationRepository})
      : _authenticationRepository = authenticationRepository,
        super(
          authenticationRepository.currentUser.isNotEmpty
              ? AppState.googleAuthenticated(authenticationRepository.currentUser)
              : const AppState.unauthenticated(),
        ) {
    on<AppUserChanged>(_onUserChanged);
    on<AppLogoutRequested>(_onLogoutRequested);
    on<AppUserRefresh>(_onUserRefresh);
    on<AppSpotifyConnectionChanged>(_onSpotifyConnectionChanged);
    _userSubscription = _authenticationRepository.user.listen(
      (user) => add(AppUserChanged(user)),
    );
  }

  final AuthRepository _authenticationRepository;
  late final StreamSubscription<User> _userSubscription;
  late final StreamSubscription<bool> _spotifyConnectionSubscription;

  Future<void> _onUserChanged(AppUserChanged event, Emitter<AppState> emit) async {
    if (event.user.isNotEmpty && state.status == AppStatus.spotifyAuthenticated) {
      emit(AppState.authenticated(state.user));
    } else if (event.user.isNotEmpty) {
      emit(AppState.googleAuthenticated(event.user));
    } else if (state.status == AppStatus.spotifyAuthenticated) {
      emit(AppState.spotifyAuthenticated(state.spotifyConnected));
    } else {
      emit(const AppState.unauthenticated());
    }
  }

  Future<void> _onSpotifyConnectionChanged(AppSpotifyConnectionChanged event, Emitter<AppState> emit) async {
    if (event.spotifyConnected && state.status == AppStatus.googleAuthenticated) {
      emit(AppState.authenticated(state.user));
    } else if (event.spotifyConnected) {
      emit(AppState.spotifyAuthenticated(event.spotifyConnected));
    } else if (state.status == AppStatus.googleAuthenticated) {
      emit(AppState.googleAuthenticated(state.user));
    } else {
      emit(const AppState.unauthenticated());
    }
  }

  Future<void> _onUserRefresh(AppUserRefresh event, Emitter<AppState> emit) async {
    if (state.user.isEmpty) {
      emit(const AppState.unauthenticated());
    } else {
      emit(AppState.googleAuthenticated(state.user));
    }
  }

  void _onLogoutRequested(AppLogoutRequested event, Emitter<AppState> emit) {
    unawaited(_authenticationRepository.logOut());
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    _spotifyConnectionSubscription.cancel();
    return super.close();
  }
}
