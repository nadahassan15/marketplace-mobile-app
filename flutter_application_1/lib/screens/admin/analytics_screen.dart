import 'package:flutter/material.dart';
import '../../services/analytics_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();
  
  Map<String, int> _stats = {
    'total_users': 0,
    'total_brands': 0,
    'total_products': 0,
    'total_reviews': 0,
  };
  bool _isLoading = true;

  // DESIGN CONSTANTS
  static const Color primarySage = Color(0xFFACBDAA);
  static const Color bgGrey = Color(0xFFFAFAFA);

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _analyticsService.getSystemStats();
    if (mounted) {
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate max value for chart scaling
    int maxValue = 1;
    _stats.forEach((_, value) {
      if (value > maxValue) maxValue = value;
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'System Analytics',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: primarySage),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: primarySage),
            onPressed: _loadStats,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primarySage))
          : LayoutBuilder(
              builder: (context, constraints) {
                // Responsive Logic
                bool isWide = constraints.maxWidth > 800;
                double horizontalPadding = isWide ? (constraints.maxWidth - 800) / 2 : 16;

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Overview",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        "Key metrics summary",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),

                      // --- 1. STATS GRID ---
                      GridView.count(
                        crossAxisCount: isWide ? 4 : 2, 
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.3,
                        children: [
                          _buildStatCard('Users', _stats['total_users']!, Icons.people_outline),
                          _buildStatCard('Brands', _stats['total_brands']!, Icons.store_outlined),
                          _buildStatCard('Products', _stats['total_products']!, Icons.shopping_bag_outlined),
                          _buildStatCard('Reviews', _stats['total_reviews']!, Icons.star_outline),
                        ],
                      ),

                      const SizedBox(height: 30),
                      const Text(
                        "Growth Chart",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),

                      // --- 2. CUSTOM BAR CHART ---
                      Container(
                        // FIX 1: Increased height from 300 to 360 to prevent overflow
                        height: 360, 
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _buildBar("Users", _stats['total_users']!, maxValue, const Color(0xFF6A9C89)),
                                  _buildBar("Brands", _stats['total_brands']!, maxValue, const Color(0xFFC4D7B2)),
                                  _buildBar("Products", _stats['total_products']!, maxValue, const Color(0xFFE3EED4)),
                                  _buildBar("Reviews", _stats['total_reviews']!, maxValue, const Color(0xFFA0C49D)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Divider(), 
                            const Text("Comparative View", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  // --- REUSABLE STAT CARD ---
  Widget _buildStatCard(String title, int count, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primarySage.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: primarySage, size: 24),
          ),
          const Spacer(),
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // --- CHART BAR BUILDER ---
  Widget _buildBar(String label, int value, int maxValue, Color color) {
    // FIX 2: Better percentage calculation
    double percentage = maxValue == 0 ? 0 : value / maxValue;
    if (percentage < 0.1 && value > 0) percentage = 0.1;

    // FIX 3: Reduced max bar height multiplier slightly (180 -> 160) for safety
    double maxBarHeight = 160; 

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Value Bubble
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Text(
            value.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        const SizedBox(height: 8),
        
        // The Bar
        AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutQuart,
          width: 40,
          height: maxBarHeight * percentage, // Dynamic height
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 12),
        
        // Label
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
      ],
    );
  }
}