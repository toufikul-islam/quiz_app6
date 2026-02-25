import 'package:hive/hive.dart';

class SessionManager {
  static final SessionManager instance = SessionManager._init();
  static const String _sessionBoxName = 'session';

  SessionManager._init();

  Future<Box> get _box async {
    if (!Hive.isBoxOpen(_sessionBoxName)) {
      return await Hive.openBox(_sessionBoxName);
    }
    return Hive.box(_sessionBoxName);
  }

  // ==================== ADMIN SESSION ====================

  // Save admin session
  Future<void> saveAdminSession() async {
    final box = await _box;
    await box.put('isAdminLoggedIn', true);
    await box.put('adminLoginTime', DateTime.now().toIso8601String());
  }

  // Check if admin is logged in
  Future<bool> isAdminLoggedIn() async {
    final box = await _box;
    return box.get('isAdminLoggedIn', defaultValue: false);
  }

  // Logout admin
  Future<void> logoutAdmin() async {
    final box = await _box;
    await box.delete('isAdminLoggedIn');
    await box.delete('adminLoginTime');
  }

  // Get admin login time
  Future<String?> getAdminLoginTime() async {
    final box = await _box;
    return box.get('adminLoginTime');
  }

  // ==================== STUDENT SESSION ====================

  // Save student session
  Future<void> saveStudentSession(
    String studentId,
    String studentName,
    String studentEmail,
  ) async {
    final box = await _box;
    await box.put('isStudentLoggedIn', true);
    await box.put('studentId', studentId);
    await box.put('studentName', studentName);
    await box.put('studentEmail', studentEmail);
    await box.put('studentLoginTime', DateTime.now().toIso8601String());
  }

  // Check if student is logged in
  Future<bool> isStudentLoggedIn() async {
    final box = await _box;
    return box.get('isStudentLoggedIn', defaultValue: false);
  }

  // Get logged in student ID
  Future<String?> getLoggedInStudentId() async {
    final box = await _box;
    return box.get('studentId');
  }

  // Get logged in student name
  Future<String?> getLoggedInStudentName() async {
    final box = await _box;
    return box.get('studentName');
  }

  // Get logged in student email
  Future<String?> getLoggedInStudentEmail() async {
    final box = await _box;
    return box.get('studentEmail');
  }

  // Get student login time
  Future<String?> getStudentLoginTime() async {
    final box = await _box;
    return box.get('studentLoginTime');
  }

  // Logout student
  Future<void> logoutStudent() async {
    final box = await _box;
    await box.delete('isStudentLoggedIn');
    await box.delete('studentId');
    await box.delete('studentName');
    await box.delete('studentEmail');
    await box.delete('studentLoginTime');
  }

  // ==================== GENERAL ====================

  // Clear all sessions
  Future<void> clearAllSessions() async {
    final box = await _box;
    await box.clear();
  }
}
