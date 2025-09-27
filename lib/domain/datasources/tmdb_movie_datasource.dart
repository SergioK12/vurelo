import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:emovie/domain/exceptions/offline_exception.dart';
import 'package:emovie/services/hive_service.dart';
import 'package:emovie/services/http_service.dart';

import 'interfaces/movie_datasource.dart';

class TMDBMovieDatasource
    with HttpService, HiveService
    implements MovieDatasource {
  TMDBMovieDatasource({required this.apiKey, Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final String _baseUrl = 'https://api.themoviedb.org/3';
  final Map<String, String> _headers = {
    'Content-Type': 'application/json;charset=utf-8',
  };

  final String apiKey;
  final Connectivity _connectivity;
  final String favoriteMoviesBoxKey = "movies_favorites";

  Future<Map<String, dynamic>> _fetch(
    String hiveBox,
    String hiveKey,
    Future<Map<String, dynamic>> Function() apiCall, {
    bool useCachedData = true,
  }) async {
    // Determinar conectividad actual (rápido, no nos suscribimos)
    final connectivityResults = await _connectivity.checkConnectivity();
    final isOnline = connectivityResults.any(
      (r) =>
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.ethernet ||
          r == ConnectivityResult.vpn,
    );

    // Si está offline forzamos uso de cache aunque el caller haya pasado useCachedData = false
    final effectiveUseCache = useCachedData || !isOnline;

    if (effectiveUseCache) {
      final cached = await get(hiveBox, hiveKey);
      if (cached != null) return cached;
      // Si estamos offline y no hay cache devolvemos OfflineException directo para que capa superior maneje
      if (!isOnline) {
        throw const OfflineException();
      }
    }

    try {
      final data = await apiCall();
      // Guardamos siempre para que esté disponible offline luego
      await save(hiveBox, hiveKey, data);
      return data;
    } catch (e) {
      final cached = await get(hiveBox, hiveKey);
      if (cached != null) return cached;
      if (e is OfflineException) rethrow; // ya es offline
      rethrow; // otros errores HTTP
    }
  }

  @override
  Future<Map<String, dynamic>> getPopularMovies({
    int page = 1,
    bool useCachedData = false,
  }) {
    return _fetch(
      'movies_popular',
      'page_$page',
      () => getJson(
        '$_baseUrl/movie/popular',

        queryParams: {'api_key': apiKey, 'language': 'en-US', 'page': '$page'},
      ),
      useCachedData: useCachedData,
    );
  }

  @override
  Future<Map<String, dynamic>> getTopRatedMovies({
    int page = 1,
    bool useCachedData = false,
  }) {
    return _fetch(
      'movies_top_rated',
      'page_$page',
      () => getJson(
        '$_baseUrl/movie/top_rated',
        headers: _headers,
        queryParams: {'api_key': apiKey, 'language': 'en-US', 'page': '$page'},
      ),
      useCachedData: useCachedData,
    );
  }

  @override
  Future<Map<String, dynamic>> getUpcomingMovies({
    int page = 1,
    bool useCachedData = false,
  }) {
    return _fetch(
      'movies_upcoming',
      'page_$page',
      () => getJson(
        '$_baseUrl/movie/upcoming',
        headers: _headers,
        queryParams: {'api_key': apiKey, 'language': 'en-US', 'page': '$page'},
      ),
      useCachedData: useCachedData,
    );
  }

  @override
  Future<Map<String, dynamic>> getForYouMovies({bool useCachedData = false}) {
    return _fetch(
      'movies_for_you',
      'for_you',
      () => getJson(
        '$_baseUrl/trending/movie/day',
        headers: _headers,
        queryParams: {'api_key': apiKey, 'language': 'en-US'},
      ),
      useCachedData: useCachedData,
    );
  }

  @override
  Future<Map<String, dynamic>> searchMovies({
    required String query,
    int page = 1,
    bool includeAdult = true,
    bool useCachedData = false,
  }) {
    final hiveBox = 'movies_search';
    final hiveKey = '${query}_page_$page';
    return _fetch(
      hiveBox,
      hiveKey,
      () => getJson(
        '$_baseUrl/search/movie',
        headers: _headers,
        queryParams: {
          'api_key': apiKey,
          'query': query,
          'include_adult': includeAdult.toString(),
          'language': 'en-US',
          'page': '$page',
        },
      ),
      useCachedData: useCachedData,
    );
  }

  @override
  Future<Map<String, dynamic>> getMovieTrailer(int movieId) {
    return getJson(
      '$_baseUrl/movie/$movieId/videos?language=en-US',
      headers: _headers,
      queryParams: {'api_key': apiKey, 'language': 'en-US'},
    );
  }

  @override
  Future<Map<String, dynamic>?> getFavorite(int movieId) async {
    return await get(favoriteMoviesBoxKey, movieId.toString());
  }

  @override
  Future<void> saveFavorite(Map<String, dynamic> movie) async {
    if (!movie.containsKey('id')) {
      throw ArgumentError('Movie must have an "id" field');
    }
    final movieId = (movie['id'] is int)
        ? movie['id'].toString()
        : int.parse(movie['id'].toString()).toString();

    await save(favoriteMoviesBoxKey, movieId, movie);
  }

  @override
  Future<void> removeFavorite(int movieId) async {
    await delete(favoriteMoviesBoxKey, movieId.toString());
  }

  @override
  Future<Map<String, dynamic>?> getFavorites() async {
    return await getAll(favoriteMoviesBoxKey);
  }

  @override
  Future<List<Map<String, dynamic>>> getCredits(int movieId) {
    return getJson(
      '$_baseUrl/movie/$movieId/credits',
      headers: _headers,
      queryParams: {'api_key': apiKey, 'language': 'en-US'},
    ).then((data) {
      final cast = (data['cast'] as List).cast<Map<String, dynamic>>();
      return cast;
    });
  }
}
