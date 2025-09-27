
import 'package:emovie/domain/datasources/interfaces/movie_datasource.dart';
import 'package:emovie/domain/models/cast.dart';
import 'package:emovie/domain/models/movie.dart';
import 'package:emovie/domain/models/trailer.dart';
import 'package:emovie/domain/responses/movie_response.dart';
import 'package:emovie/domain/responses/trailer_response.dart';

class MovieRepository {
  MovieRepository(this.datasource);

  final MovieDatasource datasource;

  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    final response = await datasource.getPopularMovies(page: page);
    final results = MovieResponse.fromJson(response);
    return _attachFavorites(results.results);
  }

  Future<(List<Movie> movies, int totalPages)> getPopularMoviesWithTotal({int page = 1}) async {
    final response = await datasource.getPopularMovies(page: page);
    final results = MovieResponse.fromJson(response);
    final movies = await _attachFavorites(results.results);
    return (movies, results.totalPages);
  }


  Future<List<Movie>> getTopRatedMovies({int page = 1}) async {
    final response = await datasource.getTopRatedMovies(page: page);
    final results = MovieResponse.fromJson(response);
    return _attachFavorites(results.results);
  }

  Future<(List<Movie> movies, int totalPages)> getTopRatedMoviesWithTotal({int page = 1}) async {
    final response = await datasource.getTopRatedMovies(page: page);
    final results = MovieResponse.fromJson(response);
    final movies = await _attachFavorites(results.results);
    return (movies, results.totalPages);
  }

  Future<List<Movie>> getUpcomingMovies({int page = 1}) async {
    final response = await datasource.getUpcomingMovies(page: page);
    final results = MovieResponse.fromJson(response);
    return _attachFavorites(results.results);
  }

  Future<(List<Movie> movies, int totalPages)> getUpcomingMoviesWithTotal({int page = 1}) async {
    final response = await datasource.getUpcomingMovies(page: page);
    final results = MovieResponse.fromJson(response);
    final movies = await _attachFavorites(results.results);
    return (movies, results.totalPages);
  }

  Future<List<Movie>> getForYouMovies() async {
    final response = await datasource.getForYouMovies();
    final results = MovieResponse.fromJson(response);
    return _attachFavorites(results.results);
  }

  Future<List<Movie>> searchMovies({
    required String query,
    int page = 1,
    bool includeAdult = true,
  }) async {
    final response = await datasource.searchMovies(
      query: query,
      page: page,
      includeAdult: includeAdult,
    );
    final results = MovieResponse.fromJson(response);
    return results.results;
  }

  Future<void> saveFavorite(Movie movie) async {
    await datasource.saveFavorite(movie.copyWith(isFavorite: true).toJson());
  }

  Future<void> removeFavorite(int movieId) async {
    await datasource.removeFavorite(movieId);
  }

  Future<List<Movie>> getFavorites() async {
    final response = await datasource.getFavorites();
    if (response == null) return [];
    return response.values.map((movieRawData) {
      final movie = Movie.fromJson(Map<String, dynamic>.from(movieRawData));
      return movie;
    }).toList();
  }

  Future<List<Cast>> fetchMovieCast(int movieId) async {
    final raw = await datasource.getCredits(movieId);
    final cast = raw
        .map(
          (e) => Cast(
            id: e['id'],
            name: e['name'] ?? '',
            character: e['character'],
            profilePath: e['profile_path'],
          ),
        )
        .toList();
    return cast;
  }

  Future<Trailer> fetchMovieTrailer(int movieId) async {
    final result = await datasource.getMovieTrailer(movieId);
    final response = TrailersResponse.fromJson(result);

    final trailer = response.results.firstWhere(
      (trailer) => trailer.site.toLowerCase() == 'youtube' && trailer.type.toLowerCase() == 'trailer'
    );

    return trailer;
  }

  Future<List<Movie>> _attachFavorites(List<Movie> movies) async {
    final result = <Movie>[];

    for (final movie in movies) {
      final fav = await datasource.getFavorite(movie.id);
      result.add(movie.copyWith(isFavorite: fav != null));
    }
    return result;
  }

}
