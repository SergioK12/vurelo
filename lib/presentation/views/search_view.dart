import 'package:emovie/presentation/blocs/favorites_bloc/favorites_bloc.dart';
import 'package:emovie/presentation/cubits/search/search_cubit.dart';
import 'package:emovie/presentation/widgets/simple_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final favoritesBloc = context.read<FavoritesBloc>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Buscar',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SearchBar(),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<SearchCubit, SearchState>(
                  builder: (context, state) {
                    if (state is SearchInitial) {
                      return Center(
                        child: Text(
                          'Escribe para buscar películas',
                          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white54),
                        ),
                      );
                    }
                    if (state is SearchLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is SearchError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.red),
                        ),
                      );
                    }
                    if (state is SearchLoaded) {
                      final movies = state.movies;
                      if (movies.isEmpty) {
                        return Center(
                          child: Text(
                            'No se encontraron resultados',
                            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white54),
                          ),
                        );
                      }
                      return GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 22,
                          childAspectRatio: .6,
                        ),
                        itemCount: movies.length,
                        itemBuilder: (context, index) {
                          final movie = movies[index];
                          return SimplePosterCard(
                            movie: movie,
                            favoritesBloc: favoritesBloc,
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      onChanged: (value) => context.read<SearchCubit>().onQueryChanged(value),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Buscar películas...',
        hintStyle: theme.textTheme.bodyMedium?.copyWith(color: Colors.white54),
        prefixIcon: const Icon(Icons.search, color: Colors.white54),
        filled: true,
        fillColor: Colors.white12,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
