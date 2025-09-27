import 'package:emovie/domain/exceptions/offline_exception.dart';
import 'package:emovie/domain/models/movie.dart';
import 'package:emovie/domain/repositories/movie_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'movie_event.dart';
part 'movie_state.dart';

class MovieBloc extends Bloc<MovieEvent, MovieState> {
  final MovieRepository movieRepository;

  MovieBloc(this.movieRepository) : super(const MovieState()) {
    on<LoadNextPopularPage>(_onLoadNextPopularPage);
    on<LoadNextTopRatedPage>(_onLoadNextTopRatedPage);
    on<LoadNextUpcomingPage>(_onLoadNextUpcomingPage);
    on<RefreshPopularMovies>(_onRefreshPopularMovies);
    on<UpdateMovieFavoriteStatus>(_onUpdateMovieFavoriteStatus);
  }

  Future<void> _onLoadNextPopularPage(
    LoadNextPopularPage event,
    Emitter<MovieState> emit,
  ) async {
    if (state.isLoadingPopular || !state.hasMorePopular) return;
    final now = DateTime.now();
    if (state.lastPopularRequestAt != null &&
        now.difference(state.lastPopularRequestAt!).inMilliseconds < 500) {
      return; // debounce
    }
    emit(
      state.copyWith(
        isLoadingPopular: true,
        clearPopularError: true,
        lastPopularRequestAt: now,
      ),
    );
    try {
      final (movies, totalPages) = await movieRepository
          .getPopularMoviesWithTotal(page: state.popularPage);
      final updated = List<Movie>.from(state.popularMovies)..addAll(movies);
      final hasMore = state.popularPage < totalPages;
      emit(
        state.copyWith(
          popularMovies: updated,
          isLoadingPopular: false,
          popularPage: state.popularPage + 1,
          hasMorePopular: hasMore,
        ),
      );
    } catch (e) {
      final msg = e is OfflineException ? 'Sin conexión. Mostrando datos almacenados si existen.' : e.toString();
      emit(state.copyWith(isLoadingPopular: false, errorPopular: msg));
    }
  }

  Future<void> _onRefreshPopularMovies(
    RefreshPopularMovies event,
    Emitter<MovieState> emit,
  ) async {
    emit(
      state.copyWith(
        popularMovies: [],
        popularPage: 1,
        hasMorePopular: true,
        clearPopularError: true,
      ),
    );
    add(const LoadNextPopularPage(force: true));
  }

  Future<void> _onLoadNextTopRatedPage(
    LoadNextTopRatedPage event,
    Emitter<MovieState> emit,
  ) async {
    if (state.isLoadingTopRated || !state.hasMoreTopRated) return;
    final now = DateTime.now();
    if (state.lastTopRatedRequestAt != null &&
        now.difference(state.lastTopRatedRequestAt!).inMilliseconds < 500) {
      return; // debounce
    }
    emit(
      state.copyWith(
        isLoadingTopRated: true,
        clearTopRatedError: true,
        lastTopRatedRequestAt: now,
      ),
    );
    try {
      final (movies, totalPages) = await movieRepository
          .getTopRatedMoviesWithTotal(page: state.topRatedPage);
      final updated = List<Movie>.from(state.topRatedMovies)..addAll(movies);
      final hasMore = state.topRatedPage < totalPages;
      emit(
        state.copyWith(
          topRatedMovies: updated,
          isLoadingTopRated: false,
          topRatedPage: state.topRatedPage + 1,
          hasMoreTopRated: hasMore,
        ),
      );
    } catch (e) {
      final msg = e is OfflineException ? 'Sin conexión. Mostrando datos almacenados si existen.' : e.toString();
      emit(
        state.copyWith(isLoadingTopRated: false, errorTopRated: msg),
      );
    }
  }

  Future<void> _onLoadNextUpcomingPage(
    LoadNextUpcomingPage event,
    Emitter<MovieState> emit,
  ) async {
    if (state.isLoadingUpcoming || !state.hasMoreUpcoming) return;
    final now = DateTime.now();
    if (state.lastUpcomingRequestAt != null &&
        now.difference(state.lastUpcomingRequestAt!).inMilliseconds < 500) {
      return; // debounce
    }
    emit(
      state.copyWith(
        isLoadingUpcoming: true,
        clearUpcomingError: true,
        lastUpcomingRequestAt: now,
      ),
    );
    try {
      final (movies, totalPages) = await movieRepository
          .getUpcomingMoviesWithTotal(page: state.upcomingPage);
      final updated = List<Movie>.from(state.upcomingMovies)..addAll(movies);
      final hasMore = state.upcomingPage < totalPages;
      emit(
        state.copyWith(
          upcomingMovies: updated,
          isLoadingUpcoming: false,
          upcomingPage: state.upcomingPage + 1,
          hasMoreUpcoming: hasMore,
        ),
      );
    } catch (e) {
      final msg = e is OfflineException ? 'Sin conexión. Mostrando datos almacenados si existen.' : e.toString();
      emit(
        state.copyWith(isLoadingUpcoming: false, errorUpcoming: msg),
      );
    }
  }

  void _onUpdateMovieFavoriteStatus(
      UpdateMovieFavoriteStatus event,
      Emitter<MovieState> emit,
      ) {
    Movie update(Movie m) => m.id == event.movieId ? m.copyWith(isFavorite: event.isFavorite) : m;
    emit(state.copyWith(
      popularMovies: state.popularMovies.map(update).toList(),
      topRatedMovies: state.topRatedMovies.map(update).toList(),
      upcomingMovies: state.upcomingMovies.map(update).toList(),
    ));
  }
}
