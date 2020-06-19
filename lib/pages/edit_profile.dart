import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/home.dart';
// import 'package:fluttershare/pages/timeline.dart';
import 'package:fluttershare/widgets/progress.dart';


class EditProfile extends StatefulWidget {
  final String currentUserId;

  EditProfile({this.currentUserId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController tier1Controller = TextEditingController();
  TextEditingController tier2Controller = TextEditingController();
  TextEditingController tier3Controller = TextEditingController();
  bool isLoading = false;
  User user;
  bool _bioValid = true;
  bool _displayNameValid = true;
  bool _tier1Acceptable = true;
  bool _tier2Acceptable = true;
  bool _tier3Acceptable = true;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.document(widget.currentUserId).get();
    user = User.fromDocument(doc);
    displayNameController.text = user.displayName;
    bioController.text = user.bio;
    tier1Controller.text = user.tier1Price.toString();
    tier2Controller.text = user.tier2Price.toString();
    tier3Controller.text = user.tier3Price.toString();
    setState(() {
      isLoading = false;
    });
  }

  buildDisplayNameField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text("Display Name", 
            style: TextStyle(
            color: Colors.grey,
            ),
          ),
        ),
        TextField(
          controller: displayNameController,
          decoration: InputDecoration(
            hintText: "Update Display Name",
            errorText: _displayNameValid ? null : "Display Name Invalid",
          ),
        ),
      ],
    );
  }

  buildBioField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text("Bio", 
            style: TextStyle(
            color: Colors.grey,
            ),
          ),
        ),
        TextField(
          controller: bioController,
          decoration: InputDecoration(
            hintText: "Update Bio",
            errorText: _bioValid ? null : "Bio too long"
          ),
        ),
      ],
    );
  }

  buildTierSelectors(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 30.0),
          child: Text("Subscription Pricing",
          style: TextStyle(
            color: Colors.grey,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Text("Tier 1",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor.withOpacity(0.6),
                    ),
                  ), 
                ],
              ),
              SizedBox(width: 25.0,),
              Column(
                children: <Widget>[
                  Text("Tier 2",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor.withOpacity(0.6),
                    ),
                  ), 
                ],
              ),
              SizedBox(width: 25.0,),
              Column(
                children: <Widget>[
                  Text("Tier 3",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor.withOpacity(0.6),
                    ),
                  ), 
                ],
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: tier1Controller,
                textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    errorText: _tier1Acceptable ? null : "5 or more",
                    contentPadding: EdgeInsets.all(10)
                  )
              ),
            ),
            SizedBox(width: 75.0,),
            Flexible(
              child: TextField(
                controller: tier2Controller,
                textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    errorText: _tier2Acceptable ? null : "> tier 1",
                    contentPadding: EdgeInsets.all(10)
                  )
              ),
            ),
            SizedBox(width: 75.0,),
            Flexible(
              child: TextField(
                controller: tier3Controller,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  WhitelistingTextInputFormatter.digitsOnly
                ],
                textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    errorText: _tier3Acceptable ? null : "> Tier 2",
                    contentPadding: EdgeInsets.all(10),
                  )
              ),
            ),
          ],
        ),
      ],
    );
  }

  updateProfileData() {
    int tier1Parse = int.parse(tier1Controller.text);
    int tier2Parse = int.parse(tier2Controller.text);
    int tier3Parse = int.parse(tier3Controller.text);


    setState(() {
      displayNameController.text.trim().length < 3 || displayNameController.text.isEmpty ? _displayNameValid = false : _displayNameValid = true;
      bioController.text.trim().length > 100 ? _bioValid = false : _bioValid = true;
      tier1Parse < 5 ? _tier1Acceptable = false : _tier1Acceptable = true;
      tier2Parse < 5 || tier2Parse < tier1Parse ? _tier2Acceptable = false : _tier2Acceptable = true;
      tier3Parse < 5 || tier3Parse < tier2Parse ? _tier3Acceptable = false : _tier3Acceptable = true;
    });

    if (_displayNameValid && _bioValid && _tier1Acceptable && _tier2Acceptable && _tier3Acceptable){
      usersRef.document(widget.currentUserId).updateData({
        "displayName": displayNameController.text,
        "bio": bioController.text,
        "tier1Price": tier1Parse,
        "tier2Price": tier2Parse,
        "tier3Price": tier3Parse,
      });
      SnackBar snackbar = SnackBar(content: Text("Profile Updated"));
      _scaffoldKey.currentState.showSnackBar(snackbar);
    }
  }

  logout() async {
    await googleSignIn.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Edit Profile",
          style: TextStyle(
            color: Theme.of(context).primaryColor.withOpacity(0.6),
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.done,
              size: 30.0,
              color: Theme.of(context).primaryColor.withOpacity(0.6),
            ),
          ),
        ],
      ),
      body: isLoading? circularProgress(): ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                  child: CircleAvatar(
                    radius: 50.0,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 40.0),
                  child: Column(
                    children: <Widget>[
                      buildDisplayNameField(),
                      buildBioField(),
                      buildTierSelectors(),
                    ],
                  ),
                ),
                RaisedButton(
                  color: Theme.of(context).primaryColor.withOpacity(0.6),
                  onPressed: updateProfileData,
                  child: Text(
                    "Update Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: FlatButton.icon(
                    onPressed: logout,
                    icon: Icon(
                      Icons.cancel,
                      color: Colors.red.shade400,
                    ),
                    label: Text(
                      "Logout",
                      style: TextStyle(
                        color: Colors.red.shade400,
                        fontSize: 20.0,
                      ),
                    ),
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
