import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geo_tracker/models/location.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});

  final CollectionReference locationCollection =
      Firestore.instance.collection('locations');
  Future updateUserData(String email, double lat, double lng) async {
    return await locationCollection
        .document(uid)
        .setData({'uid': uid, 'email': email, 'lat': lat, 'lng': lng});
  }

  List<Location> _locationListFromSnapShot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return Location(
        email: doc.data['email'],
        lat: doc.data['lat'],
        lng: doc.data['lng'],
      );
    }).toList();
  }

  Stream<List<Location>> get locations {
    return locationCollection.snapshots().map(_locationListFromSnapShot);
  }

//   UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
//     return UserData(
//       uid: uid,
//       lat: snapshot.data['lat'],
//       lng: snapshot.data['lng'],
//     );
//   }

//   Stream<UserData> get userData {
//     return locationCollection
//         .document(uid)
//         .snapshots()
//         .map(_userDataFromSnapshot);
//   }
}
