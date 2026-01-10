import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/brand.dart';
import 'chat_screen.dart';

class BrandDetailScreen extends StatelessWidget {
  final Brand brand;

  const BrandDetailScreen({super.key, required this.brand});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFACBDAA);
    return Scaffold(
      backgroundColor: primaryColor.withOpacity(0.08),
      appBar: AppBar(
        title: Text(
          brand.name.isEmpty ? 'Brand Details' : brand.name,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFACBDAA)),
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (brand.logoPath != null)
                Image.network(
                  brand.logoPath!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 50),
                    );
                  },
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      brand.name.isEmpty ? 'Unnamed Brand' : brand.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      brand.description.isEmpty ? 'No description available' : brand.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: kIsWeb
                          ? Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.location_on, size: 48),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Lat: ${brand.latitude.toStringAsFixed(6)}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      'Lng: ${brand.longitude.toStringAsFixed(6)}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        final url = Uri.parse('https://www.google.com/maps?q=${brand.latitude},${brand.longitude}');
                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(url, mode: LaunchMode.externalApplication);
                                        } else {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Could not open Google Maps')),
                                            );
                                          }
                                        }
                                      },
                                      icon: const Icon(Icons.map),
                                      label: const Text('View Location'),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: LatLng(brand.latitude, brand.longitude),
                                zoom: 15,
                              ),
                              markers: {
                                Marker(
                                  markerId: MarkerId(brand.id),
                                  position: LatLng(brand.latitude, brand.longitude),
                                  infoWindow: InfoWindow(title: brand.name),
                                ),
                              },
                              zoomControlsEnabled: true,
                              myLocationButtonEnabled: false,
                              onTap: (LatLng position) async {
                                final url = Uri.parse('https://www.google.com/maps?q=${brand.latitude},${brand.longitude}');
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url, mode: LaunchMode.externalApplication);
                                }
                              },
                            ),
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(brandId: brand.id),
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat),
                        label: const Text('Contact Brand'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFACBDAA),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

