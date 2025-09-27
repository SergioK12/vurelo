part of 'cast_cubit.dart';

enum CastStatus { initial, loading, loaded, error }

class CastState extends Equatable {
  final CastStatus status;
  final List<Cast> cast;
  final String? message;

  const CastState({
    this.status = CastStatus.initial,
    this.cast = const [],
    this.message,
  });

  CastState copyWith({CastStatus? status, List<Cast>? cast, String? message}) =>
      CastState(
        status: status ?? this.status,
        cast: cast ?? this.cast,
        message: message,
      );

  @override
  List<Object?> get props => [status, cast, message];
}
