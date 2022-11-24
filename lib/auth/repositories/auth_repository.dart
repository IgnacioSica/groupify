import 'dart:async';

import 'package:cache/cache.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

import '../auth.dart';
import 'login_with_google_failure.dart';
import 'login_with_spotify_failure.dart';
import 'logout_failure.dart';

class AuthRepository implements TokenRepository {
  AuthRepository({
    CacheClient? cache,
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FlutterSecureStorage? storage,
  })  : _cache = cache ?? CacheClient(),
        //_storage = storage ?? const FlutterSecureStorage(),
        _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.standard();

  // static Future<AuthRepository> create() async {
  //   FlutterSecureStorage storage = const FlutterSecureStorage();
  //   CacheClient cache = CacheClient();
  //
  //   final accessToken = await storage.read(key: spotifyCacheKey);
  //   if (accessToken != null && accessToken.isNotEmpty) {
  //     cache.write(key: spotifyCacheKey, value: SpotifyAccessToken(accessToken: accessToken));
  //   }
  //   return AuthRepository(cache: cache, storage: storage);
  // }

  final CacheClient _cache;
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  //final FlutterSecureStorage _storage;

  @visibleForTesting
  bool isWeb = kIsWeb;

  @visibleForTesting
  static const userCacheKey = '__user_cache_key__';

  @visibleForTesting
  static const spotifyCacheKey = '__spotify_cache_key__';

  Stream<User> get user {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      final user = firebaseUser == null ? User.empty : firebaseUser.toUser;
      _cache.write(key: userCacheKey, value: user);
      return user;
    });
  }

  Stream<SpotifyAccessToken> get spotifyUser {
    try {
      return SpotifySdk.subscribeUserStatus().asyncMap((userStatus) async {
        if (userStatus.isLoggedIn()) {
          return _cache.read<SpotifyAccessToken>(key: spotifyCacheKey) ?? SpotifyAccessToken.empty;
        } else {
          return SpotifyAccessToken.empty;
        }
      });
    } catch (e) {
      return Stream.fromFuture(getSpotifyAccessToken()).asyncMap((token) {
        _cache.write(key: spotifyCacheKey, value: token);
        return SpotifyAccessToken(accessToken: token);
      });
    }
  }

  // Stream<ConnectionStatus> get connectionStatus {
  //   return SpotifySdk.subscribeConnectionStatus().asyncMap((connectionStatus) async {
  //     print("========>" + jsonEncode(connectionStatus));
  //     return connectionStatus;
  //   });
  // }

  // Stream<SpotifyAccessTokenEvent> get spotifyAccessToken {
  //   return SpotifySdk.subscribeConnectionStatus().asyncMap((event) async {
  //     if (!event.connected) {
  //       return SpotifyAccessTokenEvent(accessToken: SpotifyAccessToken.empty, errorMessage: event.errorDetails);
  //     }
  //
  //     SpotifySdk.subscribeUserStatus()
  //
  //     return const SpotifyAccessTokenEvent(accessToken: SpotifyAccessToken.empty);
  //   });
  //   // return _firebaseAuth.authStateChanges().map((firebaseUser) {
  //   //   final user = firebaseUser == null ? User.empty : firebaseUser.toUser;
  //   //   _cache.write(key: userCacheKey, value: user);
  //   //   // final accessToken = await storage.read(key: spotifyCacheKey);
  //   //   // final user = firebaseUser == null ? User.empty : firebaseUser.toUser;
  //   //   // _cache.write(key: spotifyCacheKey, value: storage.read(key: spotifyCacheKey));
  //   //   //return user;
  //   // });
  // }

  User get currentUser {
    return _cache.read<User>(key: userCacheKey) ?? User.empty;
  }

  SpotifyAccessToken get currentSpotifyAccessToken {
    return _cache.read<SpotifyAccessToken>(key: spotifyCacheKey) ?? SpotifyAccessToken.empty;
  }

  Future<String> getSpotifyAccessToken() async {
    return await SpotifySdk.getAccessToken(
      clientId: "b9a4881e77f4488eb882788cb106a297",
      redirectUrl: "https://com.example.groupify/callback/",
      scope: [
        'app-remote-control',
        'user-library-modify',
        'user-read-currently-playing',
        'user-modify-playback-state',
        'user-read-playback-state',
        'user-read-recently-played',
        'user-read-private',
        'user-library-read',
      ].join(","),
    );
  }

  Future<void> logInWithSpotify() async {
    try {
      final accessToken = await SpotifySdk.getAccessToken(
        clientId: "b9a4881e77f4488eb882788cb106a297",
        redirectUrl: "https://com.example.groupify/callback/",
        scope: [
          'app-remote-control',
          'user-library-modify',
          'user-read-currently-playing',
          'user-modify-playback-state',
          'user-read-playback-state',
          'user-read-recently-played',
          'user-read-private',
          'user-library-read',
        ].join(","),
      );

      await SpotifySdk.connectToSpotifyRemote(
        clientId: 'b9a4881e77f4488eb882788cb106a297',
        redirectUrl: 'https://com.example.groupify/callback/',
        accessToken: accessToken,
      );

      // _storage.delete(key: spotifyCacheKey);
      //_storage.write(key: spotifyCacheKey, value: accessToken);
      _cache.write<SpotifyAccessToken>(key: spotifyCacheKey, value: SpotifyAccessToken(accessToken: accessToken));
    } catch (e) {
      throw LogInWithSpotifyFailure(e.toString());
    }
  }

  Future<void> logInWithGoogle() async {
    try {
      late final firebase_auth.AuthCredential credential;
      if (isWeb) {
        final googleProvider = firebase_auth.GoogleAuthProvider();
        final userCredential = await _firebaseAuth.signInWithPopup(
          googleProvider,
        );
        credential = userCredential.credential!;
      } else {
        final googleUser = await _googleSignIn.signIn();
        final googleAuth = await googleUser!.authentication;
        credential = firebase_auth.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
      }
      await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw LogInWithGoogleFailure.fromCode(e.code);
    } catch (_) {
      throw const LogInWithGoogleFailure();
    }
  }

  Future<void> logOut() async {
    try {
      await Future.wait([
        SpotifySdk.disconnect(),
        _firebaseAuth.signOut(),
      ]);

      _cache.delete(key: spotifyCacheKey);
    } catch (_) {
      throw LogOutFailure();
    }
  }
}

extension on firebase_auth.User {
  User get toUser {
    return User(id: uid, email: email, name: displayName, photo: photoURL);
  }
}
