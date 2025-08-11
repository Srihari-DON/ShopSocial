import '../models/user.dart';

abstract class IUserService {
  Future<User> getCurrentUser();
  Future<User> getUserById(String id);
  Future<List<User>> getUsersByIds(List<String> ids);
  Future<User> loginWithEmail(String email, String password);
  Future<User> loginWithSocial(String provider);
  Future<User> register(String name, String email, String password);
  Future<User> updateProfile(String userId, Map<String, dynamic> data);
  Future<void> logout();
}
