import 'package:emovie/presentation/blocs/favorites_bloc/favorites_bloc.dart';
import 'package:emovie/presentation/cubits/connectivity/connectivity_cubit.dart';
import 'package:emovie/presentation/widgets/error_section.dart';
import 'package:emovie/presentation/widgets/offline_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesBloc = context.read<FavoritesBloc>();

    if (favoritesBloc.state is FavoritesInitial) {
      favoritesBloc.add(LoadFavorites());
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Favoritos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: .5,
            color: Colors.red,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          favoritesBloc.add(LoadFavorites(force: true));
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: BlocBuilder<ConnectivityCubit, ConnectivityState>(
                builder: (context, connectivityState) {
                  if (!connectivityState.isOnline) {
                    return const OfflineBanner();
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            BlocBuilder<FavoritesBloc, FavoritesState>(
              builder: (context, state) {
                if (state is FavoritesLoading || state is FavoritesInitial) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (state is FavoritesError) {
                  return SliverFillRemaining(
                    child: ErrorSection(
                      message: state.message,
                      onRetry: () =>
                          favoritesBloc.add(LoadFavorites(force: true)),
                    ),
                  );
                }

                final movies = state.movies;

                if (movies.isEmpty) {
                  final isOnline = context
                      .read<ConnectivityCubit>()
                      .state
                      .isOnline;
                  return SliverFillRemaining(
                    child: Center(
                      child: Text(
                        isOnline
                            ? 'No tienes favoritos aún.\n¡Empieza a agregar algunos!'
                            : 'No hay favoritos guardados y estás sin conexión.\nAgrega cuando vuelvas a estar en línea.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.55,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final movie = movies[index];
                      return GestureDetector(
                        onTap: () => context.push('/movie', extra: movie),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Hero(
                                      tag: 'poster-${movie.id}',
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: CachedNetworkImage(
                                          imageUrl: movie.fullPosterUrl,
                                          fit: BoxFit.cover,
                                          placeholder: (_, __) =>
                                              const ColoredBox(
                                                color: Colors.black12,
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              ),
                                          errorWidget: (_, __, ___) =>
                                              const ColoredBox(
                                                color: Colors.grey,
                                                child: Center(
                                                  child: Icon(
                                                    Icons.broken_image,
                                                  ),
                                                ),
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: InkWell(
                                      onTap: () {
                                        if (movie.isFavorite) {
                                          favoritesBloc.add(
                                            RemoveFavorite(movieId: movie.id),
                                          );
                                        } else {
                                          favoritesBloc.add(
                                            AddFavorite(movieId: movie.id),
                                          );
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                        child: Icon(
                                          movie.isFavorite
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          size: 18,
                                          color: movie.isFavorite
                                              ? Colors.redAccent
                                              : Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              movie.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    }, childCount: movies.length),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
