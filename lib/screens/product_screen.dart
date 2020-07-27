import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopapp/providers/cart.dart';
import 'package:shopapp/providers/products.dart';
import 'package:shopapp/screens/cart_screen.dart';
import 'package:shopapp/widgets/app_drawer.dart';
import 'package:shopapp/widgets/badge.dart';
import 'package:shopapp/widgets/product_grid.dart';

enum FilterOptions { Favorites, All }

class ProductOverviewScreen extends StatefulWidget {
  static const routNamed = 'HomeScreen';

  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  @override
  var _inInt = true;
  var _isLoading = false;
  void initState() {
    // Future.delayed(Duration.zero).then(
    //   (value) => Provider.of<Products>(context).fetchAndSetProducts(),
    // );
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_inInt) {
      setState(() {
        _isLoading = true;
      });

      Provider.of<Products>(context , listen: false).fetchAndSetProducts().then((value) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _inInt = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final productContainer = Provider.of<Products>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('My Shop'),
        actions: <Widget>[
          Consumer<Cart>(
            builder: (_, cart, child) =>
                Badge(child: child, value: cart.itemCount.toString()),
            child: IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).pushNamed(CartScreen.routNamed);
                }),
          ),
          PopupMenuButton(
            onSelected: (FilterOptions val) {
              if (val == FilterOptions.Favorites) {
                productContainer.showFavoritesOnly();
              } else {
                productContainer.showAll();
              }
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Only Favorites'),
                value: FilterOptions.Favorites,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: FilterOptions.All,
              ),
            ],
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 5,
                  ),
                  Text('Loading..'),
                ],
              ),
            )
          : ProductGrid(),
    );
  }
}
