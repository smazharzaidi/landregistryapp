import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'help_support.dart';
import 'login.dart';
import 'sale_purchase.dart';

class Profile extends StatelessWidget {
  void _openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', 
          style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  
                ),
              ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  
                ),
              ),
            ),
            ListTile(
              title: Text('Help & Support',
                
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HelpSupportPage()),
                );
              },
            ),
            ListTile(
              title: Text('Sale & Purchase'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SalePurchase(key: UniqueKey())),
                    
                );
              },
            ),
            ListTile(
              title: Text('Logout'),
              onTap: () => _logout(context),
            ),
            ListTile(
              title: Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Profile()),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 20),
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(
                  'https://example.com/profile_picture',
                ),
              ),
            ),
            Text(
              'User Profile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
