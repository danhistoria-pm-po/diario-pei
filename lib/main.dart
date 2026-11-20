import 'package:flutter/material.dart';

import 'app.dart';
import 'core/config/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isConfigured = await SupabaseConfig.initialize();
  runApp(DiarioPeiApp(isSupabaseConfigured: isConfigured));
}
