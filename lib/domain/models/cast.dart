import 'package:equatable/equatable.dart';

class Cast extends Equatable {
  final int id;
  final String name;
  final String? character;
  final String? profilePath;

  const Cast({
    required this.id,
    required this.name,
    this.character,
    this.profilePath,
  });

  String get fullProfileUrl => profilePath != null
      ? 'https://image.tmdb.org/t/p/w300$profilePath'
      : 'https://i.stack.imgur.com/GNhxO.png';

  @override
  List<Object?> get props => [id, name, character, profilePath];
}
