import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  SupabaseConfig._();

  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://upalasbkdojgunoxeqth.supabase.co',
  );
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_CoqPJhjOBr9DQO9Ae0jcCQ_IDgA8P2l',
  );

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  static Future<bool> initialize() async {
    if (!isConfigured) {
      return false;
    }

    await Supabase.initialize(
      url: url,
      publishableKey: anonKey,
    );
    return true;
  }

  static SupabaseClient get client => Supabase.instance.client;
}
