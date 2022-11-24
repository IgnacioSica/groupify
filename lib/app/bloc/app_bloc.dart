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
    on<AppSpotifyUserChanged>(_onSpotifyUserChanged);
    on<AppLogoutRequested>(_onLogoutRequested);
    on<AppUpdate>(_onUpdate);
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
      return AppState.authenticated(authRepo.currentUser, authRepo.currentSpotifyAccessToken);
    } else {
      return AppState.unauthenticated(authRepo.currentUser, authRepo.currentSpotifyAccessToken);
    }
  }

  Future<void> _validateState(User user, SpotifyAccessToken spotifyAccessToken, Emitter<AppState> emit) async {
    if (user.isNotEmpty && spotifyAccessToken.isNotEmpty) {
      emit(AppState.authenticated(user, spotifyAccessToken));
    } else {
      emit(AppState.unauthenticated(user, spotifyAccessToken));
    }
  }

  Future<void> _onUserChanged(AppUserChanged event, Emitter<AppState> emit) async {
    _validateState(event.user, _authenticationRepository.currentSpotifyAccessToken, emit);
  }

  Future<void> _onSpotifyUserChanged(AppSpotifyUserChanged event, Emitter<AppState> emit) async {
    _validateState(_authenticationRepository.currentUser, event.spotifyAccessToken, emit);
  }

  Future<void> _onUpdate(AppUpdate event, Emitter<AppState> emit) async {
    _validateState(_authenticationRepository.currentUser, _authenticationRepository.currentSpotifyAccessToken, emit);
  }

  void _onLogoutRequested(AppLogoutRequested event, Emitter<AppState> emit) async {
    await (_authenticationRepository.logOut());
    add(AppUpdate());
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    _connectionSubscription.cancel();
    return super.close();
  }
}
