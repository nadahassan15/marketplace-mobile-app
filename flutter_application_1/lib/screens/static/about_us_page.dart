import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/app_layout.dart';
// import 'package:flutter_application_1/widgets/footer.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Center(
              child: Text(
                'ABOUT US',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            SizedBox(height: 24),

            Text(
              'INTRODUCING GOLOCAL: A HUB FOR LOCAL BRANDS AND COMMUNITY',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),

            SizedBox(height: 16),

            Text(
              'In a world dominated by global brands, it can be hard for local businesses to stand out. '
              'But what if there was a place where local brands could come together to showcase their '
              'products and connect with customers? That\'s where we come in.',
              style: TextStyle(height: 1.6),
            ),

            SizedBox(height: 16),

            Text(
              'Discover a curated collection of over 160 exceptional local brands, showcasing a diverse '
              'range of products from apparel and accessories to unique handcrafted items. Our platform '
              'is designed to foster collaboration, education, and community engagement.',
              style: TextStyle(height: 1.6),
            ),

            SizedBox(height: 24),

            Text(
              'Experience the Local Scene',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 12),

            Text(
              '• Explore: Immerse yourself in a vibrant marketplace featuring the best of local talent.',
              style: TextStyle(height: 1.6),
            ),

            SizedBox(height: 8),

            Text(
              '• Engage: Participate in dynamic events, workshops, and panel discussions hosted in our '
              'dedicated event space.',
              style: TextStyle(height: 1.6),
            ),

            SizedBox(height: 8),

            Text(
              '• Connect: Network with like-minded individuals who share a passion for supporting local businesses.',
              style: TextStyle(height: 1.6),
            ),

            SizedBox(height: 32),

            Center(
              child: Text(
                'Join us in celebrating local creativity and entrepreneurship.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),

            SizedBox(height: 40),
            // const Footer(),
          ],
        ),
      ),
    );
  }
}
