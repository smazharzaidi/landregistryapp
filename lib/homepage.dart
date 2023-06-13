import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'help_support.dart';
import 'sale_purchase.dart';
import 'login.dart';
import 'profile.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
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
      answer: 'To reset your password, go to the login screen and tap on the Forgot Password link. Follow the instructions provided to reset your password.',
    ),
  ];

  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _animations;
  late List<bool> expansionStates;

  @override
  void initState() {
    super.initState();
    expansionStates = List<bool>.generate(helpTopics.length, (index) => false);
    _animationControllers = List<AnimationController>.generate(
      helpTopics.length,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 300),
      ),
    );
    _animations = List<Animation<double>>.generate(
      helpTopics.length,
      (index) => CurvedAnimation(
        parent: _animationControllers[index],
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleExpansion(int index) {
    setState(() {
      expansionStates[index] = !expansionStates[index];
      if (expansionStates[index]) {
        _animationControllers[index].forward();
      } else {
        _animationControllers[index].reverse();
      }
    });
  }

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
                ),
              ),
            ),
            ListTile(
              title: Text('Help & Support'),
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
      body: ListView.builder(
        itemCount: helpTopics.length,
        itemBuilder: (context, index) {
          return Card(
            child: ExpansionPanelList(
              elevation: 1,
              expandedHeaderPadding: EdgeInsets.zero,
              expansionCallback: (panelIndex, isExpanded) {
                _toggleExpansion(index);
              },
              children: [
                ExpansionPanel(
                  headerBuilder: (context, isExpanded) {
                    return ListTile(
                      title: Text(
                        helpTopics[index].question,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                  body: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: expansionStates[index] ? null : 0.0,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Opacity(
                        opacity: expansionStates[index] ? 1.0 : 0.0,
                        child: Text(helpTopics[index].answer),
                      ),
                    ),
                  ),
                  isExpanded: expansionStates[index],
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