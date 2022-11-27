import 'dart:convert';

import 'package:groupify/common/repositories/api_clients/base_api_client.dart';

class SpotifyApiClient extends BaseApiClient {
  SpotifyApiClient(super.authRepository);

  Future<void> removeUserSavedTracks(String trackIds) async {
    const path = '/v1/me/tracks';
    final uri = Uri(scheme: baseScheme, host: baseHost, path: path, queryParameters: {'ids': trackIds});

    final response = await httpClient.delete(uri, headers: await getAuthHeaders());

    assessQueryResponse(response);
  }

  Future<void> addUserSavedTracks(String trackIds) async {
    const path = '/v1/me/tracks';
    final uri = Uri(scheme: baseScheme, host: baseHost, path: path, queryParameters: {'ids': trackIds});

    final response = await httpClient.put(uri, headers: await getAuthHeaders());

    assessQueryResponse(response);
  }

  Future<List> checkUserSavedTracks(String trackIds) async {
    const path = '/v1/me/tracks/contains';
    final uri = Uri(scheme: baseScheme, host: baseHost, path: path, queryParameters: {'ids': trackIds});

    final response = await httpClient.get(uri, headers: await getAuthHeaders());

    assessQueryResponse(response);

    final List list = json.decode(response.body);

    return list;
  }
}
