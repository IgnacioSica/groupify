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
    this.spotifyConnected = false,
  });

  const AppState.authenticated(User user) : this._(status: AppStatus.authenticated, user: user);

  const AppState.googleAuthenticated(User user) : this._(status: AppStatus.googleAuthenticated, user: user);

  const AppState.spotifyAuthenticated(bool spotifyConnected)
      : this._(
          status: AppStatus.spotifyAuthenticated,
          spotifyConnected: spotifyConnected,
        );

  const AppState.unauthenticated() : this._(status: AppStatus.unauthenticated);

  final AppStatus status;
  final User user;
  final bool spotifyConnected;

  @override
  List<Object> get props => [status, user];
}
