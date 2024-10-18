import 'package:flutter/material.dart';
import 'package:grid_lookup/grid_lookup.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    List<Product> products = [
      Product('Laptop', 999.99, 20),
      Product('Phone', 499.99, 50),
      Product('Tablet', 299.99, 30),
    ];
    List<Map<String, dynamic>> productData =
        products.map((p) => p.toMap()).toList();
    // Create the data source for GridLookup
    final dataSource = GridLookupDataSorce<Map<String, dynamic>>(
      data: productData,
      columns: ['productName', 'price', 'stock'], // Define columns to display
    );
    return MaterialApp(
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Color Scheme Toggle"),
        ),
        body: Builder(
          builder: (context) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GridLookup<Map<String, dynamic>>(
                    dataSource: dataSource,
                    inputHeight: 50,
                    buttonSize: 50,
                    inputWidth: 300,
                    tableHeight: 200,
                    onSelectedMenu: (selectedValue) {
                      print('Selected: $selectedValue');
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class Product extends GridLookupClass {
  final String productName;
  final double price;
  final int stock;

  Product(this.productName, this.price, this.stock);

  // Convert Product object to Map<String, dynamic>
  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'price': price,
      'stock': stock,
    };
  }
}
