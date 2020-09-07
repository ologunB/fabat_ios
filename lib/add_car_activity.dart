import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mechapp/utils/type_constants.dart';

import 'libraries/custom_button.dart';
import 'libraries/show_exception_alert_dialog.dart';
import 'libraries/toast.dart';

class AddCarActivity extends StatefulWidget {
  @override
  _AddCarActivityState createState() => _AddCarActivityState();
}

final carsReference =
    FirebaseDatabase.instance.reference().child("Car Collection").child(mUID);

class _AddCarActivityState extends State<AddCarActivity>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  File _carImage;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _carImage = image;
    });
  }

  TextEditingController _carMake = TextEditingController();
  TextEditingController _carModel = TextEditingController();
  TextEditingController _carRegNum = TextEditingController();
  TextEditingController _carDate = TextEditingController();

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text("Add New Car"),
        centerTitle: true,
        elevation: 0.0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                "assets/images/bg_image.jpg",
              ),
              fit: BoxFit.fill),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: Card(
              elevation: 5,
              child: Padding(
                padding: EdgeInsets.all(25.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        child: InkWell(
                          onTap: () {
                            getImage();
                          },
                          child: _carImage == null
                              ? Image(
                                  image: AssetImage(
                                      "assets/images/add_camera.png"),
                                  height: 90,
                                  width: 90,
                                  fit: BoxFit.contain)
                              : Image.file(_carImage,
                                  height: 90, width: 90, fit: BoxFit.contain),
                        ),
                      ),
                      TextField(
                        decoration:
                            InputDecoration(hintText: "Car Make(Brand)"),
                        style: TextStyle(fontSize: 20),
                        controller: _carMake,
                      ),
                      TextField(
                        decoration: InputDecoration(hintText: "Car Model"),
                        style: TextStyle(fontSize: 20),
                        controller: _carModel,
                      ),
                      TextField(
                        decoration:
                            InputDecoration(hintText: "Registration Number"),
                        style: TextStyle(fontSize: 20),
                        controller: _carRegNum,
                      ),
                      TextField(
                        decoration: InputDecoration(hintText: "Year"),
                        style: TextStyle(fontSize: 20),
                        keyboardType: TextInputType.number,
                        controller: _carDate,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            CustomButton(
                              title: "Cancel",
                              onPress: () {
                                Navigator.pop(context);
                              }, bgColor: Colors.red, hasColor: true,
                              icon: SizedBox(),
                            ),
                            CustomButton(
                              title: isLoading ? "Adding" : "Add Car",
                              onPress: isLoading
                                  ? null
                                  : () {
                                      addCar();
                                    },
                              icon: isLoading
                                  ? CupertinoActivityIndicator(radius: 10)
                                  : Icon(
                                      Icons.done,
                                      color: Colors.white,
                                    ),
                              iconLeft: false,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void addCar() async {
    if (_carModel.text.toString().isEmpty) {
      showEmptyToast("Car Model", context);
      return;
    } else if (_carMake.text.toString().isEmpty) {
      showEmptyToast("Car Make", context);
      return;
    } else if (_carRegNum.text.toString().isEmpty) {
      showEmptyToast("Car Reg. Number", context);
      return;
    } else if (_carDate.text.toString().isEmpty) {
      showEmptyToast("Car Date", context);
      return;
    }

    setState(() {
      isLoading = true;
    });

    if (_carImage == null) {
      carsReference.child(randomString()).set({
        'car_brand': _carMake.text,
        'car_model': _carModel.text,
        'car_date': _carDate.text,
        'car_num': _carRegNum.text,
        'car_image': "img"
      }).then((_) {
        Navigator.pop(context);

        setState(() {
          isLoading = false;
        });
        Toast.show("Car added Successfully", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      }).catchError((e) {
        showExceptionAlertDialog(
            context: context, exception: e, title: "Error");
        setState(() {
          isLoading = false;
        });
      });
    } else {
      StorageReference reference =
          FirebaseStorage.instance.ref().child("images/${randomString()}");

      StorageUploadTask uploadTask = reference.putFile(_carImage);
      StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
      String url = (await downloadUrl.ref.getDownloadURL());

      carsReference.child(randomString()).set({
        'car_brand': _carMake.text,
        'car_model': _carModel.text,
        'car_date': _carDate.text,
        'car_num': _carRegNum.text,
        'car_image': url
      }).then((_) {
        Navigator.pop(context);

        setState(() {
          isLoading = false;
        });
        Toast.show("Car added Successfully", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      }).catchError((e) {
        showExceptionAlertDialog(
            context: context, exception: e, title: "Error");
        setState(() {
          isLoading = false;
        });
      });
    }
  }
}
