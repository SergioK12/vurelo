part of 'movie_bloc.dart';

@immutable
class MovieState extends Equatable {
  final List<Movie> popularMovies;
  final List<Movie> topRatedMovies;
  final List<Movie> upcomingMovies;
  final bool isLoadingPopular;
  final bool isLoadingTopRated;
  final bool isLoadingUpcoming;
  final bool hasMorePopular;
  final bool hasMoreTopRated;
  final bool hasMoreUpcoming;
  final String? errorPopular;
  final String? errorTopRated;
  final String? errorUpcoming;
  final int popularPage;
  final int topRatedPage;
  final int upcomingPage;
  final DateTime? lastPopularRequestAt;
  final DateTime? lastTopRatedRequestAt;
  final DateTime? lastUpcomingRequestAt;

  const MovieState({
    this.popularMovies = const [],
    this.topRatedMovies = const [],
    this.upcomingMovies = const [],
    this.isLoadingPopular = false,
    this.isLoadingTopRated = false,
    this.isLoadingUpcoming = false,
    this.hasMorePopular = true,
    this.hasMoreTopRated = true,
    this.hasMoreUpcoming = true,
    this.errorPopular,
    this.errorTopRated,
    this.errorUpcoming,
    this.popularPage = 1,
    this.topRatedPage = 1,
    this.upcomingPage = 1,
    this.lastPopularRequestAt,
    this.lastTopRatedRequestAt,
    this.lastUpcomingRequestAt,
  });

  MovieState copyWith({
    List<Movie>? popularMovies,
    List<Movie>? topRatedMovies,
    List<Movie>? upcomingMovies,
    bool? isLoadingPopular,
    bool? isLoadingTopRated,
    bool? isLoadingUpcoming,
    bool? hasMorePopular,
    bool? hasMoreTopRated,
    bool? hasMoreUpcoming,
    String? errorPopular,
    String? errorTopRated,
    String? errorUpcoming,
    int? popularPage,
    int? topRatedPage,
    int? upcomingPage,
    DateTime? lastPopularRequestAt,
    DateTime? lastTopRatedRequestAt,
    DateTime? lastUpcomingRequestAt,
    bool clearPopularError = false,
    bool clearTopRatedError = false,
    bool clearUpcomingError = false,
  }) {
    return MovieState(
      popularMovies: popularMovies ?? this.popularMovies,
      topRatedMovies: topRatedMovies ?? this.topRatedMovies,
      upcomingMovies: upcomingMovies ?? this.upcomingMovies,
      isLoadingPopular: isLoadingPopular ?? this.isLoadingPopular,
      isLoadingTopRated: isLoadingTopRated ?? this.isLoadingTopRated,
      isLoadingUpcoming: isLoadingUpcoming ?? this.isLoadingUpcoming,
      hasMorePopular: hasMorePopular ?? this.hasMorePopular,
      hasMoreTopRated: hasMoreTopRated ?? this.hasMoreTopRated,
      hasMoreUpcoming: hasMoreUpcoming ?? this.hasMoreUpcoming,
      errorPopular: clearPopularError ? null : errorPopular ?? this.errorPopular,
      errorTopRated: clearTopRatedError ? null : errorTopRated ?? this.errorTopRated,
      errorUpcoming: clearUpcomingError ? null : errorUpcoming ?? this.errorUpcoming,
      popularPage: popularPage ?? this.popularPage,
      topRatedPage: topRatedPage ?? this.topRatedPage,
      upcomingPage: upcomingPage ?? this.upcomingPage,
      lastPopularRequestAt: lastPopularRequestAt ?? this.lastPopularRequestAt,
      lastTopRatedRequestAt: lastTopRatedRequestAt ?? this.lastTopRatedRequestAt,
      lastUpcomingRequestAt: lastUpcomingRequestAt ?? this.lastUpcomingRequestAt,
    );
  }

  @override
  List<Object?> get props => [
        popularMovies,
        topRatedMovies,
        upcomingMovies,
        isLoadingPopular,
        isLoadingTopRated,
        isLoadingUpcoming,
        hasMorePopular,
        hasMoreTopRated,
        hasMoreUpcoming,
        errorPopular,
        errorTopRated,
        errorUpcoming,
        popularPage,
        topRatedPage,
        upcomingPage,
        lastPopularRequestAt,
        lastTopRatedRequestAt,
        lastUpcomingRequestAt,
      ];
}
