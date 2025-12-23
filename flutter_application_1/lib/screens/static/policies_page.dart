import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/app_layout.dart';
import 'package:flutter_application_1/widgets/footer.dart';

class PoliciesPage extends StatelessWidget {
  const PoliciesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: const Text(
          '''
Shipping Policy

Orders are processed within 1–3 business days.
Delivery time: 1–3 business days.
Shipping cost depends on location and payment method.
Tracking details are sent via email (Bosta).

Refund Policy

Returns must be requested within 14 days.
Items must be unworn, undamaged, with tags.
Sale items and accessories are non-refundable.
Shipping fees are non-refundable.

Contact:
wecare@golocal.com
WhatsApp: +2010666666666
          ''',
          style: TextStyle(height: 1.6),
        ),
      ),
      // bottomNavigationBar: const Footer(), 
    );
  }
}
