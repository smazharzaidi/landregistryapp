import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'help_support.dart';

class SalePurchase extends StatefulWidget {
  SalePurchase({required Key key}) : super(key: key);

  @override
  _SalePurchaseState createState() => _SalePurchaseState();
}

class _SalePurchaseState extends State<SalePurchase> {
  final TextEditingController cnicController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.transparent,
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(
                    Icons.menu,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                );
              },
            ),
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Sell Your Land',
                style: GoogleFonts.sora(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              stretchModes: const <StretchMode>[
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
                StretchMode.fadeTitle
              ],
              centerTitle: true,
              collapseMode: CollapseMode.parallax,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/theme.jpg',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            floating: true,
            pinned: true,
            snap: true,
            expandedHeight: 200,
          ),
          SliverFillRemaining(
            child: GestureDetector(
              onScaleStart: (details) {
                // Handle scale start
              },
              onScaleUpdate: (details) {
                // Handle scale update
              },
              onScaleEnd: (details) {
                // Handle scale end
              },
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: LatLng(37.4419, -122.1419),
                  zoom: 15,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                  Factory<OneSequenceGestureRecognizer>(
                      () => ScaleGestureRecognizer()),
                ].toSet(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Enter buyer\'s CNIC:',
                        style: GoogleFonts.sora(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                          child: TextField(
                            controller: cnicController,
                            decoration: const InputDecoration(
                              hintText: 'CNIC',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      20,
                    ), // Adjust the radius to your preference
                    child: ElevatedButton(
                      onPressed: () {
                        // Button onPressed logic
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            20,
                          ), // Adjust the radius to match the ClipRRect
                        ),
                      ),
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: const Text(
                'Sell Your Land',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                // Handle Sell Your Land menu item tap
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              title: const Text('Help and Support'),
              onTap: () {
                // Handle Help and Support menu item tap
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HelpSupportPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
