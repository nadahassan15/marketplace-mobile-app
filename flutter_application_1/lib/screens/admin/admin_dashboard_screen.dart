import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/user_service.dart';
import '../../screens/auth/login_screen.dart';
import '../../theme/app_theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final UserService _userService = UserService();
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final users = await _userService.getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading users: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserRole(String userId, String newRole) async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      await _userService.updateUserRole(userId, newRole);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User role updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadUsers(); // Refresh the list
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating role: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _deleteUser(String userId, String username) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete $username?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        setState(() {
          _isLoading = true;
        });
        
        await _userService.deleteUser(userId);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadUsers(); // Refresh the list
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting user: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  Future<void> _showEditUserDialog(Map<String, dynamic> user) async {
    final usernameController = TextEditingController(
      text: user['username']?.toString() ?? '',
    );
    String selectedRole = user['role']?.toString() ?? 'user';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Role:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'user', child: Text('Customer')),
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'brand', child: Text('Brand Owner')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedRole = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Show loading
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                  
                  await _userService.updateUser(
                    userId: user['id'],
                    username: usernameController.text.trim(),
                    role: selectedRole,
                  );
                  
                  if (context.mounted) {
                    Navigator.pop(context); // Close loading dialog
                    Navigator.pop(context); // Close edit dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('User updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _loadUsers();
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context); // Close loading dialog if still open
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 5),
                      ),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final username = user?.userMetadata?['username'] ?? 
                    user?.email?.split('@').first ?? 
                    'Admin';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.primaryColor),
            onPressed: _loadUsers,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black87),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message at top left
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Welcome, $username!",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Manage Users",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Users list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadUsers,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _users.isEmpty
                        ? const Center(
                            child: Text('No users found'),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadUsers,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: _users.length,
                              itemBuilder: (context, index) {
                                final user = _users[index];
                                final userId = user['id']?.toString() ?? '';
                                final username = user['username']?.toString() ?? 'Unknown';
                                final email = user['email']?.toString() ?? 
                                             'ID: ${userId.substring(0, userId.length > 8 ? 8 : userId.length)}...';
                                final role = user['role']?.toString() ?? 'user';

                                return Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      username,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Email: $email'),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Text('Role: '),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _getRoleColor(role),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                _getRoleDisplayName(role),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Quick role change dropdown
                                        PopupMenuButton<String>(
                                          icon: const Icon(Icons.more_vert, color: AppTheme.primaryColor),
                                          onSelected: (value) {
                                            if (value == 'edit') {
                                              _showEditUserDialog(user);
                                            } else if (value == 'delete') {
                                              _deleteUser(userId, username);
                                            } else {
                                              _updateUserRole(userId, value);
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(
                                              value: 'user',
                                              child: Text('Set as Customer'),
                                            ),
                                            const PopupMenuItem(
                                              value: 'admin',
                                              child: Text('Set as Admin'),
                                            ),
                                            const PopupMenuItem(
                                              value: 'brand',
                                              child: Text('Set as Brand Owner'),
                                            ),
                                            const PopupMenuDivider(),
                                            const PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.edit, size: 18),
                                                  SizedBox(width: 8),
                                                  Text('Edit Details'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.delete, size: 18, color: Colors.red),
                                                  SizedBox(width: 8),
                                                  Text('Delete', style: TextStyle(color: Colors.red)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    onTap: () => _showEditUserDialog(user),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'brand':
        return Colors.blue;
      case 'user':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Admin';
      case 'brand':
        return 'Brand Owner';
      case 'user':
        return 'Customer';
      default:
        return role;
    }
  }
}

