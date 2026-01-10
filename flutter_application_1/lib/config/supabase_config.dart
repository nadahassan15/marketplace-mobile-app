class SupabaseConfig {
  // Supabase credentials
  static const String supabaseUrl = 'https://ptnxcsugztfcdyrjhbrj.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB0bnhjc3VnenRmY2R5cmpoYnJqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU4OTc5MDksImV4cCI6MjA4MTQ3MzkwOX0.smtWt94cPbkZFwQK3v37igoA9KANwZC2SqUXFgu7mfQ';
  
  // Validate that credentials are set
  static bool get isConfigured {
    return supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  }
}

