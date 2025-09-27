import 'package:emovie/domain/models/movie.dart';
import 'package:emovie/presentation/cubits/cast/cast_cubit.dart';
import 'package:emovie/presentation/cubits/trailers/trailers_cubit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MovieDetailView extends StatefulWidget {
  final Movie movie;
  const MovieDetailView({super.key, required this.movie});

  @override
  State<MovieDetailView> createState() => _MovieDetailViewState();
}

class _MovieDetailViewState extends State<MovieDetailView> {
  @override
  void initState() {
    super.initState();
    context.read<CastCubit>().load(widget.movie.id);
    context.read<TrailersCubit>().fetchTrailers(widget.movie.id);
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: _BackdropImage(url: movie.fullBackdropUrl)),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: size.height * 0.5,
            child: const _BottomGradient(),
          ),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => context.pop(),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                expandedHeight: size.height * 0.6,
                automaticallyImplyLeading: false,
                pinned: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 30,
                        child: _PosterAndMeta(movie: movie),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _GenresChips(genreIds: movie.genreIds),
                      const SizedBox(height: 22),
                      _SectionTitle('Movie Plot', theme: theme),
                      const SizedBox(height: 10),
                      Text(
                        movie.overview.isNotEmpty
                            ? movie.overview
                            : 'Sin sinopsis disponible.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _SectionTitle('Cast', theme: theme),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 190,
                        child: BlocBuilder<CastCubit, CastState>(
                          builder: (context, state) {
                            switch (state.status) {
                              case CastStatus.initial:
                              case CastStatus.loading:
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              case CastStatus.error:
                                return Center(
                                  child: Text(
                                    state.message ?? 'Error',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                );
                              case CastStatus.loaded:
                                if (state.cast.isEmpty) {
                                  return const Center(
                                    child: Text(
                                      'Sin reparto',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  );
                                }
                                return ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: state.cast.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 14),
                                  itemBuilder: (c, i) {
                                    final cast = state.cast[i];
                                    return SizedBox(
                                      width: 100,
                                      child: Column(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              50,
                                            ),
                                            child: Image.network(
                                              cast.fullProfileUrl,
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                              errorBuilder: (c, e, s) => Center(
                                                child: Icon(
                                                  Icons.wifi_off,
                                                  color: Colors.white54,
                                                  size: 64,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            cast.name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(color: Colors.white),
                                          ),
                                          if (cast.character != null)
                                            Text(
                                              cast.character!,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: Colors.white70,
                                                    fontSize: 10,
                                                  ),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 34),
                      _SectionTitle('Info', theme: theme),
                      const SizedBox(height: 10),
                      _InfoRow(
                        label: 'Original Title',
                        value: movie.originalTitle,
                      ),
                      _InfoRow(
                        label: 'Language',
                        value: movie.originalLanguage.toUpperCase(),
                      ),
                      _InfoRow(label: 'Release', value: movie.releaseDate),
                      _InfoRow(
                        label: 'Rating',
                        value: movie.voteAverage.toStringAsFixed(1),
                      ),
                      const SizedBox(height: 70),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PosterAndMeta extends StatelessWidget {
  final Movie movie;
  const _PosterAndMeta({required this.movie});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Hero(
            tag: 'poster-${movie.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: SizedBox(
                width: size.width * 0.44,
                height: size.height * 0.44,
                child: Image.network(movie.fullPosterUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => Center(
                  child: Icon(Icons.wifi_off, color: Colors.white54, size: 64),
                )),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                    letterSpacing: .5,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: Colors.amber.shade400,
                      size: 26,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      movie.voteAverage.toStringAsFixed(1),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '(${movie.voteCount})',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _TrailerButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrailerButton extends StatelessWidget {
  const _TrailerButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: BlocBuilder<TrailersCubit, TrailersState>(
        builder: (context, state) {
          if (state is TrailersLoading) {
            return OutlinedButton(
              onPressed: null,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                backgroundColor: Colors.white.withValues(alpha: 0.07),
              ),
              child: const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            );
          }

          if (state is TrailersLoaded) {
            return OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                backgroundColor: Colors.white.withValues(alpha: 0.07),
              ),
              onPressed: () async {
                final trailer = state.trailer;
                final url = Uri.parse(
                  "https://www.youtube.com/watch?v=${trailer.key}",
                );

                if (!await launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                    ) &&
                    context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("No se pudo abrir YouTube")),
                  );
                }
              },
              child: const Text('Ver trailer'),
            );
          }

          return OutlinedButton(
            onPressed: null,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              backgroundColor: Colors.white.withValues(alpha: 0.07),
            ),
            child: const Text('Trailer no disponible'),
          );
        },
      ),
    );
  }
}

class _BackdropImage extends StatelessWidget {
  final String url;
  const _BackdropImage({required this.url});
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.black, Colors.transparent, Colors.black],
        stops: [0, .35, 1],
      ).createShader(rect),
      blendMode: BlendMode.dstOut,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => Center(),
        loadingBuilder: (c, child, progress) {
          if (progress == null) return child;
          return Container(color: Colors.black12);
        },
      ),
    );
  }
}

class _BottomGradient extends StatelessWidget {
  const _BottomGradient();
  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black, Colors.black],
          stops: [0, .55, 1],
        ),
      ),
    );
  }
}

class _GenresChips extends StatelessWidget {
  final List<int> genreIds;
  const _GenresChips({required this.genreIds});
  static const Map<int, String> _knownGenres = {
    28: 'Action',
    12: 'Adventure',
    16: 'Animation',
    35: 'Comedy',
    80: 'Crime',
    18: 'Drama',
    10751: 'Family',
    14: 'Fantasy',
    27: 'Horror',
    9648: 'Mystery',
    878: 'Sci-Fi',
    53: 'Thriller',
    10749: 'Romance',
  };
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labels = genreIds
        .map((id) => _knownGenres[id] ?? '#$id')
        .take(5)
        .toList();
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        for (final g in labels)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24, width: 0.8),
            ),
            child: Text(
              g,
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: .3,
              ),
            ),
          ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final ThemeData theme;
  const _SectionTitle(this.text, {required this.theme});
  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: theme.textTheme.labelLarge?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.1,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 95,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white60,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
