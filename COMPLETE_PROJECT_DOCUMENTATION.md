# Flutter Quiz App - Complete Project Documentation
**Comprehensive Guide: Architecture, Files, Functions, and Implementation Details**

---

## Table of Contents

1. [App Overview](#app-overview)
2. [Project Structure](#project-structure)
3. [Architecture & Design Patterns](#architecture--design-patterns)
4. [Technology Stack](#technology-stack)
5. [Entry Point - main.dart](#entry-point---maindart)
6. [Database Layer - database_helper.dart](#database-layer---database_helperdart)
7. [Data Models](#data-models)
8. [Utilities](#utilities)
9. [Screens - Admin Section](#screens---admin-section)
10. [Screens - Student Section](#screens---student-section)
11. [Database System & Schema](#database-system--schema)
12. [Session Management](#session-management)
13. [User Workflows](#user-workflows)
14. [Data Flow Diagrams](#data-flow-diagrams)
15. [Navigation Flow](#navigation-flow)
16. [Summary](#summary)

---

# APP OVERVIEW

**Quiz App** is a Flutter web application that allows two types of users to interact with a quiz system:

- **Administrators**: Manage quiz categories and questions
- **Students**: Register, login, and take quizzes

The app uses **Hive database** (local storage compatible with web, mobile, and desktop platforms) and stores all data persistently on the device.

## Key Features

- Admin authentication with password reset functionality
- Student registration and login
- Category management (CRUD)
- Question management with multiple choice answers
- Quiz taking with real-time scoring
- Score history tracking
- Session management for both admin and student users
- Persistent login sessions
- Password security with SHA-256 hashing

---

# PROJECT STRUCTURE

```
quiz_app/
├── lib/
│   ├── main.dart                              # App entry point
│   ├── database/
│   │   └── database_helper.dart              # Database operations (Singleton)
│   ├── models/
│   │   ├── student.dart                      # Student & ScoreHistory models
│   │   ├── category.dart                     # Category model
│   │   └── question.dart                     # Question model
│   ├── screens/
│   │   ├── home_screen.dart                  # Landing page
│   │   ├── admin_login_screen.dart           # Admin authentication
│   │   ├── admin_dashboard_screen.dart       # Admin main panel
│   │   ├── category_management_screen.dart   # Category CRUD list
│   │   ├── add_category_screen.dart          # Category form (add/edit)
│   │   ├── question_management_screen.dart   # Question CRUD list
│   │   ├── add_edit_question_screen.dart     # Question form (add/edit)
│   │   ├── student_login_screen.dart         # Student authentication
│   │   ├── student_registration_screen.dart  # Student account creation
│   │   ├── student_dashboard_screen.dart     # Student main panel
│   │   ├── student_category_selection_screen.dart  # Quiz category picker
│   │   ├── student_quiz_screen.dart          # Quiz interface
│   │   ├── student_result_screen.dart        # Quiz results (saves score)
│   │   ├── category_selection_screen.dart    # Generic category selector
│   │   ├── quiz_screen.dart                  # Generic quiz screen
│   │   └── result_screen.dart                # Generic result screen
│   └── utils/
│       ├── session_manager.dart              # Session persistence (Singleton)
│       └── password_utils.dart               # Password hashing utilities
├── pubspec.yaml                              # Dependencies & config
└── web/                                      # Web assets
    ├── index.html
    ├── manifest.json
    └── icons/
```

---

# ARCHITECTURE & DESIGN PATTERNS

## Design Patterns Used

### 1. Singleton Pattern
- **DatabaseHelper**: Single instance accessed globally via `DatabaseHelper.instance`
- **SessionManager**: Single instance via `SessionManager.instance`
- Ensures single point of access to shared resources
- Manages Hive boxes (database) and session state

### 2. State Management
- **StatefulWidget Pattern**: Used for screens with user input, forms, and state changes
- **Local state**: Form controllers, loading states, UI states
- No external state management library (Riverpod, Provider, BLoC) - kept simple

### 3. Factory Pattern
- **Model classes**: `fromMap()` constructors create objects from stored data
- **copyWith()** methods for creating modified copies

### 4. Widget Composition
- Reusable UI components built as methods (e.g., `_buildAnswerButton()`)
- Promotes code reuse and maintainability

---

# TECHNOLOGY STACK

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **UI Framework** | Flutter + Material Design 3 | Cross-platform UI |
| **Database** | Hive (NoSQL) | Local persistent storage |
| **Password Security** | SHA-256 hashing (crypto package) | Secure password storage |
| **ID Generation** | UUID package | Unique identifiers |
| **State Management** | Local StatefulWidget state | Form and UI state |
| **Web Config** | index.html, manifest.json | Web platform setup |

## Dependencies (from pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  hive: ^2.2.3              # Database
  hive_flutter: ^1.1.0      # Flutter-specific Hive setup
  crypto: ^3.0.6            # SHA-256 hashing
  uuid: ^4.5.1              # UUID generation

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

---

# ENTRY POINT - main.dart

## File Purpose
Application entry point. Initializes Hive database and starts the Flutter app.

## Initialization Flow

```
Program Start
    ↓
main() async called
    ↓
WidgetsFlutterBinding.ensureInitialized()
  └─ Ensures Flutter can use platform channels
    ↓
await Hive.initFlutter()
  └─ Initializes Hive for Flutter with browser storage (web)
    ↓
await DatabaseHelper.instance.initializeAdmin()
  └─ Creates default admin: username="admin", password="admin123"
    ↓
await DatabaseHelper.instance.initializeDefaultCategories()
  └─ Creates 5 default categories:
     • Math, Science, History, Geography, General Knowledge
    ↓
runApp(const QuizApp())
    ↓
App starts with HomeScreen as home
```

## Code Structure

### Function: `void main() async`

**Type**: Async entry point  
**Purpose**: Initialize app before UI renders

**Steps**:
1. `WidgetsFlutterBinding.ensureInitialized()`
   - Ensures Flutter bindings are ready
   - Required before using async operations in main()

2. `await Hive.initFlutter()`
   - Initializes Hive database
   - Sets up browser storage for web platform
   - Uses app-specific directory for mobile/desktop

3. `await DatabaseHelper.instance.initializeAdmin()`
   - Checks if admin exists in 'admin' Hive box
   - If not, creates default admin user
   - Called once on first app launch

4. `await DatabaseHelper.instance.initializeDefaultCategories()`
   - Checks if 'categories' box is empty
   - Creates 5 default categories if empty
   - Prevents missing categories on fresh install

5. `runApp(const QuizApp())`
   - Launches the root widget
   - Passes control to Flutter's widget system

### Class: `class QuizApp extends StatelessWidget`

**Purpose**: Root widget that configures the app

**Properties**: None (stateless)

**Key Method**: 
```dart
Widget build(BuildContext context)
```

**What it does**:
- Creates MaterialApp with theme
- Sets home to HomeScreen
- Configures Material Design 3
- Disables debug banner

**Theme Configuration**:
```dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
  useMaterial3: true,
)
```

**Result**: Deep purple-themed app with Material Design 3 components

---

# DATABASE LAYER - database_helper.dart

## File Purpose
Central database manager handling all CRUD (Create, Read, Update, Delete) operations for:
- Questions
- Students
- Categories
- Score history
- Admin credentials

## Design Pattern: Singleton

```dart
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  
  DatabaseHelper._init();  // Private constructor prevents multiple instances
}
```

**Benefit**: Only one DatabaseHelper instance throughout app lifetime. Accessed everywhere via `DatabaseHelper.instance`

## Hive Boxes Architecture

The app uses 5 separate Hive boxes for data organization:

| Box Name | Purpose | Key Type | Value Type | Access |
|----------|---------|----------|-----------|--------|
| `questions` | All quiz questions | String (timestamp ID) | Map → Question | Filtered by category |
| `students` | Student accounts | String (timestamp ID) | Map → Student | Lookup by email |
| `scores` | Quiz attempts & results | String (timestamp ID) | Map → ScoreHistory | Filtered by student ID |
| `admin` | Admin credentials | "admin" (fixed key) | {username, passwordHash} | Single admin check |
| `categories` | Quiz categories | String (UUID) | Map → Category | All or by name |
| `session` | (SessionManager) Active user sessions | Various keys | Session data | Login state |

**Why separate boxes?**
- Organization and clarity
- Can clear/manage data by type
- Better performance for specific queries
- Easier to debug data issues

## Key Methods - Admin Operations

### `Future<void> initializeAdmin()`
- **Called**: App startup (in main.dart)
- **Purpose**: Create default admin if none exists
- **Logic**:
  ```
  1. Get 'admin' Hive box
  2. Check if key 'admin' exists
  3. If not:
     - Hash "admin123" password
     - Store {username: "admin", passwordHash: hash}
  4. If exists, do nothing (prevents overwrite)
  ```
- **First Run**: Creates default admin
- **Subsequent Runs**: Skips (admin already exists)

### `Future<bool> verifyAdminCredentials(String username, String password)`
- **Called**: AdminLoginScreen on login button
- **Parameters**:
  - `username`: User input from username field
  - `password`: User input from password field (plain text)
- **Returns**: `bool` - true if credentials match
- **Logic**:
  ```
  1. Get admin box and retrieve 'admin' entry
  2. If no entry found:
     - Initialize (creates default)
     - Compare with default credentials
  3. Compare entered username with stored username
  4. Hash entered password
  5. Compare hashes:
     - PasswordUtils.verifyPassword(entered, stored)
  6. Return true only if username AND password match
  ```
- **Security**: Compares hashes, never plain text

### `Future<void> resetAdminPassword(String newPassword)`
- **Called**: AdminLoginScreen password reset dialog
- **Parameters**: `newPassword` (min 6 chars, validated before call)
- **Logic**:
  ```
  1. Hash new password: PasswordUtils.hashPassword(newPassword)
  2. Update admin box entry with new hash
  3. Overwrites old password hash
  ```

## Key Methods - Question Operations

### `Future<void> createQuestion(Question question)`
- **Called**: AddEditQuestionScreen save button
- **Parameters**: Complete Question object
- **Logic**:
  ```
  1. Convert question to map: question.toMap()
  2. Store in 'questions' box with question.id as key
  3. Each question stored as: {questionText, options A-D, correctAnswer, category}
  ```

### `Future<List<Question>> getAllQuestions()`
- **Called**: QuestionManagementScreen
- **Returns**: All questions in database
- **Logic**:
  ```
  1. Get all values from 'questions' box
  2. Convert each map to Question object using Question.fromMap()
  3. Return as List<Question>
  ```

### `Future<List<Question>> getQuestionsByCategory(String category)`
- **Called**: StudentCategorySelectionScreen to load quiz questions
- **Parameters**: Category name (e.g., "Math")
- **Returns**: Questions matching that category
- **Logic**:
  ```
  1. Get all questions
  2. Filter: keep only where question.category == category
  3. Return filtered list
  ```
- **Example**: 
  - Input: "Math"
  - Returns: [All math questions from questions box]

### `Future<Question?> getQuestion(String id)`
- **Called**: Rarely used, when specific question needed
- **Parameters**: Question ID
- **Returns**: Single question or null
- **Logic**:
  ```
  1. Get 'questions' box
  2. Retrieve by ID
  3. Convert map to Question
  4. Return or null if not found
  ```

### `Future<void> updateQuestion(Question question)`
- **Called**: AddEditQuestionScreen in edit mode
- **Parameters**: Modified Question object (same ID)
- **Logic**:
  ```
  1. Get 'questions' box
  2. Replace old question with new one using same ID
  3. All fields updated (text, options, correct answer, category)
  ```

### `Future<void> deleteQuestion(String id)`
- **Called**: QuestionManagementScreen delete button
- **Parameters**: Question ID to remove
- **Logic**:
  ```
  1. Get 'questions' box
  2. Delete entry by key (ID)
  3. Question removed from all queries
  ```

## Key Methods - Category Operations

### `Future<void> initializeDefaultCategories()`
- **Called**: App startup (in main.dart)
- **Purpose**: Create 5 default categories on first launch
- **Default Categories**:
  1. Math
  2. Science
  3. History
  4. Geography
  5. General Knowledge
- **Logic**:
  ```
  1. Check if 'categories' box is empty
  2. If empty:
     - Create 5 Category objects with IDs: cat_1, cat_2, etc.
     - Store each in 'categories' box
  3. If not empty, skip (categories already exist)
  ```

### `Future<List<Category>> getAllCategories()`
- **Called**: Various screens needing all categories
- **Returns**: All categories
- **Logic**:
  ```
  1. Get all values from 'categories' box
  2. Convert each to Category object
  3. Return list
  ```

### `Future<List<String>> getAllCategoryNames()`
- **Called**: AddEditQuestionScreen dropdown, StudentCategorySelectionScreen
- **Returns**: Category names only (strings)
- **Logic**:
  ```
  1. Get all categories
  2. Extract name from each: category.name
  3. Sort alphabetically
  4. Return List<String>
  ```
- **Why separate method?** Efficient for dropdowns (don't need full objects)

### `Future<Category?> getCategoryByName(String name)`
- **Called**: AddCategoryScreen for duplicate checking
- **Parameters**: Category name to search
- **Returns**: Category object or null
- **Logic**:
  ```
  1. Get all categories
  2. Loop through each:
     - Compare lowercase names: category.name.toLowerCase() == name.toLowerCase()
  3. Return first match or null if not found
  ```
- **Case-insensitive**: "Math" == "MATH" == "math"

### `Future<void> createCategory(Category category)`
- **Called**: AddCategoryScreen create button
- **Parameters**: Category object with name and UUID id
- **Logic**:
  ```
  1. Check if category with same name exists: getCategoryByName(name)
  2. If exists, throw Exception("Category already exists")
  3. Otherwise:
     - Store in 'categories' box with category.id as key
  ```

### `Future<void> updateCategory(Category category, {String? oldName})`
- **Called**: AddCategoryScreen edit button
- **Parameters**:
  - `category`: Updated Category object
  - `oldName`: Previous category name (if changed)
- **Logic**:
  ```
  1. Update category in 'categories' box
  2. If name changed and oldName provided:
     - Call updateQuestionsCategoryName(oldName, newName)
     - This updates all questions with old category
  ```
- **Why special logic?** Ensures data consistency - if category name changes, all associated questions update

### `Future<void> updateQuestionsCategoryName(String oldName, String newName)`
- **Called**: updateCategory() when category name changes
- **Purpose**: Update category in all related questions
- **Logic**:
  ```
  1. Get all questions with oldName: getQuestionsByCategory(oldName)
  2. For each question:
     - Create copy with newName: question.copyWith(category: newName)
     - Update in database: updateQuestion(modifiedQuestion)
  3. All questions now reference new category name
  ```
- **Example**:
  - Admin renames "Maths" to "Mathematics"
  - All questions with category="Maths" now have category="Mathematics"

### `Future<void> deleteCategory(String id)`
- **Called**: CategoryManagementScreen delete button
- **Parameters**: Category ID
- **Logic**:
  ```
  1. Get 'categories' box
  2. Delete by ID
  ```
- **Safety**: QuestionManagementScreen prevents deletion if questions exist

### `Future<int> getQuestionCountByCategory(String categoryName)`
- **Called**: CategoryManagementScreen to show counts
- **Parameters**: Category name
- **Returns**: Number of questions in category
- **Logic**:
  ```
  1. Get all questions in category: getQuestionsByCategory(categoryName)
  2. Return length of list
  3. Returns 0 if error or no questions
  ```

## Key Methods - Student Operations

### `Future<void> registerStudent(Student student)`
- **Called**: StudentRegistrationScreen register button
- **Parameters**: Complete Student object (all fields populated)
- **Logic**:
  ```
  1. Check if email already exists: getStudentByEmail(email)
  2. If exists, throw Exception("Email already registered")
  3. Otherwise:
     - Store in 'students' box with student.id as key
     - ID is timestamp-based, password is hashed
  ```

### `Future<Student?> getStudentByEmail(String email)`
- **Called**: loginStudent(), registerStudent() for duplicate check
- **Parameters**: Email to search for
- **Returns**: Student object or null
- **Logic**:
  ```
  1. Get all students from 'students' box
  2. Loop through each:
     - Compare lowercase emails
     - student.email.toLowerCase() == email.toLowerCase()
  3. Return first match or null
  ```

### `Future<Student?> loginStudent(String email, String password)`
- **Called**: StudentLoginScreen login button
- **Parameters**:
  - `email`: User-entered email
  - `password`: User-entered password (plain text)
- **Returns**: Authenticated Student object or null
- **Logic**:
  ```
  1. Find student by email: getStudentByEmail(email)
  2. If not found, return null (login fails)
  3. If found:
     - Verify password: PasswordUtils.verifyPassword(password, student.passwordHash)
  4. Return student if password correct, null if wrong
  ```
- **Security**: Password never compared as plain text

### `Future<Student?> getStudentById(String id)`
- **Called**: StudentLoginScreen after session check
- **Parameters**: Student ID
- **Returns**: Student object or null
- **Logic**:
  ```
  1. Get 'students' box
  2. Retrieve by ID
  3. Convert map to Student object
  4. Return or null if not found
  ```

## Key Methods - Score Operations

### `Future<void> saveScore(ScoreHistory score)`
- **Called**: StudentResultScreen initState()
- **Parameters**: Complete ScoreHistory object with results
- **Logic**:
  ```
  1. Store in 'scores' box with score.id as key
  2. Records: studentId, category, score, totalQuestions, timestamp
  3. Used for score history display
  ```

### `Future<List<ScoreHistory>> getStudentScores(String studentId)`
- **Called**: StudentDashboardScreen to show quiz history
- **Parameters**: Student ID
- **Returns**: All quiz attempts for that student
- **Logic**:
  ```
  1. Get all scores from 'scores' box
  2. Filter: keep only where score.studentId == studentId
  3. Sort by timestamp descending (newest first)
  4. Return sorted list
  ```
- **Used in**: StudentDashboardScreen Score History section

### `Future<void> close()`
- **Purpose**: Close all Hive boxes
- **Called**: App shutdown (rarely used)
- **Logic**:
  ```
  For each of 5 boxes:
    1. Check if box is open: Hive.isBoxOpen(boxName)
    2. If open, close it: Hive.box(boxName).close()
  ```

---

# DATA MODELS

## Student Model (`lib/models/student.dart`)

**Purpose**: Represents a student user account

### Class: `Student`

**Properties**:
```dart
final String id;              // Unique ID (millisecondsSinceEpoch timestamp)
final String name;            // Full name
final String email;           // Email (unique, used for login)
final String address;         // Student address
final String phone;           // Phone number
final String passwordHash;    // SHA-256 hashed password (NOT plain text)
final DateTime createdAt;     // Account creation timestamp
```

**Constructor**:
```dart
Student({
  String? id,                 // Auto-generated if not provided
  required this.name,
  required this.email,
  required this.address,
  required this.phone,
  required this.passwordHash,
  DateTime? createdAt,        // Auto-set if not provided
})
```

**Key Methods**:

### `Map<String, dynamic> toMap()`
- **Purpose**: Convert Student to JSON-serializable map
- **Used**: When saving to Hive database
- **Returns**: Map with all fields
- **Example**:
  ```json
  {
    "id": "1703352000000",
    "name": "John Doe",
    "email": "john@example.com",
    "address": "123 Main St",
    "phone": "555-1234",
    "passwordHash": "e3b0c44298fc1c149afbf4c8996fb92427ae41e...",
    "createdAt": "2023-12-23T16:00:00.000Z"
  }
  ```

### `factory Student.fromMap(Map<String, dynamic> map)`
- **Purpose**: Create Student from stored map
- **Used**: When retrieving from Hive
- **Parameters**: Stored data as map
- **Returns**: Student object
- **Logic**: Parses ISO8601 createdAt string back to DateTime

### `Student copyWith({...fields...})`
- **Purpose**: Create modified copy
- **Used**: Update specific fields
- **Example**: `student.copyWith(name: "New Name")`
- **Pattern**: Functional approach for immutability

---

## ScoreHistory Model (in `student.dart`)

**Purpose**: Track quiz attempt and performance

### Class: `ScoreHistory`

**Properties**:
```dart
final String id;              // Unique ID (timestamp)
final String studentId;       // Foreign key to Student
final String category;        // Quiz category (e.g., "Math")
final int score;              // Points scored (e.g., 8)
final int totalQuestions;     // Total questions (e.g., 10)
final DateTime timestamp;     // When quiz was taken
```

**Constructor**:
```dart
ScoreHistory({
  String? id,                 // Auto-generated if not provided
  required this.studentId,
  required this.category,
  required this.score,
  required this.totalQuestions,
  DateTime? timestamp,        // Auto-set to now if not provided
})
```

**Computed Property**:

### `int get percentage`
- **Formula**: `(score / totalQuestions * 100).round()`
- **Example**: 8/10 → 80
- **Used**: Display in StudentDashboardScreen history

**Key Methods**:

### `Map<String, dynamic> toMap()`
- Converts to storage map

### `factory ScoreHistory.fromMap(Map<String, dynamic> map)`
- Creates from stored data

---

## Category Model (`lib/models/category.dart`)

**Purpose**: Represents a quiz category

### Class: `Category`

**Properties**:
```dart
final String id;      // Unique ID (UUID format)
final String name;    // Category name (e.g., "Math", "Science")
```

**Constructor**:
```dart
Category({
  required this.id,
  required this.name,
})
```

**Default Categories** (created on app startup):
1. Math
2. Science
3. History
4. Geography
5. General Knowledge

**Methods**:
- `Map<String, dynamic> toMap()` - Convert to map
- `factory Category.fromMap(...)` - Create from map

---

## Question Model (`lib/models/question.dart`)

**Purpose**: Represents a quiz question with 4 options

### Class: `Question`

**Properties**:
```dart
final String id;              // Unique ID (timestamp)
final String questionText;    // The question to display
final String optionA;         // First answer option
final String optionB;         // Second answer option
final String optionC;         // Third answer option
final String optionD;         // Fourth answer option
final String correctAnswer;   // Correct option (A, B, C, or D)
final String category;        // Category this belongs to
```

**Constructor**:
```dart
Question({
  String? id,                 // Auto-generated if not provided
  required this.questionText,
  required this.optionA,
  required this.optionB,
  required this.optionC,
  required this.optionD,
  required this.correctAnswer,  // Must be 'A', 'B', 'C', or 'D'
  required this.category,
})
```

**Validation**:
- All text fields must be non-empty
- `correctAnswer` must be one of: 'A', 'B', 'C', 'D'
- Category must exist in database

**Methods**:
- `Map<String, dynamic> toMap()` - Convert to map
- `factory Question.fromMap(...)` - Create from map (defaults category to 'General Knowledge')
- `Question copyWith({...})` - Create modified copy for editing

---

# UTILITIES

## PasswordUtils (`lib/utils/password_utils.dart`)

**Purpose**: Password security using SHA-256 hashing

### Class: `PasswordUtils` (static methods only)

#### `static String hashPassword(String password)`
- **Purpose**: Hash plain text password for storage
- **Parameters**: Plain text password
- **Returns**: SHA-256 hash as hexadecimal string
- **Algorithm**:
  ```
  1. Convert password to UTF-8 bytes
  2. Apply SHA-256 hashing
  3. Convert result to hex string
  ```
- **Example**:
  ```dart
  String hash = PasswordUtils.hashPassword('myPassword123');
  // Returns: "9f86d081884c7d6d9ffd60014fc7ee77e42eafda57c..."
  ```
- **Security**: One-way function (cannot be reversed)
- **Used**: Registration, password reset

#### `static bool verifyPassword(String password, String hashedPassword)`
- **Purpose**: Verify password matches stored hash
- **Parameters**:
  - `password`: Plain text password to check
  - `hashedPassword`: Stored hash to compare
- **Returns**: bool - true if password matches
- **Logic**:
  ```
  1. Hash the entered password
  2. Compare hash with stored hash
  3. Return true only if equal
  ```
- **Example**:
  ```dart
  bool isValid = PasswordUtils.verifyPassword(
    'myPassword123',
    storedHash
  );
  ```
- **Used**: Login screens for authentication

#### `static final String defaultAdminPasswordHash`
- **Value**: Hash of "admin123"
- **Used**: Default admin initialization

---

## SessionManager (`lib/utils/session_manager.dart`)

**Purpose**: Manage user login sessions with persistent storage

### Pattern: Singleton
```dart
static final SessionManager instance = SessionManager._init();
SessionManager._init();  // Private constructor
```

### Storage
- **Box**: `'session'` Hive box
- **Persistence**: Data survives app restart
- **Access**: Via `SessionManager.instance`

---

## Admin Session Methods

### `Future<void> saveAdminSession()`
- **Purpose**: Save admin login session
- **Called**: AdminLoginScreen after successful login
- **Logic**:
  ```
  1. Set 'isAdminLoggedIn' = true
  2. Set 'adminLoginTime' = now
  ```
- **Persistence**: Survives app restart

### `Future<bool> isAdminLoggedIn()`
- **Purpose**: Check if admin currently logged in
- **Returns**: bool (default false)
- **Called**: AdminLoginScreen initState()
- **Used**: Auto-login if session exists

### `Future<void> logoutAdmin()`
- **Purpose**: Clear admin session
- **Logic**: Delete session keys
- **Called**: AdminDashboardScreen logout button

### `Future<String?> getAdminLoginTime()`
- **Returns**: ISO8601 timestamp of login or null

---

## Student Session Methods

### `Future<void> saveStudentSession(String studentId, String studentName, String studentEmail)`
- **Purpose**: Save student login session
- **Called**: StudentLoginScreen after successful login
- **Logic**:
  ```
  1. Set 'isStudentLoggedIn' = true
  2. Set 'studentId' = studentId
  3. Set 'studentName' = studentName
  4. Set 'studentEmail' = studentEmail
  5. Set 'studentLoginTime' = now
  ```
- **Persistence**: Session survives app restart

### `Future<bool> isStudentLoggedIn()`
- **Purpose**: Check if student logged in
- **Returns**: bool
- **Called**: StudentLoginScreen initState() for auto-login

### `Future<String?> getLoggedInStudentId()`
- **Returns**: Student ID or null

### `Future<String?> getLoggedInStudentName()`
- **Returns**: Student name or null

### `Future<String?> getLoggedInStudentEmail()`
- **Returns**: Student email or null

### `Future<String?> getStudentLoginTime()`
- **Returns**: ISO8601 timestamp or null

### `Future<void> logoutStudent()`
- **Purpose**: Clear student session
- **Called**: StudentDashboardScreen logout button

---

## General Method

### `Future<void> clearAllSessions()`
- **Purpose**: Clear all sessions (admin + student)
- **Called**: Rarely (complete app logout)

---

# SCREENS - ADMIN SECTION

## HomeScreen (`lib/screens/home_screen.dart`)

**Purpose**: Landing page with two options

**Class**: `StatelessWidget` (no internal state)

**UI Layout**:
```
┌─────────────────────────────────┐
│  Quiz App (Title)               │
├─────────────────────────────────┤
│                                 │
│     ❓ (Quiz Icon)              │
│  Welcome to Quiz App            │
│                                 │
│  ┌─────────────────────────┐    │
│  │ Administrator           │    │
│  │ Manage categories...    │    │
│  │ [Manage Button]         │    │
│  └─────────────────────────┘    │
│                                 │
│  ┌─────────────────────────┐    │
│  │ Start Quiz              │    │
│  │ Login or register...    │    │
│  │ [Start Quiz Button]     │    │
│  └─────────────────────────┘    │
│                                 │
└─────────────────────────────────┘
```

**Navigation**:
- Admin button → AdminLoginScreen
- Student button → StudentLoginScreen

**Theme**: Deep Purple gradient background

---

## AdminLoginScreen (`lib/screens/admin_login_screen.dart`)

**Purpose**: Admin authentication with password recovery

**Class**: `StatefulWidget`

**State Variables**:
```dart
GlobalKey<FormState> _formKey;
TextEditingController _usernameController;
TextEditingController _passwordController;
bool _isLoading = false;
bool _obscurePassword = true;
```

**Lifecycle**:

### `void initState()`
- Calls `_checkExistingSession()`

### `Future<void> _checkExistingSession()`
- **Logic**:
  ```
  1. Check if admin already logged in
  2. If yes, navigate to AdminDashboardScreen
  3. If no, show login form
  ```
- **Purpose**: Auto-login if session exists

**Main Methods**:

### `Future<void> _login()`
- **Called**: Login button press
- **Validation**: Form fields not empty
- **Logic**:
  ```
  1. Show loading spinner
  2. Call DatabaseHelper.verifyAdminCredentials(username, password)
  3. If valid:
     - Call SessionManager.saveAdminSession()
     - Navigate to AdminDashboardScreen
  4. If invalid:
     - Show error snackbar: "Invalid username or password"
  5. Hide loading spinner
  ```

### `void _showForgotPasswordDialog()`
- **Purpose**: Show password reset dialog
- **Master Code**: "ADMIN@RESET"
- **Dialog Fields**:
  - Master Recovery Code (password field)
  - New Password (min 6 chars)
  - Confirm Password
- **Validation**:
  - Master code must equal "ADMIN@RESET"
  - Password ≥ 6 characters
  - Passwords must match
- **On Success**:
  - Call `DatabaseHelper.resetAdminPassword(newPassword)`
  - Show success snackbar
  - Close dialog

**Default Credentials**:
- Username: `admin`
- Password: `admin123`

---

## AdminDashboardScreen (`lib/screens/admin_dashboard_screen.dart`)

**Purpose**: Main admin panel with management options

**Class**: `StatelessWidget`

**UI Components**:

1. **AppBar**: Title "Admin Panel", Logout button
2. **Card 1 - Manage Categories**:
   - Icon: library_add_rounded
   - Text: "Manage Categories"
   - Navigation: → CategoryManagementScreen

3. **Card 2 - Manage Questions**:
   - Icon: edit_note
   - Text: "Manage Questions"
   - Navigation: → QuestionManagementScreen

**Method**:

### `Future<void> _logout(BuildContext context)`
- **Logic**:
  ```
  1. Call SessionManager.logoutAdmin()
  2. Navigate to HomeScreen
  3. Clear all previous screens (removeUntil)
  ```

---

## CategoryManagementScreen (`lib/screens/category_management_screen.dart`)

**Purpose**: List, edit, and delete categories

**Class**: `StatefulWidget`

**State Variables**:
```dart
List<Category> _categories = [];
Map<String, int> _questionCounts = {};
bool _isLoading = true;
```

**Lifecycle**:

### `void initState()`
- Calls `_loadCategories()`

### `Future<void> _loadCategories()`
- **Logic**:
  ```
  1. Get all categories from database
  2. For each category:
     - Get question count
     - Store in _questionCounts map
  3. Update state
  4. Set _isLoading = false
  ```

**Main Methods**:

### `Future<void> _deleteCategory(Category category)`
- **Pre-check**: If category has questions, show error and return
  - Prevents orphaned questions
- **Delete Flow**:
  ```
  1. Show confirmation dialog
  2. User confirms
  3. Call DatabaseHelper.deleteCategory(id)
  4. Reload categories
  5. Show success snackbar
  ```

**UI Layout**:
- Empty state: "No categories yet"
- Or ListView of categories:
  - Category name
  - Question count
  - Edit/Delete buttons

**FloatingActionButton**:
- Icon: add
- Tap: → AddCategoryScreen
- On return with result=true: Reload categories

---

## AddCategoryScreen (`lib/screens/add_category_screen.dart`)

**Purpose**: Create or edit category

**Class**: `StatefulWidget`

**Constructor**: `Category? category` (null = create, non-null = edit)

**State Variables**:
```dart
GlobalKey<FormState> _formKey;
TextEditingController _nameController;
bool _isLoading = false;
bool get _isEditing => widget.category != null;
```

**Lifecycle**:

### `void initState()`
- If editing, pre-fill name field

**Main Method**:

### `Future<void> _saveCategory()`
- **Validation**:
  ```
  1. Form validation (name not empty, ≥ 2 chars)
  2. Check for duplicate names (case-insensitive)
  ```
- **Create Flow**:
  ```
  1. Generate UUID for new ID
  2. Check if name already exists
  3. If not, call DatabaseHelper.createCategory(category)
  4. Navigate back with result=true
  ```
- **Update Flow**:
  ```
  1. If name changed, check for duplicates
  2. Call DatabaseHelper.updateCategory(category, oldName: oldName)
  3. This updates all related questions
  4. Navigate back with result=true
  ```

---

## QuestionManagementScreen (`lib/screens/question_management_screen.dart`)

**Purpose**: List all questions grouped by category

**Class**: `StatefulWidget`

**State Variables**:
```dart
Map<String, List<Question>> _questionsByCategory = {};
bool _isLoading = true;
```

**Lifecycle**:

### `void initState()`
- Calls `_loadQuestions()`

### `Future<void> _loadQuestions()`
- **Logic**:
  ```
  1. Get all questions
  2. Group by category:
     - For each question:
       - If category not in map, create empty list
       - Add question to category list
  3. Update state
  ```

**Main Methods**:

### `Future<void> _deleteQuestion(String id)`
- **Logic**:
  ```
  1. Call DatabaseHelper.deleteQuestion(id)
  2. Reload questions
  3. Show success snackbar
  ```

**UI Layout**:
- Empty state: "No questions added yet"
- Or grouped by category:
  - Category header (deep purple background)
  - Question cards:
    - Number circle (1, 2, 3...)
    - Question text
    - Options A, B, C, D with green checkmark for correct
    - Edit/Delete buttons

**FloatingActionButton**:
- Text: "Add Question"
- Tap: → AddEditQuestionScreen
- On return: Reload questions

---

## AddEditQuestionScreen (`lib/screens/add_edit_question_screen.dart`)

**Purpose**: Create or edit question with clickable option selection

**Class**: `StatefulWidget`

**Constructor**: `Question? question` (null = create, non-null = edit)

**State Variables**:
```dart
GlobalKey<FormState> _formKey;
TextEditingController _questionController;
TextEditingController _optionAController;
TextEditingController _optionBController;
TextEditingController _optionCController;
TextEditingController _optionDController;
String _selectedCorrectAnswer = '';  // Which option is correct
String? _selectedCategory;
List<String> _categories = [];
bool _isLoadingCategories = true;
```

**Lifecycle**:

### `void initState()`
- Load categories dropdown
- If editing, pre-fill all fields

**Main Method**:

### `Future<void> _saveQuestion()`
- **Validation**:
  ```
  1. Form validation (all fields not empty)
  2. Category selected
  3. Correct answer selected (must click option)
  ```
- **Create/Update Logic**:
  ```
  1. Create Question object from form fields
  2. If new: DatabaseHelper.createQuestion(question)
  3. If edit: DatabaseHelper.updateQuestion(question)
  4. Show success snackbar
  5. Navigate back
  ```

**Key Interaction**:

### `Widget _buildClickableOption(String letter, TextEditingController controller)`
- **Design**: Letter circle (left) + text input (right)
- **Interaction**: Tap to mark as correct answer
- **Styling**:
  - Not selected: Gray background
  - Selected: Green background with checkmark
- **Shows**: "Correct Answer: Option X" badge when selected

**UI Layout**:
```
┌──────────────────────────┐
│ Category Dropdown        │
├──────────────────────────┤
│ Question Text (3 lines)  │
├──────────────────────────┤
│ Options (Click to mark)  │
│ ┌──────────────────────┐ │
│ │[A] Option A text...  │ │
│ └──────────────────────┘ │
│ ┌──────────────────────┐ │
│ │[B] Option B text...  │ │
│ └──────────────────────┘ │
│ ┌──────────────────────┐ │
│ │[C] Option C text...  │ │
│ └──────────────────────┘ │
│ ┌──────────────────────┐ │
│ │[D] Option D text... ✓│ │ ← Selected (green)
│ └──────────────────────┘ │
├──────────────────────────┤
│ ✓ Correct Answer: Option D
├──────────────────────────┤
│ [Save Question Button]   │
└──────────────────────────┘
```

---

# SCREENS - STUDENT SECTION

## StudentLoginScreen (`lib/screens/student_login_screen.dart`)

**Purpose**: Student authentication with email/password

**Class**: `StatefulWidget`

**State Variables**:
```dart
GlobalKey<FormState> _formKey;
TextEditingController _emailController;
TextEditingController _passwordController;
bool _isLoading = false;
bool _obscurePassword = true;
```

**Lifecycle**:

### `void initState()`
- Calls `_checkExistingSession()` for auto-login

### `Future<void> _checkExistingSession()`
- **Logic**:
  ```
  1. Check if student already logged in
  2. If yes:
     - Get student ID from session
     - Fetch student from database
     - Navigate to StudentDashboardScreen with student data
  3. If no, show login form
  ```

**Main Method**:

### `Future<void> _login()`
- **Logic**:
  ```
  1. Validate form
  2. Call DatabaseHelper.loginStudent(email, password)
  3. If student returned:
     - Save session: SessionManager.saveStudentSession(id, name, email)
     - Navigate to StudentDashboardScreen
  4. If null (invalid):
     - Show error snackbar
  ```

**Bottom Link**:
- "Don't have an account?" → StudentRegistrationScreen

---

## StudentRegistrationScreen (`lib/screens/student_registration_screen.dart`)

**Purpose**: Create new student account

**Class**: `StatefulWidget`

**State Variables**:
```dart
GlobalKey<FormState> _formKey;
TextEditingController _nameController;
TextEditingController _emailController;
TextEditingController _addressController;
TextEditingController _phoneController;
TextEditingController _passwordController;
TextEditingController _confirmPasswordController;
bool _isLoading = false;
bool _obscurePassword = true;
bool _obscureConfirmPassword = true;
```

**Main Method**:

### `Future<void> _register()`
- **Validation**:
  ```
  1. Form validation:
     - All fields required
     - Email format check (contains @ and .)
     - Password ≥ 6 chars
     - Passwords match
  ```
- **Logic**:
  ```
  1. Hash password: PasswordUtils.hashPassword(password)
  2. Create Student object
  3. Call DatabaseHelper.registerStudent(student)
  4. If email already exists:
     - Show error snackbar
  5. If successful:
     - Show success snackbar
     - Navigate to StudentLoginScreen (user must log in)
  ```

**Form Fields** (8 total):
- Full Name
- Email (email keyboard)
- Address (multi-line)
- Phone (phone keyboard)
- Password (toggle visibility)
- Confirm Password (toggle visibility)

---

## StudentDashboardScreen (`lib/screens/student_dashboard_screen.dart`)

**Purpose**: Main student interface with profile and quiz history

**Class**: `StatefulWidget`

**Constructor**: `Student student` (logged-in student)

**State Variables**:
```dart
List<ScoreHistory> _scoreHistory = [];
bool _isLoading = true;
```

**Lifecycle**:

### `void initState()`
- Calls `_loadScoreHistory()`

### `Future<void> _loadScoreHistory()`
- **Logic**:
  ```
  1. Call DatabaseHelper.getStudentScores(student.id)
  2. Scores returned sorted newest first
  3. Update state with scores list
  ```

**Main Method**:

### `void _logout()`
- **Logic**:
  ```
  1. Call SessionManager.logoutStudent()
  2. Navigate to HomeScreen
  ```

**Helper Method**:

### `String _formatDate(DateTime date)`
- **Format**: "Jan 23, 2023 at 16:45"
- **Used**: Display in score history

**UI Layout**:
```
┌──────────────────────────┐
│ Profile Card             │
│ [Avatar] Welcome, Name!  │
│           email@test.com │
├──────────────────────────┤
│ [Start Quiz Button]      │
├──────────────────────────┤
│ Score History            │
│ ┌──────────────────────┐ │
│ │[80%] Math            │ │  ← Score 8/10
│ │      Dec 23 at 16:45 │ │
│ │ ✓ (passed)           │ │
│ └──────────────────────┘ │
│ ┌──────────────────────┐ │
│ │[45%] Science         │ │  ← Score 5/10
│ │      Dec 22 at 14:30 │ │
│ │ ⚠ (failed)           │ │
│ └──────────────────────┘ │
└──────────────────────────┘
```

**Score History Logic**:
- Pass (≥50%): Green badge with checkmark
- Fail (<50%): Orange badge with warning icon

---

## StudentCategorySelectionScreen (`lib/screens/student_category_selection_screen.dart`)

**Purpose**: Choose quiz category to start

**Class**: `StatefulWidget`

**Constructor**: `Student student`

**State Variables**:
```dart
List<String> _categories = [];
bool _isLoading = true;
```

**Lifecycle**:

### `void initState()`
- Calls `_loadCategories()`

### `Future<void> _loadCategories()`
- Load all category names

**Main Method**:

### `Future<void> _startQuiz(String category)`
- **Logic**:
  ```
  1. Get questions in category: DatabaseHelper.getQuestionsByCategory(category)
  2. If no questions:
     - Show toast
     - Return
  3. Otherwise:
     - Navigate to StudentQuizScreen with:
       - questions list
       - student object
       - category name
  ```

**Color/Icon Mapping**:
- Math → Indigo + calculate icon
- Science → Teal + science icon
- History → Brown + history_edu icon
- Geography → Cyan + public icon
- General Knowledge → Blue + lightbulb icon

---

## StudentQuizScreen (`lib/screens/student_quiz_screen.dart`)

**Purpose**: Quiz interface - answer questions

**Class**: `StatefulWidget`

**Constructor Parameters**:
```dart
final List<Question> questions;
final Student student;
final String category;
```

**State Variables**:
```dart
int _currentQuestionIndex = 0;
int _score = 0;
String? _selectedAnswer;     // A, B, C, or D
bool _answered = false;
```

**Key Methods**:

### `void _answerQuestion(String answer)`
- **Logic**:
  ```
  1. If already answered, return (prevent re-answer)
  2. Mark as answered
  3. Check if answer correct
  4. If correct: increment score
  5. Update UI with feedback
  ```

### `void _nextQuestion()`
- **Logic**:
  ```
  1. If more questions:
     - Increment index
     - Reset selectedAnswer and answered
  2. If last question:
     - Navigate to StudentResultScreen
     - Pass: score, totalQuestions, student, category
  ```

**Answer Button States**:
- Not answered: White, gray border
- Selected (not answered): Purple tint
- Correct: Green with checkmark
- Wrong: Red with X, correct answer shown in green

---

## StudentResultScreen (`lib/screens/student_result_screen.dart`)

**Purpose**: Display quiz results and save score

**Class**: `StatefulWidget`

**Constructor Parameters**:
```dart
final int score;
final int totalQuestions;
final Student student;
final String category;
```

**Lifecycle**:

### `void initState()`
- Calls `_saveScore()`

### `Future<void> _saveScore()`
- **Logic**:
  ```
  1. Create ScoreHistory object
  2. Call DatabaseHelper.saveScore(scoreHistory)
  3. Score automatically recorded in database
  4. Timestamp auto-added
  ```
- **Timing**: Runs before build() - score saved before UI shows

**Calculation**:
```dart
percentage = (score / totalQuestions * 100).round()
isPassed = percentage >= 50
```

**UI Layout**:
```
Passed (≥50%):
┌─────────────────────┐
│ 🏆 Congratulations! │
│ You did great!      │
│ Category: Math      │
│                     │
│    Score: 8/10      │
│    Percentage: 80%  │
│                     │
│ [Try Again] (green) │
│ [Dashboard] (purple)│
└─────────────────────┘

Failed (<50%):
┌─────────────────────┐
│ 🔄 Keep Practicing! │
│ Don't give up!      │
│ Category: Math      │
│                     │
│    Score: 5/10      │
│    Percentage: 50%  │
│                     │
│ [Try Again] (orange)│
│ [Dashboard] (purple)│
└─────────────────────┘
```

**Buttons**:
- "Try Again" → StudentCategorySelectionScreen (restart)
- "Go to Dashboard" → StudentDashboardScreen (home)

---

# DATABASE SYSTEM & SCHEMA

## Hive Database Architecture

Hive is a lightweight NoSQL database that works on web, mobile, and desktop. It stores data as key-value pairs in "boxes" (collections).

```
┌─────────────────────────────────────────────────┐
│              Hive Database                      │
├─────────────────────────────────────────────────┤
│                                                 │
│  Box: "questions" (contains Question objects)  │
│  ├─ Key: "1703352000000" (timestamp ID)       │
│  │  Value: {                                  │
│  │    questionText: "What is 2+2?",          │
│  │    optionA: "3", optionB: "4", ...        │
│  │    correctAnswer: "B",                     │
│  │    category: "Math"                        │
│  │  }                                         │
│  └─ Key: "1703352000001" ...                 │
│                                                 │
│  Box: "categories" (Category objects)          │
│  ├─ Key: "cat_1"                             │
│  │  Value: { id: "cat_1", name: "Math" }     │
│  └─ Key: "cat_2" ...                         │
│                                                 │
│  Box: "students" (Student accounts)            │
│  ├─ Key: "1703352000100" (timestamp ID)       │
│  │  Value: {                                  │
│  │    id: "1703352000100",                   │
│  │    name: "John Doe",                      │
│  │    email: "john@example.com",             │
│  │    address: "123 Main St",                │
│  │    phone: "555-1234",                     │
│  │    passwordHash: "e3b0c44298fc...",       │
│  │    createdAt: "2023-12-23..."             │
│  │  }                                         │
│  └─ Key: "1703352000101" ...                 │
│                                                 │
│  Box: "scores" (Quiz attempts)                │
│  ├─ Key: "1703352000200" (timestamp ID)       │
│  │  Value: {                                  │
│  │    studentId: "1703352000100",            │
│  │    category: "Math",                      │
│  │    score: 8,                              │
│  │    totalQuestions: 10,                    │
│  │    timestamp: "2023-12-23..."             │
│  │  }                                         │
│  └─ Key: "1703352000201" ...                 │
│                                                 │
│  Box: "admin" (Admin credentials)              │
│  └─ Key: "admin" (single admin)               │
│     Value: {                                  │
│       username: "admin",                      │
│       passwordHash: "8c6976e5b5410415bde90..."│
│     }                                         │
│                                                 │
│  Box: "session" (Active sessions)              │
│  ├─ Key: "isAdminLoggedIn"                    │
│  │  Value: true/false                        │
│  ├─ Key: "isStudentLoggedIn"                  │
│  │  Value: true/false                        │
│  ├─ Key: "studentId"                         │
│  │  Value: "1703352000100"                   │
│  └─ ... (other session keys)                 │
│                                                 │
└─────────────────────────────────────────────────┘
```

## Data Relationships

```
Student (1) ──────────── (many) ScoreHistory
   |                           Each score tracks
   |                        a quiz attempt by student
   └───────────────────────────────────────┐
                              Shows which
                           student took quiz

Category (1) ──────────── (many) Question
   |                            Each question
   |                         belongs to category
   └──────────────────────────────┐
                          Question
                      references category

ScoreHistory → Question (implicit)
   Stores category name, not question ID
   Can reconstruct results from category name
```

---

# SESSION MANAGEMENT

## How Sessions Work

### Admin Session Flow

```
User opens app
    ↓
AdminLoginScreen loads
    ↓
initState() checks: isAdminLoggedIn()?
    ├─ YES → Auto-navigate to AdminDashboardScreen
    └─ NO → Show login form
        ↓
    User enters credentials
    User taps "Login"
        ↓
    verifyAdminCredentials(username, password)
        ├─ Invalid → Show error
        └─ Valid → saveAdminSession()
            ├─ Set isAdminLoggedIn = true
            ├─ Set adminLoginTime = now
            └─ Navigate to AdminDashboardScreen
```

### Student Session Flow

```
User opens app (or clicks "Start Quiz")
    ↓
StudentLoginScreen loads
    ↓
initState() checks: isStudentLoggedIn()?
    ├─ YES → Auto-navigate to StudentDashboardScreen
    └─ NO → Show login form
        ↓
    User enters email and password
    User taps "Login"
        ↓
    loginStudent(email, password)
        ├─ Invalid → Show error
        └─ Valid → saveStudentSession(id, name, email)
            ├─ Set isStudentLoggedIn = true
            ├─ Store studentId, studentName, studentEmail
            ├─ Set studentLoginTime = now
            └─ Navigate to StudentDashboardScreen
```

### Session Persistence

Sessions are stored in Hive's "session" box, which means:
- **Survive app restart**: User stays logged in when app closes/opens
- **Manual logout**: Cleared when user taps logout
- **Auto-check on screen init**: Each login screen checks existing session

---

# USER WORKFLOWS

## Admin Workflow

```
┌─ HomeScreen
│  ├─ Click "Admin" button
│  └─→ AdminLoginScreen
│     ├─ Check: isAdminLoggedIn()?
│     │  ├─ YES → Jump to AdminDashboard
│     │  └─ NO → Show login form
│     │
│     ├─ Enter credentials
│     ├─ Tap "Login"
│     └─→ (if valid) AdminDashboardScreen
│        ├─ Option 1: "Manage Categories"
│        │  └─→ CategoryManagementScreen
│        │     ├─ [FAB] "Add"
│        │     │  └─→ AddCategoryScreen
│        │     │     ├─ Enter name
│        │     │     └─ Save → (if unique) Category created
│        │     │
│        │     ├─ List categories
│        │     └─ Edit/Delete each
│        │        └─ If delete: check for questions first
│        │
│        └─ Option 2: "Manage Questions"
│           └─→ QuestionManagementScreen
│              ├─ Organized by category
│              ├─ [FAB] "Add Question"
│              │  └─→ AddEditQuestionScreen
│              │     ├─ Select category
│              │     ├─ Enter question
│              │     ├─ Enter 4 options
│              │     ├─ Click option to mark correct
│              │     └─ Save → Question created
│              │
│              └─ Edit/Delete each question
│
└─ Admin session ends when tapping Logout
   └─ Clear session → HomeScreen
```

## Student Workflow

```
┌─ HomeScreen
│  ├─ Click "Start Quiz" button
│  └─→ StudentLoginScreen
│     ├─ Check: isStudentLoggedIn()?
│     │  ├─ YES → Jump to StudentDashboard
│     │  └─ NO → Show login form
│     │
│     ├─ Option A: Existing student
│     │  ├─ Enter email & password
│     │  ├─ Tap "Login"
│     │  └─→ (if valid) StudentDashboardScreen
│     │
│     └─ Option B: New student
│        ├─ Click "Register"
│        └─→ StudentRegistrationScreen
│           ├─ Enter: name, email, address, phone
│           ├─ Enter & confirm password
│           ├─ Tap "Register"
│           ├─ (if email unique) Student created
│           └─→ Redirected to StudentLoginScreen (must log in)
│
├─→ StudentDashboardScreen
│  ├─ Shows profile & welcome
│  ├─ Shows score history (if any)
│  ├─ [Start Quiz Button]
│  └─→ StudentCategorySelectionScreen
│     ├─ Shows all categories with colors
│     ├─ Click category
│     └─→ StudentQuizScreen
│        ├─ Question 1/N
│        ├─ Show progress bar
│        ├─ Display question + 4 options
│        ├─ Student selects answer
│        │  ├─ If correct: green, checkmark
│        │  ├─ If wrong: red X, show correct in green
│        │  └─ Next button appears
│        │
│        ├─ Student taps "Next Question"
│        ├─ (Repeat for all questions)
│        │
│        └─ Last question done
│           └─→ StudentResultScreen
│              ├─ Score automatically saved to database
│              ├─ Shows result: X/Y, percentage
│              ├─ "Try Again" → Back to categories
│              └─ "Dashboard" → StudentDashboardScreen
│
└─ Score now appears in "Score History" on dashboard
```

---

# DATA FLOW DIAGRAMS

## Question Management Flow

```
Admin clicks "Add Question" (FAB in QuestionManagementScreen)
    ↓
Open AddEditQuestionScreen (question=null)
    ↓
Load categories for dropdown
    ↓
Admin fills form:
├─ Select category
├─ Enter question text
├─ Enter 4 options (A, B, C, D)
└─ Click option to mark as correct
    ↓
Admin taps "Add Question"
    ↓
Validation:
├─ Category selected? ✓
├─ Question not empty? ✓
├─ All options not empty? ✓
└─ Correct answer selected? ✓
    ↓
Create Question object:
├─ id = DateTime.now().millisecondsSinceEpoch
├─ All fields from form
└─ category = selected
    ↓
DatabaseHelper.createQuestion(question)
    ↓
Hive "questions" box updated:
└─ Key: question.id
   Value: question.toMap()
    ↓
Success snackbar: "Question added successfully!"
    ↓
Navigate back to QuestionManagementScreen
    ↓
_loadQuestions() called
    ↓
New question appears in list
```

## Category Update with Cascading Changes

```
Admin clicks "Edit" on category (CategoryManagementScreen)
    ↓
Open AddCategoryScreen (category=existing)
    ↓
Pre-fill name field with current name
    ↓
Admin changes name: "Maths" → "Mathematics"
    ↓
Admin taps "Update Category"
    ↓
DatabaseHelper.updateCategory(newCategory, oldName: "Maths")
    ↓
Two operations happen:
│
├─ 1. Update categories box
│    └─ Replace old with new (same ID, new name)
│
└─ 2. Call updateQuestionsCategoryName("Maths", "Mathematics")
    ├─ Get all questions with category="Maths"
    ├─ For each question:
    │  ├─ Create copy: question.copyWith(category: "Mathematics")
    │  └─ Update in database
    └─ All questions now reference new category
    ↓
Success: "Category updated!"
    ↓
Navigate back
    ↓
All related data now consistent
```

## Student Quiz Flow

```
Student selects "Math" category in StudentCategorySelectionScreen
    ↓
DatabaseHelper.getQuestionsByCategory("Math")
    ↓
Returns List of 10 math questions
    ↓
Navigate to StudentQuizScreen(questions, student, "Math")
    ↓
Question 1 displayed:
├─ Show "Question 1/10" in AppBar
├─ Show progress bar (10%)
├─ Display question text
└─ Show 4 clickable options
    ↓
Student taps option B
    ↓
_answerQuestion("B") called
    ↓
Check if correct:
├─ Compare with question.correctAnswer
├─ If match: _score++
└─ Set _answered = true
    ↓
UI updates immediately:
├─ Show green background on correct answer
├─ Show red on selected wrong answer
└─ Show checkmark/X icons
    ↓
"Next Question" button appears
    ↓
Student taps "Next Question"
    ↓
Check if more questions:
├─ If yes: _currentQuestionIndex++, reset state, show next
└─ If no: Navigate to StudentResultScreen
    ↓
StudentResultScreen opened:
│
└─ initState() calls _saveScore()
    ├─ Create ScoreHistory:
    │  ├─ studentId: student.id
    │  ├─ category: "Math"
    │  ├─ score: 8 (final score)
    │  ├─ totalQuestions: 10
    │  └─ timestamp: now
    │
    └─ DatabaseHelper.saveScore(scoreHistory)
        ├─ Store in "scores" Hive box
        ├─ Key: auto-generated ID
        └─ Value: scoreHistory.toMap()
    ↓
Score now saved in database
    ↓
UI shows results
    ↓
Next time student opens dashboard:
└─ Score appears in "Score History"
```

## Student Login & Session

```
StudentLoginScreen opened
    ↓
initState() calls _checkExistingSession()
    ↓
SessionManager.isStudentLoggedIn()?
    ├─ YES (session exists):
    │  ├─ Get studentId from session
    │  ├─ Fetch Student from database
    │  └─ Navigate to StudentDashboardScreen (skip login)
    │
    └─ NO (no session):
        └─ Show login form
            ↓
        User enters email & password
        User taps "Login"
            ↓
        DatabaseHelper.loginStudent(email, password)
            ├─ Find student by email
            ├─ Verify password hash
            └─ Return Student or null
            ↓
        If Student returned:
        │
        ├─ SessionManager.saveStudentSession(id, name, email)
        │  ├─ Set isStudentLoggedIn = true
        │  ├─ Store studentId, studentName, studentEmail
        │  ├─ Set studentLoginTime = now
        │  └─ All stored in "session" Hive box
        │
        └─ Navigate to StudentDashboardScreen
            ↓
        Session persists across app restarts
        ↓
        When user closes & reopens app:
        └─ StudentLoginScreen again checks isStudentLoggedIn()
           └─ YES → Auto-navigate to dashboard
```

---

# NAVIGATION FLOW

## Complete Navigation Map

```
┌─────────────────────────────────────────────────────────┐
│                    HomeScreen                           │
│          (Landing page, two main options)               │
├─────────────┬───────────────────────────────────────────┤
│             │                                           │
│             ▼                                           ▼
│  AdminLoginScreen                      StudentLoginScreen
│  │                                      │
│  ├─ Forgot Password                     └─ Don't have account?
│  │  └─ Password Reset Dialog                  ↓
│  │                                      StudentRegistrationScreen
│  └─ (if valid)                          │
│    ↓                                     └─ (after register) Back to login
│  AdminDashboardScreen
│  │
│  ├─ Manage Categories
│  │  └─ CategoryManagementScreen
│  │     ├─ Edit category → AddCategoryScreen
│  │     ├─ Add new → AddCategoryScreen
│  │     └─ Delete → (back to list)
│  │
│  └─ Manage Questions
│     └─ QuestionManagementScreen
│        ├─ Edit question → AddEditQuestionScreen
│        ├─ Add new → AddEditQuestionScreen
│        └─ Delete → (back to list)
│
└─ (if valid)
   ↓
StudentDashboardScreen
│
├─ Start Quiz
│  └─ StudentCategorySelectionScreen
│     ├─ Select category
│     └─→ StudentQuizScreen
│        └─ Answer all questions
│           └─→ StudentResultScreen
│              ├─ Try Again → Back to categories
│              └─ Dashboard → Back to dashboard
│
└─ Logout → HomeScreen
```

## Key Navigation Patterns

### Navigation with Data
```dart
// Passing data TO next screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => NextScreen(dataObject),
  ),
);

// Example: Quiz navigation
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => StudentQuizScreen(
      questions: questionsList,
      student: studentObject,
      category: "Math",
    ),
  ),
);
```

### Navigation Replacement (No Back)
```dart
// Remove current screen from stack
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => NewScreen()),
);

// Used after login to prevent back to login screen
```

### Navigation with Result (Data FROM next screen)
```dart
// Wait for result from next screen
final result = await Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => NextScreen()),
);

if (result == true) {
  // Reload data
}

// Used in CategoryManagementScreen to reload after add/edit
```

---

# SUMMARY

## File Organization

| Layer | Files | Purpose |
|-------|-------|---------|
| **Entry Point** | main.dart | App initialization |
| **Database** | database_helper.dart | CRUD operations |
| **Models** | student.dart, category.dart, question.dart | Data structures |
| **Utilities** | session_manager.dart, password_utils.dart | Security & sessions |
| **Admin Screens** | home_screen.dart, admin_login_screen.dart, admin_dashboard_screen.dart, category_management_screen.dart, add_category_screen.dart, question_management_screen.dart, add_edit_question_screen.dart | Admin panel |
| **Student Screens** | student_login_screen.dart, student_registration_screen.dart, student_dashboard_screen.dart, student_category_selection_screen.dart, student_quiz_screen.dart, student_result_screen.dart | Student features |
| **Generic Screens** | category_selection_screen.dart, quiz_screen.dart, result_screen.dart | Reusable components |

## Core Architecture

1. **Singleton Pattern**: DatabaseHelper and SessionManager ensure single instance access
2. **Hive Database**: 5 boxes for organized data storage
3. **State Management**: StatefulWidget local state for forms and UI
4. **Data Models**: Student, Category, Question, ScoreHistory with toMap/fromMap
5. **Security**: SHA-256 password hashing, session persistence

## Key Features

- Admin authentication with master recovery code
- Complete CRUD for categories and questions
- Student registration and login
- Quiz taking with real-time scoring
- Score history tracking
- Persistent sessions (survive app restart)
- Auto-login when session exists

## Data Flow Summary

```
Question Creation:
  Admin Form → Question Object → Database Box → List Display

Category Management:
  Edit Category → Update box → Update all related questions → Consistency

Quiz Attempt:
  Select Category → Get Questions → Show Questions → Score → Save Score → Display Results

Student Login:
  Check Session → Show Login → Verify Credentials → Save Session → Dashboard
```

This comprehensive documentation covers every aspect of the Flutter Quiz App from entry point through user interactions, providing a complete reference for understanding the application's architecture, design, and implementation.
