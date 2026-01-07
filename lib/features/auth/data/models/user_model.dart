import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:resq/features/auth/domain/entities/user.dart' as domain;

extension UserModel on firebase_auth.UserCredential {
  domain.User toDomain() {
    return domain.User(
      id: user!.uid,
      email: user!.email ?? '',
      name: user!.displayName,
    );
  }
}

