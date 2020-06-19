import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String photoUrl;
  final String displayName;
  final String bio;
  final int tier1Price;
  final int tier2Price;
  final int tier3Price;

  User({
    this.id,
    this.username,
    this.email,
    this.photoUrl,
    this.displayName,
    this.bio,
    this.tier1Price,
    this.tier2Price,
    this.tier3Price,
  });

  factory User.fromDocument(DocumentSnapshot doc){
    return User(
      id: doc['id'],
      email: doc['email'],
      username: doc['username'],
      photoUrl: doc['photoUrl'],
      displayName: doc ['displayName'],
      bio: doc['bio'],
      tier1Price: doc['tier1Price'],
      tier2Price: doc['tier2Price'],
      tier3Price: doc['tier3Price'],
    );
  }

}