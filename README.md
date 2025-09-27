## Descripción
App Flutter para explorar películas (populares, mejores valoradas, proximas), ver detalles, reparto, trailers y marcar favoritos.

## Arquitectura
Capas básicas: domain (modelos, interfaces), presentation (BLoCs / vistas), services (HTTP, Hive). Paginación y favoritos centralizados en MovieBloc + MovieRepository.

## Dependencias
flutter_bloc, http, hive_ce(+flutter), cached_network_image, connectivity_plus, go_router, url_launcher.

## Dependecias (Desarrollo)
Dev: flutter_test, bloc_test, mocktail, flutter_lints.

## Testing
```bash
flutter test
flutter test test/presentation/blocs/movie_bloc_test.dart
flutter test --coverage
```
Cobertura HTML (macOS/Linux):
```bash
brew install lcov        # macOS (una sola vez)

genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html  # macOS
xdg-open coverage/html/index.html  # Linux
```

## Splash Screen
Configurada con flutter_native_splash en pubspec:
```bash
flutter pub run flutter_native_splash:create
flutter pub run flutter_native_splash:remove   # eliminar
```
