import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:groupify/common/common.dart';

class VoteCounter extends StatelessWidget {
  const VoteCounter({Key? key, required this.track}) : super(key: key);

  final Track track;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: CircleAvatar(
        backgroundColor: track.voted ? Colors.transparent : Theme.of(context).colorScheme.primary,
        child: Text(
          track.votes.toString(),
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: track.voted ? Theme.of(context).colorScheme.primary : CupertinoColors.black,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
