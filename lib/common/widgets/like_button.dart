import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groupify/common/common.dart';
import 'package:spotify_sdk/models/library_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class LikeButton extends StatelessWidget {
  const LikeButton({Key? key, required this.spotifyUri, this.size = 18}) : super(key: key);
  final String spotifyUri;
  final double size;

  @override
  Widget build(BuildContext context) {
    final repo = RepositoryProvider.of<SpotifyRepository>(context);

    return FutureBuilder<LibraryState?>(
      future: SpotifySdk.getLibraryState(spotifyUri: spotifyUri),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && !snapshot.hasError && snapshot.hasData) {
          return LikeButtonWid(spotifyUri: spotifyUri, liked: snapshot.data!.isSaved, size: size);
        } else {
          return const DummyLikeButton();
        }
      },
    );
  }
}

class LikeButtonWid extends StatefulWidget {
  const LikeButtonWid({Key? key, required this.spotifyUri, required this.liked, this.size = 18}) : super(key: key);
  final String spotifyUri;
  final bool liked;
  final double size;

  @override
  State<LikeButtonWid> createState() => _LikeButtonWidState();
}

class _LikeButtonWidState extends State<LikeButtonWid> {
  late bool liked;

  @override
  void initState() {
    liked = widget.liked;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final repo = RepositoryProvider.of<SpotifyRepository>(context);

    return IconButton(
      key: const ValueKey('like_button'),
      onPressed: () async {
        if (liked) {
          await SpotifySdk.removeFromLibrary(spotifyUri: widget.spotifyUri);
          setState(() => liked = false);
        } else {
          await SpotifySdk.addToLibrary(spotifyUri: widget.spotifyUri);
          setState(() => liked = true);
        }
      },
      visualDensity: VisualDensity.compact,
      icon: FaIcon(
        liked ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
        size: widget.size,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class DummyLikeButton extends StatelessWidget {
  const DummyLikeButton({Key? key, this.size = 18}) : super(key: key);
  final double size;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const ValueKey('dummy_like_button'),
      onPressed: null,
      visualDensity: VisualDensity.compact,
      icon: FaIcon(FontAwesomeIcons.heart, size: size, color: Theme.of(context).colorScheme.primary),
    );
  }
}
