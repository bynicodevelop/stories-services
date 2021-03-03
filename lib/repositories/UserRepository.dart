abstract class UserRepository {
  Future<bool> isAuthenticated();

  Future<Map<String, String>> authencateWithEmail(
    String email,
    String password,
  );

  Future<String> getUserId();

  Future<String> getUserEmail();

  Future<void> updateEmail(String email);

  Future<void> signOut();
}
