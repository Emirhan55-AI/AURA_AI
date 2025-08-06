import 'dart:io';

void main() async {
  final server = await HttpServer.bind('localhost', 8084);
  print('🚀 CORS Proxy Server running on http://localhost:8084');
  print('📡 Forwarding requests to: https://aura-one-sigma.vercel.app');
  
  await for (HttpRequest request in server) {
    // Add CORS headers
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    request.response.headers.add('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    request.response.headers.add('Access-Control-Allow-Headers', 'Origin, Content-Type, X-Auth-Token, Authorization');
    
    if (request.method == 'OPTIONS') {
      // Handle preflight request
      request.response.statusCode = 200;
      await request.response.close();
      continue;
    }
    
    try {
      // Forward request to actual API
      final targetUrl = 'https://aura-one-sigma.vercel.app${request.uri.path}';
      print('🔄 Proxying ${request.method} ${request.uri.path} -> $targetUrl');
      
      final client = HttpClient();
      final proxyRequest = await client.openUrl(request.method, Uri.parse(targetUrl));
      
      // Copy headers (except host)
      request.headers.forEach((name, values) {
        if (name.toLowerCase() != 'host') {
          for (var value in values) {
            proxyRequest.headers.add(name, value);
          }
        }
      });
      
      // Copy body for POST requests
      if (request.method == 'POST') {
        final bodyBytes = <int>[];
        await for (var chunk in request) {
          bodyBytes.addAll(chunk);
        }
        proxyRequest.add(bodyBytes);
      }
      
      final proxyResponse = await proxyRequest.close();
      
      // Copy response status and headers
      request.response.statusCode = proxyResponse.statusCode;
      proxyResponse.headers.forEach((name, values) {
        if (name.toLowerCase() != 'transfer-encoding') {
          for (var value in values) {
            request.response.headers.add(name, value);
          }
        }
      });
      
      // Copy response body
      await proxyResponse.pipe(request.response);
      
    } catch (e) {
      print('❌ Proxy error: $e');
      request.response.statusCode = 500;
      request.response.write('Proxy error: $e');
      await request.response.close();
    }
  }
}
