import 'package:emovie/domain/models/cast.dart';
import 'package:emovie/domain/repositories/movie_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'cast_state.dart';

class CastCubit extends Cubit<CastState> {
  final MovieRepository movieRepository;
  final Map<int, List<Cast>> _cache = {};

  CastCubit({required this.movieRepository}) : super(const CastState());

  Future<void> load(int movieId, {bool force = false}) async {
    if (!force && _cache.containsKey(movieId)) {
      emit(state.copyWith(status: CastStatus.loaded, cast: _cache[movieId]!));
      return;
    }
    emit(
      state.copyWith(status: CastStatus.loading, cast: const [], message: null),
    );
    try {
      final result = await movieRepository.fetchMovieCast(movieId);
      _cache[movieId] = result;
      emit(state.copyWith(status: CastStatus.loaded, cast: result));
    } catch (e) {
      emit(state.copyWith(status: CastStatus.error, message: e.toString()));
    }
  }
}
