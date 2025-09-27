part of 'favorites_bloc.dart';

@immutable
sealed class FavoritesState extends Equatable {
  const FavoritesState({required this.movies});
  
  final List<Movie> movies;
}

class FavoritesInitial extends FavoritesState {
  const FavoritesInitial() : super(movies: const []);

  @override
  List<Object?> get props => [];
}

class FavoritesLoading extends FavoritesState {
  const FavoritesLoading() : super(movies: const []);
  
  @override
  List<Object?> get props => [movies];
}

class FavoritesLoaded extends FavoritesState {
  const FavoritesLoaded({required super.movies});
  
  @override
  List<Object?> get props => [movies];
}

class FavoritesError extends FavoritesState {
  const FavoritesError({required this.message, required super.movies});
  
  final String message;
  
  @override
  List<Object?> get props => [message, movies];
}

class AddFavoriteSuccess extends FavoritesState {
  const AddFavoriteSuccess({required this.addedMovieId, required super.movies});

  final int addedMovieId;
  
  @override
  List<Object?> get props => [movies, addedMovieId];
}

class RemoveFavoriteSuccess extends FavoritesState {
  const RemoveFavoriteSuccess({required this.removedMovieId, required super.movies});

  final int removedMovieId;
  
  @override
  List<Object?> get props => [movies, removedMovieId];
}

