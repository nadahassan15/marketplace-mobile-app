import 'package:flutter/material.dart';
import '../models/brand.dart';
import '../models/event.dart';
import '../services/brand_service.dart';
import '../services/event_service.dart';
import 'create_brand_screen.dart';
import 'create_event_screen.dart';
import 'brand_detail_screen.dart';
import 'event_detail_screen.dart';

class BrandOwnerDashboard extends StatefulWidget {
  const BrandOwnerDashboard({super.key});

  @override
  State<BrandOwnerDashboard> createState() => _BrandOwnerDashboardState();
}

class _BrandOwnerDashboardState extends State<BrandOwnerDashboard> {
  final BrandService _brandService = BrandService();
  final EventService _eventService = EventService();
  List<Brand> _myBrands = [];
  List<Event> _myEvents = [];
  bool _isLoading = true;
  int _selectedTab = 0; // 0 = Brands, 1 = Events
  final Color primaryColor = const Color(0xFFACBDAA);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final brands = await _brandService.getUserBrands();
      final allEvents = await _eventService.getAllEvents();
      
      // Filter events for user's brands
      final brandIds = brands.map((b) => b.id).toSet();
      final myEvents = allEvents.where((e) => brandIds.contains(e.brandId)).toList();

      setState(() {
        _myBrands = brands;
        _myEvents = myEvents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor.withOpacity(0.08),
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text(
          'Brand Owner Dashboard',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFACBDAA)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFACBDAA)),
            onPressed: _loadData,
          ),
        ],
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor.withOpacity(0.18), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFACBDAA)),
              )
            : Column(
                children: [
                  // Tabs
                  Container(
                    color: Colors.grey[50],
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildTabButton(0, 'My Brands', Icons.store),
                        ),
                        Expanded(
                          child: _buildTabButton(1, 'My Events', Icons.event),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Expanded(
                    child: _selectedTab == 0 ? _buildBrandsTab() : _buildEventsTab(),
                  ),
                ],
              ),
      ),
      floatingActionButton: _selectedTab == 0
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateBrandScreen(),
                  ),
                );
                _loadData();
              },
              backgroundColor: const Color(0xFFACBDAA),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateEventScreen(),
                  ),
                );
                _loadData();
              },
              backgroundColor: const Color(0xFFACBDAA),
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon) {
    final isSelected = _selectedTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFACBDAA).withOpacity(0.1) : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFFACBDAA) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFACBDAA) : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFFACBDAA) : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandsTab() {
    if (_myBrands.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            const Text(
              'No brands yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to create your first brand',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myBrands.length,
      itemBuilder: (context, index) {
        final brand = _myBrands[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BrandDetailScreen(brand: brand),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFACBDAA).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.store,
                      color: Color(0xFFACBDAA),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          brand.name.isEmpty ? 'Unnamed Brand' : brand.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          brand.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFFACBDAA),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventsTab() {
    if (_myEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            const Text(
              'No events yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to create your first event',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myEvents.length,
      itemBuilder: (context, index) {
        final event = _myEvents[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetailScreen(event: event),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFACBDAA).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.event,
                      color: Color(0xFFACBDAA),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${event.currentReservations}/${event.maxSeats} reserved',
                          style: TextStyle(
                            fontSize: 14,
                            color: event.isFull ? Colors.red : const Color(0xFFACBDAA),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFFACBDAA),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

