import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabaseAnonKey,
  );

  runApp(const ProviderScope(child: MenlogApp()));
}

class MenlogApp extends StatelessWidget {
  const MenlogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '멘로그',
      debugShowCheckedModeBanner: false,
      home: const Placeholder(),
    );
  }
}
