import 'package:cached_network_image/cached_network_image.dart';
import 'package:emovie/domain/models/movie.dart';
import 'package:emovie/presentation/blocs/favorites_bloc/favorites_bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SimplePosterCard extends StatelessWidget {
  const SimplePosterCard({
    super.key,
    required this.movie,
    required this.favoritesBloc
  });

  final Movie movie;
  final FavoritesBloc favoritesBloc;

  @override
  Widget build(BuildContext context) {
    
    final theme = Theme.of(context);

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
                        width: double.infinity,
                        placeholder: (_, _) => const ColoredBox(
                          color: Colors.black12,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (_, _, _) => const ColoredBox(
                          color: Colors.grey,
                          child: Center(child: Icon(Icons.broken_image)),
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
                        favoritesBloc.add(RemoveFavorite(movieId: movie.id));
                      } else {
                        favoritesBloc.add(AddFavorite(movieId: movie.id));
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(
                        movie.isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: movie.isFavorite ? Colors.redAccent : Colors.white,
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
            style: theme.textTheme.labelSmall?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
