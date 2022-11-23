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

  Future<void> _incrementCounter() async {
    setState(() {
      _counter++;
    });
    // await SpotifySdk.play(spotifyUri: '7ID9hY0L3R4GKtvUThHa0q');
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
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          // IconButton(
          //   onPressed: () async {
          //     await RepositoryProvider.of<AuthRepository>(context).logOut();
          //   },
          //   icon: const Icon(Icons.logout_rounded),
          // )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const BaseTile(
              margin: EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 8),
              child: NowPlaying(),
            ),
            BaseTile(
              margin: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Queue',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      ElevatedButton.icon(
                        key: const Key('connect_with_spotify_raisedButton'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: enhance ? Theme.of(context).colorScheme.primary : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        label: Text(
                          'Enhance',
                          style: enhance ? Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.black) : null,
                        ),
                        icon: Icon(CupertinoIcons.sparkles, color: enhance ? Colors.black : Colors.white),
                        onPressed: () {
                          setState(() {
                            enhance = !enhance;
                          });
                        },
                      ),
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Skip',
        child: CustomAnimatedIcon(
          iconA: const Icon(Icons.skip_next_rounded, key: ValueKey('ia')),
          iconB: const Icon(Icons.people_rounded, key: ValueKey('ib')),
          showA: _counter % 2 == 1,
        ),
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
