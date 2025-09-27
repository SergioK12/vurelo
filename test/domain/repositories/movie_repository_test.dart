import 'package:emovie/domain/datasources/interfaces/movie_datasource.dart';
import 'package:emovie/domain/models/cast.dart';
import 'package:emovie/domain/models/movie.dart';
import 'package:emovie/domain/models/trailer.dart';
import 'package:emovie/domain/repositories/movie_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockMovieDatasource extends Mock implements MovieDatasource {}

void main() {
  late _MockMovieDatasource ds;
  late MovieRepository repo;

  setUpAll(() {
    registerFallbackValue(<int>[]);
  });

  setUp(() {
    ds = _MockMovieDatasource();
    repo = MovieRepository(ds);
  });

  Map<String, dynamic> movieJson(int id, {bool fav = false}) => {
        "adult": false,
        "backdrop_path": null,
        "genre_ids": [1, 2],
        "id": id,
        "original_language": "en",
        "original_title": "Title $id",
        "overview": "Overview $id",
        "popularity": 11.1,
        "poster_path": null,
        "release_date": "2024-01-01",
        "title": "Title $id",
        "video": false,
        "vote_average": 7.1,
        "vote_count": 10,
        if (fav) "is_favorite": true,
      };

  group('Favorites', () {
    test('getFavorites vacio devuelve []', () async {
      when(() => ds.getFavorites()).thenAnswer((_) async => null);
      final result = await repo.getFavorites();
      expect(result, isEmpty);
    });

    test('getFavorites retorna lista mapeada', () async {
      when(() => ds.getFavorites()).thenAnswer((_) async => {
            '1': movieJson(1, fav: true),
            '2': movieJson(2, fav: false),
          });
      final result = await repo.getFavorites();
      expect(result.length, 2);
      expect(result.first.id, 1);
      expect(result.first.isFavorite, true);
    });

    test('saveFavorite delega a datasource con isFavorite true', () async {
      when(() => ds.saveFavorite(any())).thenAnswer((_) async {});
      final movie = Movie.fromJson(movieJson(5));
      await repo.saveFavorite(movie);
  verify(() => ds.saveFavorite(any(that: predicate((m) {
    final map = (m as Map<String, dynamic>?);
    if (map == null) return false;
    return map['id'] == 5 && map['is_favorite'] == true;
      })))).called(1);
    });

    test('removeFavorite delega a datasource', () async {
      when(() => ds.removeFavorite(5)).thenAnswer((_) async {});
      await repo.removeFavorite(5);
      verify(() => ds.removeFavorite(5)).called(1);
    });
  });

  group('Popular with favorites flag', () {
    test('marca isFavorite según datasource.getFavorite', () async {
  when(() => ds.getPopularMovies(page: any(named: 'page'), useCachedData: any(named: 'useCachedData'))).thenAnswer((_) async => {
    'page': 1,
    'results': [movieJson(10), movieJson(11)],
    'total_pages': 3,
    'total_results': 2,
      });
      when(() => ds.getFavorite(10)).thenAnswer((_) async => movieJson(10, fav: true));
      when(() => ds.getFavorite(11)).thenAnswer((_) async => null);

      final (movies, totalPages) = await repo.getPopularMoviesWithTotal(page: 1);
      expect(totalPages, 3);
      final m10 = movies.firstWhere((m) => m.id == 10);
      final m11 = movies.firstWhere((m) => m.id == 11);
      expect(m10.isFavorite, true);
      expect(m11.isFavorite, false);
    });
  });

  group('Credits & Trailer', () {
    test('fetchMovieCast mapea correctamente', () async {
      when(() => ds.getCredits(77)).thenAnswer((_) async => [
            {"id": 1, "name": "Actor 1", "character": "Hero", "profile_path": "/a.png"},
            {"id": 2, "name": "Actor 2", "character": "Villain", "profile_path": null},
          ]);
      final cast = await repo.fetchMovieCast(77);
      expect(cast, isA<List<Cast>>());
      expect(cast.length, 2);
      expect(cast.first.name, 'Actor 1');
    });

    test('fetchMovieTrailer selecciona el trailer YouTube correcto', () async {
      when(() => ds.getMovieTrailer(88)).thenAnswer((_) async => {
            'id': 88,
            'results': [
              {"site": "YouTube", "type": "Teaser", "id": "t1", "key": "K1", "name": "Teaser", "published_at": "2024-01-01", "size": 1080, "official": false},
              {"site": "YouTube", "type": "Trailer", "id": "t2", "key": "K2", "name": "Trailer Oficial", "published_at": "2024-01-02", "size": 1080, "official": true},
              {"site": "Vimeo", "type": "Trailer", "id": "t3", "key": "K3", "name": "Otro", "published_at": "2024-01-03", "size": 720, "official": true},
            ],
          });
      final trailer = await repo.fetchMovieTrailer(88);
      expect(trailer, isA<Trailer>());
      expect(trailer.key, 'K2');
    });
  });
}
