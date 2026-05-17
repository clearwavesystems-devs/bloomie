/// Supabase project credentials.
///
/// Replace these values with your own Supabase project URL and anon key.
/// In production, load these via `--dart-define` so they stay out of source:
///
///   flutter run \
///     --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///     --dart-define=SUPABASE_ANON_KEY=eyJ...
///
/// Then read them here with:
///   const _url = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
class SupabaseConfig {
  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://osxclbuiojqbmaxukzls.supabase.co', // ← replace
  );

  static const anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9zeGNsYnVpb2pxYm1heHVremxzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg5OTYwNjMsImV4cCI6MjA5NDU3MjA2M30.2tQrMgAfYybPKwuQ2p55geyMbQB3HTtBA18kK76pAGQ',
  );
}
