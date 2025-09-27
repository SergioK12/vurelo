part of 'movie_bloc.dart';

@immutable
sealed class MovieEvent extends Equatable {
  const MovieEvent();
  @override
  List<Object?> get props => [];
}

class LoadNextPopularPage extends MovieEvent {
  final bool force;
  const LoadNextPopularPage({this.force = false});
  @override
  List<Object?> get props => [force];
}

class LoadNextTopRatedPage extends MovieEvent {
  final bool force;
  const LoadNextTopRatedPage({this.force = false});
  @override
  List<Object?> get props => [force];
}

class LoadNextUpcomingPage extends MovieEvent {
  final bool force;
  const LoadNextUpcomingPage({this.force = false});
  @override
  List<Object?> get props => [force];
}

class RefreshPopularMovies extends MovieEvent {
  const RefreshPopularMovies();
}

class UpdateMovieFavoriteStatus extends MovieEvent {
  const UpdateMovieFavoriteStatus({required this.movieId, required this.isFavorite});

  final int movieId;
  final bool isFavorite;

  @override
  List<Object?> get props => [movieId, isFavorite];
}
