import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final String title;
  final Widget icon;
  final bool hasColor;
  final bool iconLeft;
  final Color bgColor;
  final void Function() onPress;
  final BuildContext context;

  CustomButton(
      {Key key,
      @required this.title,
      @required this.onPress,
      this.icon,
      this.bgColor,
      this.iconLeft = true,
      this.hasColor = false,
      this.context})
      : super(key: key);
  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Container(
        decoration: BoxDecoration(
          color: widget.hasColor
              ? widget.bgColor
              : Color.fromARGB(255, 22, 58, 78),
          borderRadius: BorderRadius.circular(50),
        ),
        child: FlatButton(
          onPressed: () {
            widget.onPress();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              widget.iconLeft ? widget.icon : Text(""),
              Padding(
                padding: EdgeInsets.all(5.0),
                child: Text(
                  widget.title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white),
                ),
              ),
              !widget.iconLeft ? widget.icon : Text(""),
            ],
          ),
        ),
      ),
    );
  }
}
