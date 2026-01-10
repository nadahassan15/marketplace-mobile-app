import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/brand.dart';
import '../services/brand_service.dart';
import 'brand_detail_screen.dart';

const Color primaryColor = Color(0xFFACBDAA);

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final BrandService _brandService = BrandService();
  GoogleMapController? _mapController;

  List<Brand> _brands = [];
  bool _isLoading = true;
  Brand? _selectedBrand;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(24.7136, 46.6753),
    zoom: 12,
  );

  static const String _mapStyle = '''
[
  {
    "featureType": "poi",
    "stylers": [{"visibility": "off"}]
  },
  {
    "featureType": "transit",
    "stylers": [{"visibility": "off"}]
  }
]
''';

  @override
  void initState() {
    super.initState();
    _loadBrands();
  }

  Future<void> _loadBrands() async {
    try {
      final brands = await _brandService.getAllBrands();
      setState(() {
        _brands = brands;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading brands: $e'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _loadBrands,
            ),
          ),
        );
      }
    }
  }

  Set<Marker> _getMarkers() {
    return _brands.map((brand) {
      final isSelected = _selectedBrand?.id == brand.id;
      return Marker(
        markerId: MarkerId(brand.id),
        position: LatLng(brand.latitude, brand.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          isSelected
              ? BitmapDescriptor.hueAzure
              : BitmapDescriptor.hueRed,
        ),
        onTap: () {
          setState(() => _selectedBrand = brand);
          _mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(brand.latitude, brand.longitude),
                zoom: 15.5,
                tilt: 45,
                bearing: 30,
              ),
            ),
          );
        },
      );
    }).toSet();
  }

  String _formatLocation(double lat, double lng) {
    return '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
  }

void _navigateToBrand(Brand brand) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BrandDetailScreen(brand: brand),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
      );
    }

    if (_brands.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Brand Locations')),
        body: const Center(
          child: Text(
            'No brands available',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: primaryColor.withOpacity(0.08),
      appBar: AppBar(
        title: const Text('Brand Locations'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor.withOpacity(0.18), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: GoogleMap(
                initialCameraPosition: _initialPosition,
                markers: _getMarkers(),
                myLocationEnabled: !kIsWeb,
                myLocationButtonEnabled: !kIsWeb,
                zoomControlsEnabled: false,
                onMapCreated: (controller) {
                  _mapController = controller;
                  controller.setMapStyle(_mapStyle);
                },
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.35,
            minChildSize: 0.2,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.96),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.35),
                      blurRadius: 24,
                      offset: const Offset(0, -10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Found Brands',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3A4D39),
                            ),
                          ),
                          Text(
                            '${_brands.length} results',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _brands.length,
                        itemBuilder: (_, index) {
                          return _buildBrandCard(_brands[index]);
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBrandCard(Brand brand) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToBrand(brand),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
               ClipRRect(
  borderRadius: BorderRadius.circular(8),
  child: Image.network(
    brand.logoPath ?? '',
    width: 80,
    height: 80,
    fit: BoxFit.cover,
    loadingBuilder: (context, child, progress) {
      if (progress == null) return child;
      return Container(
        width: 80,
        height: 80,
        color: primaryColor.withOpacity(0.1),
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    },
    errorBuilder: (context, error, stackTrace) {
      return Container(
        width: 80,
        height: 80,
        color: primaryColor.withOpacity(0.2),
        child: const Icon(
          Icons.store,
          color: Colors.black45,
          size: 40,
        ),
      );
    },
  ),
),

                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        brand.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatLocation(
                            brand.latitude, brand.longitude),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '4.5',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Available',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final url = 'https://www.google.com/maps/search/?api=1&query=${brand.latitude},${brand.longitude}';
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not open Google Maps')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.black87,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Icon(Icons.navigation, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
