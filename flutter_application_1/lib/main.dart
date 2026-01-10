import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth/auth_gate.dart'; // Import the gate we just made
import 'theme/app_theme.dart';

//ahh el file bt3yy

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ptnxcsugztfcdyrjhbrj.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB0bnhjc3VnenRmY2R5cmpoYnJqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU4OTc5MDksImV4cCI6MjA4MTQ3MzkwOX0.smtWt94cPbkZFwQK3v37igoA9KANwZC2SqUXFgu7mfQ',
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Golokal',
      theme: AppTheme.lightTheme,
      // The AuthGate handles all the logic of where to go next
      home: const AuthGate(), 
    );
  }
}