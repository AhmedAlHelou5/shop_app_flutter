import 'package:flutter/material.dart';
import '../providers/cart.dart' show Cart;
import 'package:provider/provider.dart';
import 'package:shop_app_flutter/widgets/cartItem.dart' as ci;

import '../providers/orders.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your CartScreen'),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      '\$ ${cart.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                          color: Theme
                              .of(context)
                              .primaryTextTheme
                              .headline6
                              ?.color),
                    ),
                    backgroundColor: Theme
                        .of(context)
                        .primaryColor,
                  ),
                  OrderButton(cart: cart),

                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
              child: ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (ctx, i) =>
                      ci.CartItem(
                          cart.items.values.toList()[i].id,
                          cart.items.keys.toList()[i],
                          cart.items.values.toList()[i].price,
                          cart.items.values.toList()[i].quantity,
                          cart.items.values.toList()[i].title)))
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
final Cart cart;

OrderButton({required this.cart});

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return   TextButton(
        onPressed: (widget.cart.totalAmount <=0 ||_isLoading) ? null : () async{
          setState(() {
            _isLoading = true;
          });
        await  Provider.of<Orders>(context,listen: false).addOrder(
              widget.cart.items.values.toList(),
              widget.cart.totalAmount);
          setState(() {
            _isLoading = false;
          });
          widget.cart.clear();
        },

        child:_isLoading ? CircularProgressIndicator(): Text(
          'ORDER NOW',
          style: TextStyle(color: Theme
              .of(context)
              .primaryColor),
        ));
  }
}
