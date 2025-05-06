import 'package:dio/dio.dart';
import '../../../data/models/user/user_model.dart';
import '../../../core/constants/api/login_api.dart';
import '../../../core/constants/user/role.dart';

class LoginService {
  Future<User> login(Dio dio, String name, String password) async {
    final response = await dio.post(
      LoginApi.login,
      data: {
        'name': name,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final userData = response.data;
      return User(
        userId: userData['id'].toString(),
        role: userData['role'] == 'PARENT' ? UserRole.parent : UserRole.child,
        childList: [],
        myParent: null,
      );
    } else {
      throw Exception('로그인 실패: 서버 응답 오류 (${response.statusCode})');
    }
  }
}
