import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groupify/common/common.dart';
import 'package:groupify/root/root.dart';

class QueueTile extends StatelessWidget {
  const QueueTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rootCubit = BlocProvider.of<RootCubit>(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              'Queue',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const Spacer(),
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.queue_music_rounded),
            ),
            //const SizedBox(width: 8),
          ],
        ),
        const SizedBox(height: 8),
        FirestoreListView<Map<String, dynamic>>(
          physics: const NeverScrollableScrollPhysics(),
          pageSize: 10,
          query: FirebaseFirestore.instance
              .collection('rooms')
              .doc(rootCubit.state.readProperty<String>('room_id'))
              .collection('queue')
              .orderBy('created_at', descending: true),
          shrinkWrap: true,
          emptyBuilder: (context) => const Text('empty'),
          errorBuilder: (context, obj, st) => const Text('error'),
          itemBuilder: (context, snapshot) {
            Map<String, dynamic> json = snapshot.data();
            json['spotify_uri'] = snapshot.id;
            final firestoreTrack = FirestoreTrack.fromJson(json);

            return TrackRow(
              track: firestoreTrack,
              position: 1,
              key: ValueKey('${firestoreTrack.spotifyUri}row'),
            );
          },
        ),
      ],
    );
  }
}

/*
FirestoreListView<Map<String, dynamic>>(
                pageSize: 10,
                query: FirebaseFirestore.instance.collection('rooms'),
                shrinkWrap: true,
                emptyBuilder: (context) => const Text('empty'),
                errorBuilder: (context, obj, st) => const Text('error'),
                itemBuilder: (context, snapshot) {
                  Map<String, dynamic> user = snapshot.data();

                  return Text('Room name is ${user['name']}');
                },
              ),
 */
