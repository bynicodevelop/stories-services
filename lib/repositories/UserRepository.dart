abstract class UserRepository {
  Future<bool> isAuthenticated();

  Future<String> authencateWithEmail(String email, String password);

  Future<String> getUserId();

  Future<void> signOut();
}
