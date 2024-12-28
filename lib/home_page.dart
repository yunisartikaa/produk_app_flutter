import 'package:flutter/material.dart';
import 'dart:convert'; // Untuk mengelola JSON
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Import intl untuk format harga
import 'detail_produk.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      print("Fetching products from the server...");
      final response = await http.get(Uri.parse('http://172.22.192.1:3000/products'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map<String, dynamic> && data.containsKey('data')) {
          setState(() {
            products = data['data'];
            isLoading = false;
          });
          print("Successfully fetched ${products.length} products.");
        } else {
          throw Exception("Unexpected response format: $data");
        }
      } else {
        throw Exception("Failed to load products. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching products: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fungsi untuk memformat harga
  String formatPrice(int price) {
    return NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF37898C), // Warna latar belakang #37898C (hijau kebiruan)
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: Color.fromARGB(255, 54, 122, 125), // Warna AppBar
        title: Text(
          "Daftar Produk",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  elevation: 5.0,
                  margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                  color: Color(0xFF9DD8D4), // Warna emas terang untuk card
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(12.0),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(0.0),
                      leading: Container(
                        padding: EdgeInsets.only(right: 12.0),
                        decoration: BoxDecoration(
                          border: Border(right: BorderSide(width: 1.0, color: Colors.white70)),
                        ),
                        child: Icon(Icons.shopping_cart, color: Colors.white),
                      ),
                      title: Text(
                        product['name'] ?? 'Nama produk tidak tersedia',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18.0),
                      ),
                      subtitle: Text(
                        "Rp ${formatPrice(product['price'] ?? 0)}",
                        style: TextStyle(color: Colors.white70, fontSize: 14.0),
                      ),
                      trailing: Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailProdukPage(productId: product['id']),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
