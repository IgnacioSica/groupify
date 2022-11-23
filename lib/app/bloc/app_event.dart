part of 'app_bloc.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object> get props => [];
}

class AppLogoutRequested extends AppEvent {}

class AppUserRefresh extends AppEvent {}

class AppUserChanged extends AppEvent {
  const AppUserChanged(this.user);

  final User user;

  @override
  List<Object> get props => [user];
}

class AppSpotifyConnectionChanged extends AppEvent {
  const AppSpotifyConnectionChanged(this.spotifyConnected);

  final bool spotifyConnected;

  @override
  List<Object> get props => [spotifyConnected];
}
