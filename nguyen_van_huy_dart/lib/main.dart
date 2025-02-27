import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class Order {
  String item;
  String itemName;
  double price;
  String currency;
  int quantity;

  Order({required this.item, required this.itemName, required this.price, required this.currency, required this.quantity});

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      item: json['Item'],
      itemName: json['ItemName'],
      price: (json['Price'] as num).toDouble(),
      currency: json['Currency'],
      quantity: json['Quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Item': item,
      'ItemName': itemName,
      'Price': price,
      'Currency': currency,
      'Quantity': quantity,
    };
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Order> orders = [];
  TextEditingController searchController = TextEditingController();
  TextEditingController itemController = TextEditingController();
  TextEditingController itemNameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController currencyController = TextEditingController();
  TextEditingController quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  Future<void> loadOrders() async {
    String data = '[{"Item": "A1000","ItemName": "Iphone 15","Price": 1200,"Currency":"USD","Quantity":1},{"Item": "A1001","ItemName": "Iphone 16","Price":1500,"Currency": "USD","Quantity":1}]';
    setState(() {
      orders = (jsonDecode(data) as List).map((e) => Order.fromJson(e)).toList();
    });
  }

  void addOrder() {
    setState(() {
      orders.add(Order(
        item: itemController.text,
        itemName: itemNameController.text,
        price: double.parse(priceController.text),
        currency: currencyController.text,
        quantity: int.parse(quantityController.text),
      ));
    });
  }

  void searchOrder() {
    String searchText = searchController.text.toLowerCase();
    setState(() {
      orders = orders.where((order) => order.itemName.toLowerCase().contains(searchText)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('My Order')),
        body: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              TextField(controller: searchController, decoration: InputDecoration(labelText: 'Search Item Name'), onChanged: (_) => searchOrder()),
              Row(
                children: [
                  Expanded(child: TextField(controller: itemController, decoration: InputDecoration(labelText: 'Item'))),
                  Expanded(child: TextField(controller: itemNameController, decoration: InputDecoration(labelText: 'Item Name'))),
                ],
              ),
              Row(
                children: [
                  Expanded(child: TextField(controller: priceController, decoration: InputDecoration(labelText: 'Price'))),
                  Expanded(child: TextField(controller: quantityController, decoration: InputDecoration(labelText: 'Quantity'))),
                  Expanded(child: TextField(controller: currencyController, decoration: InputDecoration(labelText: 'Currency'))),
                ],
              ),
              ElevatedButton(onPressed: addOrder, child: Text('Add Item to Cart')),
              Expanded(
                child: ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('${orders[index].itemName} (${orders[index].item})'),
                      subtitle: Text('Price: ${orders[index].price} ${orders[index].currency}, Quantity: ${orders[index].quantity}'),
                      trailing: IconButton(icon: Icon(Icons.delete), onPressed: () {
                        setState(() {
                          orders.removeAt(index);
                        });
                      }),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<List<Order>> readOrdersFromFile(String filePath) async {
  final file = File(filePath);
  if (!await file.exists()) return [];
  final contents = await file.readAsString();
  List<dynamic> jsonData = jsonDecode(contents);
  return jsonData.map((json) => Order.fromJson(json)).toList();
}

Future<void> writeOrdersToFile(String filePath, List<Order> orders) async {
  final file = File(filePath);
  String jsonString = jsonEncode(orders.map((order) => order.toJson()).toList());
  await file.writeAsString(jsonString);
}
