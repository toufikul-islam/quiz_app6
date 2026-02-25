import 'dart:convert';
import 'package:crypto/crypto.dart';

class PasswordUtils {
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static bool verifyPassword(String password, String hashedPassword) {
    final inputHash = hashPassword(password);
    return inputHash == hashedPassword;
  }

  static final String defaultAdminPasswordHash = hashPassword('admin123');
}
