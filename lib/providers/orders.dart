import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app_flutter/providers/cart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({required this.id,
    required this.amount,
    required this.products,
    required this.dateTime});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
   String authToken;
   String userId;


  Orders(this._orders, this.authToken,this.userId);

  List<OrderItem> get orders {
    return [..._orders];
  }


  Future<void> fetchAndSetOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final extractedUserData = await json.decode(prefs.getString('userData')!);
    final expiryDate = DateTime.parse(extractedUserData['expiryDate'] );
    authToken =await extractedUserData['token'];
    userId =await extractedUserData['userId'] ;
    print('fetchAndSetOrders $authToken');
    print('fetchAndSetOrders $userId');
    final url = Uri.parse('https://shopappflutter-ec047-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(
        OrderItem(
          id: orderId,
          amount: orderData['amount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          products: (orderData['products'] as List<dynamic>)
              .map(
                (item) => CartItem(
              id: item['id'],
              price: item['price'],
              quantity: item['quantity'],
              title: item['title'],
            ),
          )
              .toList(),
        ),
      );
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final prefs = await SharedPreferences.getInstance();
    final extractedUserData = await json.decode(prefs.getString('userData')!);
    final expiryDate = DateTime.parse(extractedUserData['expiryDate'] );
    authToken =await extractedUserData['token'];
    userId =await extractedUserData['userId'] ;
    print('addOrder $authToken');
    print('addOrder $userId');
    final url = Uri.parse('https://shopappflutter-ec047-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    final timestamp = DateTime.now();
    final response = await http.post(
      url,
      body: json.encode({
        'amount': total,
        'dateTime': timestamp.toIso8601String(),
        'products': cartProducts
            .map((cp) => {
          'id': cp.id,
          'title': cp.title,
          'quantity': cp.quantity,
          'price': cp.price,
        })
            .toList(),
      }),
    );
    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        amount: total,
        dateTime: timestamp,
        products: cartProducts,
      ),
    );
    notifyListeners();
  }
}

