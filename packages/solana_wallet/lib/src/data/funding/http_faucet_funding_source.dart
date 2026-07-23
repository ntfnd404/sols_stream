import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:solana_wallet/src/data/funding/funding_request_outcome.dart';
import 'package:solana_wallet/src/data/funding/funding_source.dart';

const int _successfulStatusStart = 200;
const int _successfulStatusEndExclusive = 300;
const Duration defaultFaucetRequestTimeout = Duration(seconds: 30);

/// Requests funding from the sols.stream HTTP faucet contract.
final class HttpFaucetFundingSource implements FundingSource {
  final http.Client _httpClient;
  final Uri _faucetUri;
  final Duration _requestTimeout;

  HttpFaucetFundingSource({
    required this._httpClient,
    required this._faucetUri,
    this._requestTimeout = defaultFaucetRequestTimeout,
  }) {
    if (!_faucetUri.isAbsolute ||
        !_faucetUri.hasAuthority ||
        _faucetUri.host.isEmpty ||
        (_faucetUri.scheme != 'http' && _faucetUri.scheme != 'https') ||
        _faucetUri.userInfo.isNotEmpty ||
        _faucetUri.hasFragment) {
      throw ArgumentError.value(
        _faucetUri,
        'faucetUri',
        'must be an absolute HTTP or HTTPS URI without user info or fragment',
      );
    }
    if (_requestTimeout.isNegative) {
      throw ArgumentError.value(
        _requestTimeout,
        'requestTimeout',
        'must not be negative',
      );
    }
  }

  @override
  Future<FundingRequestOutcome> requestFunding(String address) async {
    try {
      return await _request(address).timeout(_requestTimeout);
    } on Exception {
      return FundingRequestOutcome.indeterminate;
    }
  }

  Future<FundingRequestOutcome> _request(String address) async {
    final request = http.Request('POST', _faucetUri)
      ..followRedirects = false
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode({'wallet': address});
    final streamedResponse = await _httpClient.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= _successfulStatusStart && response.statusCode < _successfulStatusEndExclusive) {
      return FundingRequestOutcome.accepted;
    }
    if (response.statusCode >= 400 && response.statusCode < 500 && response.statusCode != 408) {
      return FundingRequestOutcome.fallbackAllowed;
    }

    return FundingRequestOutcome.indeterminate;
  }
}
