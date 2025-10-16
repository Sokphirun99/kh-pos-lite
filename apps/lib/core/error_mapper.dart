Exception mapDioError(Object error) {
  // TODO: map Dio/Network errors to app-specific exceptions
  return Exception(error.toString());
}
