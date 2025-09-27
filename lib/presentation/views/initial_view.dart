import 'package:emovie/presentation/blocs/favorites_bloc/favorites_bloc.dart';
import 'package:emovie/presentation/blocs/movie_bloc/movie_bloc.dart';
import 'package:emovie/presentation/cubits/connectivity/connectivity_cubit.dart';
import 'package:emovie/presentation/widgets/horitontal_section.dart';
import 'package:emovie/presentation/widgets/offline_banner.dart';
import 'package:emovie/presentation/widgets/simple_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InitialView extends StatefulWidget {
  const InitialView({super.key});

  @override
  State<InitialView> createState() => _InitialViewState();
}

class _InitialViewState extends State<InitialView> {
  String? _yearFilter; // ejemplo: '2025'
  bool _onlySpanish = false;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<MovieBloc>();
    if (bloc.state.upcomingMovies.isEmpty) {
      bloc.add(const LoadNextUpcomingPage());
    }
    if (bloc.state.topRatedMovies.isEmpty) {
      bloc.add(const LoadNextTopRatedPage());
    }
    if (bloc.state.popularMovies.isEmpty) {
      bloc.add(const LoadNextPopularPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    final movieBloc = context.read<MovieBloc>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'eMovie',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: .5,
            color: Colors.red
          ),
          
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            movieBloc.add(const RefreshPopularMovies());
            movieBloc.add(const LoadNextTopRatedPage(force: true));
            movieBloc.add(const LoadNextUpcomingPage(force: true));
          },
          color: Colors.white,
          backgroundColor: Colors.black87,
          child: MultiBlocListener(
            listeners: [
              BlocListener<FavoritesBloc, FavoritesState>(
                listener: (context, state) {
                  if (state is AddFavoriteSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Película añadida a favoritos')),
                    );
                    movieBloc.add(UpdateMovieFavoriteStatus(movieId: state.addedMovieId, isFavorite: true));
                  }
                  if (state is RemoveFavoriteSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Película eliminada de favoritos')),
                    );
                    movieBloc.add(UpdateMovieFavoriteStatus(movieId: state.removedMovieId, isFavorite: false));
                  }
                },
              )
            ],
            child: CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverToBoxAdapter(
                child: BlocBuilder<ConnectivityCubit, ConnectivityState>(
                  builder: (context, state) {
                    if (!state.isOnline) return const OfflineBanner();
                    return const SizedBox.shrink();
                  },
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _SectionBlock(
                      title: 'Próximos estrenos',
                      list: BlocBuilder<MovieBloc, MovieState>(
                        builder: (context, state) {
                          return SizedBox(
                            height: 230,
                            child: HorizontalMovieList(
                              movies: state.upcomingMovies,
                              isLoading: state.isLoadingUpcoming,
                              hasMore: state.hasMoreUpcoming,
                              error: state.errorUpcoming,
                              onRetry: () => movieBloc.add(const LoadNextUpcomingPage()),
                              onLoadMore: () => movieBloc.add(const LoadNextUpcomingPage()),
                              onToggleFavorite: (movie) {
                                final favBloc = context.read<FavoritesBloc>();
                                if (movie.isFavorite) {
                                  favBloc.add(RemoveFavorite(movieId: movie.id));
                                } else {
                                  favBloc.add(AddFavorite(movieId: movie.id));
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 4),
                    _SectionBlock(
                      title: 'Tendencia',
                      list: BlocBuilder<MovieBloc, MovieState>(
                        builder: (context, state) {
                          return SizedBox(
                            height: 230,
                            child: HorizontalMovieList(
                              movies: state.topRatedMovies, // reutilizamos top rated como "tendencia"
                              isLoading: state.isLoadingTopRated,
                              hasMore: state.hasMoreTopRated,
                              error: state.errorTopRated,
                              onRetry: () => movieBloc.add(const LoadNextTopRatedPage()),
                              onLoadMore: () => movieBloc.add(const LoadNextTopRatedPage()),
                              onToggleFavorite: (movie) {
                                final favBloc = context.read<FavoritesBloc>();
                                if (movie.isFavorite) {
                                  favBloc.add(RemoveFavorite(movieId: movie.id));
                                } else {
                                  favBloc.add(AddFavorite(movieId: movie.id));
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Recomendadas para ti',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFilters(theme),
                    const SizedBox(height: 12),
                  ]),
                ),
              ),
              // Grid de recomendadas (usamos populares con filtros simulados)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: BlocBuilder<MovieBloc, MovieState>(
                  builder: (context, state) {
                    var movies = state.popularMovies.take(6).toList();
                    // Filtros simples de ejemplo (no se hace otra petición, solo filtrado local)
                    if (_onlySpanish) {
                      movies = movies.where((m) => m.originalLanguage == 'es').toList();
                    }
                    if (_yearFilter != null) {
                      movies = movies.where((m) => m.releaseDate.startsWith(_yearFilter!)).toList();
                    }
                    if (movies.isEmpty && state.isLoadingPopular) {
                      return const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == movies.length - 6 && state.hasMorePopular && !state.isLoadingPopular) {
                            movieBloc.add(const LoadNextPopularPage());
                          }
                          final movie = movies[index];
                          final favoritesBloc = context.read<FavoritesBloc>();
                          return SimplePosterCard(movie: movie, favoritesBloc: favoritesBloc);
                        },
                        childCount: movies.length,
                      ),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 22,
                        childAspectRatio: .6,
                      ),
                    );
                  },
                ),
              )
            ],
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(ThemeData theme) {
    final chipStyle = theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500);
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        FilterChip(
          selected: _onlySpanish,
          label: Text('En español', style: chipStyle),
          onSelected: (val) => setState(() => _onlySpanish = val),
          selectedColor: Colors.white,
          backgroundColor: Colors.white10,
          checkmarkColor: Colors.black,
          labelStyle: TextStyle(color: _onlySpanish ? Colors.black : Colors.white),
        ),
        FilterChip(
          selected: _yearFilter == '2024',
          label: Text('Lanzadas en 2024', style: chipStyle),
          onSelected: (val) => setState(() => _yearFilter = val ? '2024' : null),
          selectedColor: Colors.white,
          backgroundColor: Colors.white10,
          checkmarkColor: Colors.black,
          labelStyle: TextStyle(color: _yearFilter == '2024' ? Colors.black : Colors.white),
        ),
      ],
    );
  }
}

class _SectionBlock extends StatelessWidget {
  final String title;
  final Widget list;
  const _SectionBlock({required this.title, required this.list});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 12),
        list,
        const SizedBox(height: 20),
      ],
    );
  }
}
