import 'dart:async';
import 'package:emovie/domain/models/movie.dart';
import 'package:emovie/domain/repositories/movie_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit({ required this.repository }) : super(SearchInitial());

  final MovieRepository repository;
  Timer? _debounce;

  void onQueryChanged(String query) {
    _debounce?.cancel();

    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    _debounce = Timer(const Duration(seconds: 2), () async {
      emit(SearchLoading());
      try {
        final movies = await repository.searchMovies(query: query);
        emit(SearchLoaded(movies));
      } catch (e) {
        emit(SearchError('Error buscando películas'));
      }
    });
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
