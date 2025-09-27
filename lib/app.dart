import 'package:emovie/domain/datasources/tmdb_movie_datasource.dart';
import 'package:emovie/domain/repositories/movie_repository.dart';
import 'package:emovie/presentation/blocs/favorites_bloc/favorites_bloc.dart';
import 'package:emovie/presentation/blocs/movie_bloc/movie_bloc.dart';
import 'package:emovie/presentation/cubits/cast/cast_cubit.dart';
import 'package:emovie/presentation/cubits/connectivity/connectivity_cubit.dart';
import 'package:emovie/presentation/cubits/search/search_cubit.dart';
import 'package:emovie/presentation/cubits/trailers/trailers_cubit.dart';
import 'package:emovie/presentation/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EMovieApp extends StatelessWidget {
  const EMovieApp({super.key});
  static const apiKey = String.fromEnvironment(
    'TMDB_API_KEY',
    defaultValue: '',
  );

  @override
  Widget build(BuildContext context) {

    final movieRepo = MovieRepository(TMDBMovieDatasource(apiKey: apiKey));
    
    return MultiBlocProvider(
      providers: [
        BlocProvider<MovieBloc>(
          create: (_) =>
              MovieBloc(movieRepo),
        ),
        BlocProvider<FavoritesBloc>(
          create: (_) => FavoritesBloc(repository: movieRepo)
        ),
        BlocProvider<CastCubit>(
          create: (_) => CastCubit(
            movieRepository: movieRepo
          )
        ),
        BlocProvider<ConnectivityCubit>(
          create: (_) => ConnectivityCubit(),
        ),
        BlocProvider<TrailersCubit>(
          create: (_) => TrailersCubit(movieRepository: movieRepo)
        ),
        BlocProvider<SearchCubit>(
          create: (_) => SearchCubit(repository: movieRepo)
        )
      ],

      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Emovie',
        routerConfig: router,
      ),
    );
  }
}
