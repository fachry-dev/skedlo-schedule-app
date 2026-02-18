import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CohereService {
  static const String _apiKey = '1WSMw9WufHsMTWTBDJvAjYSZIwIjX3sw0GuFVQBq';
  static const String _baseUrl =
      'https://api.cohere.com/v2/chat';

  Future<List<String>> generateActivities(
    String title,
    DateTime date,
    DateTime startTime,
    DateTime endTime,
  ) async {
    final prompt =
        '''
    Buatkan daftar kegiatan detail untuk jadwal berikut:
    Judul: $title
    Tanggal: ${date.toIso8601String()}
    Waktu: ${startTime.hour}:${startTime.minute} sampai ${endTime.hour}:${endTime.minute}
    
    Berikan output hanya berupa daftar poin-poin kegiatan (string) tanpa nomor atau bullet point di awal, dipisahkan dengan baris baru.
    Konteks: Kamu adalah asisten pribadi yang membantu merincikan kegiatan.
    ''';

    try {
      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
              'X-Client-Name': 'FlutterScheduleApp',
            },
            body: jsonEncode({
              'model': 'command-r-08-2024', 
              'messages': [
                {'role': 'user', 'content': prompt},
              ],
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final contentList = data['message']['content'] as List;
        final text = contentList.first['text'] as String;

        return text
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty && !e.startsWith('```'))
            .map((e) => e.replaceAll(RegExp(r'^[-*•]\s*'), ''))
            .toList();
      } else {
        debugPrint(
          'Cohere API Error: ${response.statusCode} - ${response.body}',
        );
        return ['Gagal: API Error ${response.statusCode}'];
      }
    } catch (e) {
      debugPrint('Error generating activities: $e');
      return ['Gagal: ${e.toString()}'];
    }
  }
}
