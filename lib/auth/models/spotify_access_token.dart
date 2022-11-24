import 'package:equatable/equatable.dart';

class SpotifyAccessToken extends Equatable {
  const SpotifyAccessToken({required this.accessToken});

  final String accessToken;

  static const empty = SpotifyAccessToken(accessToken: '');

  bool get isEmpty => this == SpotifyAccessToken.empty;

  bool get isNotEmpty => this != SpotifyAccessToken.empty;

  @override
  List<Object?> get props => [accessToken];
}

class SpotifyAccessTokenEvent {
  const SpotifyAccessTokenEvent({required this.accessToken, this.errorMessage});

  final SpotifyAccessToken accessToken;
  final String? errorMessage;
}
