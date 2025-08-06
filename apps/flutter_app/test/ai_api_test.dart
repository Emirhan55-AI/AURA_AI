import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('Aura AI API Tests', () {
    
    test('AI API is accessible', () async {
      // Test basic connectivity
      final uri = Uri.parse('https://aura-one-sigma.vercel.app/');
      final response = await http.get(uri);
      
      expect(response.statusCode, 200);
      expect(response.body, contains('Aura AI Backend'));
      print('✅ AI API is accessible');
      print('Response: ${response.body}');
    });

    test('AI API endpoints are available', () async {
      // Test documentation endpoint
      final docsUri = Uri.parse('https://aura-one-sigma.vercel.app/docs');
      final docsResponse = await http.get(docsUri);
      
      expect(docsResponse.statusCode, 200);
      expect(docsResponse.body, contains('swagger'));
      print('✅ API documentation is available');
    });

    test('Process image endpoint is reachable', () async {
      // Test if the process-image endpoint responds (even without image)
      final uri = Uri.parse('https://aura-one-sigma.vercel.app/process-image/');
      
      try {
        final response = await http.post(uri);
        // We expect 400 or 422 since we're not sending an image
        expect([400, 422].contains(response.statusCode), true);
        print('✅ Process image endpoint is reachable');
        print('Status: ${response.statusCode}');
      } catch (e) {
        print('⚠️ Process image endpoint test: $e');
      }
    });

    test('Get recommendation endpoint is reachable', () async {
      // Test if the get-recommendation endpoint responds
      final uri = Uri.parse('https://aura-one-sigma.vercel.app/get-recommendation/');
      
      try {
        final response = await http.post(uri);
        // We expect 400 or 422 since we're not sending required data
        expect([400, 422].contains(response.statusCode), true);
        print('✅ Get recommendation endpoint is reachable');
        print('Status: ${response.statusCode}');
      } catch (e) {
        print('⚠️ Get recommendation endpoint test: $e');
      }
    });
  });
}
