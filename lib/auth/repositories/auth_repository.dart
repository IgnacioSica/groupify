import 'dart:async';
import 'dart:convert';

import 'package:cache/cache.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';
import 'package:spotify_sdk/models/connection_status.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

import '../auth.dart';

class LogInWithSpotifyFailure implements Exception {
  const LogInWithSpotifyFailure([
    this.message = 'An unknown exception occurred.',
  ]);

  /// Create an authentication message
  /// from a firebase authentication exception code.
  factory LogInWithSpotifyFailure.fromCode(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return const LogInWithSpotifyFailure(
          'Account exists with different credentials.',
        );
      case 'invalid-credential':
        return const LogInWithSpotifyFailure(
          'The credential received is malformed or has expired.',
        );
      case 'operation-not-allowed':
        return const LogInWithSpotifyFailure(
          'Operation is not allowed.  Please contact support.',
        );
      case 'user-disabled':
        return const LogInWithSpotifyFailure(
          'This user has been disabled. Please contact support for help.',
        );
      case 'user-not-found':
        return const LogInWithSpotifyFailure(
          'Email is not found, please create an account.',
        );
      case 'wrong-password':
        return const LogInWithSpotifyFailure(
          'Incorrect password, please try again.',
        );
      case 'invalid-verification-code':
        return const LogInWithSpotifyFailure(
          'The credential verification code received is invalid.',
        );
      case 'invalid-verification-id':
        return const LogInWithSpotifyFailure(
          'The credential verification ID received is invalid.',
        );
      default:
        return const LogInWithSpotifyFailure();
    }
  }

  final String message;
}

class LogInWithGoogleFailure implements Exception {
  const LogInWithGoogleFailure([
    this.message = 'An unknown exception occurred.',
  ]);

  /// Create an authentication message
  /// from a firebase authentication exception code.
  factory LogInWithGoogleFailure.fromCode(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return const LogInWithGoogleFailure(
          'Account exists with different credentials.',
        );
      case 'invalid-credential':
        return const LogInWithGoogleFailure(
          'The credential received is malformed or has expired.',
        );
      case 'operation-not-allowed':
        return const LogInWithGoogleFailure(
          'Operation is not allowed.  Please contact support.',
        );
      case 'user-disabled':
        return const LogInWithGoogleFailure(
          'This user has been disabled. Please contact support for help.',
        );
      case 'user-not-found':
        return const LogInWithGoogleFailure(
          'Email is not found, please create an account.',
        );
      case 'wrong-password':
        return const LogInWithGoogleFailure(
          'Incorrect password, please try again.',
        );
      case 'invalid-verification-code':
        return const LogInWithGoogleFailure(
          'The credential verification code received is invalid.',
        );
      case 'invalid-verification-id':
        return const LogInWithGoogleFailure(
          'The credential verification ID received is invalid.',
        );
      default:
        return const LogInWithGoogleFailure();
    }
  }

  final String message;
}

class LogOutFailure implements Exception {}

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
          final spotifyAccessToken = SpotifyAccessToken(accessToken: await getSpotifyAccessToken());
          _cache.write(key: spotifyCacheKey, value: spotifyAccessToken);
          return spotifyAccessToken;
        } else {
          return SpotifyAccessToken.empty;
        }
      });
    } catch (e) {
      return Stream.fromIterable([SpotifyAccessToken.empty]);
    }
  }

  Stream<ConnectionStatus> get connectionStatus {
    return SpotifySdk.subscribeConnectionStatus().asyncMap((connectionStatus) async {
      print("========>" + jsonEncode(connectionStatus));
      return connectionStatus;
    });
  }

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
      redirectUrl: "http://mysite.com/callback",
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
        redirectUrl: "http://mysite.com/callback",
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

      SpotifySdk.connectToSpotifyRemote(
        clientId: 'b9a4881e77f4488eb882788cb106a297',
        redirectUrl: 'http://mysite.com/callback',
        accessToken: accessToken,
      );

      // _storage.delete(key: spotifyCacheKey);
      // _storage.write(key: spotifyCacheKey, value: accessToken);
      // _cache.write<SpotifyAccessToken>(key: spotifyCacheKey, value: SpotifyAccessToken(accessToken: accessToken));
    } on FirebaseAuthException catch (e) {
      throw LogInWithSpotifyFailure.fromCode(e.code);
    } catch (_) {
      throw const LogInWithSpotifyFailure();
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
