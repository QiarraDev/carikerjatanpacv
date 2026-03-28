import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:3000', // Khusus Emulator Android
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<Response> login(String email, String password) {
    return _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
  }

  Future<Response> getJobs() {
    return _dio.get('/jobs');
  }

  Future<Response> getAssessment(String jobId) {
    return _dio.get('/assessment/$jobId');
  }

  Future<Response> submitApplication(String userId, String jobId, String? videoUrl) {
    return _dio.post('/applications', data: {
      'user_id': userId,
      'job_id': jobId,
      'video_url': videoUrl ?? '',
    });
  }

  Future<Response> register(String name, String email, String password) {
    return _dio.post('/auth/register', data: {
      'full_name': name,
      'email': email,
      'password': password,
    });
  }

  // 💼 Apply Job (Real)
  Future<Response> applyJob(String jobId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    return _dio.post('/applications', data: {
      'user_id': userId,
      'job_id': jobId,
    });
  }

  Future<Response> getProfile(String userId) {
    return _dio.get('/users/$userId');
  }

  Future<Response> updateProfile(String id, Map<String, dynamic> data) async {
    return _dio.patch('/users/$id', data: data);
  }

  // 🔗 Simpan Profile Video (Legacy Support / Dedicated Endpoint)
  Future<Response> saveProfileVideo(String userId, String url) async {
    return _dio.patch('/users/$userId', data: {"video_url": url});
  }
}
