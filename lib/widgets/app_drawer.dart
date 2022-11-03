import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app_flutter/helpers/custom_route.dart';
import 'package:shop_app_flutter/screen/auth_screen.dart';
import 'package:shop_app_flutter/screen/order_screen.dart';

import '../screen/user_product_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';

class AppDrawer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(title:const Text('Hello Friend! '),
          automaticallyImplyLeading: false,),
          const Divider(),
          ListTile(
            leading:const Icon(Icons.shop),
            title:const Text('Shop'),
            onTap: (){
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          const Divider(),
          ListTile(
            leading:const Icon(Icons.payment),
            title:const Text('Order'),
            onTap: (){
              // Navigator.of(context).pushReplacement(CustomRoute(builder: (ctx)=>OrderScreen() ));
              Navigator.of(context).pushReplacementNamed(OrderScreen.routeName);
            },
          ),
          const  Divider(),
          ListTile(
            leading:const Icon(Icons.edit),
            title:const Text('Manage Products'),
            onTap: (){
              Navigator.of(context).pushReplacementNamed(UserProductsScreen.routeName);
            },
          ),
          const  Divider(),
          ListTile(
            leading:const Icon(Icons.exit_to_app),
            title:const Text('Logout'),
            onTap: (){
              // Navigator.of(context).pop();
              Navigator.of(context)
                  .pushReplacementNamed(AuthScreen.routeName);
              Provider.of<Auth>(context, listen: false).logout();

            },
          ),


        ],
      ),
    );
  }
}
