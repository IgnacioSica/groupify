part of 'app_bloc.dart';

enum AppStatus {
  authenticated,
  unauthenticated,
}

class AppState extends Equatable {
  const AppState._({
    required this.status,
    this.user = User.empty,
    this.spotifyAccessToken = SpotifyAccessToken.empty,
  });

  const AppState.authenticated(User user, SpotifyAccessToken spotifyAccessToken)
      : this._(status: AppStatus.authenticated, user: user, spotifyAccessToken: spotifyAccessToken);

  const AppState.unauthenticated(User user, SpotifyAccessToken spotifyAccessToken)
      : this._(status: AppStatus.unauthenticated, user: user, spotifyAccessToken: spotifyAccessToken);

  final AppStatus status;
  final User user;
  final SpotifyAccessToken spotifyAccessToken;

  bool get googleAuthenticated => user != User.empty;
  bool get spotifyAuthenticated => spotifyAccessToken != SpotifyAccessToken.empty;

  @override
  List<Object> get props => [status, user, spotifyAccessToken];
}
