import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mechapp/utils/my_models.dart';
import 'package:mechapp/utils/type_constants.dart';

import 'view_mech_profile.dart';

class NearbyF extends StatefulWidget {
  @override
  _NearbyFState createState() => _NearbyFState();
}

class _NearbyFState extends State<NearbyF> {
  List<EachMechanic> mechList = [];

  Map dATA = {};
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

/*
  Future<List<EachMechanic>> filteredByDistance(Position myPos) async {
    for (EachMechanic item in mechList) {
      await Geolocator()
          .distanceBetween(
              myPos.latitude, myPos.longitude, item.mLat, item.mLong)
          .then((value) {
        print(value);
        if (value > 10) {
          filteredList.add(item);
        }
      });
    }
    return filteredList;
  }
*/

  LatLng _center = const LatLng(7.3034138, 5.143012800000008);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
    getUserLocation();
  }

  Future<Position> locateUser() async {
    return getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  getUserLocation() async {
    List<Placemark> placeMark = await  placemarkFromCoordinates(
        currentLocation.latitude, currentLocation.longitude);

    setState(() {
      markers.add(
        Marker(
          markerId: MarkerId("Current Location"),
          position: LatLng(currentLocation.latitude, currentLocation.longitude),
          infoWindow: InfoWindow(title: mName, snippet: placeMark[0].name),
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
            String tempRating = dATA[key]['Rating'];

            String tempMechUid = dATA[key]['Mech Uid'];
            var tempLongPos =
                double.parse(dATA[key]['LOc Longitude'].toString());
            var tempLatPos = double.parse(dATA[key]['Loc Latitude'].toString());
            String tempDBtwn = calculateDistance(
                    currentLocation.latitude,
                    currentLocation.longitude,
                    tempLatPos.toDouble(),
                    tempLongPos.toDouble())
                .toString();
            //  Future.delayed(Duration(milliseconds: 500));
            List cat = dATA[key]["Categories"];
            List specs = dATA[key]["Specifications"];
            mechList.add(EachMechanic(
                dBtwn: tempDBtwn,
                uid: tempMechUid,
                name: tempName,
                locality: tempLocality,
                phoneNumber: tempPhoneNumber,
                streetName: tempStreetName,
                city: tempCity,
                descrpt: tempDescription,
                image: tempImage,
                specs: specs,
                categories: cat,
                rating: tempRating,
                mLat: tempLatPos,
                mLong: tempLongPos));
          }

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
                          zoom: 10.0,
                        ),
                        markers: Set<Marker>.of(markers),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    "Nearby Mechanics",
                    style: TextStyle(
                        fontSize: 18,
                        color: primaryColor,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                Expanded(
                  child: MediaQuery.removePadding(
                    context: context,
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
                                        borderRadius:
                                            BorderRadius.circular(15)),
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
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black54),
                                                ),
                                              ),
                                              Icon(
                                                Icons.message,
                                                color: primaryColor,
                                              ),
                                            ],
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: .0),
                                              child: Text(
                                                " ${mechList[index].dBtwn}  KM Away",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black54),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      title: Text(
                                        mechList[index].name,
                                        style: TextStyle(
                                            fontSize: 20,
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
                                                "assets/images/person.png"),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Image(
                                            image: AssetImage(
                                                "assets/images/person.png"),
                                          ),
                                        ),
                                      ),
                                    )),
                                  ),
                                ),
                              );
                            },
                          ),
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

  static int calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return (12742 * asin(sqrt(a))).toInt();
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;

    return Container(
      color: primaryColor,
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          color: Color(0xb090A1AE),
          height: double.infinity,
          child: _body(primaryColor),
        ),
      ),
    );
  }
}
