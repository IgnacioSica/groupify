part of 'app_bloc.dart';

enum AppStatus {
  authenticated,
  googleAuthenticated,
  spotifyAuthenticated,
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

  const AppState.googleAuthenticated(User user) : this._(status: AppStatus.googleAuthenticated, user: user);

  const AppState.spotifyAuthenticated(SpotifyAccessToken spotifyConnected)
      : this._(status: AppStatus.spotifyAuthenticated, spotifyAccessToken: spotifyConnected);

  const AppState.unauthenticated() : this._(status: AppStatus.unauthenticated);

  final AppStatus status;
  final User user;
  final SpotifyAccessToken spotifyAccessToken;

  @override
  List<Object> get props => [status, user, spotifyAccessToken];
}
