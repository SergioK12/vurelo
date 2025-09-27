import 'package:emovie/domain/exceptions/offline_exception.dart';
import 'package:emovie/domain/models/movie.dart';
import 'package:emovie/domain/repositories/movie_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final MovieRepository repository;

  FavoritesBloc({required this.repository}) : super(const FavoritesInitial()) {
    on<LoadFavorites>(_onLoadFavorites);

    on<AddFavorite>(_onAddFavorite);

    on<RemoveFavorite>(_onRemoveFavorite);
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      emit(const FavoritesLoading());
      final movies = await repository.getFavorites();
      emit(FavoritesLoaded(movies: movies));
    } catch (e) {
      final msg = e is OfflineException ? 'Sin conexión. No se pudieron actualizar los favoritos.' : e.toString();
      emit(FavoritesError(message: msg, movies: const []));
    }
  }

  Future<void> _onAddFavorite(
    AddFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final currentMovies = state.movies;
      final allMovies = [...await repository.getPopularMovies(), ...await repository.getTopRatedMovies(), ...await repository.getUpcomingMovies()];
      final movie = allMovies.firstWhere((m) => m.id == event.movieId);

      await repository.saveFavorite(movie);
      final updatedMovies = List<Movie>.from(currentMovies)..add(movie.copyWith(isFavorite: true));
      emit(AddFavoriteSuccess(addedMovieId: event.movieId, movies: updatedMovies));
    } catch (e) {
      final msg = e is OfflineException ? 'Sin conexión. No se pudo añadir el favorito.' : e.toString();
      emit(FavoritesError(message: msg, movies: state.movies));
    }
  }

  Future<void> _onRemoveFavorite(
    RemoveFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      await repository.removeFavorite(event.movieId);
      final updatedMovies = state.movies.where((m) => m.id != event.movieId).toList();
      emit(RemoveFavoriteSuccess(removedMovieId: event.movieId, movies: updatedMovies));
    } catch (e) {
      final msg = e is OfflineException ? 'Sin conexión. No se pudo eliminar el favorito.' : e.toString();
      emit(FavoritesError(message: msg, movies: state.movies));
    }
  }
}
