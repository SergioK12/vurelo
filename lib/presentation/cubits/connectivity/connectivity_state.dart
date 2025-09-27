part of 'connectivity_cubit.dart';

class ConnectivityState extends Equatable {
  final bool isOnline;
  const ConnectivityState({required this.isOnline});
  const ConnectivityState.initial() : isOnline = true; // assume online initially

  ConnectivityState copyWith({bool? isOnline}) => ConnectivityState(isOnline: isOnline ?? this.isOnline);

  @override
  List<Object?> get props => [isOnline];
}
