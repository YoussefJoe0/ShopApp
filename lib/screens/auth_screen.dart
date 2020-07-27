import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopapp/models/http_exceptions.dart';
import 'package:shopapp/providers/auth.dart';
import 'package:shopapp/screens/product_details_screen.dart';
import 'package:shopapp/screens/product_screen.dart';

enum AuthMode { SignUp, Login }

class AuthScreen extends StatelessWidget {
  static const routNamed = 'AuthScreen';
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.yellow,
                  Colors.yellow.shade300,
                  Colors.yellow,
                  Colors.yellow.shade600,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.orange,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 8,
                              color: Colors.black26,
                              offset: Offset(0, 2),
                            ),
                          ]),
                      child: Text(
                        'MyShop',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 50.0,
                          fontFamily: 'Anton',
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  AnimationController _controller;
  Animation<Offset> _slideAnimation;
  Animation<double> _opacityAnimation;
  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 300,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1.5),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
      ),
    );
    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occured!'),
        content: Text(message),
        actions: [
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Okay'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        if (keepMeLogin == true) {
          keepUserLogedIn();
        }
        // Log user in
        await Provider.of<Auth>(context, listen: false).login(
          _authData['email'],
          _authData['password'],
        );
        Navigator.of(context).pushNamed(ProductOverviewScreen.routNamed);
      } else {
        // Sign user up
        await Provider.of<Auth>(context, listen: false).singup(
          _authData['email'],
          _authData['password'],
        );
      }
    } on HttpExceptions catch (error) {
      var errorMessage = 'Authentication failed';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password.';
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      const errorMessage =
          'Could not authenticate you. Please try again later.';
      _showErrorDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.SignUp;
      });
      _controller.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _controller.reverse();
    }
  }

  bool keepMeLogin = false;

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 8.0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        height: _authMode == AuthMode.SignUp ? 360 : 300,
        curve: Curves.easeIn,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.SignUp ? 360 : 300),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val.isEmpty || !val.contains('@gmail.com')) {
                      return 'Invalid email';
                    }
                  },
                  onSaved: (val) {
                    _authData['email'] = val;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (val) {
                    if (val.isEmpty || val.length < 5) {
                      return 'Password is too short!';
                    }
                  },
                  onSaved: (val) {
                    _authData['password'] = val;
                  },
                ),
                if (_authMode == AuthMode.Login)
                  Row(
                    children: [
                      Theme(
                        data: ThemeData(unselectedWidgetColor: Colors.orange),
                        child: Checkbox(
                          value: keepMeLogin,
                          onChanged: (val) {
                            setState(() {
                              keepMeLogin = val;
                            });
                          },
                        ),
                      ),
                      Text(
                        'Remmeber Me',
                        style: TextStyle(color: Colors.orange),
                      )
                    ],
                  ),
                AnimatedContainer(
                  constraints: BoxConstraints(
                      minHeight: _authMode == AuthMode.SignUp ? 60 : 0,
                      maxHeight: _authMode == AuthMode.SignUp ? 120 : 0),
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: SlideTransition(
                      position: _slideAnimation ,
                      child: TextFormField(
                        enabled: _authMode == AuthMode.SignUp,
                        decoration:
                            InputDecoration(labelText: 'Confirm Password'),
                        validator: _authMode == AuthMode.SignUp
                            ? (val) {
                                if (val != _passwordController.text) {
                                  return 'Password do not match';
                                }
                              }
                            : null,
                      ),
                    ),
                  ),
                ),
                if (_authMode == AuthMode.SignUp)
                  SizedBox(
                    height: 30,
                  ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  RaisedButton(
                    child:
                        Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                    onPressed: _submit,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    color: Colors.orange,
                    textColor: Colors.white,
                  ),
                FlatButton(
                  onPressed: _switchAuthMode,
                  child: Text(
                      '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textColor: Colors.black,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void keepUserLogedIn() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool('keepMeLogedIn', keepMeLogin);
  }
}
