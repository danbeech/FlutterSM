import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:fluttershare/pages/home.dart';


// final usersRef = Firestore.instance.collection('users');
// final timelineRef = Firestore.instance.collection('timeline');

class Timeline extends StatefulWidget {
  final User currentUser;
  Timeline({this.currentUser});


  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Post> posts;
  List<String> followingList = [];

  @override
  void initState() {
    super.initState();
    getTimeline();
    // getFollowing();
  }

  getTimeline() async {
    QuerySnapshot snapshot = await timelineRef
        .document(widget.currentUser.id)
        .collection('timelinePosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    
    setState(() {
      List<Post> posts =
        snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
      this.posts = posts;
    });
  }

  // getFollowing() async {
  //   QuerySnapshot snapshot = await followingRef
  //       .document(widget.currentUser.id)
  //       .collection('userFollowing')
  //       .getDocuments();
  //   setState(() {
  //     followingList = snapshot.documents.map((doc) => doc.documentID).toList();
  //   });
  // }

  buildTimeline() {
    if (posts == null) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return buildNoContent();
    } else {
      return ListView(children: posts);
    }
  }
  

  buildNoContent(){
    return Center(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 40.0),
              child: SvgPicture.asset('assets/images/no_content.svg', 
              height: 150.0,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text("Follow users to \nsee their posts!", 
                  style: TextStyle(
                  color: Theme.of(context).primaryColor.withOpacity(0.6),
                  fontSize: 20.0, 
                  fontWeight: FontWeight.bold,
                  ),
              ),
            ),
          ],
        ),
      ),
    ); 
  }

  @override
  Widget build(context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context, isAppTitle: true),
      body: RefreshIndicator(
        onRefresh: () => getTimeline(),
        child: buildTimeline(),
      ),
    );
  }
}