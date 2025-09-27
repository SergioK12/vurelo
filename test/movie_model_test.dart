import 'package:emovie/domain/models/movie.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Movie model', () {
    test('fromJson/toJson consistency', () {
      final json = {
        "adult": false,
        "backdrop_path": "/path.jpg",
        "genre_ids": [12, 18],
        "id": 42,
        "original_language": "en",
        "original_title": "Original",
        "overview": "Desc",
        "popularity": 123.4,
        "poster_path": "/poster.jpg",
        "release_date": "2024-05-20",
        "title": "My Movie",
        "video": false,
        "vote_average": 7.8,
        "vote_count": 999,
      };

      final movie = Movie.fromJson({...json});
      expect(movie.id, 42);
      expect(movie.isFavorite, false);

      final back = movie.toJson();
      expect(back['id'], 42);
      expect(back['is_favorite'], false);
      expect(back['genre_ids'], [12, 18]);
    });

    test('copyWith updates isFavorite only', () {
      final movie = Movie(
        adult: false,
        backdropPath: null,
        genreIds: const [],
        id: 1,
        originalLanguage: 'en',
        originalTitle: 'A',
        overview: 'B',
        popularity: 1,
        posterPath: null,
        releaseDate: '2024-01-01',
        title: 'A',
        video: false,
        voteAverage: 5,
        voteCount: 10,
        isFavorite: false,
      );

      final fav = movie.copyWith(isFavorite: true);
      expect(fav.isFavorite, true);
      expect(fav.id, movie.id);
    });
  });
}
