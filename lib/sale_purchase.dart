import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'help_support.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';
import 'profile.dart';

class CNICInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;

    String formattedText = '';

    for (int i = 0; i < newText.length; i++) {
      formattedText += newText[i];
      if (i == 4 || i == 11) {
        formattedText += '-';
      }
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class SalePurchase extends StatefulWidget {
  SalePurchase({required Key key}) : super(key: key);

  @override
  _SalePurchaseState createState() => _SalePurchaseState();
}

class _SalePurchaseState extends State<SalePurchase> {
  final TextEditingController cnicController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GoogleMapController? _mapController;
  Set<Circle> _circles = {};
  Set<Polyline> _polylines = {};
  List<LatLng> _polygonPoints = [];
  Marker? _selectedMarker;

  LatLng? _midPoint;
  Circle? _midPointCircle;
  Set<Marker> _markers = {};

  List<DocumentSnapshot>? _landDocuments;
  String? _selectedLandDocumentId;

  @override
  void dispose() {
    cnicController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchLandDocuments();
  }

  void _fetchLandDocuments() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userCNIC = user.uid;
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCNIC)
          .get();

      if (userSnapshot.exists) {
        String userCnic = userSnapshot['cnic'];

        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('landRecords')
            .where('userCNIC', isEqualTo: userCnic)
            .get();

        setState(() {
          _landDocuments = snapshot.docs;
          _selectedLandDocumentId = _landDocuments!.isNotEmpty
              ? _landDocuments![0].id
              : null; // Set the initial selected document id
        });
      }
    }
  }

  void _openDrawer(BuildContext context) {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _submitForm() {
    // Handle form submission
    String buyerCNIC = cnicController.text.trim();

    // Check if the buyer CNIC exists in the users table
    _checkBuyerCNICExists(buyerCNIC);
  }

  void _checkBuyerCNICExists(String cnic) async {
    print('Checking buyer CNIC: $cnic');

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('cnic', isEqualTo: cnic)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Transfer land ownership to the buyer
      _transferLandOwnership(cnic);
    } else {
      // Show error message if the buyer CNIC is not found
      _showSnackbar('CNIC does not exist');
    }
  }

  void _transferLandOwnership(String buyerCNIC) async {
    // Query the 'users' collection to find the buyer with the matching CNIC
    QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('cnic', isEqualTo: buyerCNIC)
        .get();

    if (usersSnapshot.docs.isNotEmpty) {
      // Transfer land ownership to the buyer by updating the userCNIC field
      await FirebaseFirestore.instance
          .collection('landRecords')
          .doc(_selectedLandDocumentId)
          .update({'userCNIC': buyerCNIC});

      _showSnackbar('Land ownership transferred successfully');
    } else {
      _showSnackbar('CNIC does not exist');
    }
  }

  void _addMarker(LatLng position) {
    final markerId = MarkerId(position.toString());

    Marker? marker;

    for (var m in _markers) {
      if (m.position.latitude == position.latitude &&
          m.position.longitude == position.longitude) {
        marker = m;
        break;
      }
    }

    if (marker != null) {
      setState(() {
        _selectedMarker = marker;
      });
    } else {
      Marker newMarker = Marker(
        markerId: markerId,
        position: position,
        draggable: true,
        onDragEnd: (newPosition) {
          _onMarkerDragEnd(markerId, newPosition);
        },
        infoWindow: InfoWindow(
          title: 'Marker',
        ),
      );

      setState(() {
        _markers.add(newMarker);
        _polygonPoints.add(position);
        _updatePolygons();
      });
    }
  }

  void _onMarkerDragEnd(MarkerId markerId, LatLng newPosition) {
    if (_selectedMarker != null && _selectedMarker!.markerId == markerId) {
      final updatedMarkers = _markers.map((marker) {
        if (marker.markerId == markerId) {
          return marker.copyWith(positionParam: newPosition);
        }
        return marker;
      }).toSet();

      final updatedPolygonPoints = _polygonPoints.map((point) {
        if (point == _selectedMarker!.position) {
          return newPosition;
        }
        return point;
      }).toList();

      setState(() {
        _markers = updatedMarkers;
        _polygonPoints = updatedPolygonPoints;
        _updatePolygons();
      });
    }
  }

  void _updatePolygons() {
    setState(() {
      _polylines.clear();

      if (_polygonPoints.length > 1) {
        final List<LatLng> polygonPointsCopy = List.from(_polygonPoints);
        polygonPointsCopy.add(_polygonPoints[0]);

        _polylines.add(
          Polyline(
            polylineId: PolylineId('boundary'),
            points: polygonPointsCopy,
            color: Colors.blue,
            width: 2,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Sell Your Land',
          style: GoogleFonts.sora(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            color: Color.fromARGB(255, 10, 10, 10),
          ),
          onPressed: () {
            _openDrawer(context);
          },
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
      body: Column(
        children: [
          _landDocuments != null
              ? DropdownButton<String>(
                  value: _selectedLandDocumentId,
                  items: _landDocuments!
                      .map((doc) => DropdownMenuItem<String>(
                            value: doc.id,
                            child: Text(
                              '${doc['Khasra']}, ${doc['Division']}, ${doc['Tehsil']}',
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLandDocumentId = value;
                    });
                    _updateMarkersAndPolygons(value);
                  },
                )
              : SizedBox(),
          Expanded(
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: LatLng(37.4419, -122.1419),
                zoom: 15,
              ),
              markers: _markers,
              circles: _circles,
              polylines: _polylines,
              onTap: _addMarker,
              onMapCreated: (controller) {
                _mapController = controller;
              },
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                Factory<OneSequenceGestureRecognizer>(
                  () => ScaleGestureRecognizer(),
                ),
              ].toSet(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Enter buyer\'s CNIC:',
                  style: GoogleFonts.sora(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: cnicController,
                  decoration: const InputDecoration(
                    hintText: 'CNIC',
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(15),
                    CNICInputFormatter(),
                  ],
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Submit',
                        style: GoogleFonts.sora(),
                      ),
                      const Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _updateMarkersAndPolygons(String? landDocumentId) {
    setState(() {
      _markers.clear();
      _polygonPoints.clear();
      _polylines.clear();

      if (landDocumentId != null) {
        DocumentSnapshot<Object?>? selectedDocument;

        for (var doc in _landDocuments!) {
          if (doc.id == landDocumentId) {
            selectedDocument = doc;
            break;
          }
        }

        if (selectedDocument != null) {
          List<dynamic> cornerPoints = selectedDocument['CornerPoints'];
          for (var point in cornerPoints) {
            double latitude = point.latitude;
            double longitude = point.longitude;
            LatLng position = LatLng(latitude, longitude);
            final markerId = MarkerId(position.toString());

            Marker newMarker = Marker(
              markerId: markerId,
              position: position,
              draggable: true,
              onDragEnd: (newPosition) {
                _onMarkerDragEnd(markerId, newPosition);
              },
              infoWindow: InfoWindow(
                title: 'Marker',
              ),
            );

            _markers.add(newMarker);
            _polygonPoints.add(position);
          }

          _updatePolygons();
        }
      }
    });
  }

  String _getLandDescription(DocumentSnapshot doc) {
    String khasra = doc['Khasra'];
    String division = doc['Division'];
    String tehsil = doc['Tehsil'];

    if (division != null && division.isNotEmpty) {
      return '$khasra, $division, $tehsil';
    } else {
      return '$khasra, $tehsil';
    }
  }

  void _showSnackbar(String message) {
    final snackbar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
}

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }

void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sale Purchase App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SalePurchase(key: UniqueKey()),
    );
  }
}
