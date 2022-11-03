import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Product with ChangeNotifier {
final String id;
final String title;
final String description;
final double price;
final String imageUrl;
bool isFavorite;

Product({required this.id,required this.title,required this.description,required this.price,required this.imageUrl,
       this.isFavorite=false});

       void _setFavValue(bool newValue) {
              isFavorite=newValue;
              notifyListeners();
       }

Future<void> toggleFavoriteStatus(String token, String userId) async {
  final prefs = await SharedPreferences.getInstance();
  final extractedUserData = await json.decode(prefs.getString('userData')!);
  final expiryDate = DateTime.parse(extractedUserData['expiryDate'] );
  token =await extractedUserData['token'];
  userId =await extractedUserData['userId'] ;
  print('toggleFavoriteStatus $token');
  print('toggleFavoriteStatus $userId');
  final oldStatus = isFavorite;
  isFavorite = !isFavorite;
  notifyListeners();
  final url =
  Uri.parse('https://shopappflutter-ec047-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$token');
  try {
    final response = await http.put(
      url,
      body: json.encode(
        isFavorite,
      ),
    );
    if (response.statusCode >= 400) {
      _setFavValue(oldStatus);
      print('400> $oldStatus');
    }
  } catch (error) {
    _setFavValue(oldStatus);
    print('error$oldStatus');

  }
}



}
