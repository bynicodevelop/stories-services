abstract class ReservationRepository {
  createReservation(String username, String slug, String phoneNumber);

  Future<bool> slugExists(String slug);

  Future<bool> phoneNumberExist(String phoneNumber);
}
