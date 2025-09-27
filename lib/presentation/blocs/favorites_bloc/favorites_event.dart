part of 'favorites_bloc.dart';

@immutable
sealed class FavoritesEvent extends Equatable {}

class AddFavorite extends FavoritesEvent {
  final int movieId;
  AddFavorite({required this.movieId});
  @override
  List<Object?> get props => [movieId];
}

class RemoveFavorite extends FavoritesEvent {
  final int movieId;
  RemoveFavorite({required this.movieId});
  @override
  List<Object?> get props => [movieId];
}

class LoadFavorites extends FavoritesEvent {
  final bool force;
  LoadFavorites({this.force = false});
  @override
  List<Object?> get props => [force];
}
