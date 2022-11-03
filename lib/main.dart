import 'package:flutter/material.dart';
import 'package:shop_app_flutter/helpers/custom_route.dart';
import 'package:shop_app_flutter/providers/cart.dart';
import 'package:shop_app_flutter/providers/orders.dart';
import 'package:shop_app_flutter/providers/products.dart';
import 'package:shop_app_flutter/screen/auth_screen.dart';
import 'package:shop_app_flutter/screen/cart_screen.dart';
import 'package:shop_app_flutter/screen/edit_product_screen.dart';
import 'package:shop_app_flutter/screen/order_screen.dart';
import 'package:shop_app_flutter/screen/product_detail_screen.dart';
import 'package:shop_app_flutter/screen/products_overview_screen.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_flutter/screen/splash_screen.dart';
import 'providers/auth.dart';
import 'screen/user_product_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => Auth()),
        ChangeNotifierProxyProvider<Auth, Products>(
            create: (context) => Products(),
            update: (ctx, auth, preProducts) =>
            preProducts!
              ..getData(
                  auth.token!,
                  auth.userId,
                  preProducts.items)),
        ChangeNotifierProvider(create: (ctx) => Cart()),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (ctx) => Orders([], '', ''),
          update: (ctx, auth, previousOrders) {
            return Orders(
              previousOrders == null ? [] : previousOrders.orders,
              auth.userId,
              auth.token!,
            );
          },
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) =>
            MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'MyShop',
                theme: ThemeData(
                    primarySwatch: Colors.blue,
                    accentColor: Colors.deepOrange,
                    fontFamily: 'Lato',
                    pageTransitionsTheme: PageTransitionsTheme(builders: {
                      TargetPlatform.android:CustomPageTransitionBuilder(),
                      TargetPlatform.iOS:CustomPageTransitionBuilder(),
                    })
                ),
                home: auth.isAuth
                    ? const ProductsOverviewScreen()
                    : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                  authResultSnapshot.connectionState ==
                      ConnectionState.waiting
                      ? const SplashScreen()
                      : AuthScreen(),
                ),
                routes: {
                  AuthScreen.routeName: (ctx) => AuthScreen(),
                  ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
                  CartScreen.routeName: (ctx) => CartScreen(),
                  OrderScreen.routeName: (ctx) => OrderScreen(),
                  UserProductsScreen.routeName: (
                      ctx) => const UserProductsScreen(),
                  EditProductScreen.routeName: (ctx) => EditProductScreen(),
                }),
      ),
    );
  }
}
