import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/login_screen.dart';
import '../../services/user_service.dart';
import 'ordershistory_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final TextEditingController _nameController = TextEditingController();
  bool _isEditingName = false;
  bool _isLoading = false;
  List<Map<String, dynamic>> _addresses = [];

  // DESIGN CONSTANTS
  static const Color primarySage = Color(0xFFACBDAA);
  static const Color bgGrey = Color(0xFFFAFAFA);

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAddresses();
  }

  Future<void> _loadUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final username = user.userMetadata?['username'] ?? '';
      _nameController.text = username;

      if (username.isEmpty) {
        try {
          final profile = await _userService.getUserById(user.id);
          if (profile != null && profile['username'] != null) {
            _nameController.text = profile['username'].toString();
          }
        } catch (e) {
          print('Error loading profile: $e');
        }
      }
    }
  }

  Future<void> _loadAddresses() async {
    // Keep your logic
    setState(() {
      _addresses = [];
    });
  }

  Future<void> _saveName() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await _userService.updateUser(
          userId: user.id,
          username: _nameController.text.trim(),
        );

        final updatedMetadata = Map<String, dynamic>.from(user.userMetadata ?? {});
        updatedMetadata['username'] = _nameController.text.trim();
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(data: updatedMetadata),
        );

        setState(() {
          _isEditingName = false;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Name updated successfully'), backgroundColor: primarySage),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating name: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _addAddress() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add address functionality coming soon'), backgroundColor: primarySage),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // --- UI HELPER: INPUT STYLE ---
  InputDecoration _inputStyle(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: primarySage, size: 20),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: primarySage, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? 'No email';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: primarySage),
        actions: [
          PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primarySage.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 20, color: primarySage),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            onSelected: (value) {
              if (value == 'signout') _signOut();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Text(email, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'signout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18, color: Colors.redAccent),
                    SizedBox(width: 12),
                    Text('Sign out', style: TextStyle(color: Colors.redAccent)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
        ],
      ),
      
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive Center Constraint
          bool isWide = constraints.maxWidth > 600;
          double padding = isWide ? (constraints.maxWidth - 500) / 2 : 16;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: padding, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 1. PROFILE INFO CARD ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      // Avatar Area
                      Center(
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: primarySage.withOpacity(0.2),
                          child: const Icon(Icons.person, size: 40, color: primarySage),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Name Field
                      Row(
                        children: [
                          Expanded(
                            child: _isEditingName
                                ? TextField(
                                    controller: _nameController,
                                    decoration: _inputStyle('Username', Icons.person_outline),
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("Name", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                      const SizedBox(height: 4),
                                      Text(
                                        _nameController.text.isEmpty ? 'No Name' : _nameController.text,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                          ),
                          IconButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    if (_isEditingName) {
                                      _saveName();
                                    } else {
                                      setState(() => _isEditingName = true);
                                    }
                                  },
                            icon: _isLoading
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: primarySage))
                                : Icon(
                                    _isEditingName ? Icons.check_circle : Icons.edit_outlined,
                                    color: primarySage,
                                  ),
                          ),
                          if (_isEditingName)
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _isEditingName = false;
                                  _loadUserData();
                                });
                              },
                              icon: const Icon(Icons.cancel_outlined, color: Colors.grey),
                            ),
                        ],
                      ),
                      const Divider(height: 30),
                      
                      // Email Field (Read Only)
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Email", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(email, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                          const Icon(Icons.lock_outline, color: Colors.grey, size: 18),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // --- 2. ORDERS BUTTON ---
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(color: Colors.grey.shade100, blurRadius: 4, offset: const Offset(0, 2))
                    ]
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersHistoryScreen()));
                    },
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primarySage.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.history, color: primarySage),
                    ),
                    title: const Text("Orders History", style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  ),
                ),

                const SizedBox(height: 24),
                
                // --- 3. ADDRESSES SECTION ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("My Addresses", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      onPressed: _addAddress,
                      icon: const Icon(Icons.add, size: 16, color: primarySage),
                      label: const Text("Add New", style: TextStyle(color: primarySage)),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                
                if (_addresses.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.location_off_outlined, size: 40, color: Colors.grey[400]),
                        const SizedBox(height: 10),
                        Text("No addresses saved yet.", style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  )
                else
                  ..._addresses.map((address) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.location_on_outlined, color: primarySage),
                        title: Text(address['label'] ?? 'Address'),
                        subtitle: Text(address['address'] ?? ''),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.grey),
                          onPressed: () {
                            // Delete logic placeholder
                          },
                        ),
                      ),
                    ),
                  )),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Sign Out", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primarySage,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Sign Out", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await Supabase.instance.client.auth.signOut();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
}