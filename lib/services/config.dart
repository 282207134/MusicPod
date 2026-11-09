class ServiceConfig {
  const ServiceConfig({
    this.supabaseUrl = '',
    this.supabaseKey = '',
    this.jamendoClientId = '',
    this.redirectUrl = 'com.musicpod.musicpod://login-callback/',
  });

  static const environment = ServiceConfig(
    supabaseUrl: String.fromEnvironment('SUPABASE_URL'),
    supabaseKey: String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
    jamendoClientId: String.fromEnvironment('JAMENDO_CLIENT_ID'),
    redirectUrl: String.fromEnvironment(
      'AUTH_REDIRECT_URL',
      defaultValue: 'com.musicpod.musicpod://login-callback/',
    ),
  );
  static const demo = bool.fromEnvironment('MUSICPOD_DEMO');
  final String supabaseUrl, supabaseKey, jamendoClientId, redirectUrl;

  bool get hasSupabase =>
      Uri.tryParse(supabaseUrl)?.scheme == 'https' &&
      supabaseKey.startsWith('sb_publishable_');
  bool get hasMusic => jamendoClientId.trim().isNotEmpty;
}
