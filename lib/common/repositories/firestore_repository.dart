import 'package:cache/cache.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:groupify/auth/auth.dart';
import 'package:groupify/common/common.dart';

class FirestoreRepository {
  FirestoreRepository(this._authRepository)
      : _instance = FirebaseFirestore.instance,
        _cache = CacheClient();

  final CacheClient _cache;
  final AuthRepository _authRepository;
  final FirebaseFirestore _instance;

  static const currentRoomCacheKey = '__current_token_cache_key__';

  Future<String> get currentRoom async {
    var currentRoom = _cache.read<String>(key: currentRoomCacheKey) ?? '';
    if (currentRoom.isEmpty) {
      currentRoom = await _currentRoom();
    }

    return currentRoom;
  }

  Future<String> _currentRoom() async {
    final user = await _instance.collection("users").doc(_authRepository.currentUser.id).get();
    final activeRoom = user.data()!['active_room'];
    _cache.write<String>(key: currentRoomCacheKey, value: activeRoom);

    return user.data()!['active_room'];
  }

  Future<void> changeVote(FirestoreTrack track) async {
    final voted = track.votes.contains(_authRepository.currentUser.id);
    if (voted) {
      await removeVote(await currentRoom, track.spotifyUri);
    } else {
      await addVote(await currentRoom, track.spotifyUri);
    }
  }

  Future<void> addVote(String roomId, String spotifyUri) async {
    final track = _instance.collection("rooms").doc(roomId).collection('queue').doc(spotifyUri);

    await track.update({
      "votes_count": FieldValue.increment(1),
      "votes": FieldValue.arrayUnion([_authRepository.currentUser.id]),
    });
  }

  Future<void> removeVote(String roomId, String spotifyUri) async {
    final track = _instance.collection("rooms").doc(roomId).collection('queue').doc(spotifyUri);

    await track.update({
      "votes_count": FieldValue.increment(-1),
      "votes": FieldValue.arrayRemove([_authRepository.currentUser.id]),
    });
  }

  Future<void> removeTrack(String spotifyUri) async {
    final track = _instance.collection("rooms").doc(await currentRoom).collection('queue').doc(spotifyUri);

    await track.delete();
  }
}
