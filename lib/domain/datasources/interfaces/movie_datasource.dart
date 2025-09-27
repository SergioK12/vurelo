
abstract class MovieDatasource {
  Future<Map<String, dynamic>> getPopularMovies({int page = 1, bool useCachedData = false,});
  Future<Map<String, dynamic>> getTopRatedMovies({int page = 1, bool useCachedData = false,});
  Future<Map<String, dynamic>> getUpcomingMovies({int page = 1, bool useCachedData = false,});
  Future<Map<String, dynamic>> getForYouMovies({bool useCachedData = false});
  Future<Map<String, dynamic>> searchMovies({
    required String query,
    int page = 1,
    bool includeAdult = true,
    bool useCachedData = false,
  });
  Future<Map<String, dynamic>> getMovieTrailer(int movieId);
  Future<Map<String, dynamic>?> getFavorite(int movieId);
  Future<void> saveFavorite(Map<String, dynamic> movie);
  Future<void> removeFavorite(int movieId);
  Future<Map<String, dynamic>?> getFavorites();
  Future<List<Map<String, dynamic>>> getCredits(int movieId);
}
