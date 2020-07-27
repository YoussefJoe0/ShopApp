import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopapp/helpers/custom_route.dart';
import 'package:shopapp/providers/auth.dart';
import 'package:shopapp/screens/auth_screen.dart';
import 'package:shopapp/screens/order_screen.dart';
import 'package:shopapp/screens/product_screen.dart';
import 'package:shopapp/screens/user_product_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text('Hello Man!'),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('Shop'),
            onTap: () {
              Navigator.pushReplacementNamed(
                  context, ProductOverviewScreen.routNamed);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text('Orders'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(
                OrderScreen.routNamed,
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Manage Product'),
            onTap: () {
              Navigator.pushReplacementNamed(
                  context, UserProductsScreen.routNamed);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () async {
              SharedPreferences pref = await SharedPreferences.getInstance();
              pref.clear();
              Navigator.of(context).pushReplacementNamed(AuthScreen.routNamed);
              Provider.of<Auth>(context, listen: false).logout();
            },
          ),
        ],
      ),
    );
  }
}
