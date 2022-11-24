import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:groupify/common/common.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class NowPlaying extends StatefulWidget {
  const NowPlaying({Key? key}) : super(key: key);

  @override
  State<NowPlaying> createState() => _NowPlayingState();
}

class _NowPlayingState extends State<NowPlaying> with TickerProviderStateMixin {
  late Animation<double> _myAnimation;
  late AnimationController _controller;
  late double _millisecondsElapsed;

  @override
  void initState() {
    super.initState();

    _millisecondsElapsed = 0;
    _controller = AnimationController(vsync: this, duration: Cte.defaultAnimationDuration);
    _myAnimation = CurvedAnimation(curve: Curves.linear, parent: _controller);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: SpotifySdk.subscribePlayerState(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.hasError) {
          return const SizedBox(height: 100, width: double.infinity, child: NowPlayingDummy());
        }

        final playerState = snapshot.data!;

        if (playerState.isPaused) _controller.reverse();
        if (!playerState.isPaused) _controller.forward();
        _millisecondsElapsed = playerState.playbackPosition.toDouble();

        return SizedBox(
          height: 100,
          width: double.infinity,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: SizedBox(width: 100, child: SpotifyImageBuilder(imageUri: playerState.track!.imageUri)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AutoSizeText(
                                playerState.track!.name,
                                style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                                maxLines: 2,
                                minFontSize: 15,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                playerState.track!.artists.map((e) => e.name).join(', '),
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                            onPressed: () async {
                              if (playerState.isPaused) {
                                _controller.forward();
                                await SpotifySdk.resume();
                              } else {
                                _controller.reverse();
                                await SpotifySdk.pause();
                              }
                            },
                            icon: AnimatedIcon(icon: AnimatedIcons.play_pause, progress: _myAnimation),
                            iconSize: 32),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: StreamBuilder<int>(
                        stream: Stream<int>.periodic(const Duration(milliseconds: 150), (x) => 150),
                        builder: (context, periodicSnapshot) {
                          if (periodicSnapshot.hasData) {
                            if (!playerState.isPaused) {
                              _millisecondsElapsed += periodicSnapshot.data!.toDouble();
                            }
                          }

                          return LinearProgressIndicator(
                            minHeight: 6,
                            value: _millisecondsElapsed / (playerState.track!.duration - 2000),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class NowPlayingDummy extends StatelessWidget {
  const NowPlayingDummy({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: SizedBox(
            width: 100,
            child: Container(),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Loading...',
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text('p4ssenger', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.play_arrow_rounded), iconSize: 32),
                ],
              ),
              const Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: const LinearProgressIndicator(minHeight: 6),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
