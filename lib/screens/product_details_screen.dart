import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopapp/providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routNamed = 'ProductDetails';
//  final String title;
//  final double price;

//  ProductDetailScreen(this.title, this.price);
  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments as String;
    final loadedProduct =
        Provider.of<Products>(context, listen: false).findById(productId);

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(loadedProduct.title),
      // ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(loadedProduct.title),
              background: Hero(
                tag: loadedProduct.id,
                child: Image.network(
                  loadedProduct.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(
                    loadedProduct.title,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '\$${loadedProduct.price}',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                width: double.infinity,
                child: Text(
                  loadedProduct.description,
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              SizedBox(height: 800,)
            ]),
          ),
        ],
      ),
    );
  }
}
