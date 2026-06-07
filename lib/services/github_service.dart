import 'dart:convert';
import 'package:http/http.dart' as http;

class GithubService {
  Future<bool> uploadFile({
    required String pat,
    required String repo,
    required String path,
    required String content,
    required String message,
  }) async {
    try {
      final uri = Uri.https('api.github.com', '/repos/$repo/contents/$path');
      final headers = {
        'Authorization': 'token $pat',
        'Accept': 'application/vnd.github+json',
      };
      
      final getResp = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
      String? sha;
      if (getResp.statusCode == 200) {
        final getJson = jsonDecode(getResp.body);
        sha = getJson['sha'] as String?;
      }
      
      final body = {
        'message': message,
        'content': base64Encode(utf8.encode(content)),
        if (sha != null) 'sha': sha,
      };
      
      final putResp = await http.put(
        uri,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));
      
      return putResp.statusCode == 200 || putResp.statusCode == 201;
    } catch (e) {
      print('GitHub Upload Error: $e');
      return false;
    }
  }
}