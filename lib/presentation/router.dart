import 'package:emovie/domain/models/movie.dart';
import 'package:emovie/presentation/views/detail_view.dart';
import 'package:emovie/presentation/views/favorites_view.dart';
import 'package:emovie/presentation/views/initial_view.dart';
import 'package:emovie/presentation/views/main_view.dart';
import 'package:emovie/presentation/views/search_view.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: "home_navigator_branch");
final _favoritesNavigatorKey = GlobalKey<NavigatorState>(debugLabel: "favorites_navigator_branch");
final _searchNavigatorKey = GlobalKey<NavigatorState>(debugLabel: "search_navigator_branch");

final router = GoRouter(
  initialLocation: '/',
  navigatorKey: _rootNavigatorKey,
  routes: [
    GoRoute(
      path: '/movie',
      builder: (context, state) {
        final movie = state.extra as Movie;
        return MovieDetailView(movie: movie);
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScreen(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _homeNavigatorKey,
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) {
                return const InitialView();
              },
            ),
          ]
        ),
        StatefulShellBranch(
          navigatorKey: _searchNavigatorKey,
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) {
                return const SearchView();
              },
            )
          ]
        ),
        StatefulShellBranch(
          navigatorKey: _favoritesNavigatorKey,
          routes: [
            GoRoute(
              path: '/favorites',
              builder: (context, state) {
                return const FavoritesView();
              },
            )
          ]
        )
      ]
    )
  ],
);
