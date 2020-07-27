import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopapp/providers/auth.dart';
import 'package:shopapp/providers/cart.dart';
import 'package:shopapp/providers/orders.dart';
import 'package:shopapp/screens/auth_screen.dart';
import 'package:shopapp/screens/cart_screen.dart';
import 'package:shopapp/screens/edit_product_screen.dart';
import 'package:shopapp/screens/order_screen.dart';
import 'package:shopapp/screens/product_screen.dart';
import 'package:shopapp/screens/user_product_screen.dart';

import './screens/product_details_screen.dart';
import './providers/products.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  bool isUserLoggedIn = false;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        } else {
          isUserLoggedIn = snapshot.data.get('keepMeLogedIn') ?? false;
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (ctx) => Products(),
              ),
              ChangeNotifierProvider(
                create: (ctx) => Cart(),
              ),
              ChangeNotifierProvider.value(
                value: Orders(),
              ),
              ChangeNotifierProvider.value(
                value: Auth(),
              ),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                fontFamily: 'Lato',
                accentColor: Colors.yellowAccent,
                primaryColor: Colors.yellowAccent,
              ),
              initialRoute: isUserLoggedIn
                  ? ProductOverviewScreen.routNamed
                  : AuthScreen.routNamed,
              routes: {
                ProductDetailScreen.routNamed: (ctx) => ProductDetailScreen(),
                CartScreen.routNamed: (ctx) => CartScreen(),
                OrderScreen.routNamed: (ctx) => OrderScreen(),
                ProductOverviewScreen.routNamed: (ctx) =>
                    ProductOverviewScreen(),
                UserProductsScreen.routNamed: (ctx) => UserProductsScreen(),
                EditProductScreen.routNamed: (ctx) => EditProductScreen(),
                AuthScreen.routNamed: (ctx) => AuthScreen(),

              },
            ),
          );
        }
      },
    );
  }
}
