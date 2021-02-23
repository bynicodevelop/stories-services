import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:services/repositories/FirebaseReservationRepository.dart';

main() {
  group("createReservation", () {
    test("Doit retourner un success", () async {
      // ARRANGE
      FirebaseFirestoreMock firebaseFirestoreMock = FirebaseFirestoreMock();
      CollectionReferenceMock collectionReferenceMock =
          CollectionReferenceMock();
      DocumentReferenceMock documentReferenceMock = DocumentReferenceMock();

      when(documentReferenceMock.set(any)).thenAnswer((_) => Future.value());

      when(collectionReferenceMock.doc('slug'))
          .thenReturn(documentReferenceMock);

      when(firebaseFirestoreMock
              .collection(FirebaseReservationRepository.collectionName))
          .thenReturn(collectionReferenceMock);

      FirebaseReservationRepository firebaseReservationRepository =
          FirebaseReservationRepository(
        firestore: firebaseFirestoreMock,
      );

      // ACT
      // ASSERT
      await firebaseReservationRepository.createReservation(
        'username',
        'slug',
        'phoneNumber',
      );

      verify(documentReferenceMock.set({
        'displayName': 'username',
        'slug': 'slug',
        'phoneNumber': 'phoneNumber',
      }));
    });
  });

  group("slugExists", () {
    test("Doit retourner false quand le slug n'existe pas", () async {
      // ARRANGE
      FirebaseFirestoreMock firebaseFirestoreMock = FirebaseFirestoreMock();
      CollectionReferenceMock collectionReferenceMock =
          CollectionReferenceMock();
      DocumentReferenceMock documentReferenceMock = DocumentReferenceMock();
      DocumentSnapshotMock documentSnapshotMock = DocumentSnapshotMock();

      when(documentSnapshotMock.exists).thenReturn(false);

      when(documentReferenceMock.get())
          .thenAnswer((_) => Future.value(documentSnapshotMock));

      when(collectionReferenceMock.doc('slug'))
          .thenReturn(documentReferenceMock);

      when(firebaseFirestoreMock
              .collection(FirebaseReservationRepository.collectionName))
          .thenReturn(collectionReferenceMock);

      FirebaseReservationRepository firebaseReservationRepository =
          FirebaseReservationRepository(firestore: firebaseFirestoreMock);

      // ACT
      final bool result =
          await firebaseReservationRepository.slugExists('slug');

      // ASSERT

      expect(result, false);
    });

    test("Doit retourner vrai si le slug exist", () async {
      // ARRANGE
      FirebaseFirestoreMock firebaseFirestoreMock = FirebaseFirestoreMock();
      CollectionReferenceMock collectionReferenceMock =
          CollectionReferenceMock();
      DocumentReferenceMock documentReferenceMock = DocumentReferenceMock();
      DocumentSnapshotMock documentSnapshotMock = DocumentSnapshotMock();

      when(documentSnapshotMock.exists).thenReturn(true);

      when(documentReferenceMock.get())
          .thenAnswer((_) => Future.value(documentSnapshotMock));

      when(collectionReferenceMock.doc('slug'))
          .thenReturn(documentReferenceMock);

      when(firebaseFirestoreMock
              .collection(FirebaseReservationRepository.collectionName))
          .thenReturn(collectionReferenceMock);

      FirebaseReservationRepository firebaseReservationRepository =
          FirebaseReservationRepository(firestore: firebaseFirestoreMock);

      // ACT
      final bool result =
          await firebaseReservationRepository.slugExists('slug');

      // ASSERT
      expect(result, true);
    });
  });

  group("phoneNumberExists", () {
    test("Doit retourner false si le numéro n'existe pas.", () async {
      // ARRANGE
      FirebaseFirestoreMock firebaseFirestoreMock = FirebaseFirestoreMock();
      CollectionReferenceMock collectionReferenceMock =
          CollectionReferenceMock();
      QueryMock queryMock = QueryMock();
      QuerySnapshotMock querySnapshotMock = QuerySnapshotMock();

      when(querySnapshotMock.docs).thenReturn([QueryDocumentSnapshotMock()]);

      when(queryMock.get()).thenAnswer((_) => Future.value(querySnapshotMock));

      when(collectionReferenceMock.where('phoneNumber',
              isEqualTo: '+33601010101'))
          .thenReturn(queryMock);

      when(firebaseFirestoreMock
              .collection(FirebaseReservationRepository.collectionName))
          .thenReturn(collectionReferenceMock);

      FirebaseReservationRepository firebaseReservationRepository =
          FirebaseReservationRepository(firestore: firebaseFirestoreMock);

      // ACT
      final bool result =
          await firebaseReservationRepository.phoneNumberExist('+33601010101');

      // ASSERT
      expect(result, true);
    });

    test("Doit retourner true si le numéro existe.", () async {
      // ARRANGE
      FirebaseFirestoreMock firebaseFirestoreMock = FirebaseFirestoreMock();
      CollectionReferenceMock collectionReferenceMock =
          CollectionReferenceMock();
      QueryMock queryMock = QueryMock();
      QuerySnapshotMock querySnapshotMock = QuerySnapshotMock();

      when(querySnapshotMock.docs).thenReturn([]);

      when(queryMock.get()).thenAnswer((_) => Future.value(querySnapshotMock));

      when(collectionReferenceMock.where('phoneNumber',
              isEqualTo: '+33601010101'))
          .thenReturn(queryMock);

      when(firebaseFirestoreMock
              .collection(FirebaseReservationRepository.collectionName))
          .thenReturn(collectionReferenceMock);

      FirebaseReservationRepository firebaseReservationRepository =
          FirebaseReservationRepository(firestore: firebaseFirestoreMock);

      // ACT
      final bool result =
          await firebaseReservationRepository.phoneNumberExist('+33601010101');

      // ASSERT
      expect(result, false);
    });
  });
}

class FirebaseFirestoreMock extends Mock implements FirebaseFirestore {}

class CollectionReferenceMock extends Mock implements CollectionReference {}

class DocumentReferenceMock extends Mock implements DocumentReference {}

class DocumentSnapshotMock extends Mock implements DocumentSnapshot {}

class QuerySnapshotMock extends Mock implements QuerySnapshot {}

class QueryMock extends Mock implements Query {}

class QueryDocumentSnapshotMock extends Mock implements QueryDocumentSnapshot {}

class FirebaseReservationRepositoryMock extends Mock
    implements FirebaseReservationRepository {}
