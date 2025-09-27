class OfflineException implements Exception {
  final String message;
  const OfflineException([this.message = 'No hay conexión a Internet']);
  @override
  String toString() => message;
}
