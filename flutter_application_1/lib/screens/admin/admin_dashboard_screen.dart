import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'manage_users_screen.dart';
import 'manage_events_screen.dart';
import 'analytics_screen.dart';
import '../../screens/auth/login_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  // DESIGN CONSTANTS
  static const Color primarySage = Color(0xFFACBDAA);
  static const Color bgGrey = Color(0xFFFAFAFA);

  @override
  Widget build(BuildContext context) {
    // Get current user details for the header
    final user = Supabase.instance.client.auth.currentUser;
    final username = user?.userMetadata?['username'] ?? 'Admin';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Admin Portal',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          )
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive Logic: Center content on wide screens
          bool isWide = constraints.maxWidth > 800;
          double horizontalPadding = isWide ? (constraints.maxWidth - 600) / 2 : 20;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome back,\n$username 👋",
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Select an option to manage",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 30),

                // --- MENU GRID ---
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: isWide ? 3 : 2, // 3 columns on web, 2 on mobile
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1, // Slightly taller cards
                  children: [
                    _buildMenuCard(
                      context,
                      title: 'Manage Users',
                      icon: Icons.people_outline, // Cleaner outline icon
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageUsersScreen())),
                    ),
                    _buildMenuCard(
                      context,
                      title: 'Manage Events',
                      icon: Icons.event_note,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageEventsScreen())),
                    ),
                    _buildMenuCard(
                      context,
                      title: 'Analytics',
                      icon: Icons.analytics_outlined,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen())),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- REUSABLE MENU CARD (Matches Design System) ---
  Widget _buildMenuCard(BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50], // Theme background
          borderRadius: BorderRadius.circular(15), // Theme Radius
          border: Border.all(color: Colors.grey.shade300), // Theme Border
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: onTap,
            hoverColor: primarySage.withOpacity(0.05), // Subtle hover effect
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon Circle
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primarySage.withOpacity(0.15), // Light Sage circle
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 32, color: primarySage), // Sage Icon
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.black87
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}