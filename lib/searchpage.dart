import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Item {
  final String imageUrl;
  final String name;
  final String mrp;
  final String weight;
  final String quantity;
  final String cart;
  final String category;
  final String details;

  Item({
    required this.imageUrl,
    required this.name,
    required this.mrp,
    required this.weight,
    required this.quantity,
    required this.cart,
    required this.category,
    required this.details,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      imageUrl: json['image'],
      name: json['title'],
      mrp: json['price'],
      weight: json['wt'],
      quantity: json['qty'],
      cart: json['cart'],
      category: json['category'],
      details: json['details'],
    );
  }
}

Future<List<Item>> fetchItems() async {
  final response =
      await http.get(Uri.parse('http://kudalebandhubhajiwale.com/api/getData'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    List<dynamic> itemsJson = data['item'];
    return itemsJson.map((item) => Item.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load items');
  }
}

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Item>> _itemsFuture;
  List<Item> _allItems = []; // To store the full list of items
  List<Item> _filteredItems = []; // To store the filtered list of items

  @override
  void initState() {
    super.initState();
    _itemsFuture = fetchItems().then((items) {
      setState(() {
        _allItems = items;
        _filteredItems = items; // Initialize filtered items with the full list
      });
      return items;
    });
  }

  void _filterItems(String query) {
    setState(() {
      _filteredItems = _allItems.where((item) {
        return item.name.toLowerCase().contains(query.toLowerCase().trim());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Item>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No items found'));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search fruit or vegetable name',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _filterItems, // Filter items on text change
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = _filteredItems[index];
                    return Container(
                      // height: 100,
                        color: index % 2 == 0 ? Colors.black12 : Colors.grey[200], // Set the background color here
                        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    child: ListTile(
                      leading:
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: CachedNetworkImage(
                          imageUrl:
                            'https://kudalebandhubhajiwale.com/'+item.imageUrl,
                          width: 100.0, // Fixed width
                          height: 100.0, // Fixed height
                          fit: BoxFit.cover, // Crop the image to center
                          placeholder: (context, url) => const CircularProgressIndicator(
                            strokeWidth: 1,
                            color: Colors.green,
                          ), // Show a loading spinner while the image is loading
                          errorWidget: (context, url, error) => const Icon(Icons.error), // Show an error icon if the image fails to load
                        ),
                      ),
                      title: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,fontWeight:FontWeight.normal,
                          )
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // Align text to the start
                        children: [
                          const SizedBox(height: 6,),
                          Text(
                              item.weight,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                              )
                          ),
                          const SizedBox(height: 6,),
                          Text(
                              'Rs. ${item.mrp}',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight:FontWeight.bold,
                              )
                          ),
                          const SizedBox(height: 10,),
                          // Add more text widgets here if needed
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.shopping_cart),
                        onPressed: () {
                          // Handle cart icon press
                        },
                      ),
                    ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}