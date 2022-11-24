part of 'root_page.dart';

class RootView extends StatefulWidget {
  const RootView({super.key, required this.title});

  final String title;

  @override
  State<RootView> createState() => _RootViewState();
}

class _RootViewState extends State<RootView> {
  int _counter = 0;
  bool enhance = false;

  static Future<void> _connectToSpotifyRemote(String accessToken) async {
    await SpotifySdk.connectToSpotifyRemote(
      clientId: 'b9a4881e77f4488eb882788cb106a297',
      redirectUrl: "http://mysite.com/callback",
      accessToken: accessToken,
    );
  }

  Future<void> _incrementCounter() async {
    final spotifyAccessToken = RepositoryProvider.of<AuthRepository>(context).currentSpotifyAccessToken;
    await _connectToSpotifyRemote(spotifyAccessToken.accessToken);
    setState(() {
      _counter++;
    });
  }

  final List<Track> tracks = [Track.random(), Track.random(), Track.random(), Track.random(), Track.random()];

  @override
  Widget build(BuildContext context) {
    tracks.sort((a, b) => -a.votes.compareTo(b.votes));
    // for (int i = 0; i < tracks.length; i++) {
    //   tracks[i].position = i + 1;
    // }
    // tracks.shuffle();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () async {
              BlocProvider.of<AppBloc>(context).add(AppLogoutRequested());
            },
            icon: const Icon(Icons.logout_rounded),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const BaseTile(
              margin: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
              child: NowPlaying(),
            ),
            BaseTile(
              margin: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'Queue',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(fontWeight: FontWeight.bold, color: Colors.white),
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
                  ListView.separated(
                    itemCount: tracks.length,
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return TrackRow(
                        track: tracks[index],
                        actions: [],
                        position: index + 1,
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 8),
                  ),
                ],
              ),
            ),
            SuggestionsTile(),
          ],
        ),
      ),
      floatingActionButton:
          FloatingActionButton(onPressed: _incrementCounter, tooltip: 'Skip', child: const Icon(Icons.search)
              // CustomAnimatedIcon(
              //   iconA: const Icon(Icons.skip_next_rounded, key: ValueKey('ia')),
              //   iconB: const Icon(Icons.people_rounded, key: ValueKey('ib')),
              //   showA: _counter % 2 == 1,
              // ),
              ),
    );
  }
}

/*
BaseTile(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Search', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    style: Theme.of(context).textTheme.bodyLarge,
                    textInputAction: TextInputAction.search,
                    suffix: IconButton(onPressed: () {}, icon: const Icon(Icons.clear)),
                  ),
                  //FormzTextInput<SearchCubit>(title: 'Search', propKey: 'query')
                ],
              ),
            ),
 */
