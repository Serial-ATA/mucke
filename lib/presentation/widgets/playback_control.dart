import 'package:flutter/material.dart';

import 'next_button.dart';
import 'play_pause_button.dart';
import 'previous_button.dart';

class PlaybackControl extends StatelessWidget {
  const PlaybackControl({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Icon(Icons.repeat, size: 20.0),
          const PreviousButton(iconSize: 32.0),
          const PlayPauseButton(
            circle: true,
            iconSize: 52.0,
          ),
          const NextButton(iconSize: 32.0),
          Icon(Icons.shuffle, size: 20.0),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      ),
    );
  }
}
