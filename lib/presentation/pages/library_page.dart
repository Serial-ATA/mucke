import 'package:flutter/material.dart';

import '../state/music_store.dart';
import 'albums_page.dart';
import 'songs_page.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({Key key, @required this.store}) : super(key: key);

  final MusicStore store;

  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  @override
  Widget build(BuildContext context) {
    print('LibraryPage.build');
    return DefaultTabController(
      length: 3,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            const TabBar(
              tabs: <Tab>[
                Tab(
                  text: 'Artists',
                ),
                Tab(
                  text: 'Albums',
                ),
                Tab(
                  text: 'Songs',
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  const Center(
                    child: Text('Artists'),
                  ),
                  AlbumsPage(
                    key: const PageStorageKey('AlbumsPage'),
                    store: widget.store,
                  ),
                  SongsPage(
                    key: const PageStorageKey('SongsPage'),
                    store: widget.store,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}