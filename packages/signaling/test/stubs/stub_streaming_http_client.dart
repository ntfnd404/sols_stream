import 'package:http/http.dart' as http;

typedef StreamingResponseHandler =
    Future<http.StreamedResponse> Function(
      http.BaseRequest request,
    );

final class StubStreamingHttpClient extends http.BaseClient {
  final StreamingResponseHandler handler;

  StubStreamingHttpClient(this.handler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) => handler(request);
}
