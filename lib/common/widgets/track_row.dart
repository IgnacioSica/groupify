import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groupify/common/common.dart';

class TrackRow extends StatefulWidget {
  const TrackRow({Key? key, required this.track, required this.actions, required this.position}) : super(key: key);
  final Track track;
  final List<Widget> actions;
  final int position;

  @override
  State<TrackRow> createState() => _TrackRowState();
}

class _TrackRowState extends State<TrackRow> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(9),
      onTap: () {
        setState(() {
          widget.track.voted = !widget.track.voted;
          widget.track.votes += !widget.track.voted ? 1 : -1;
        });
      },
      child: Ink(
        height: 50,
        decoration: BoxDecoration(
          color: widget.position >= 0 && widget.position <= 3
              ? Theme.of(context).colorScheme.primary.withOpacity((0.30 / widget.position))
              : null,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Image.network(widget.track.album.images[0].url),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.track.name),
                  Text(widget.track.artists.map((e) => e.name).join(', '), style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Row(children: widget.actions),
            if (widget.track.votes > 0)
              IconButton(
                onPressed: () {
                  setState(() => widget.track.liked = !widget.track.liked);
                },
                visualDensity: VisualDensity.compact,
                icon: FaIcon(
                  widget.track.liked ? FontAwesomeIcons.heart : FontAwesomeIcons.solidHeart,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            if (widget.track.votes <= 0)
              IconButton(
                onPressed: () {},
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.remove_circle_outline_rounded,
                  size: 18,
                  color: CupertinoColors.destructiveRed,
                ),
              ),
            VoteCounter(track: widget.track),
          ],
        ),
      ),
    );
  }
}
