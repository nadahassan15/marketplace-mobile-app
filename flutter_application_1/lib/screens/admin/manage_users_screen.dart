import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/user_service.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final UserService _userService = UserService();

  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String? _errorMessage;

  // DESIGN CONSTANTS
  static const Color primarySage = Color(0xFFACBDAA);
  static const Color bgGrey = Color(0xFFFAFAFA);

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  // ==========================================
  // 1. READ (Fetch Users) - UNTOUCHED
  // ==========================================
  Future<void> fetchUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final users = await _userService.getAllUsers();
      if (mounted) {
        setState(() {
          _users = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading users: $e';
          _isLoading = false;
        });
      }
    }
  }

  // ==========================================
  // 3. UPDATE (Edit User) - UI UPDATED ONLY
  // ==========================================
  Future<void> updateUser(String id, String currentUsername, String currentRole) async {
    final usernameController = TextEditingController(text: currentUsername);

    String uiRole = currentRole.toLowerCase();
    if (uiRole == 'user') uiRole = 'customer';
    if (uiRole == 'brand') uiRole = 'brand_owner';

    if (!['admin', 'customer', 'brand_owner'].contains(uiRole)) {
      uiRole = 'customer';
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Edit User", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Styled TextField
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: "Username",
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[50],
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: primarySage, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Role", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              
              // Styled Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: uiRole,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, color: primarySage),
                    items: const [
                      DropdownMenuItem(value: 'customer', child: Text("Customer")),
                      DropdownMenuItem(value: 'brand_owner', child: Text("Brand Owner")),
                      DropdownMenuItem(value: 'admin', child: Text("Admin")),
                    ],
                    onChanged: (value) {
                      setDialogState(() => uiRole = value!);
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primarySage,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                try {
                  setDialogState(() {});
                  String dbRole = uiRole;

                  await _userService.updateUser(
                    userId: id,
                    username: usernameController.text,
                    role: dbRole
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                    fetchUsers();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("User Updated!"), backgroundColor: primarySage),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 4. DELETE (Remove User) - UI UPDATED ONLY
  // ==========================================
  Future<void> deleteUser(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete User?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), 
            child: const Text("Cancel", style: TextStyle(color: Colors.grey))
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _userService.deleteUser(id);
        fetchUsers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User deleted"), backgroundColor: primarySage),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  // ==========================================
  // UI BUILDER - NEW LOOK
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Manage Users",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: primarySage), // Sage back button
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: primarySage),
            onPressed: fetchUsers,
          )
        ],
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primarySage))
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];

                    // Safe Data Handling
                    final id = user['id'] ?? '';
                    final username = user['username'] ?? 'Unknown';
                    final email = user['email'] ?? 'No Email';
                    final rawRole = user['role']?.toString().toLowerCase() ?? 'customer';

                    // --- NEW CARD DESIGN ---
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50], // Light fill
                        borderRadius: BorderRadius.circular(15), // Rounded 15
                        border: Border.all(color: Colors.grey.shade300), // Grey border
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                        child: ListTile(
                          // Avatar Box
                          leading: Container(
                            height: 45,
                            width: 45,
                            decoration: BoxDecoration(
                              color: primarySage.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.person, color: primarySage),
                          ),
                          
                          // Title & Email
                          title: Text(
                            username, 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(email, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                              const SizedBox(height: 6),
                              // Role Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Text(
                                  _formatRoleName(rawRole),
                                  style: TextStyle(
                                    color: _getRoleColor(rawRole),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          // Action Buttons
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Colors.grey),
                                onPressed: () => updateUser(id, username, rawRole),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => deleteUser(id),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  // --- HELPER FUNCTIONS (Adjusted colors to match palette better) ---
  Color _getRoleColor(String role) {
    if (role.contains('admin')) return Colors.redAccent;
    if (role.contains('brand')) return Colors.blueGrey;
    return primarySage; // Customer gets the theme color
  }

  String _formatRoleName(String role) {
    if (role == 'brand_owner' || role == 'brand') return 'Brand Owner';
    if (role == 'admin') return 'Admin';
    if (role == 'customer') return 'Customer';
    return 'Customer';
  }
}