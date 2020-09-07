import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mechapp/utils/my_models.dart';
import 'package:mechapp/utils/type_constants.dart';
import 'package:mechapp/view_mech_profile.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';

class EachService extends StatefulWidget {
  final String title;

  EachService({Key key, @required this.title}) : super(key: key);

  @override
  _EachServiceState createState() => _EachServiceState();
}

class _EachServiceState extends State<EachService>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  List<EachMechanic> mechList = [];
  Map dATA = {};
  LatLng locationCoordinates;
  Position currentLocation;
  GoogleMapController mapController;
  List<Marker> markers = <Marker>[];

  Future<Map> getAllMechanics() async {
    DatabaseReference dataRef =
        FirebaseDatabase.instance.reference().child("Mechanic Collection");

    await dataRef.once().then((snapshot) {
      dATA = snapshot.value;
    });
    return dATA;
  }

  List<EachMechanic> filteredByService(String service) {
    List<EachMechanic> _tempList = [];
    for (EachMechanic item in mechList) {
      if (item.categories.contains(service)) {
        _tempList.add(item);
      }
    }
    return _tempList;
  }

  LatLng _center = const LatLng(7.3034138, 5.143012800000008);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
    getUserLocation();
    getAllMechanics();
  }

  Future<Position> locateUser() async {
    return getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  getUserLocation() async {
    currentLocation = await locateUser();
    setState(() {
      locationCoordinates =
          LatLng(currentLocation.latitude, currentLocation.longitude);
    });

    /* List<Placemark> placeMark = await Geolocator().placemarkFromCoordinates(
        currentLocation.latitude, currentLocation.longitude);
*/
    setState(() {
      markers.add(
        Marker(
          markerId: MarkerId("Current Location"),
          position: LatLng(currentLocation.latitude, currentLocation.longitude),
          infoWindow: InfoWindow(
              title: mName, snippet: /*placeMark[0].name*/ "Decoded location"),
          icon: BitmapDescriptor.defaultMarkerWithHue(120.0),
          onTap: () {},
        ),
      );
      _center = LatLng(currentLocation.latitude, currentLocation.longitude);
    });
  }

  Widget _body(Color primaryColor) {
    return FutureBuilder(
      future: getAllMechanics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          var kEYS = [];
          if (snapshot.hasData) {
            kEYS = dATA.keys.toList();
          }
          mechList.clear();
          for (var key in kEYS) {
            String tempName = dATA[key]['Company Name'];
            String tempPhoneNumber = dATA[key]['Phone Number'];
            String tempStreetName = dATA[key]['Street Name'];
            String tempCity = dATA[key]['City'];
            String tempLocality = dATA[key]['Locality'];
            String tempDescription = dATA[key]['Description'];
            String tempImage = dATA[key]['Image Url'];
            String tempMechUid = dATA[key]['Mech Uid'];
            String tempRating = dATA[key]['Rating'];
            var tempLongPos =
                double.parse(dATA[key]['LOc Longitude'].toString());
            var tempLatPos = double.parse(dATA[key]['Loc Latitude'].toString());

            List tempCat = dATA[key]["Categories"];
            List tempSpecs = dATA[key]["Specifications"];
            mechList.add(EachMechanic(
                uid: tempMechUid,
                name: tempName,
                locality: tempLocality,
                phoneNumber: tempPhoneNumber,
                streetName: tempStreetName,
                city: tempCity,
                descrpt: tempDescription,
                image: tempImage,
                specs: tempSpecs,
                categories: tempCat,
                mLat: tempLatPos,
                mLong: tempLongPos,
                rating: tempRating));
          }

          mechList = filteredByService(widget.title);

          for (var i = 0; i < mechList.length; i++) {
            markers.add(
              Marker(
                markerId: MarkerId(mechList[i].uid),
                position: LatLng(mechList[i].mLat, mechList[i].mLong),
                infoWindow: InfoWindow(
                    title: mechList[i].name, snippet: mechList[i].streetName),
                onTap: () {},
              ),
            );
          }
          return Container(
            color: Color(0xb090A1AE),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    height: MediaQuery.of(context).size.height / 3.5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: _center,
                          zoom: 15.0,
                        ),
                        markers: Set<Marker>.of(markers),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    "Available Mechanics",
                    style: TextStyle(
                        fontSize: 18,
                        color: primaryColor,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                Expanded(
                  child: mechList.isEmpty
                      ? emptyList("Nearby Mechanic")
                      : ListView.builder(
                          itemCount: mechList.length,
                          itemBuilder: (context, int index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => ViewMechProfile(
                                      mechanic: mechList[index],
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(color: Colors.black12)
                                      ],
                                      borderRadius: BorderRadius.circular(15)),
                                  child: Center(
                                      child: ListTile(
                                    subtitle: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Icon(
                                              Icons.call,
                                              color: primaryColor,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: Text(
                                                mechList[index].phoneNumber,
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black54),
                                              ),
                                            ),
                                            Icon(
                                              Icons.message,
                                              color: primaryColor,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    title: Text(
                                      mechList[index].name,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black),
                                    ),
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
                                      child: CachedNetworkImage(
                                        imageUrl: mechList[index].image,
                                        height: 48,
                                        width: 48,
                                        placeholder: (context, url) => Image(
                                          image: AssetImage(
                                            "assets/images/person.png",
                                          ),
                                          height: 48,
                                          width: 48,
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Image(
                                          image: AssetImage(
                                              "assets/images/person.png"),
                                          height: 48,
                                          width: 48,
                                        ),
                                      ),
                                    ),
                                  )),
                                ),
                              ),
                            );
                          },
                        ),
                )
              ],
            ),
          );
        }
        return Center(child: CupertinoActivityIndicator(radius: 20));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;

    final container = _body(primaryColor);
    return Scaffold(
        backgroundColor: primaryColor,
        appBar: AppBar(
          title: Text(widget.title),
          elevation: 0.0,
          centerTitle: true,
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        body: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                color: Color(0xb090A1AE),
              ),
              height: double.infinity,
              child: container),
        ));
  }
}
