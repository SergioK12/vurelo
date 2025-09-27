part of 'search_cubit.dart';

abstract class SearchState extends Equatable {}

class SearchInitial extends SearchState {

  @override
  List<Object?> get props => [];
}

class SearchLoading extends SearchState {

  @override
  List<Object?> get props => [];
}

class SearchLoaded extends SearchState {
  SearchLoaded(this.movies);

  final List<Movie> movies;

  @override
  List<Object?> get props => [movies];
}

class SearchError extends SearchState {
  SearchError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
