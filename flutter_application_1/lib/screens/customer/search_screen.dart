import 'package:flutter/material.dart';
import '../../utils/responsive.dart';

class AppSearchDelegate extends SearchDelegate<String?> {
  @override
  String get searchFieldLabel => 'Search products or brands';
  @override
  List<Widget>? buildActions(BuildContext context) {
        final double screenPadding = Responsive.padding(context);
    final double titleFontSize =Responsive.fontSize(context, mobile: 24, tablet: 26, desktop: 28);
    final double bodyFontSize = Responsive.fontSize(context, mobile: 12, tablet: 14, desktop: 16);

    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }
  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Text(
        'Search results for "$query"',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center();
  }
}
