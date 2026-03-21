import 'package:flutter/material.dart';
import 'package:newrapidx/Common/CommonLogin.dart';

class mainAdmin extends StatefulWidget {
  const mainAdmin({super.key});

  @override
  State<mainAdmin> createState() => _mainAdminState();
}

class _mainAdminState extends State<mainAdmin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin panel"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const customerLogin()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(child: Text("Admin")),
    );
  }
}
