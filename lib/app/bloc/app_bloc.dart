import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:groupify/auth/auth.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc({required AuthRepository authenticationRepository})
      : _authenticationRepository = authenticationRepository,
        super(_init(authenticationRepository)) {
    on<AppUserChanged>(_onUserChanged);
    on<AppLogoutRequested>(_onLogoutRequested);
    on<AppSpotifyUserChanged>(_onSpotifyUserChanged);
    _userSubscription = _authenticationRepository.user.listen(
      (user) => add(AppUserChanged(user)),
    );
    _connectionSubscription = _authenticationRepository.spotifyUser.listen(
      (spotifyAccessToken) => add(AppSpotifyUserChanged(spotifyAccessToken)),
    );
  }

  final AuthRepository _authenticationRepository;
  late final StreamSubscription<User> _userSubscription;
  late final StreamSubscription<SpotifyAccessToken> _connectionSubscription;

  static AppState _init(AuthRepository authRepo) {
    if (authRepo.currentUser.isNotEmpty && authRepo.currentSpotifyAccessToken.isNotEmpty) {
      return AppState.authenticated(authRepo.currentUser, authRepo.currentSpotifyAccessToken!);
    } else if (authRepo.currentUser.isNotEmpty) {
      return AppState.googleAuthenticated(authRepo.currentUser);
    } else if (authRepo.currentSpotifyAccessToken.isNotEmpty) {
      return AppState.spotifyAuthenticated(authRepo.currentSpotifyAccessToken!);
    } else {
      return const AppState.unauthenticated();
    }
  }

  Future<void> _validateState(User user, SpotifyAccessToken spotifyAccessToken, Emitter<AppState> emit) async {
    if (user.isNotEmpty && spotifyAccessToken.isNotEmpty) {
      emit(AppState.authenticated(user, spotifyAccessToken));
    } else if (user.isNotEmpty) {
      emit(AppState.googleAuthenticated(user));
    } else if (spotifyAccessToken.isNotEmpty) {
      emit(AppState.spotifyAuthenticated(spotifyAccessToken));
    } else {
      emit(const AppState.unauthenticated());
    }
  }

  Future<void> _onUserChanged(AppUserChanged event, Emitter<AppState> emit) async {
    _validateState(event.user, state.spotifyAccessToken, emit);
  }

  Future<void> _onSpotifyUserChanged(AppSpotifyUserChanged event, Emitter<AppState> emit) async {
    _validateState(state.user, event.spotifyAccessToken, emit);
  }

  // Future<void> _onSpotifyConnectionChanged(AppSpotifyConnectionChanged event, Emitter<AppState> emit) async {
  //   if (state.user.isNotEmpty && event.spotifyAccessToken.connected) {
  //     emit(AppState.authenticated(state.user, state.spotifyAccessToken));
  //   } else if (state.user.isNotEmpty) {
  //     emit(AppState.googleAuthenticated(state.user));
  //   } else if (event.spotifyAccessToken.connected) {
  //     emit(AppState.spotifyAuthenticated(state.spotifyAccessToken));
  //   } else {
  //     emit(const AppState.unauthenticated());
  //   }
  // }

  void _onLogoutRequested(AppLogoutRequested event, Emitter<AppState> emit) {
    unawaited(_authenticationRepository.logOut());
    add(const AppSpotifyUserChanged(SpotifyAccessToken.empty));
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    _connectionSubscription.cancel();
    return super.close();
  }
}
