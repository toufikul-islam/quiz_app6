import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import '../models/question.dart';
import '../models/student.dart';
import '../models/category.dart';
import '../utils/password_utils.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _boxName = 'questions';
  static const String _studentsBoxName = 'students';
  static const String _scoresBoxName = 'scores';
  static const String _adminBoxName = 'admin';
  static const String _categoriesBoxName = 'categories';

  DatabaseHelper._init();

  // --- Helper for Box Access ---
  Future<Box> _getBox(String name) async {
    if (!Hive.isBoxOpen(name)) {
      return await Hive.openBox(name);
    }
    return Hive.box(name);
  }

  // --- Admin Operations ---
  Future<void> initializeAdmin() async {
    final box = await _getBox(_adminBoxName);
    if (!box.containsKey('admin')) {
      await box.put('admin', {
        'username': 'admin',
        'passwordHash': PasswordUtils.hashPassword('admin123'),
      });
    }
    try {
      await _firestore.collection('config').doc('admin').set({
        'username': 'admin',
        'passwordHash': PasswordUtils.hashPassword('admin123'),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Firebase Admin Sync Skip: $e');
    }
  }

  Future<bool> verifyAdminCredentials(String username, String password) async {
    try {
      final doc = await _firestore.collection('config').doc('admin').get();
      if (doc.exists) {
        final data = doc.data()!;
        return username == data['username'] &&
            PasswordUtils.verifyPassword(password, data['passwordHash']);
      }
    } catch (e) {
      print('Firebase Admin Auth Fallback: $e');
    }

    final box = await _getBox(_adminBoxName);
    final adminData = box.get('admin');
    if (adminData == null) {
      await initializeAdmin();
      return username == 'admin' && password == 'admin123';
    }
    return username == adminData['username'] &&
        PasswordUtils.verifyPassword(password, adminData['passwordHash']);
  }

  // --- Question Operations ---
  Future<void> createQuestion(Question question) async {
    try {
      final box = await _getBox(_boxName);
      await box.put(question.id, question.toMap());
      await _firestore
          .collection('questions')
          .doc(question.id)
          .set(question.toMap());
    } catch (e) {
      throw Exception('Failed to add question: $e');
    }
  }

  Future<List<Question>> getAllQuestions() async {
    try {
      final snapshot = await _firestore.collection('questions').get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => Question.fromMap(doc.data()))
            .toList();
      }
    } catch (e) {
      print('Firebase Load Questions Fallback: $e');
    }
    final box = await _getBox(_boxName);
    return box.values
        .map((item) => Question.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<List<Question>> getQuestionsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection('questions')
          .where('category', isEqualTo: category)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => Question.fromMap(doc.data()))
            .toList();
      }
    } catch (e) {
      print('Firebase Category Load Fallback: $e');
    }
    final all = await getAllQuestions();
    return all.where((q) => q.category == category).toList();
  }

  // --- Category Operations ---
  Future<List<Category>> getAllCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => Category.fromMap(doc.data()))
            .toList();
      }
    } catch (e) {
      print('Firebase Categories Load Fallback: $e');
    }
    final box = await _getBox(_categoriesBoxName);
    return box.values
        .map((item) => Category.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<List<String>> getAllCategoryNames() async {
    final categories = await getAllCategories();
    final names = categories.map((c) => c.name).toList();
    names.sort();
    return names;
  }

  Future<void> createCategory(Category category) async {
    try {
      final existing = await getCategoryByName(category.name);
      if (existing != null) throw Exception('Category already exists');

      final box = await _getBox(_categoriesBoxName);
      await box.put(category.id, category.toMap());
      await _firestore
          .collection('categories')
          .doc(category.id)
          .set(category.toMap());
    } catch (e) {
      throw Exception('Failed to add category: $e');
    }
  }

  Future<Category?> getCategoryByName(String name) async {
    final categories = await getAllCategories();
    for (var category in categories) {
      if (category.name.toLowerCase() == name.toLowerCase()) return category;
    }
    return null;
  }

  Future<void> updateCategory(Category category, {String? oldName}) async {
    try {
      final box = await _getBox(_categoriesBoxName);
      await box.put(category.id, category.toMap());
      await _firestore
          .collection('categories')
          .doc(category.id)
          .set(category.toMap());

      if (oldName != null && oldName != category.name) {
        await updateQuestionsCategoryName(oldName, category.name);
      }
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  Future<void> updateQuestionsCategoryName(
    String oldName,
    String newName,
  ) async {
    final questions = await getQuestionsByCategory(oldName);
    for (var question in questions) {
      final updated = Question(
        id: question.id,
        questionText: question.questionText,
        optionA: question.optionA,
        optionB: question.optionB,
        optionC: question.optionC,
        optionD: question.optionD,
        correctAnswer: question.correctAnswer,
        category: newName,
      );
      await updateQuestion(updated);
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      final box = await _getBox(_categoriesBoxName);
      await box.delete(id);
      await _firestore.collection('categories').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  Future<int> getQuestionCountByCategory(String categoryName) async {
    final questions = await getQuestionsByCategory(categoryName);
    return questions.length;
  }

  Future<void> initializeDefaultCategories() async {
    final cats = await getAllCategories();
    if (cats.isEmpty) {
      final defaultCategories = [
        'Math',
        'Science',
        'History',
        'Geography',
        'General Knowledge',
      ];
      for (int i = 0; i < defaultCategories.length; i++) {
        final category = Category(
          id: 'cat_${i + 1}',
          name: defaultCategories[i],
        );
        await createCategory(category);
      }
    }
  }

  Future<Question?> getQuestion(String id) async {
    try {
      final doc = await _firestore.collection('questions').doc(id).get();
      if (doc.exists) return Question.fromMap(doc.data()!);
    } catch (e) {}
    final box = await _getBox(_boxName);
    final data = box.get(id);
    return data != null
        ? Question.fromMap(Map<String, dynamic>.from(data as Map))
        : null;
  }

  Future<void> updateQuestion(Question question) async {
    await createQuestion(question);
  }

  Future<void> deleteQuestion(String id) async {
    try {
      final box = await _getBox(_boxName);
      await box.delete(id);
      await _firestore.collection('questions').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete question: $e');
    }
  }

  // --- Student Operations ---
  Future<void> registerStudent(Student student, String password) async {
    try {
      // 1. Firebase Auth - create user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: student.email,
        password: password,
      );

      // 2. Send verification email
      await userCredential.user!.sendEmailVerification();

      // 3. Store in Firestore with isActive: false
      await _firestore.collection('students').doc(userCredential.user!.uid).set(
        {
          ...student.toMap(),
          'isActive': false,
          'uid': userCredential.user!.uid,
        },
      );

      // 4. Store in local Hive
      final box = await _getBox(_studentsBoxName);
      await box.put(student.id, {...student.toMap(), 'isActive': false});
    } catch (e) {
      throw Exception('Failed to register student: $e');
    }
  }

  Future<Student?> loginStudent(String email, String password) async {
    try {
      // 1. Firebase Auth - sign in
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Refresh and check email verification
      await userCredential.user!.reload();
      if (!userCredential.user!.emailVerified) {
        throw Exception('ACCOUNT_NOT_ACTIVATED');
      }

      // 3. Activate account in Firestore
      final uid = userCredential.user!.uid;
      await _firestore.collection('students').doc(uid).update({
        'isActive': true,
      });

      // 4. Return student data
      final doc = await _firestore.collection('students').doc(uid).get();
      if (doc.exists) {
        return Student.fromMap(doc.data()!);
      }
    } catch (e) {
      rethrow;
    }

    // Local fallback (offline)
    final student = await getStudentByEmail(email);
    if (student != null &&
        PasswordUtils.verifyPassword(password, student.passwordHash)) {
      if (!student.isActive) {
        throw Exception('ACCOUNT_NOT_ACTIVATED');
      }
      return student;
    }
    return null;
  }

  Future<Student?> getStudentByEmail(String email) async {
    final box = await _getBox(_studentsBoxName);
    for (var value in box.values) {
      final s = Student.fromMap(Map<String, dynamic>.from(value as Map));
      if (s.email.toLowerCase() == email.toLowerCase()) return s;
    }
    return null;
  }

  Future<Student?> getStudentById(String id) async {
    try {
      final doc = await _firestore.collection('students').doc(id).get();
      if (doc.exists) return Student.fromMap(doc.data()!);
    } catch (e) {}
    final box = await _getBox(_studentsBoxName);
    final data = box.get(id);
    return data != null
        ? Student.fromMap(Map<String, dynamic>.from(data as Map))
        : null;
  }

  // --- Score Operations ---
  Future<void> saveScore(ScoreHistory score) async {
    try {
      final box = await _getBox(_scoresBoxName);
      await box.put(score.id, score.toMap());
      await _firestore.collection('scores').doc(score.id).set(score.toMap());
    } catch (e) {
      throw Exception('Failed to save score: $e');
    }
  }

  Future<List<ScoreHistory>> getStudentScores(String studentId) async {
    try {
      final snapshot = await _firestore
          .collection('scores')
          .where('studentId', isEqualTo: studentId)
          .get();
      if (snapshot.docs.isNotEmpty) {
        final scores = snapshot.docs
            .map((doc) => ScoreHistory.fromMap(doc.data()))
            .toList();
        scores.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return scores;
      }
    } catch (e) {
      print('Firebase Scores Load Fallback: $e');
    }
    final box = await _getBox(_scoresBoxName);
    final scores = box.values
        .map(
          (item) =>
              ScoreHistory.fromMap(Map<String, dynamic>.from(item as Map)),
        )
        .where((s) => s.studentId == studentId)
        .toList();
    scores.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return scores;
  }

  // --- Admin Password Reset ---
  Future<void> resetAdminPassword(String newPassword) async {
    try {
      final newHash = PasswordUtils.hashPassword(newPassword);

      final box = await _getBox(_adminBoxName);
      await box.put('admin', {'username': 'admin', 'passwordHash': newHash});

      await _firestore.collection('config').doc('admin').set({
        'username': 'admin',
        'passwordHash': newHash,
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to reset admin password: $e');
    }
  }

  Future<void> updateStudentProfile(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('students').doc(id).update(data);
      final box = await _getBox(_studentsBoxName);
      final currentData = box.get(id);
      if (currentData != null) {
        final updatedData = Map<String, dynamic>.from(currentData);
        updatedData.addAll(data);
        await box.put(id, updatedData);
      }
    } catch (e) {
      throw Exception('Failed to update student profile: $e');
    }
  }

  Future<void> updateStudentPassword(String email, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user != null && user.email == email) {
        await user.updatePassword(newPassword);
        
        // Update hash in firestore and hive
        final newHash = PasswordUtils.hashPassword(newPassword);
        final student = await getStudentByEmail(email);
        if (student != null) {
          await updateStudentProfile(student.id, {'passwordHash': newHash});
        }
      } else {
        throw Exception('User not logged in or email mismatch');
      }
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }

  Future<void> close() async {
    await Hive.close();
  }
}
