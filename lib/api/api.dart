

// ignore_for_file: avoid_print

import 'dart:io';

import 'package:chatx/models/message.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;

import 'package:chatx/main.dart';
import 'package:chatx/models/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class APIs {
  ///Firebase Authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  ///Firestore
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  ///Firebase Storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  //Firebase Messaging
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // / for storing self information
  static ChatUser me = ChatUser(
      id: cuser.uid,
      name: cuser.displayName.toString(),
      email: cuser.email.toString(),
      about: "Hey, I'm using We Chat!",
      image: cuser.photoURL.toString(),
      createdAt: '',
      isOnline: false,
      lastActive: '',
      pushToken: '');


  // to return current user
  static User get user => auth.currentUser!;



  // for adding an chat user for our conversation
  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    print('data: ${data.docs}');

    if (data.docs.isNotEmpty && data.docs.first.id != user.email) {
      //user exists

      print('user exists: ${data.docs.first.data()}');

      firestore
          .collection('users')
          .doc(user.email)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});

      return true;
    } else {
      //user doesn't exists

      return false;
    }
  }






  ///get current user
  static User get cuser => auth.currentUser!;

  ///For Checking user exists or not
  static Future<bool> userExists() async {
    return (await firestore
            .collection("users")
            .doc(auth.currentUser?.email)
            .get())
        .exists;
  }

  ///For Creating new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
      image: cuser.photoURL,
      name: cuser.displayName ?? UserName,
      about: "Hey, I'm using ChatX!",
      createdAt: time,
      lastActive: time,
      id: cuser.uid,
      isOnline: false,
      email: cuser.email,
      pushToken: "",
      verified: false,
    );

    return await firestore
        .collection("users")
        .doc(cuser.email)
        .set(chatUser.toJson());
  }

  ///Getting all user from firestore
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return APIs.firestore
        .collection("users")
        .where("id", isNotEqualTo: auth.currentUser!.uid)
        .snapshots();
  }

  // for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  /// Update profile picture of the user
  static Future<String?> updateUserProfileImage(imageFile) async {
    try {
      if (imageFile == null) {
        throw Exception("No image selected!");
      }

      // Get the file name
      String fileName = path.basename(imageFile.path);

      // Create a reference to the "profile_images" folder in Firebase Storage
      Reference storageReference =
          FirebaseStorage.instance.ref().child("profile_images/$fileName");

      // Upload the file to Firebase Storage
      TaskSnapshot uploadTask = await storageReference.putFile(imageFile);

      // Get the download URL of the uploaded image
      String downloadURL = await uploadTask.ref.getDownloadURL();

      // Update the user's profile image in Firestore
      await firestore
          .collection("users")
          .doc(cuser.email)
          .update({'image': downloadURL});

      return downloadURL;
    } catch (e) {
      // Handle any errors that occurred during the upload process
      print("Error uploading image: $e");
      return null;
    }
  }



  // update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(cuser.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
    });
  }



  /// *************   Chat Screen Related APIs  *********************** ///

  ///useful for getting conversation id
  static String getConversationID(String id) =>
      cuser.uid.hashCode <= id.hashCode
          ? '${cuser.uid}_$id'
          : '${id}_${cuser.uid}';


  ///Getting all messages of a specific conversation from firestore
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    try {
      final messages = firestore
          .collection("chats/${getConversationID(user.id!)}/messages/")
          .snapshots();
      return messages;
    } catch (e) {
      print("getAllMessages Method : \n $e");
      return const Stream.empty();
    }
  }

  ///For sending message
  static Future<void> sendMessage(ChatUser chatUser, String msg, Type type) async {
    ///message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //messsage to send
    final Message message = Message(
        msg: msg,
        read: "",
        toId: chatUser.id!,
        type: type,
        fromId: APIs.cuser.uid,
        sent: time);


    try {
      final ref = firestore
          .collection("chats/${getConversationID(chatUser.id!)}/messages/");
      await ref.doc(time).set(message.toJson());
    } catch(error){
      print("Send Message Error : \n$error");
    }
  }

  //update read status of message
  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }


  //get only last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id!)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }


  ///Send Image to Firebase Storage and then send its url to Firestore
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    final ext = file.path.split('.').last;

    final ref = FirebaseStorage.instance.ref().child(
        'images/${getConversationID(chatUser.id!)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    final uploadTask = ref.putFile(file, SettableMetadata(contentType: 'image/$ext'));

    try {
      // Await the completion of the upload task
      await uploadTask;

      // Retrieve the download URL after upload is complete
      final downloadUrl = await ref.getDownloadURL();
      print('Download URL: $downloadUrl');

      // Here you can call your sendMessage function and include the downloadUrl
      sendMessage(chatUser, downloadUrl.toString(), Type.image);
    } catch (error) {
      print('Upload Error: $error');
    }
  }



  //delete message
  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }


}
