import 'package:flutter/material.dart';

class RadioCustom extends StatefulWidget {
  List<RadioModel> optionsList;

  RadioCustom(this.optionsList);

  @override
  createState() {
    return new RadioCustomState();
  }
}

class RadioCustomState extends State<RadioCustom> {


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("ListItem"),
      ),
      body: new ListView.builder(
        itemCount: widget.optionsList.length,
        itemBuilder: (BuildContext context, int index) {
          return new InkWell(
            //highlightColor: Colors.red,
            splashColor: Colors.blueAccent,
            onTap: () {
              setState(() {
                widget.optionsList.forEach((element) => element.isSelected = false);
                widget.optionsList[index].isSelected = true;
              });
            },
            child: new RadioItem(widget.optionsList[index]),
          );
        },
      ),
    );
  }
}

class RadioItem extends StatelessWidget {
  final RadioModel _item;
  RadioItem(this._item);
  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: new EdgeInsets.all(15.0),
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          new Container(
            height: 50.0,
            width: 50.0,
            decoration: new BoxDecoration(
              color: _item.isSelected
                  ? Colors.blueAccent
                  : Colors.transparent,
              border: new Border.all(
                  width: 1.0,
                  color: _item.isSelected
                      ? Colors.blueAccent
                      : Colors.grey),
              borderRadius: const BorderRadius.all(const Radius.circular(2.0)),
            ),
          ),
          new Container(
            margin: new EdgeInsets.only(left: 10.0),
            child: new Text(_item.text),
          )
        ],
      ),
    );
  }
}

class RadioModel {
  bool isSelected;
  final String text;

  RadioModel(this.isSelected, this.text);
}