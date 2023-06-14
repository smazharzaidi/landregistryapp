import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:semester_project/sale_purchase.dart';

import 'login.dart';
import 'profile.dart';

class HelpSupportPage extends StatefulWidget {
  @override
  _HelpSupportPageState createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  List<HelpTopic> helpTopics = [
    HelpTopic(
      question: 'How do I reset my password?',
      answer: 'To reset your password, go to the login screen and tap on the Forgot Password link. Follow the instructions provided to reset your password.',
    ),
    HelpTopic(
      question: 'How can I contact customer support?',
      answer: 'For any assistance or queries, you can reach our customer support team by emailing support@example.com or by calling +1-123-456-7890.',
    ),
    HelpTopic(
      question: 'What payment methods are accepted?',
      answer: 'We accept all major credit cards, including Visa, Mastercard, and American Express. You can also pay using PayPal.',
    ),
    HelpTopic(
      question: 'How do I set up my system?',
      answer: 'To set up your system, you need to have sign up with your correct credentials, then you will be provided with step by setp guidelines. Follow those instructions provided to set up your account. you can login again to see further updates',
    ),
  ];

  

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Help and Support', 
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
              title: Text('Help & Support'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Sale & Purchase'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SalePurchase(key: UniqueKey())),
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
      body: ListView.builder(
        itemCount: helpTopics.length,
        itemBuilder: (context, index) {
          return Card(
            child: ExpansionTile(
              title: Text(
                helpTopics[index].question,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(helpTopics[index].answer),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class HelpTopic {
  final String question;
  final String answer;

  HelpTopic({required this.question, required this.answer});
}
