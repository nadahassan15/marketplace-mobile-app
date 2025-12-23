import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/checkout_provider.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CheckoutProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              'Contact',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: provider.emailController,
              decoration: InputDecoration(
                labelText: 'Email or mobile phone number',
                errorText: provider.emailError,
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Delivery',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            TextField(
              decoration: const InputDecoration(
                labelText: 'First name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              decoration: const InputDecoration(
                labelText: 'Last name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: provider.addressController,
              decoration: InputDecoration(
                labelText: 'Address',
                errorText: provider.addressError,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              decoration: const InputDecoration(
                labelText: 'City',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: provider.governorate,
              items: const [
                DropdownMenuItem(value: 'Cairo', child: Text('Cairo')),
                DropdownMenuItem(value: 'Giza', child: Text('Giza')),
                DropdownMenuItem(value: 'Alexandria', child: Text('Alexandria')),
                DropdownMenuItem(value: 'Aswan', child: Text('Aswan')),
                DropdownMenuItem(value: 'Asyut', child: Text('Asyut')),
                DropdownMenuItem(value: 'Beheira', child: Text('Beheira')),
                DropdownMenuItem(value: 'Beni Suef', child: Text('Beni Suef')),
                DropdownMenuItem(value: 'Dakahlia', child: Text('Dakahlia')),
                DropdownMenuItem(value: 'Damietta', child: Text('Damietta')),
                DropdownMenuItem(value: 'Faiyum', child: Text('Faiyum')),
                DropdownMenuItem(value: 'Gharbia', child: Text('Gharbia')),
                DropdownMenuItem(value: 'Ismailia', child: Text('Ismailia')),
                DropdownMenuItem(value: 'Kafr El Sheikh', child: Text('Kafr El Sheikh')),
                DropdownMenuItem(value: 'Luxor', child: Text('Luxor')),
                DropdownMenuItem(value: 'Matrouh', child: Text('Matrouh')),
                DropdownMenuItem(value: 'Minya', child: Text('Minya')),
                DropdownMenuItem(value: 'Monufia', child: Text('Monufia')),
                DropdownMenuItem(value: 'New Valley', child: Text('New Valley')),
                DropdownMenuItem(value: 'North Sinai', child: Text('North Sinai')),
                DropdownMenuItem(value: 'Port Said', child: Text('Port Said')),
                DropdownMenuItem(value: 'Qalyubia', child: Text('Qalyubia')),
                DropdownMenuItem(value: 'Qena', child: Text('Qena')),
                DropdownMenuItem(value: 'Red Sea', child: Text('Red Sea')),
                DropdownMenuItem(value: 'Sharqia', child: Text('Sharqia')),
                DropdownMenuItem(value: 'Sohag', child: Text('Sohag')),
                DropdownMenuItem(value: 'South Sinai', child: Text('South Sinai')),
                DropdownMenuItem(value: 'Suez', child: Text('Suez')),
              ],
              onChanged: (value) {
                provider.governorate = value!;
                provider.notifyListeners();
              },
              decoration: const InputDecoration(
                labelText: 'Governorate',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: provider.phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone',
                errorText: provider.phoneError,
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Shipping method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            const _CardRow(
              title: 'Standard Shipping',
              subtitle: 'Delivery in 2–3 days',
              trailing: 'E£90.00',
            ),

            const SizedBox(height: 24),

            const Text(
              'Payment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            const _CardRow(
              title: 'Cash on Delivery (COD)',
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                onPressed: provider.submitOrder,
                child: const Text(
                  'Complete order',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? trailing;

  const _CardRow({
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 0, 0, 0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              if (subtitle != null)
                Text(subtitle!, style: const TextStyle(color: Colors.grey)),
            ],
          ),
          if (trailing != null)
            Text(trailing!, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
