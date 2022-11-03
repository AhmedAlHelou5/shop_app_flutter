import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../model/http_exception.dart';
import './product.dart';
import 'auth.dart';

class Products with ChangeNotifier {
  List<Product> _products = [];
  String?  authToken;
  String? userId;


   List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

   getData(String authToken,String uId,List<Product>products) {
     authToken = authToken  ;
     userId=uId;
     _items=products ;
     notifyListeners();


   }


  // var _showFavoritesOnly = false;


  // final prefs=  SharedPreferences.getInstance() as dynamic  ;
  //  String? token =  prefs.getString('token') ;
  //  String? userId = prefs.getString('userId');
  //  String? expiryDate = prefs.getString('expiryDate');

  // Products(this.authToken,this.userId,this._items);




  List<Product> get items {
    return [..._items];
  }





  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }


  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final prefs = await SharedPreferences.getInstance();
      final extractedUserData =  json.decode(prefs.getString('userData')!);
      authToken = extractedUserData['token'];
      userId = extractedUserData['userId'] ;
      print('fetchAndSetProducts $authToken from extractedUserData ');
      print('fetchAndSetProducts $userId from extractedUserData ');

    final filterString = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var urls =
       Uri.parse('https://shopappflutter-ec047-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString');
    try {

      final response = await http.get(urls);
      print('urls $urls');

      final extractedData = json.decode(response.body)as Map<String, dynamic>;
      if (extractedData == null) {
        print('extractedData is empty');
        print(extractedData);
        return;
      }

     var url = Uri.parse('https://shopappflutter-ec047-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken');
      final favoriteResponse = await http.get(url);
      print('url $url');
      final favoriteData = json.decode(favoriteResponse.body) as Map<dynamic, dynamic>;
      print(favoriteData.toString());
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(
            Product(
          id: prodId,
          title: prodData["title"] ,
          description: prodData["description"],
          price: prodData["price"] ,
          isFavorite:
          favoriteData == null  ? false : favoriteData[prodId] ?? false  ,
          imageUrl: prodData["imageUrl"],
        ));
      });
      _items = loadedProducts;
      print(_items.toString());
      notifyListeners();
    } catch (error) {
      print(error.toString());
      rethrow;
    }
  }


  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }
  // Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final extractedUserData = await json.decode(prefs.getString('userData')!);
  //   final expiryDate = DateTime.parse(extractedUserData['expiryDate'] );
  //   authToken =await extractedUserData['token'];
  //   userId =await extractedUserData['userId'] ;
  //   print('fetchAndSetProducts $authToken from extractedUserData ');
  //   print('fetchAndSetProducts $userId from extractedUserData ');
  //   final filterString = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
  //   var url =
  //   Uri.parse('https://shopappflutter-ec047-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString');
  //   print('token = $authToken');
  //   print('userId = $userId');
  //   print(url);
  //   try {
  //     final response = await http.get(url);
  //
  //     final extractedData = json.decode(response.body) as Map<String, dynamic> ;
  //     print(extractedData.toString());
  //     if (response.statusCode == 200) {
  //       return print(response.statusCode);
  //     }
  //
  //     print ('data $extractedData');
  //     if (extractedData == null || extractedData.isEmpty) {
  //       return;
  //     }
  //     // https://shopappflutter-ec047-default-rtdb.firebaseio.com/
  //     url =
  //         Uri.parse('https://shopappflutter-ec047-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken');
  //     print('userFavorites token = $authToken');
  //     print('userFavorites userId = $userId');
  //     print('url $url');
  //     final favoriteResponse = await http.get(url);
  //     final favoriteData = json.decode(favoriteResponse.body);
  //     final List<Product> loadedProducts = [] ;
  //     print('loadedProducts = $loadedProducts ');
  //     extractedData.forEach((prodId, prodData) {
  //       loadedProducts.add(
  //           Product(
  //
  //         id: prodId,
  //         title: prodData['title'] ,
  //         description: prodData['description'],
  //         price: prodData['price'] ,
  //         isFavorite: favoriteData == null ? false : favoriteData[prodId] ?? false  ,
  //         imageUrl: prodData['imageUrl'] ,
  //       ));
  //     });
  //     _items = loadedProducts;
  //     print('items = $items ');
  //     print('loadedProducts after = $loadedProducts ');
  //     notifyListeners();
  //   } catch (error) {
  //     print (error);
  //     // print ('i dont know token || user id');
  //     rethrow;
  //   }
  // }


  Future<void> addProduct(Product product) async {
    final prefs = await SharedPreferences.getInstance();
    final extractedUserData = await json.decode(prefs.getString('userData')!);
    final expiryDate = DateTime.parse(extractedUserData['expiryDate'] );
    authToken =await extractedUserData['token'];
    userId =await extractedUserData['userId'] ;
    print('addProduct $authToken');
    print('addProduct $userId');
    final url =
    Uri.parse('https://shopappflutter-ec047-default-rtdb.firebaseio.com/products.json?auth=$authToken');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title ,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price ,
          'isFavorite': product.isFavorite ,
          'creatorId': userId ,
        }),
      );
      final newProduct = Product(
        title: product.title ,
        description: product.description ,
        price: product.price ,
        imageUrl: product.imageUrl ,
        isFavorite: product.isFavorite ,
        id: json.decode(response.body)['name'] ,
      );
      _items.add(newProduct);
      // _items.insert(0, newProduct); // at the start of the list
      notifyListeners();
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prefs = await SharedPreferences.getInstance();
    final extractedUserData = await json.decode(prefs.getString('userData')!);
    final expiryDate = DateTime.parse(extractedUserData['expiryDate'] );
    authToken =await extractedUserData['token'];
    userId =await extractedUserData['userId'] ;
    print('updateProduct $authToken');
    print('updateProduct $userId');
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
      Uri.parse('https://shopappflutter-ec047-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description  ,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price ,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final extractedUserData = await json.decode(prefs.getString('userData')!);
    final expiryDate = DateTime.parse(extractedUserData['expiryDate'] );
    authToken =await extractedUserData['token'];
    userId =await extractedUserData['userId'] ;
    print('deleteProduct $authToken');
    print('deleteProduct $userId');
    final url =
    Uri.parse('https://shopappflutter-ec047-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    Product? existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url );
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }
}
