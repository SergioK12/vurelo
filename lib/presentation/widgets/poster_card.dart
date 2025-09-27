import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PosterCard extends StatelessWidget {
  final String movieTitle;
  final String imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onViewDetails;
  final String favoriteLabel;
  final String? heroTag;

  const PosterCard({
    super.key,
    required this.movieTitle,
    required this.imageUrl,
    required this.favoriteLabel,
    this.onTap,
    this.onToggleFavorite,
    this.onViewDetails,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 140,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: heroTag == null
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
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
                          )
                        : Hero(
                            tag: heroTag!,
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
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
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              movieTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
