import '../models/user.dart';
import '../services/i_user_service.dart';

class UserRepository {
  final IUserService _userService;
  
  UserRepository(this._userService);
  
  Future<User> getCurrentUser() {
    return _userService.getCurrentUser();
  }
  
  Future<User> getUserById(String id) {
    return _userService.getUserById(id);
  }
  
  Future<List<User>> getUsersByIds(List<String> ids) {
    return _userService.getUsersByIds(ids);
  }
  
  Future<User> loginWithEmail(String email, String password) {
    return _userService.loginWithEmail(email, password);
  }
  
  Future<User> loginWithSocial(String provider) {
    return _userService.loginWithSocial(provider);
  }
  
  Future<User> register(String name, String email, String password) {
    return _userService.register(name, email, password);
  }
  
  Future<User> updateProfile(String userId, Map<String, dynamic> data) {
    return _userService.updateProfile(userId, data);
  }
  
  Future<void> logout() {
    return _userService.logout();
  }
}
