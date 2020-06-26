import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geo_tracker/models/location.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});

  final CollectionReference locationCollection =
      Firestore.instance.collection('locations');
  Future updateUserData(String email, double lat, double lng) async {
    return await locationCollection.document(uid).setData(
        {'uid': uid, 'email': email, 'lat': lat, 'lng': lng, 'online': false});
  }

  Future updateUserLocation(double lat, double lng) async {
    return await locationCollection
        .document(uid)
        .updateData({'lat': lat, 'lng': lng});
  }

  Future updateUserStatus(bool status) async {
    return await locationCollection
        .document(uid)
        .updateData({'online': status});
  }

  List<Location> _locationListFromSnapShot(QuerySnapshot snapshot) {
    List _filteredLocations =
        snapshot.documents.where((doc) => doc.data['online'] == true).toList();
    return _filteredLocations.map((doc) {
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
}
