const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
// const logging = require('@google-cloud/logging')();
// const stripe = require('stripe')(functions.config().stripe.token);
// const currency = functions.config().stripe.currency || 'USD';

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//


exports.onCreateFollower = functions.firestore
  .document("/followers/{userId}/userFollowers/{followerId}")//add /followType ( free, t1, t2, t3)
  .onCreate(async (snapshot, context) => {
    console.log("Follower Created", snapshot.id);
    const userId = context.params.userId;
    const followerId = context.params.followerId;

    // 1) Create followed users posts ref
    const followedUserPostsRef = admin
      .firestore()
      .collection("posts")
      .doc(userId)
      .collection("userPosts");

    // 2) Create following user's timeline ref
    const timelinePostsRef = admin
      .firestore()
      .collection("timeline")
      .doc(followerId)
      .collection("timelinePosts");//.where("followType" > postTier) to get post type and limit them to free(0), t1,t2,t3 etc.

    // 3) Get followed users posts
    const querySnapshot = await followedUserPostsRef.get();

    // 4) Add each user post to following user's timeline
    querySnapshot.forEach(doc => {
      if (doc.exists) {
        const postId = doc.id;
        const postData = doc.data();
        timelinePostsRef.doc(postId).set(postData);
      }
    });
  });

exports.onDeleteFollower = functions.firestore
  .document("/followers/{userId}/userFollowers/{followerId}")
  .onDelete(async (snapshot, context) => {
    console.log("Follower Deleted", snapshot.id);

    const userId = context.params.userId;
    const followerId = context.params.followerId;

    const timelinePostsRef = admin
      .firestore()
      .collection("timeline")
      .doc(followerId)
      .collection("timelinePosts")
      .where("ownerId", "==", userId);

    const querySnapshot = await timelinePostsRef.get();
    querySnapshot.forEach(doc => {
      if (doc.exists) {
        doc.ref.delete();
      }
    });
  });

// when a post is created, add post to timeline of each follower (of post owner)
exports.onCreatePost = functions.firestore
  .document("/posts/{userId}/userPosts/{postId}")
  .onCreate(async (snapshot, context) => {
    const postCreated = snapshot.data();
    const userId = context.params.userId;
    const postId = context.params.postId;

    // 1) Get all the followers of the user who made the post
    const userFollowersRef = admin
      .firestore()
      .collection("followers")
      .doc(userId)
      .collection("userFollowers");

    const querySnapshot = await userFollowersRef.get();
    // 2) Add new post to each follower's timeline
    querySnapshot.forEach(doc => {
      const followerId = doc.id;

      admin
        .firestore()
        .collection("timeline")
        .doc(followerId)
        .collection("timelinePosts")
        .doc(postId)
        .set(postCreated);
    });
  });

exports.onUpdatePost = functions.firestore
  .document("/posts/{userId}/userPosts/{postId}")
  .onUpdate(async (change, context) => {
    const postUpdated = change.after.data();
    const userId = context.params.userId;
    const postId = context.params.postId;

    // 1) Get all the followers of the user who made the post
    const userFollowersRef = admin
      .firestore()
      .collection("followers")
      .doc(userId)
      .collection("userFollowers");

    const querySnapshot = await userFollowersRef.get();
    // 2) Update each post in each follower's timeline
    querySnapshot.forEach(doc => {
      const followerId = doc.id;

      admin
        .firestore()
        .collection("timeline")
        .doc(followerId)
        .collection("timelinePosts")
        .doc(postId)
        .get()
        .then(doc => {
          if (doc.exists) {
            doc.ref.update(postUpdated);
          }
        });
    });
  });

exports.onDeletePost = functions.firestore
  .document("/posts/{userId}/userPosts/{postId}")
  .onDelete(async (snapshot, context) => {
    const userId = context.params.userId;
    const postId = context.params.postId;

    // 1) Get all the followers of the user who made the post
    const userFollowersRef = admin
      .firestore()
      .collection("followers")
      .doc(userId)
      .collection("userFollowers");

    const querySnapshot = await userFollowersRef.get();
    // 2) Delete each post in each follower's timeline
    querySnapshot.forEach(doc => {
      const followerId = doc.id;

      admin
        .firestore()
        .collection("timeline")
        .doc(followerId)
        .collection("timelinePosts")
        .doc(postId)
        .get()
        .then(doc => {
          if (doc.exists) {
            doc.ref.delete();
          }
        });
    });
  });


  //STRIPE PAYMENT FUNCTIONS LISTED BELOW

  //create a stripe customer
//   exports.createStripeCustomer = functions.auth.user().onCreate(async (user) => {
//     const customer = await stripe.customers.create({email: user.email});
//     return admin.firestore().collection('users')
//         .doc(user.id).set({stripeId: customer.id});
// });

// //create a stripe payment method
// exports.addPaymentSource = functions.firestore
//     .document('/users/{userId}/tokens/{pushId}')
//     .onWrite(async (change, context) => {
//     const source = change.after.data();
//     const token = source.token;
//     if (source === null) {
//         return null;
//     }
//     try {
//     const snapshot = await
//     admin.firestore()
//     .collection('users')
//     .doc(context.params.userId)
//     .get();
//     const customer = snapshot.data().stripeId;
//     const response = await stripe.customers
//         .createSource(customer, {source: token});
//     return admin.firestore()
//     .collection('users')
//     .doc(context.params.userId)
//     .collection("sources")
//     .doc(response.fingerprint)
//     .set(response, {merge: true});
//     } catch (error) {
//     await change.after.ref
//         .set({'error':userFacingMessage(error)},{merge:true});
//     }
// });

// //make a payment with idempotency
// exports.createStripeCharge = functions.firestore
//     .document('users/{userId}/charges/{id}')
//     .onCreate(async (snap, context) => {
//     const val = snap.data();
//     try {
//     // Look up the Stripe customer id written in createStripeCustomer
//     const snapshot = await admin.firestore()
//     .collection(`users`)
//     .doc(context.params.userId).get();
    
//     const snapval = snapshot.data();
//     const customer = snapval.stripeId;
//     // Create a charge using the pushId as the idempotency key
//     // protecting against double charges
//     const amount = val.amount;
//     const idempotencyKey = context.params.id;
//     const charge = {amount, currency, customer};
//     if (val.source !== null) {
//        charge.source = val.source;
//     }
//     const response = await stripe.charges
//         .create(charge, {idempotency_key: idempotencyKey});
//     // If the result is successful, write it back to the database
//     return snap.ref.set(response, { merge: true });
//     } catch(error) {
//         await snap.ref.set({error: userFacingMessage(error)}, { merge: true });
//     }
// });

// // When a user deletes their account, clean up after them. Needed for data compliance.
// exports.cleanupUser = functions.auth.user().onDelete(async (user) => {
//   const snapshot = await admin.firestore().collection('users').doc(user.id).get();
//   const customer = snapshot.data();
//   await stripe.customers.del(customer.stripeId);
//   return admin.firestore().collection('users').doc(user.id).delete();
// });