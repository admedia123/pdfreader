import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pdf_file.dart';
import '../models/user_profile.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  late SupabaseClient _client;

  // Supabase configuration
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }

  SupabaseClient get client => _client;

  // Authentication methods
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: fullName != null ? {'full_name': fullName} : null,
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // PDF Files CRUD operations
  Future<List<PDFFile>> getUserPDFFiles() async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await _client
        .from('pdf_files')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (response as List).map((json) => PDFFile.fromJson(json)).toList();
  }

  Future<PDFFile> uploadPDFFile({
    required String fileName,
    required String filePath,
    required int fileSize,
    String? description,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Upload file to Supabase Storage
    final fileBytes = await File(filePath).readAsBytes();
    final fileName =
        '${user.id}/${DateTime.now().millisecondsSinceEpoch}_$fileName';

    await _client.storage.from('pdf_files').uploadBinary(fileName, fileBytes);

    // Get public URL
    final publicUrl = _client.storage.from('pdf_files').getPublicUrl(fileName);

    // Save metadata to database
    final response = await _client
        .from('pdf_files')
        .insert({
          'user_id': user.id,
          'file_name': fileName,
          'file_path': publicUrl,
          'file_size': fileSize,
          'description': description,
          'is_favorite': false,
          'created_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();

    return PDFFile.fromJson(response);
  }

  Future<void> updatePDFFile({
    required String fileId,
    String? fileName,
    String? description,
    bool? isFavorite,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    final updateData = <String, dynamic>{};
    if (fileName != null) updateData['file_name'] = fileName;
    if (description != null) updateData['description'] = description;
    if (isFavorite != null) updateData['is_favorite'] = isFavorite;

    await _client
        .from('pdf_files')
        .update(updateData)
        .eq('id', fileId)
        .eq('user_id', user.id);
  }

  Future<void> deletePDFFile(String fileId) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Get file info first
    final fileInfo = await _client
        .from('pdf_files')
        .select('file_path')
        .eq('id', fileId)
        .eq('user_id', user.id)
        .single();

    // Delete from storage
    final fileName = fileInfo['file_path'].split('/').last;
    await _client.storage.from('pdf_files').remove(['${user.id}/$fileName']);

    // Delete from database
    await _client
        .from('pdf_files')
        .delete()
        .eq('id', fileId)
        .eq('user_id', user.id);
  }

  // Favorites management
  Future<List<PDFFile>> getFavoriteFiles() async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await _client
        .from('pdf_files')
        .select()
        .eq('user_id', user.id)
        .eq('is_favorite', true)
        .order('created_at', ascending: false);

    return (response as List).map((json) => PDFFile.fromJson(json)).toList();
  }

  Future<void> toggleFavorite(String fileId, bool isFavorite) async {
    await updatePDFFile(fileId: fileId, isFavorite: isFavorite);
  }

  // Recent files management
  Future<List<PDFFile>> getRecentFiles({int limit = 20}) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await _client
        .from('pdf_files')
        .select()
        .eq('user_id', user.id)
        .order('last_accessed_at', ascending: false)
        .limit(limit);

    return (response as List).map((json) => PDFFile.fromJson(json)).toList();
  }

  Future<void> updateLastAccessed(String fileId) async {
    await _client
        .from('pdf_files')
        .update({'last_accessed_at': DateTime.now().toIso8601String()}).eq(
            'id', fileId);
  }

  // User profile management
  Future<UserProfile> getUserProfile() async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await _client
        .from('user_profiles')
        .select()
        .eq('user_id', user.id)
        .single();

    return UserProfile.fromJson(response);
  }

  Future<void> updateUserProfile({
    String? fullName,
    String? avatarUrl,
    Map<String, dynamic>? preferences,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    final updateData = <String, dynamic>{};
    if (fullName != null) updateData['full_name'] = fullName;
    if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;
    if (preferences != null) updateData['preferences'] = preferences;

    await _client.from('user_profiles').upsert({
      'user_id': user.id,
      ...updateData,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // Real-time subscriptions
  RealtimeChannel subscribeToPDFFiles() {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    return _client
        .channel('pdf_files')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'pdf_files',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: user.id,
          ),
          callback: (payload) {
            // Handle real-time updates
            print('PDF file updated: $payload');
          },
        )
        .subscribe();
  }
}

