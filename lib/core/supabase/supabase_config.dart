/// Điền URL và anon key từ Supabase dashboard của bạn.
/// Project Settings → API → Project URL + anon/public key
class SupabaseConfig {
  static const supabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
  static const supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  /// Phải khớp với Redirect URL bạn thêm trong Supabase dashboard
  /// Authentication → URL Configuration → Redirect URLs
  static const redirectUrl = 'io.supabase.sounddiary://login-callback';
}
