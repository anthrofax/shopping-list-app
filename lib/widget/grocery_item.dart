import 'package:flutter/material.dart';

class GroceryItem extends StatelessWidget {
  const GroceryItem(
      {super.key,
      required this.color,
      required this.name,
      required this.quantity});

  final Color color;
  final String name;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Container(
              width: 48,
              height: 48,
              color: color,
            ),
            const SizedBox(
              width: 12,
            ),
            Text(name)
          ]),
          Text(
            quantity.toString(),
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          )
        ],
      ),
    );
  }
}
