import 'package:emovie/domain/models/trailer.dart';
import 'package:emovie/domain/repositories/movie_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'trailers_state.dart';

final class TrailersCubit extends Cubit<TrailersState> {
  TrailersCubit({
    required this.movieRepository,
  }) : super(const TrailersInitial());

  final MovieRepository movieRepository;

  Future<void> fetchTrailers(int movieId) async {
    emit(const TrailersLoading());
    try {
      final trailer = await movieRepository.fetchMovieTrailer(movieId);
      emit(TrailersLoaded(trailer));
    } catch (e) {
      emit(const TrailersInitial());
    }
  }
}
