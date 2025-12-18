// import 'package:flutter/material.dart';
// import '../../models/cart_item_model.dart';

// class CartItemCard extends StatelessWidget {
//   final CartItem item;
//   final VoidCallback onAdd;
//   final VoidCallback onRemove;
//   final VoidCallback onDelete;

//   const CartItemCard({
//     super.key,
//     required this.item,
//     required this.onAdd,
//     required this.onRemove,
//     required this.onDelete,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: ListTile(
//         // leading: Image.network(item.image, width: 50),
//         title: Text(item.name),
//         subtitle: Text('EGP ${item.price}'),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             IconButton(onPressed: onRemove, icon: const Icon(Icons.remove)),
//             Text(item.quantity.toString()),
//             IconButton(onPressed: onAdd, icon: const Icon(Icons.add)),
//             IconButton(onPressed: onDelete, icon: const Icon(Icons.delete)),
//           ],
//         ),
//       ),
//     );
//   }
// }
