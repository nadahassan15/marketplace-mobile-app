import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/customer/product_details_screen.dart';
import 'package:flutter_application_1/widgets/app_layout.dart';
import 'package:flutter_application_1/widgets/footer.dart';
import 'package:flutter_application_1/screens/static/about_us_page.dart';
import 'package:flutter_application_1/screens/customer/products_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/responsive.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenPadding = Responsive.padding(context);
    final double titleFontSize =Responsive.fontSize(context, mobile: 24, tablet: 26, desktop: 28);
    final double bodyFontSize = Responsive.fontSize(context, mobile: 12, tablet: 14, desktop: 16);

    return AppLayout(
      drawer: const _MainMenuDrawer(),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                height: 260,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/images/homaimage.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: const [
                    _TopButton('NEW ARRIVALS'),
                    SizedBox(width: 12),
                    _TopButton('BEST SELLERS'),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ================= OLD FEMALE / MALE COLLECTIONS (COMMENTED OUT) =================
              // const Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 16),
              //   child: Text(
              //     'FEMALE COLLECTIONS',
              //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              //   ),
              // ),
              // const SizedBox(height: 16),
              // _CollectionRow(),
              //
              // const SizedBox(height: 32),
              //
              // const Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 16),
              //   child: Text(
              //     'MALE COLLECTIONS',
              //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              //   ),
              // ),
              // const SizedBox(height: 16),
              // _CollectionRow(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'COLLECTIONS',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 200,
                  child: Row(
                    children: const [
                      Expanded(child: _GenderTile(title: 'WOMEN')),
                      SizedBox(width: 12),
                      Expanded(child: _GenderTile(title: 'MEN')),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              _SectionHeader('EVERYDAY FITS'),
              _ProductsHorizontal(filter: 'everyday_fit'),

              const SizedBox(height: 32),

              _SectionHeader('SHOP HOODIES'),
              _ProductsHorizontal(filter: 'hoodie'),

              const SizedBox(height: 32),

              const Center(
                child: Text(
                  'FAQ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 16),

              FaqItem(
                title: 'What is GoLocal?',
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black87, height: 1.5),
                    children: [
                      const TextSpan(
                        text:
                            'An idea to support our community\'s creative economy while finding one-of-a-kind pieces. ',
                      ),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AboutUsPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'Get to know more About us',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              FaqItem(
                title: 'Where are your products made?',
                child: const Text(
                  'We\'re selling 100% Egyptian products crafted with local threads by our amazing Egyptian tailors.',
                  style: TextStyle(height: 1.5),
                ),
              ),

              FaqItem(
                title: 'How can I track my order?',
                child: const Text(
                  'You can track your order through Customer Area, link in the email sent by us, or by contacting our customer service email wecare@golocal.com',
                  style: TextStyle(height: 1.5),
                ),
              ),

              const SizedBox(height: 40),

              const Footer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _MainMenuDrawer extends StatefulWidget {
  const _MainMenuDrawer();

  @override
  State<_MainMenuDrawer> createState() => _MainMenuDrawerState();
}

class _MainMenuDrawerState extends State<_MainMenuDrawer> {
  String? activeMenu;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: _mainMenu(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _mainMenu() {
    return [
      _MenuItem(
        title: 'WOMEN',
        onTap: () {
          setState(() {
            activeMenu = activeMenu == 'women' ? null : 'women';
          });
        },
      ),
      if (activeMenu == 'women') ..._subMenu('women'),
      _MenuItem(
        title: 'MEN',
        onTap: () {
          setState(() {
            activeMenu = activeMenu == 'men' ? null : 'men';
          });
        },
      ),
      if (activeMenu == 'men') ..._subMenu('men'),
      const _MenuItem(title: 'SHOP BY BRAND'),
    ];
  }

  List<Widget> _subMenu(String gender) {
    return [
      _SubMenuItem(
        title: 'TOP',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const ProductsScreen(filter: 'top', title: 'Tops'),
            ),
          );
        },
      ),
      _SubMenuItem(
        title: 'BOTTOMS',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const ProductsScreen(filter: 'bottom', title: 'Bottoms'),
            ),
          );
        },
      ),
    ];
  }
}

// UI HELPERS

class _MenuItem extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const _MenuItem({required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.black,
      ),
      onTap: onTap,
    );
  }
}

class _SubMenuItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _SubMenuItem({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: ListTile(title: Text(title), onTap: onTap),
    );
  }
}

class _TopButton extends StatelessWidget {
  final String text;
  const _TopButton(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFACBDAA),
          border: Border.all(color: Color(0xFFACBDAA)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// class _CollectionRow extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 200,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         itemCount: 3,
//         separatorBuilder: (_, __) => const SizedBox(width: 12),
//         itemBuilder: (_, __) => Container(
//           width: 160,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             color: Colors.grey.shade300,
//           ),
//         ),
//       ),
//     );
//   }
// }

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  String get filter {
    switch (title) {
      case 'EVERYDAY FITS':
        return 'everyday_fit';
      case 'SHOP HOODIES':
        return 'hoodie';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: filter.isEmpty
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductsScreen(filter: filter, title: title),
                ),
              );
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}

// class _ProductsHorizontal extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 260,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         itemCount: 4,
//         separatorBuilder: (_, __) => const SizedBox(width: 12),
//         itemBuilder: (_, __) => Container(
//           width: 180,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             color: Colors.grey.shade200,
//           ),
//         ),
//       ),
//     );
//   }
// }

class _GenderTile extends StatelessWidget {
  final String title;

  const _GenderTile({required this.title});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductsScreen(
              filter: title.toLowerCase(),
              title: title, // women / men
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              title == 'WOMEN'
                  ? 'assets/images/womenimage.png'
                  : 'assets/images/menimage.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
            Container(color: Colors.black.withOpacity(0.3)),
            Center(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class _FaqItem extends StatelessWidget {
//   final String text;
//   const _FaqItem(this.text);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(8),
//           color: Colors.grey.shade200,
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [Text(text), const Icon(Icons.keyboard_arrow_down)],
//         ),
//       ),
//     );
//   }
// }

class FaqItem extends StatefulWidget {
  final String title;
  final Widget child;

  const FaqItem({super.key, required this.title, required this.child});

  @override
  State<FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<FaqItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Icon(
              _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            ),
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: widget.child,
            ),
        ],
      ),
    );
  }
}

class _ProductsHorizontal extends StatefulWidget {
  final String filter;
  const _ProductsHorizontal({required this.filter});

  @override
  State<_ProductsHorizontal> createState() => _ProductsHorizontalState();
}

class _ProductsHorizontalState extends State<_ProductsHorizontal> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadPreviewProducts(widget.filter);
    });
  }

  @override
  Widget build(BuildContext context) {
    final products =
        context.watch<ProductProvider>().previewProducts[widget.filter] ?? [];

    if (products.isEmpty) {
      return const SizedBox(height: 260);
    }

    return SizedBox(
      height: 260,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final product = products[index];

          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailsScreen(product: product),
                ),
              );
            },
            child: SizedBox(
              width: 180,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/${product.imagePath}',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('EGP ${product.price}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
