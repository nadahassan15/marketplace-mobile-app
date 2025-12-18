import 'package:flutter/material.dart';
import '../screens/static/about_us_page.dart';
import '../screens/static/policies_page.dart';
import '../screens/static/contact_us_page.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, 
      color: const Color(0xFFACBDAA),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FooterLink(
            context,
            'Shipping & Refund Policy',
            const PoliciesPage(),
          ),
          _FooterLink(context, 'About Us', const AboutUsPage()),
          _FooterLink(context, 'Contact Us', const ContactUsPage()),
        ],
      ),
    );
  }
}

Widget _FooterLink(BuildContext context, String text, Widget page) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          decoration: TextDecoration.none,
        ),
      ),
    ),
  );
}
