import 'package:emovie/presentation/widgets/poster_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HorizontalMovieList extends StatelessWidget {
  final List<dynamic> movies;
  final bool isLoading;
  final bool hasMore;
  final VoidCallback onLoadMore;
  final VoidCallback? onRetry;
  final String? error;
  final String favoriteLabel;
  final EdgeInsetsGeometry padding;
  final Function(dynamic movie)? onToggleFavorite;

  const HorizontalMovieList({
    super.key,
    required this.movies,
    required this.isLoading,
    required this.hasMore,
    required this.onLoadMore,
    this.onRetry,
    this.error,
    this.favoriteLabel = 'Fav',
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    if (error != null && movies.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(error!, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      );
    }
    if (movies.isEmpty && isLoading) {
      return ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemBuilder: (_, i) => _SkeletonCard(index: i),
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: 6,
      );
    }
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: padding,
      itemCount: hasMore ? movies.length : movies.length + 1,
      itemBuilder: (context, index) {
        if (!hasMore && index == movies.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('No hay más'),
            ),
          );
        }
        final movie = movies[index];
        if (index == movies.length - 4 && !isLoading && hasMore) {
          onLoadMore();
        }
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Stack(
            children: [
              PosterCard(
                movieTitle: movie.title,
                imageUrl: movie.fullPosterUrl,
                favoriteLabel: favoriteLabel,
                onTap: () => context.push('/movie', extra: movie),
                onToggleFavorite: null, // deshabilitamos menú interno para favoritos
                heroTag: 'poster-${movie.id}',
              ),
              if (onToggleFavorite != null)
                Positioned(
                  top: 6,
                  right: 6,
                  child: InkWell(
                    onTap: () => onToggleFavorite!(movie),
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
        );
      },
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final int index;
  const _SkeletonCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(milliseconds: 600),
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: baseColor.withValues(alpha:  0.4),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [baseColor.withValues(alpha: 0.25), baseColor.withValues(alpha: 0.6)],
          ),
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }
}
