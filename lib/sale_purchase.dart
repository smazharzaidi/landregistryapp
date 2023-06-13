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
  Set<Circle> _circles = {};
  Set<Polyline> _polylines = {};
  List<LatLng> _polygonPoints = [];
  Marker? _selectedMarker;

  LatLng? _midPoint;
  Circle? _midPointCircle;
  Set<Marker> _markers = {};

  @override
  void dispose() {
    cnicController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _openDrawer(BuildContext context) {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _submitForm() {
    // Handle form submission
  }

  void _addMarker(LatLng position) {
    final markerId = MarkerId(position.toString());        //ye masla hy

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

  // void _updateMidPoint() {
  //   if (_polygonPoints.length > 1) {
  //     final double sumLat =
  //         _polygonPoints.fold(0, (prev, element) => prev + element.latitude);
  //     final double sumLng =
  //         _polygonPoints.fold(0, (prev, element) => prev + element.longitude);
  //     final int count = _polygonPoints.length;

  //     final LatLng midPoint = LatLng(sumLat / count, sumLng / count);

  //     if (_midPoint == null) {
  //       _midPoint = midPoint;
  //       _addMidPointCircle();
  //     } else {
  //       setState(() {
  //         _midPoint = midPoint;
  //         _moveMidPointCircle();
  //       });
  //     }
  //   } else {
  //     setState(() {
  //       _midPoint = null;
  //       _midPointCircle = null;
  //     });
  //   }
  // }

  // void _addMidPointCircle() {
  //   final Circle midPointCircle = Circle(
  //     circleId: CircleId('midPoint'),
  //     center: _midPoint!,
  //     radius: 10, // Adjust the radius to your preference
  //     fillColor: Colors.red.withOpacity(0.5),
  //     strokeWidth: 0,
  //     consumeTapEvents: true,
  //   );

  //   setState(() {
  //     _midPointCircle = midPointCircle;
  //   });
  // }

  // void _moveMidPointCircle() {
  //   final Circle updatedMidPointCircle =
  //       _midPointCircle!.copyWith(centerParam: _midPoint!);

  //   final updatedCircles = Set<Circle>.from(_circles);
  //   updatedCircles.remove(_midPointCircle);
  //   updatedCircles.add(updatedMidPointCircle);

  //   setState(() {
  //     _midPointCircle = updatedMidPointCircle;
  //     _circles = updatedCircles;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Sell Your Land',
          style: GoogleFonts.sora(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            color: Colors.white,
          ),
          onPressed: () {
            _openDrawer(context);
          },
        ),
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
                      builder: (context) => HelpSupportPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
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
                    () => ScaleGestureRecognizer()),
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
}
