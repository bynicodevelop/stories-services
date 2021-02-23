import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:services/repositories/ReservationRepository.dart';

class FirebaseReservationRepository implements ReservationRepository {
  static const String collectionName = 'reservations';

  final FirebaseFirestore firestore;

  FirebaseReservationRepository({
    this.firestore,
  }) {
    print(firestore);
  }

  @override
  createReservation(String displayName, String slug, String phoneNumber) async {
    await firestore.collection(collectionName).doc(slug).set({
      'displayName': displayName,
      'slug': slug,
      'phoneNumber': phoneNumber,
    });
  }

  @override
  Future<bool> slugExists(String slug) async {
    DocumentSnapshot documentSnapshot =
        await firestore.collection(collectionName).doc(slug).get();

    return documentSnapshot.exists;
  }

  @override
  Future<bool> phoneNumberExist(String phoneNumber) async {
    QuerySnapshot querySnapshot = await firestore
        .collection(collectionName)
        .where('phoneNumber', isEqualTo: phoneNumber)
        .get();

    return querySnapshot.docs.length > 0;
  }
}
