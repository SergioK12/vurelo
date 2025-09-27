part of 'trailers_cubit.dart';

@immutable
sealed class TrailersState extends Equatable {
  const TrailersState();
}

final class TrailersInitial extends TrailersState {
  const TrailersInitial();

  @override
  List<Object?> get props => [];
}

final class TrailersLoading extends TrailersState {
  const TrailersLoading();

  @override
  List<Object?> get props => [];
}

final class TrailersLoaded extends TrailersState {
  const TrailersLoaded(this.trailer);

  final Trailer trailer;

  @override
  List<Object?> get props => [trailer];
}
