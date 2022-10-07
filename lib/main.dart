import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  final methodChannel = const MethodChannel('com.okta_poc');
  final TextEditingController _emailController = TextEditingController(text: "gguess@ffo.kr");
  final TextEditingController _passController = TextEditingController(text: "Nat123456");
  bool isLoading = false;
  String accessToken = "";

  Future<Token?> getToken({required String email, required String password}) async {
    try {
      final argumentMap = {
        'email': email,
        'password': password,
        'issuer': "https://dev-08901952.okta.com/oauth2/default",
        'clientId': "0oa6n8dw1yIMgQ5RE5d7",
        "redirectUri": "com.embeddedauth://callback"
      };
      final result = await methodChannel.invokeMethod('signin', argumentMap);

      if (result != null) {
        return Token.fromJson(jsonDecode(result.toString()));
      }
      return null;
    } catch (e) {
      print("error : $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Okta POC"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            children: [
              const SizedBox(height: 50),
              const Center(
                child: Text(
                  "Login to Okta",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                ),
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Colors.grey,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Colors.grey,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Colors.grey,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 15,
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              TextFormField(
                obscureText: true,
                controller: _passController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Colors.grey,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Colors.grey,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Colors.grey,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 15,
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              GestureDetector(
                onTap: () async {
                  setState(() {
                    isLoading = true;
                  });
                  Token? tkn = await getToken(email: _emailController.text, password: _passController.text);
                  if (tkn != null) {
                    //navigate to next page and show details
                    print("Token: ${tkn.accessToken}");
                    setState(() {
                      isLoading = false;
                      accessToken = "${tkn.accessToken}";
                    });
                  }
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              accessToken.isNotEmpty
                  ? SizedBox(height: 300, child: SingleChildScrollView(child: Text("Access Token: $accessToken")))
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}

class Token {
  final String? accessToken;
  final String? id;
  final String? idToken;
  final String? tokenType;
  final bool? isRefreshing;
  final bool? isValid;
  final bool? isExpired;
  final String? refreshToken;
  final String? deviceSecret;
  final String? authorizationHeader;

  Token({
    this.accessToken,
    this.id,
    this.idToken,
    this.tokenType,
    this.isRefreshing,
    this.isValid,
    this.isExpired,
    this.refreshToken,
    this.deviceSecret,
    this.authorizationHeader,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
        accessToken: json["accessToken"],
        id: json["id"],
        idToken: json["idToken"],
        tokenType: json["tokenType"],
        isRefreshing: json["isRefreshing"],
        isValid: json["isValid"],
        isExpired: json["isExpired"],
        refreshToken: json["refreshToken"],
        deviceSecret: json["deviceSecret"],
        authorizationHeader: json["authorizationHeader"]);
  }
}
