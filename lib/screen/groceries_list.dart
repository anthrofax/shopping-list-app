import 'dart:convert';

import "package:http/http.dart" as http;

import 'package:flutter/material.dart';
import 'package:learn_flutter/data/categories.dart';
import 'package:learn_flutter/models/grocery.dart';
import 'package:learn_flutter/screen/add_new_item_screen.dart';
import 'package:learn_flutter/widget/grocery_item.dart';

class GroceriesList extends StatefulWidget {
  const GroceriesList({super.key});

  @override
  State<GroceriesList> createState() => _GroceriesListState();
}

class _GroceriesListState extends State<GroceriesList> {
  List<Grocery> groceriesList = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    try {
      final url = Uri.https(
          "flutter-prep-fe77f-default-rtdb.asia-southeast1.firebasedatabase.app",
          "shopping-list.json");

      final response = await http.get(url);

      if (response.statusCode >= 400) {
        setState(() {
          _error = "Failed to load items. Please try again later.";
        });
      }

      if (response.body == "null") {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      Map<String, dynamic> result = json.decode(response.body);
      List<Grocery> tempGroceryList = [];

      for (final item in result.entries) {
        final category = categories.entries.firstWhere(
            (catData) => catData.value.categoryName == item.value['category']);

        tempGroceryList.add(Grocery(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category.value));
      }

      setState(() {
        groceriesList = tempGroceryList;
        _isLoading = false;
      });
    } catch (err) {
      setState(() {
        _error = "There's something wrong in the application.";
      });
    }
  }

  void _addItem() async {
    Grocery? newItem = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (ctx) => const AddNewItemScreen()));

    if (newItem == null) {
      return;
    }

    setState(() {
      groceriesList.add(newItem);
    });
  }

  void _deleteItem(Grocery item) async {
    final index = groceriesList.indexOf(item);

    setState(() {
      groceriesList.remove(item);
    });

    final url = Uri.https(
        "flutter-prep-fe77f-default-rtdb.asia-southeast1.firebasedatabase.app",
        "shopping-list/${item.id}.json");

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      setState(() {
        groceriesList.insert(index, item);
      });

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Failed to delete item. Please try again later.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text("No Groceries"));

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      content = Center(child: Text(_error!));
    }

    if (groceriesList.isNotEmpty) {
      content = ListView.builder(
          itemCount: groceriesList.length,
          itemBuilder: (ctx, i) => Dismissible(
                key: ValueKey(groceriesList[i].id),
                onDismissed: (direction) {
                  _deleteItem(groceriesList[i]);
                },
                child: GroceryItem(
                  key: ValueKey(groceriesList[i].id),
                  name: groceriesList[i].name,
                  quantity: groceriesList[i].quantity,
                  color: groceriesList[i].category.color,
                ),
              ));
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Your Groceries',
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: Theme.of(context).colorScheme.onSurface),
          ),
          actions: [
            IconButton(
              onPressed: _addItem,
              icon: const Icon(Icons.add),
            )
          ],
          centerTitle: false,
        ),
        body: content);
  }
}
