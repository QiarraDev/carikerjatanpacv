import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://carikerjatanpacv-production.up.railway.app/api',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // Dio khusus upload video — timeout 5 menit karena file besar!
  final Dio _uploadDio = Dio(
    BaseOptions(
      baseUrl: 'https://carikerjatanpacv-production.up.railway.app/api',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 5),
      sendTimeout: const Duration(minutes: 5),
    ),
  );

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    // Interceptor untuk _dio (request biasa)
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
    // Interceptor yang sama untuk _uploadDio
    _uploadDio.interceptors.add(
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

  // 🧠 Auto-Matching Jobs
  Future<Response> getRecommendedJobs(String userId) {
    return _dio.get('/jobs/match/$userId');
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

  Future<Response> register(String name, String email, String password, {String? role}) {
    return _dio.post('/auth/register', data: {
      'full_name': name,
      'email': email,
      'password': password,
      'role': role ?? 'candidate',
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

  // 📝 Create Job (Recruiter)
  Future<Response> createJob(Map<String, dynamic> data) {
    return _dio.post('/jobs', data: data);
  }

  // 👤 List Candidates (Recruiter)
  Future<Response> getCandidates() {
    return _dio.get('/users'); // Asumsi backend punya endpoint ini atau admin/hr bisa akses
  }

  // ⭐ Shortlist Candidate (Recruiter)
  Future<Response> shortlistCandidate(String userId) {
    return _dio.post('/shortlist', data: {"user_id": userId});
  }

  // 🚀 Upload Pitch Video ke Cloudinary via Backend
  Future<Response> uploadPitchVideo(String userId, {String? filePath, Uint8List? fileBytes, String? fileName}) async {
    MultipartFile multipartFile;
    if (fileBytes != null) {
      multipartFile = MultipartFile.fromBytes(fileBytes, filename: fileName ?? 'video.mp4');
    } else if (filePath != null) {
      multipartFile = await MultipartFile.fromFile(filePath, filename: fileName ?? 'video.mp4');
    } else {
      throw Exception('Harus memasukkan filePath atau fileBytes');
    }

    final formData = FormData.fromMap({'video': multipartFile});

    // Gunakan _uploadDio dengan timeout 5 menit!
    return _uploadDio.post(
      '/users/upload-video/$userId',
      data: formData,
      onSendProgress: (sent, total) {
        if (total > 0) {
          final pct = (sent / total * 100).toStringAsFixed(0);
          // ignore: avoid_print
          print('📤 Upload: $pct% ($sent/$total bytes)');
        }
      },
    );
  }
}
