import 'dart:io';

import 'package:moor/moor.dart';
import 'package:moor_ffi/moor_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/album_model.dart';
import 'music_data_source_contract.dart';

part 'moor_music_data_source.g.dart';

@DataClassName('MoorAlbum')
class Albums extends Table {
  TextColumn get title => text()();
  TextColumn get artist => text()();
  TextColumn get albumArtPath => text().nullable()();
  IntColumn get year => integer().nullable()();

  @override
  Set<Column> get primaryKey => {title, artist, year};
}

@UseMoor(tables: [Albums])
class MoorMusicDataSource extends _$MoorMusicDataSource
    implements MusicDataSource {
  MoorMusicDataSource() : super(_openConnection());
  MoorMusicDataSource.withQueryExecutor(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  @override
  Future<List<AlbumModel>> getAlbums() async {
    return select(albums).get().then((moorAlbumList) => moorAlbumList
        .map((moorAlbum) => AlbumModel.fromMoor(moorAlbum))
        .toList());
  }

  // TODO: insert can throw exception -> implications?
  // TODO: use companion instead: https://moor.simonbinder.eu/docs/getting-started/writing_queries/
  @override
  Future<void> insertAlbum(AlbumModel albumModel) async {
    await into(albums).insert(albumModel.toMoor());
    return;
  }

  @override
  Future<bool> albumExists(AlbumModel albumModel) async {
    final List<AlbumModel> albumList = await getAlbums();
    return albumList.contains(albumModel);
  }
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final Directory dbFolder = await getApplicationDocumentsDirectory();
    final File file = File(p.join(dbFolder.path, 'db.sqlite'));
    return VmDatabase(file);
  });
}
