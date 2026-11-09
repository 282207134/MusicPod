import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config.dart';

abstract class LibraryCloud {
  String? get userId;
  String get displayName;
  String get email;
  Stream<void> get changes;
  Future<void> signIn();
  Future<void> signOut();
  Future<Map<String, dynamic>?> load();
  Future<void> save(String userId, Map<String, dynamic> data);
}

class SupabaseLibraryCloud implements LibraryCloud {
  SupabaseLibraryCloud(this.client, this.config);
  final SupabaseClient client;
  final ServiceConfig config;
  @override
  String? get userId => client.auth.currentUser?.id;
  @override
  String get displayName =>
      (client.auth.currentUser?.userMetadata?['user_name'] ??
              client.auth.currentUser?.userMetadata?['name'] ??
              'MusicPod listener')
          .toString();
  @override
  String get email => client.auth.currentUser?.email ?? '';
  @override
  Stream<void> get changes => client.auth.onAuthStateChange.map((_) {});
  @override
  Future<void> signIn() async {
    final launched = await client.auth.signInWithOAuth(
      OAuthProvider.github,
      redirectTo: kIsWeb ? Uri.base.origin : config.redirectUrl,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
    if (!launched) throw StateError('Could not open the sign-in browser.');
  }

  @override
  Future<void> signOut() => client.auth.signOut(scope: SignOutScope.local);
  @override
  Future<Map<String, dynamic>?> load() async {
    final row = await client
        .from('user_libraries')
        .select('data')
        .eq('user_id', userId!)
        .maybeSingle();
    return row == null ? null : Map<String, dynamic>.from(row['data'] as Map);
  }

  @override
  Future<void> save(String userId, Map<String, dynamic> data) async {
    await client.from('user_libraries').upsert({
      'user_id': userId,
      'data': data,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }
}
