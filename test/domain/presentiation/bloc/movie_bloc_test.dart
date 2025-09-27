import 'package:bloc_test/bloc_test.dart';
import 'package:emovie/domain/exceptions/offline_exception.dart';
import 'package:emovie/domain/models/movie.dart';
import 'package:emovie/domain/repositories/movie_repository.dart';
import 'package:emovie/presentation/blocs/movie_bloc/movie_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late _MockMovieRepository mockRepo;
  late MovieBloc bloc;

  setUp(() {
    mockRepo = _MockMovieRepository();
    bloc = MovieBloc(mockRepo);
  });

  tearDown(() => bloc.close());

  Movie buildMovie(int id) => Movie(
        adult: false,
        backdropPath: null,
        genreIds: const [1, 2],
        id: id,
        originalLanguage: 'en',
        originalTitle: 'Title $id',
        overview: 'Overview',
        popularity: 10.0,
        posterPath: null,
        releaseDate: '2024-01-01',
        title: 'Title $id',
        video: false,
        voteAverage: 8.5,
        voteCount: 100,
        isFavorite: false,
      );

  group('MovieBloc popular movies', () {
    blocTest<MovieBloc, MovieState>(
      'emite loading y luego lista popular con incremento de página y hasMore=true',
      build: () {
        when(() => mockRepo.getPopularMoviesWithTotal(page: any(named: 'page')))
            .thenAnswer((_) async => ([buildMovie(1), buildMovie(2)], 5));
        return bloc;
      },
      act: (b) => b.add(const LoadNextPopularPage()),
      expect: () => [
        predicate<MovieState>((s) => s.isLoadingPopular == true && s.popularMovies.isEmpty),
        predicate<MovieState>((s) =>
            s.isLoadingPopular == false &&
            s.popularMovies.length == 2 &&
            s.popularPage == 2 &&
            s.hasMorePopular == true &&
            s.errorPopular == null),
      ],
      verify: (_) {
        verify(() => mockRepo.getPopularMoviesWithTotal(page: 1)).called(1);
      },
    );

    blocTest<MovieBloc, MovieState>(
      'no vuelve a cargar si ya está cargando',
      build: () {
        when(() => mockRepo.getPopularMoviesWithTotal(page: any(named: 'page')))
            .thenAnswer((_) async => ([buildMovie(1)], 1));
        return bloc;
      },
      act: (b) {
        b.add(const LoadNextPopularPage());
        b.add(const LoadNextPopularPage()); // segundo debe ignorarse mientras loading
      },
      expect: () => [
        predicate<MovieState>((s) => s.isLoadingPopular),
        predicate<MovieState>((s) => s.isLoadingPopular == false && s.popularMovies.length == 1),
      ],
      verify: (_) {
        verify(() => mockRepo.getPopularMoviesWithTotal(page: 1)).called(1);
      },
    );

    blocTest<MovieBloc, MovieState>(
      'maneja error offline mostrando mensaje',
      build: () {
        when(() => mockRepo.getPopularMoviesWithTotal(page: any(named: 'page')))
            .thenThrow(OfflineException());
        return bloc;
      },
      act: (b) => b.add(const LoadNextPopularPage()),
      expect: () => [
        predicate<MovieState>((s) => s.isLoadingPopular),
        predicate<MovieState>((s) => s.isLoadingPopular == false && s.errorPopular?.contains('Sin conexión') == true),
      ],
    );

    blocTest<MovieBloc, MovieState>(
      'refresh reinicia lista y vuelve a cargar',
      build: () {
        when(() => mockRepo.getPopularMoviesWithTotal(page: any(named: 'page')))
            .thenAnswer((invocation) async {
          final page = invocation.namedArguments[const Symbol('page')] as int? ?? 1;
          if (page == 1) return ([buildMovie(1)], 2);
          return ([buildMovie(2)], 2);
        });
        return bloc;
      },
      act: (b) async {
        b.add(const LoadNextPopularPage());
        await Future.delayed(const Duration(milliseconds: 10));
        b.add(const RefreshPopularMovies());
      },
      wait: const Duration(milliseconds: 50),
      expect: () => [
        // loading inicial
        predicate<MovieState>((s) => s.isLoadingPopular && s.popularMovies.isEmpty && s.popularPage == 1),
        // datos primer load
        predicate<MovieState>((s) => !s.isLoadingPopular && s.popularMovies.length == 1 && s.popularPage == 2),
        // refresh limpia (el nuevo load se debounced o aún no emitió antes del wait)
        predicate<MovieState>((s) => !s.isLoadingPopular && s.popularMovies.isEmpty && s.popularPage == 1),
      ],
    );
  });

  group('UpdateMovieFavoriteStatus', () {
    blocTest<MovieBloc, MovieState>(
      'carga listas y luego actualiza isFavorite en todas',
      build: () {
        when(() => mockRepo.getPopularMoviesWithTotal(page: any(named: 'page')))
            .thenAnswer((_) async => ([buildMovie(10)], 1));
        when(() => mockRepo.getTopRatedMoviesWithTotal(page: any(named: 'page')))
            .thenAnswer((_) async => ([buildMovie(10)], 1));
        when(() => mockRepo.getUpcomingMoviesWithTotal(page: any(named: 'page')))
            .thenAnswer((_) async => ([buildMovie(10)], 1));
        return bloc;
      },
      act: (b) async {
        b.add(const LoadNextPopularPage());
        b.add(const LoadNextTopRatedPage());
        b.add(const LoadNextUpcomingPage());
        await Future.delayed(const Duration(milliseconds: 30));
        b.add(const UpdateMovieFavoriteStatus(movieId: 10, isFavorite: true));
      },
      wait: const Duration(milliseconds: 120),
      expect: () => [
        // popular loading
        predicate<MovieState>((s) => s.isLoadingPopular),
        predicate<MovieState>((s) => s.popularMovies.length == 1 && !s.isLoadingPopular),
        // top rated loading
        predicate<MovieState>((s) => s.isLoadingTopRated),
        predicate<MovieState>((s) => s.topRatedMovies.length == 1 && !s.isLoadingTopRated),
        // upcoming loading
        predicate<MovieState>((s) => s.isLoadingUpcoming),
        predicate<MovieState>((s) => s.upcomingMovies.length == 1 && !s.isLoadingUpcoming),
        // favorite update
        predicate<MovieState>((s) =>
            s.popularMovies.first.isFavorite &&
            s.topRatedMovies.first.isFavorite &&
            s.upcomingMovies.first.isFavorite),
      ],
    );
  });
}
