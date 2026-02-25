# Flutter Quiz App - Complete File-by-File Documentation

## Table of Contents
1. [Entry Point](#entry-point)
2. [Database Layer](#database-layer)
3. [Models](#models)
4. [Utilities](#utilities)
5. [Screens - Admin](#screens---admin)
6. [Screens - Student](#screens---student)
7. [Screens - Navigation](#screens---navigation)

---

# ENTRY POINT

## `lib/main.dart`

**Purpose**: Application entry point. Initializes Hive database and starts the Flutter app.

**What it does**:
- Initializes Flutter bindings to ensure platform channels are set up
- Initializes Hive database for local storage
- Creates default admin user if not exists
- Creates default quiz categories on first launch
- Launches the QuizApp widget

**Key Functions**:

### `void main() async`
- **Type**: Entry point function
- **Async**: Yes, performs async database initialization
- **Steps**:
  1. `WidgetsFlutterBinding.ensureInitialized()` - Ensures Flutter widgets can use platform channels before runApp is called
  2. `await Hive.initFlutter()` - Initializes Hive database with Flutter-specific configuration (uses browser storage on web)
  3. `await DatabaseHelper.instance.initializeAdmin()` - Creates default admin if none exists (username: "admin", password: "admin123")
  4. `await DatabaseHelper.instance.initializeDefaultCategories()` - Creates 5 default categories (Math, Science, History, Geography, General Knowledge)
  5. `runApp(const QuizApp())` - Launches the main app widget

**Classes**:

### `class QuizApp extends StatelessWidget`
- **Purpose**: Root widget of the application
- **Properties**: None (stateless, immutable)
- **Methods**:
  - `Widget build(BuildContext context)` - Builds the app with Material design theme

**Theme Configuration**:
```dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
  useMaterial3: true,
)
```
- Uses Material Design 3
- Primary color: Deep Purple seed color
- Home screen: HomeScreen (landing page)

**Dependencies**: 
- `package:flutter`
- `package:hive_flutter`
- `database_helper.dart`
- `home_screen.dart`

---

# DATABASE LAYER

## `lib/database/database_helper.dart`

**Purpose**: Central database manager. Handles all CRUD operations for questions, students, categories, scores, and admin credentials.

**What it does**:
- Provides singleton pattern database access
- Manages 5 Hive boxes (local storage collections)
- Implements password verification with hashing
- Synchronizes category name changes across all related questions
- Provides query methods for filtering and retrieving data

**Pattern Used**: **Singleton** - Only one instance exists throughout app lifetime
```dart
static final DatabaseHelper instance = DatabaseHelper._init();
DatabaseHelper._init();  // Private constructor
```

**Hive Boxes**:

| Box Name | Purpose | Key | Value Type |
|----------|---------|-----|------------|
| `questions` | Stores quiz questions | Question.id | Map<String, dynamic> |
| `students` | Stores student accounts | Student.id | Map<String, dynamic> |
| `scores` | Stores quiz attempts and scores | ScoreHistory.id | Map<String, dynamic> |
| `admin` | Stores admin credentials | "admin" | {username, passwordHash} |
| `categories` | Stores quiz categories | Category.id | Map<String, dynamic> |

**Key Methods**:

### Admin Operations

#### `Future<void> initializeAdmin()`
- **Purpose**: Create default admin user on app first launch
- **Logic**:
  1. Get admin box
  2. Check if 'admin' key exists
  3. If not, create default: username="admin", password hash of "admin123"
- **Used in**: main.dart during app initialization

#### `Future<bool> verifyAdminCredentials(String username, String password)`
- **Purpose**: Authenticate admin user
- **Parameters**:
  - `username`: Admin username entered
  - `password`: Admin password entered (plain text)
- **Logic**:
  1. Get stored admin data from box
  2. If not found, initialize and return true for default credentials
  3. Compare entered username with stored username
  4. Hash entered password and compare with stored hash
  5. Return true only if both match
- **Returns**: `bool` - true if credentials valid
- **Used in**: AdminLoginScreen

#### `Future<void> resetAdminPassword(String newPassword)`
- **Purpose**: Reset admin password using master recovery code
- **Parameters**:
  - `newPassword`: New password to set (min 6 chars)
- **Logic**:
  1. Hash the new password using PasswordUtils
  2. Update admin box entry with new password hash
- **Used in**: AdminLoginScreen password reset dialog

### Question Operations

#### `Future<void> createQuestion(Question question)`
- **Purpose**: Add new quiz question to database
- **Parameters**:
  - `question`: Question object with all fields populated
- **Logic**:
  1. Convert question to map using `question.toMap()`
  2. Store in 'questions' box with question.id as key
  3. Throw exception if error occurs
- **Used in**: AddEditQuestionScreen

#### `Future<Question?> getQuestion(String id)`
- **Purpose**: Retrieve single question by ID
- **Parameters**:
  - `id`: Question ID to find
- **Returns**: `Question?` - Question object or null if not found
- **Logic**:
  1. Get 'questions' box
  2. Retrieve data by ID
  3. Convert map back to Question object
  4. Return question or null

#### `Future<List<Question>> getAllQuestions()`
- **Purpose**: Retrieve all questions from database
- **Returns**: `List<Question>` - All questions
- **Logic**:
  1. Get all values from 'questions' box
  2. Map each value to Question object using Question.fromMap()
  3. Return as list
- **Used in**: QuestionManagementScreen

#### `Future<List<Question>> getQuestionsByCategory(String category)`
- **Purpose**: Get all questions in a specific category
- **Parameters**:
  - `category`: Category name to filter by
- **Returns**: `List<Question>` - Questions in that category
- **Logic**:
  1. Get all questions
  2. Filter where question.category == category
  3. Return filtered list
- **Used in**: StudentCategorySelectionScreen, QuizScreen

#### `Future<void> updateQuestion(Question question)`
- **Purpose**: Update existing question
- **Parameters**:
  - `question`: Updated question object with same ID
- **Logic**:
  1. Get 'questions' box
  2. Update entry by replacing old question with new one
- **Used in**: AddEditQuestionScreen

#### `Future<void> deleteQuestion(String id)`
- **Purpose**: Remove question from database
- **Parameters**:
  - `id`: Question ID to delete
- **Logic**:
  1. Get 'questions' box
  2. Delete entry by key
- **Used in**: QuestionManagementScreen

### Category Operations

#### `Future<void> initializeDefaultCategories()`
- **Purpose**: Create default categories on app first launch
- **Logic**:
  1. Check if 'categories' box is empty
  2. If empty, create 5 default categories: Math, Science, History, Geography, General Knowledge
  3. Store each with ID "cat_1", "cat_2", etc.
- **Used in**: main.dart during initialization

#### `Future<List<Category>> getAllCategories()`
- **Purpose**: Get all categories from database
- **Returns**: `List<Category>` - All categories
- **Logic**:
  1. Get all values from 'categories' box
  2. Map each to Category object
  3. Return as list
- **Used in**: AddEditQuestionScreen, other screens

#### `Future<List<String>> getAllCategoryNames()`
- **Purpose**: Get category names only (for dropdowns)
- **Returns**: `List<String>` - Category names sorted alphabetically
- **Logic**:
  1. Get all categories
  2. Extract name from each
  3. Sort alphabetically
  4. Return list
- **Used in**: AddEditQuestionScreen, StudentCategorySelectionScreen

#### `Future<Category?> getCategoryByName(String name)`
- **Purpose**: Find category by name (case-insensitive)
- **Parameters**:
  - `name`: Category name to search for
- **Returns**: `Category?` - Category object or null
- **Logic**:
  1. Get all categories
  2. Loop through and compare lowercase names
  3. Return first match or null
- **Used in**: AddCategoryScreen for duplicate checking

#### `Future<void> createCategory(Category category)`
- **Purpose**: Create new category
- **Parameters**:
  - `category`: Category object with name and ID
- **Logic**:
  1. Check if category with same name already exists
  2. If exists, throw exception "Category already exists"
  3. Otherwise, store in 'categories' box
- **Used in**: AddCategoryScreen

#### `Future<void> updateCategory(Category category, {String? oldName})`
- **Purpose**: Update existing category and rename associated questions
- **Parameters**:
  - `category`: Updated category object
  - `oldName`: Previous category name (for updating questions)
- **Logic**:
  1. Update category in 'categories' box
  2. If name changed and oldName provided:
     - Call `updateQuestionsCategoryName(oldName, newName)`
     - This updates all questions with old category name to new name
- **Used in**: AddCategoryScreen

#### `Future<void> updateQuestionsCategoryName(String oldName, String newName)`
- **Purpose**: Update category name in all related questions
- **Parameters**:
  - `oldName`: Previous category name
  - `newName`: New category name
- **Logic**:
  1. Get all questions with oldName
  2. For each question:
     - Create copy with newName
     - Update in database
  3. Ensures data consistency
- **Called by**: updateCategory()

#### `Future<void> deleteCategory(String id)`
- **Purpose**: Delete category by ID
- **Parameters**:
  - `id`: Category ID
- **Logic**:
  1. Delete from 'categories' box
  2. Note: CategoryManagementScreen prevents deletion if questions exist
- **Used in**: CategoryManagementScreen

#### `Future<int> getQuestionCountByCategory(String categoryName)`
- **Purpose**: Count questions in a category
- **Parameters**:
  - `categoryName`: Category name to count
- **Returns**: `int` - Number of questions
- **Logic**:
  1. Get all questions in category
  2. Return length of list
  3. Returns 0 if error or no questions
- **Used in**: CategoryManagementScreen

### Student Operations

#### `Future<void> registerStudent(Student student)`
- **Purpose**: Create new student account
- **Parameters**:
  - `student`: Student object with all info
- **Logic**:
  1. Check if email already exists
  2. If yes, throw "Email already registered"
  3. Otherwise, store in 'students' box with student.id as key
- **Used in**: StudentRegistrationScreen

#### `Future<Student?> getStudentByEmail(String email)`
- **Purpose**: Find student by email (case-insensitive)
- **Parameters**:
  - `email`: Student email
- **Returns**: `Student?` - Student object or null
- **Logic**:
  1. Loop through all students
  2. Compare lowercase emails
  3. Return first match or null
- **Used in**: StudentLoginScreen, loginStudent()

#### `Future<Student?> loginStudent(String email, String password)`
- **Purpose**: Authenticate student
- **Parameters**:
  - `email`: Student email
  - `password`: Student password (plain text)
- **Returns**: `Student?` - Authenticated student or null
- **Logic**:
  1. Find student by email
  2. If not found, return null
  3. Verify password hash matches
  4. Return student if password correct, null otherwise
- **Used in**: StudentLoginScreen

#### `Future<Student?> getStudentById(String id)`
- **Purpose**: Retrieve student by ID
- **Parameters**:
  - `id`: Student ID
- **Returns**: `Student?` - Student or null
- **Used in**: StudentLoginScreen, StudentDashboardScreen

### Score Operations

#### `Future<void> saveScore(ScoreHistory score)`
- **Purpose**: Record quiz attempt
- **Parameters**:
  - `score`: ScoreHistory object with results
- **Logic**:
  1. Store in 'scores' box with score.id as key
  2. Records: studentId, category, score, totalQuestions, timestamp
- **Used in**: StudentResultScreen, ResultScreen

#### `Future<List<ScoreHistory>> getStudentScores(String studentId)`
- **Purpose**: Get all quiz attempts for a student
- **Parameters**:
  - `studentId`: Student ID
- **Returns**: `List<ScoreHistory>` - All scores for student, sorted newest first
- **Logic**:
  1. Get all scores from 'scores' box
  2. Filter where studentId matches
  3. Sort by timestamp descending (newest first)
  4. Return sorted list
- **Used in**: StudentDashboardScreen to show score history

### Connection Management

#### `Future<void> close()`
- **Purpose**: Close all Hive boxes
- **Logic**:
  1. Check if each box is open
  2. Close all 5 boxes
- **Used in**: App shutdown (rarely called)

---

# MODELS

## `lib/models/student.dart`

**Purpose**: Define Student user data structure and score history.

**Classes**:

### `class Student`

**Properties**:
```dart
final String id;              // Unique ID (timestamp-based)
final String name;            // Full name
final String email;           // Email (unique identifier for login)
final String address;         // Student address
final String phone;           // Phone number
final String passwordHash;    // SHA-256 hashed password
final DateTime createdAt;     // Account creation timestamp
```

**Constructor**:
```dart
Student({
  String? id,  // If not provided, generates from current timestamp
  required this.name,
  required this.email,
  required this.address,
  required this.phone,
  required this.passwordHash,
  DateTime? createdAt,  // If not provided, uses current time
})
```

**Methods**:

#### `Map<String, dynamic> toMap()`
- **Purpose**: Convert Student to JSON-serializable map for storage
- **Returns**: Map with all student fields
- **Used in**: DatabaseHelper when storing in Hive
- **Example Output**:
```json
{
  "id": "1703352000000",
  "name": "John Doe",
  "email": "john@example.com",
  "address": "123 Main St",
  "phone": "555-1234",
  "passwordHash": "e3b0c44...",
  "createdAt": "2023-12-23T16:00:00.000Z"
}
```

#### `factory Student.fromMap(Map<String, dynamic> map)`
- **Purpose**: Create Student from stored map
- **Parameters**: map - Stored data from Hive
- **Returns**: Student object
- **Used in**: DatabaseHelper when retrieving from Hive
- **Parsing**: Converts ISO8601 string back to DateTime

#### `Student copyWith({...fields...})`
- **Purpose**: Create modified copy of Student
- **Usage**: Update specific fields without recreating entire object
- **Example**: 
```dart
student.copyWith(name: "New Name")
```
- **Pattern**: Functional programming approach for immutability

---

### `class ScoreHistory`

**Purpose**: Track quiz performance record.

**Properties**:
```dart
final String id;              // Unique ID
final String studentId;       // Foreign key to Student
final String category;        // Quiz category taken
final int score;              // Points scored
final int totalQuestions;     // Total questions in quiz
final DateTime timestamp;     // When quiz was taken
```

**Constructor**:
```dart
ScoreHistory({
  String? id,
  required this.studentId,
  required this.category,
  required this.score,
  required this.totalQuestions,
  DateTime? timestamp,
})
```

**Computed Property**:

#### `int get percentage`
- **Purpose**: Calculate percentage score
- **Formula**: `(score / totalQuestions * 100).round()`
- **Example**: score=8, total=10 → returns 80
- **Used in**: StudentDashboardScreen to show percentage in history

**Methods**:

#### `Map<String, dynamic> toMap()`
- Converts to storage format

#### `factory ScoreHistory.fromMap(Map<String, dynamic> map)`
- Creates from stored data

---

## `lib/models/category.dart`

**Purpose**: Define quiz category structure.

**Class**: `class Category`

**Properties**:
```dart
final String id;      // Unique identifier (UUID format)
final String name;    // Category name (e.g., "Math", "Science")
```

**Constructor**:
```dart
Category({
  required this.id,
  required this.name,
})
```

**Methods**:

#### `Map<String, dynamic> toMap()`
- Returns: `{'id': id, 'name': name}`

#### `factory Category.fromMap(Map<String, dynamic> map)`
- Parses stored data

**Default Categories** (initialized on app start):
1. Math
2. Science
3. History
4. Geography
5. General Knowledge

---

## `lib/models/question.dart`

**Purpose**: Define quiz question structure with multiple choice options.

**Class**: `class Question`

**Properties**:
```dart
final String id;              // Unique ID (timestamp-based)
final String questionText;    // The question to display
final String optionA;         // First answer option
final String optionB;         // Second answer option
final String optionC;         // Third answer option
final String optionD;         // Fourth answer option
final String correctAnswer;   // Which option is correct (A, B, C, or D)
final String category;        // Category this question belongs to
```

**Constructor**:
```dart
Question({
  String? id,  // Defaults to current timestamp if not provided
  required this.questionText,
  required this.optionA,
  required this.optionB,
  required this.optionC,
  required this.optionD,
  required this.correctAnswer,  // Must be A, B, C, or D
  required this.category,
})
```

**Methods**:

#### `Map<String, dynamic> toMap()`
- Converts to storage format
- All fields are strings when stored

#### `factory Question.fromMap(Map<String, dynamic> map)`
- Creates from stored data
- Defaults category to 'General Knowledge' if missing

#### `Question copyWith({...fields...})`
- Creates modified copy for editing questions

**Validation Notes**:
- `correctAnswer` must be one of: 'A', 'B', 'C', 'D'
- All text fields must be non-empty
- Category must match an existing category

---

# UTILITIES

## `lib/utils/password_utils.dart`

**Purpose**: Password security utilities using SHA-256 hashing.

**Class**: `class PasswordUtils` (static methods only)

**Methods**:

### `static String hashPassword(String password)`
- **Purpose**: Hash plain text password for secure storage
- **Parameters**:
  - `password`: Plain text password to hash
- **Returns**: SHA-256 hash as hexadecimal string
- **Algorithm**:
  1. Convert password to UTF-8 bytes
  2. Apply SHA-256 hashing
  3. Convert result to hex string
- **Security Notes**:
  - One-way function (cannot reverse)
  - Same password always produces same hash
  - Used during registration and password reset
- **Example**:
```dart
String hash = PasswordUtils.hashPassword('myPassword123');
// hash = "9f86d081884c7d6d9ffd60014fc7ee77e42eafda57c53ee1"
```

### `static bool verifyPassword(String password, String hashedPassword)`
- **Purpose**: Verify password matches stored hash
- **Parameters**:
  - `password`: Plain text password to check
  - `hashedPassword`: Stored hash to compare against
- **Returns**: bool - true if password matches hash
- **Logic**:
  1. Hash the entered password
  2. Compare hashes
  3. Return true only if they match
- **Used in**: Login screens for authentication
- **Example**:
```dart
bool isValid = PasswordUtils.verifyPassword(
  'myPassword123',
  storedHash
);
```

**Class Constant**:
```dart
static final String defaultAdminPasswordHash = hashPassword('admin123');
```

**Why SHA-256 (Not Perfect but Used Here)**:
- One-way hashing
- Industry standard
- Deterministic (same input = same output)
- Note: Production apps should use bcrypt or Argon2

---

## `lib/utils/session_manager.dart`

**Purpose**: Manage user login sessions persistently using Hive.

**Class**: `class SessionManager` (singleton pattern)

**Pattern**:
```dart
static final SessionManager instance = SessionManager._init();
SessionManager._init();  // Private constructor
```

**Session Storage Box**: `'session'` (Hive box for persistent storage)

**Session Data Structure**:
```dart
// Admin session
{
  'isAdminLoggedIn': bool,
  'adminLoginTime': String (ISO8601)
}

// Student session
{
  'isStudentLoggedIn': bool,
  'studentId': String,
  'studentName': String,
  'studentEmail': String,
  'studentLoginTime': String (ISO8601)
}
```

**Admin Session Methods**:

### `Future<void> saveAdminSession()`
- **Purpose**: Save admin login session
- **Logic**:
  1. Store isAdminLoggedIn = true
  2. Store current time as login time
- **Used in**: AdminLoginScreen after successful login
- **Persistence**: Survives app restart

### `Future<bool> isAdminLoggedIn()`
- **Purpose**: Check if admin is currently logged in
- **Returns**: bool - true if logged in
- **Default**: false if session data missing
- **Used in**: AdminLoginScreen initState() for auto-login
- **Example**:
```dart
if (await SessionManager.instance.isAdminLoggedIn()) {
  // Navigate to dashboard
}
```

### `Future<void> logoutAdmin()`
- **Purpose**: Clear admin session
- **Logic**: Delete both session keys
- **Used in**: AdminDashboardScreen logout button

### `Future<String?> getAdminLoginTime()`
- **Purpose**: Get when admin logged in
- **Returns**: ISO8601 timestamp or null
- **Used in**: Admin panel for session info display

**Student Session Methods**:

### `Future<void> saveStudentSession(String studentId, String studentName, String studentEmail)`
- **Purpose**: Save student login session
- **Parameters**:
  - `studentId`: Student's unique ID
  - `studentName`: Student's full name
  - `studentEmail`: Student's email
- **Logic**:
  1. Store isStudentLoggedIn = true
  2. Store all student info
  3. Store login timestamp
- **Used in**: StudentLoginScreen after successful authentication
- **Persistence**: Session survives app restart

### `Future<bool> isStudentLoggedIn()`
- **Purpose**: Check if student is logged in
- **Returns**: bool
- **Used in**: StudentLoginScreen initState() for auto-login check
- **Example**: If true, auto-navigate to dashboard

### `Future<String?> getLoggedInStudentId()`
- **Purpose**: Get ID of currently logged-in student
- **Returns**: String (studentId) or null
- **Used in**: StudentDashboardScreen, result screens

### `Future<String?> getLoggedInStudentName()`
- **Purpose**: Get name of current student
- **Returns**: String or null
- **Used in**: UI display (welcome messages)

### `Future<String?> getLoggedInStudentEmail()`
- **Purpose**: Get email of current student
- **Returns**: String or null

### `Future<String?> getStudentLoginTime()`
- **Purpose**: Get when student logged in
- **Returns**: ISO8601 string or null

### `Future<void> logoutStudent()`
- **Purpose**: Clear student session
- **Logic**: Delete all student-related keys
- **Used in**: StudentDashboardScreen logout

**General Method**:

### `Future<void> clearAllSessions()`
- **Purpose**: Clear all session data (admin and student)
- **Logic**: Clear entire session box
- **Used in**: Complete app logout (rarely)

---

# SCREENS - ADMIN

## `lib/screens/home_screen.dart`

**Purpose**: Landing page showing two options: admin login or student quiz.

**Class**: `class HomeScreen extends StatelessWidget`
- **Stateless**: No internal state (just navigation)

**Build Method**:
```dart
Widget build(BuildContext context)
```

**UI Components**:

1. **Header AppBar**
   - Title: "Quiz App"
   - Color: Deep Purple
   - Centered

2. **Body**:
   - Gradient background (light to lighter purple)
   - Two cards with action buttons

3. **Card 1: Administrator**
   - Icon: admin_panel_settings
   - Button: "Manage categories and questions"
   - Navigation: → AdminLoginScreen
   - Color: Deep Purple

4. **Card 2: Start Quiz**
   - Icon: play_circle_outline
   - Button: "Start Quiz"
   - Subtitle: "Login or register to take a quiz"
   - Navigation: → StudentLoginScreen
   - Color: Blue

**Theme Colors**:
- Primary: Colors.deepPurple
- Secondary: Colors.blue
- Gradients: Purple shades for background

**Navigation**:
- Admin button → AdminLoginScreen
- Student button → StudentLoginScreen
- Back button: Goes to previous screen (from other screens)

---

## `lib/screens/admin_login_screen.dart`

**Purpose**: Admin authentication with username/password and password recovery.

**Class**: `class AdminLoginScreen extends StatefulWidget`

**State Class**: `_AdminLoginScreenState`

**State Variables**:
```dart
GlobalKey<FormState> _formKey;     // Form validation key
TextEditingController _usernameController;
TextEditingController _passwordController;
bool _isLoading = false;           // Loading state during login
bool _obscurePassword = true;      // Show/hide password toggle
```

**Lifecycle Methods**:

### `void initState()`
- Calls `_checkExistingSession()`

### `Future<void> _checkExistingSession()`
- **Purpose**: Auto-login if admin session exists
- **Logic**:
  1. Check if `isAdminLoggedIn()` from SessionManager
  2. If true:
     - Navigate to AdminDashboardScreen
     - Replace current screen (no back button)
  3. This prevents re-entering login if already logged in
- **User Experience**: User sees dashboard automatically on return

### `void dispose()`
- Disposes text controllers to free memory

**Main Methods**:

### `Future<void> _login()`
- **Purpose**: Handle admin login button press
- **Validation**: 
  1. Form validation (fields not empty)
  2. Username/password verification
- **Logic**:
  1. Set `_isLoading = true` (show spinner)
  2. Call `DatabaseHelper.instance.verifyAdminCredentials(username, password)`
  3. If credentials valid:
     - Call `SessionManager.instance.saveAdminSession()`
     - Navigate to AdminDashboardScreen with replacement
  4. If invalid:
     - Show error snackbar: "Invalid username or password"
     - Keep on login screen
- **Error Handling**: Show snackbar with error message

### `void _showForgotPasswordDialog()`
- **Purpose**: Show password reset dialog with master code
- **Master Recovery Code**: "ADMIN@RESET"
- **Dialog Flow**:
  1. Show text fields:
     - Master Recovery Code (password field)
     - New Password (min 6 chars)
     - Confirm Password
  2. Validation:
     - Master code must equal "ADMIN@RESET"
     - New password ≥ 6 characters
     - Both passwords must match
  3. On success:
     - Call `DatabaseHelper.instance.resetAdminPassword(newPassword)`
     - Close dialog
     - Show success snackbar
  4. On error:
     - Show error dialog with message
- **Security Note**: Master code is hardcoded (should be environment variable in production)

**UI Components**:

1. **AppBar**:
   - Title: "Admin Login"
   - Color: Deep Purple
   - Back button (with custom handler)
   - Home button → HomeScreen

2. **Form Fields**:
   - Username (TextFormField)
     - Validator: Not empty
     - Icon: person
   - Password (TextFormField)
     - Validator: Not empty
     - Obscured text toggle button
     - Icon: lock

3. **Buttons**:
   - Login button (full width)
     - Shows loading spinner if `_isLoading`
     - Disabled while loading
   - Forgot Password link (text button)
   - Back to Home link

**Theme**: 
- Card elevation: 8
- Colors: Deep Purple shades
- Rounded corners: 16px

**Error Handling**:
- Form validation errors shown inline
- API/DB errors shown in snackbar
- Credential errors shown in snackbar with red background

---

## `lib/screens/admin_dashboard_screen.dart`

**Purpose**: Main admin control panel with options to manage categories and questions.

**Class**: `class AdminDashboardScreen extends StatelessWidget`

**Navigation Options**:

1. **Manage Categories Card**
   - Icon: library_add_rounded
   - Text: "Manage Categories" / "Add, edit, or delete quiz categories"
   - Navigation: → CategoryManagementScreen

2. **Manage Questions Card**
   - Icon: edit_note
   - Text: "Manage Questions" / "Add, edit, or delete quiz questions"
   - Navigation: → QuestionManagementScreen

**Methods**:

### `Future<void> _logout(BuildContext context)`
- **Purpose**: Clear admin session and return to home
- **Logic**:
  1. Call `SessionManager.instance.logoutAdmin()`
  2. Navigate to HomeScreen with removeUntil (removes all previous screens)
- **Used in**: Logout button in AppBar

**UI Components**:

1. **AppBar**:
   - Title: "Admin Panel"
   - Logout button (with icon)
   - No back button (dashboard is main screen)

2. **Body**:
   - Gradient background
   - Icon: admin_panel_settings (large)
   - Title: "Admin Panel"
   - Subtitle: "Manage your quiz content"
   - Two gradient cards with icons

3. **Cards**:
   - Gradient background (purple and blue)
   - Icon in white circle
   - Text with description
   - Right arrow icon
   - Tap to navigate

**Theme Colors**:
- Card 1: Purple gradient
- Card 2: Blue/Indigo gradient

---

## `lib/screens/category_management_screen.dart`

**Purpose**: CRUD interface for quiz categories with question count display.

**Class**: `class CategoryManagementScreen extends StatefulWidget`

**State**: `_CategoryManagementScreenState`

**State Variables**:
```dart
List<Category> _categories = [];
Map<String, int> _questionCounts = {};  // Category → count mapping
bool _isLoading = true;
```

**Lifecycle**:

### `void initState()`
- Calls `_loadCategories()`

### `Future<void> _loadCategories()`
- **Purpose**: Fetch all categories and their question counts
- **Logic**:
  1. Set `_isLoading = true`
  2. Get all categories from database
  3. For each category, get question count:
     ```dart
     counts[category.name] = await DatabaseHelper.instance
         .getQuestionCountByCategory(category.name);
     ```
  4. Update state with categories and counts
  5. Set `_isLoading = false`
- **Error Handling**: Show snackbar if error

**CRUD Methods**:

### `Future<void> _deleteCategory(Category category)`
- **Purpose**: Delete category with safety checks
- **Pre-check**: 
  - If category has questions:
    - Show error: "Cannot delete - it has X question(s)"
    - Return without deleting
  - This prevents orphaned questions
- **Delete Flow**:
  1. Show confirmation dialog
  2. User confirms delete
  3. Call `DatabaseHelper.instance.deleteCategory(id)`
  4. Reload categories
  5. Show success snackbar
- **Error Handling**: Show error snackbar

**UI Components**:

1. **AppBar**:
   - Title: "Manage Categories"
   - Back button
   - Home button

2. **Body**:
   - Empty state: "No categories yet"
   - Or ListView of categories:
     - Category name
     - Question count subtitle
     - Edit button (blue)
     - Delete button (red)

3. **FloatingActionButton**:
   - Icon: add
   - Color: Deep Purple
   - Tap: Open AddCategoryScreen
   - On return with result=true: Reload categories

**List Item Layout**:
- Icon (orange background)
- Category name (bold)
- Question count ("X question(s)")
- Edit/Delete buttons (trailing)

---

## `lib/screens/add_category_screen.dart`

**Purpose**: Form to create or edit quiz category.

**Class**: `class AddCategoryScreen extends StatefulWidget`

**Constructor Parameter**:
```dart
final Category? category;  // null = new, non-null = edit mode
```

**State**: `_AddCategoryScreenState`

**State Variables**:
```dart
GlobalKey<FormState> _formKey;
TextEditingController _nameController;
bool _isLoading = false;
bool get _isEditing => widget.category != null;
```

**Lifecycle**:

### `void initState()`
- If editing mode:
  - Pre-fill name field with category.name

### `void dispose()`
- Dispose controller

**Main Method**:

### `Future<void> _saveCategory()`
- **Purpose**: Save category (create or update)
- **Validation**:
  1. Form validation (name not empty, ≥ 2 characters)
  2. Check for duplicate names (case-insensitive)
- **Create Flow**:
  1. Get new name from controller
  2. Check if name already exists
  3. If yes: throw "Category name already exists"
  4. Create Category with UUID id
  5. Call `DatabaseHelper.instance.createCategory(newCategory)`
  6. Navigate back with result=true
- **Update Flow**:
  1. Get new name
  2. If name changed: check if new name exists
  3. Call `DatabaseHelper.instance.updateCategory(category, oldName: oldName)`
  4. This updates all questions with old category name
  5. Navigate back with result=true
- **Error Handling**: Show snackbar with error
- **Success**: Show snackbar and navigate back

**UI Components**:

1. **AppBar**:
   - Title: "Add Category" or "Edit Category"
   - Back button
   - Home button

2. **Form**:
   - Card with category icon
   - Text field for name
   - Label: "Category Name"
   - Hint: "Enter category name"
   - Text capitalization: Words
   - Validation message: "At least 2 characters"

3. **Button**:
   - "Add Category" or "Update Category" (text changes based on mode)
   - Shows loading spinner if `_isLoading`
   - Disabled while loading

**Validation**:
- Name must not be empty
- Name must be ≥ 2 characters
- Name must be unique (not already in database)

---

## `lib/screens/question_management_screen.dart`

**Purpose**: Display all questions organized by category with edit/delete options.

**Class**: `class QuestionManagementScreen extends StatefulWidget`

**State**: `_QuestionManagementScreenState`

**State Variables**:
```dart
Map<String, List<Question>> _questionsByCategory = {};
bool _isLoading = true;
```

**Lifecycle**:

### `void initState()`
- Calls `_loadQuestions()`

### `Future<void> _loadQuestions()`
- **Purpose**: Fetch all questions and group by category
- **Logic**:
  1. Get all questions from database
  2. Create empty map
  3. For each question:
     ```dart
     if (!grouped.containsKey(question.category)) {
       grouped[question.category] = [];
     }
     grouped[question.category]!.add(question);
     ```
  4. Update state with grouped questions

**CRUD Methods**:

### `Future<void> _deleteQuestion(String id)`
- **Purpose**: Delete question
- **Logic**:
  1. Call `DatabaseHelper.instance.deleteQuestion(id)`
  2. Reload questions
  3. Show success snackbar
- **Error Handling**: Show error snackbar

**UI Components**:

1. **AppBar**:
   - Title: "Manage Questions"
   - Home button

2. **Body**:
   - Empty state: "No questions added yet"
   - Or grouped by category:
     - Category header (deep purple background)
       - Category icon
       - Category name
       - Question count badge (white circle)
     - Question cards below:
       - Number circle (1, 2, 3...)
       - Question text
       - Options A, B, C, D
         - Letter circle (green if correct)
         - Option text
         - Green checkmark if correct
       - Edit/Delete buttons (trailing)

3. **FloatingActionButton**:
   - Extended: "Add Question"
   - Icon: add
   - Tap: → AddEditQuestionScreen
   - On return: Reload questions

**Helper Widget**:

### `Widget _buildOption(String letter, String text, bool isCorrect)`
- **Purpose**: Display answer option with styling
- **Logic**:
  - If isCorrect: green background and checkmark
  - Otherwise: gray background
- **UI**: Letter circle + option text

**List Item Interactions**:
- **Edit**: Open AddEditQuestionScreen with question data
- **Delete**: Show confirmation dialog, then delete

---

## `lib/screens/add_edit_question_screen.dart`

**Purpose**: Form to create or edit quiz question with clickable options.

**Class**: `class AddEditQuestionScreen extends StatefulWidget`

**Constructor Parameter**:
```dart
final Question? question;  // null = new, non-null = edit
```

**State**: `_AddEditQuestionScreenState`

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
- Call `_loadCategories()`
- If editing:
  - Pre-fill all fields with question data

### `Future<void> _loadCategories()`
- Load category names for dropdown
- Used in form

**Main Methods**:

### `Future<void> _saveQuestion()`
- **Purpose**: Create or update question
- **Validation**:
  1. Form validation (all fields not empty)
  2. Category selected
  3. Correct answer selected (must click option)
- **Logic**:
  1. Create Question object:
     ```dart
     final question = Question(
       id: widget.question?.id ?? 
           DateTime.now().millisecondsSinceEpoch.toString(),
       questionText: _questionController.text.trim(),
       optionA: _optionAController.text.trim(),
       optionB: _optionBController.text.trim(),
       optionC: _optionCController.text.trim(),
       optionD: _optionDController.text.trim(),
       correctAnswer: _selectedCorrectAnswer,
       category: _selectedCategory!,
     );
     ```
  2. If new: `DatabaseHelper.instance.createQuestion(question)`
  3. If edit: `DatabaseHelper.instance.updateQuestion(question)`
  4. Show success snackbar
  5. Navigate back
- **Error Handling**: Show error snackbar

**UI Components**:

1. **AppBar**:
   - Title: "Add Question" or "Edit Question"

2. **Form Fields**:
   - Category dropdown
   - Question text area (3 lines)
   - Options section with label:
     "Options (Click on an option to mark it as correct)"
   - Each option is clickable

3. **Clickable Option Widget** (`_buildClickableOption`):
   - **Design**:
     - Left side: Letter circle (green if selected)
     - Right side: Text input field
   - **Interaction**:
     - Tap option → mark as correct answer
     - Border turns green when selected
     - Shows checkmark icon
   - **UI States**:
     - Not selected: Gray background, gray border
     - Selected (correct): Green background, green border, checkmark

4. **Correct Answer Display**:
   - Shows below options
   - Green badge: "Correct Answer: Option [X]"
   - Shows when user has selected

5. **Save Button**:
   - "Add Question" or "Update Question"
   - Full width
   - Deep Purple

**Key Interaction**:
- Users click on any option to mark it as the correct answer
- Selected option highlights in green
- Badge shows confirmation below
- Provides clear visual feedback

---

# SCREENS - STUDENT

## `lib/screens/student_login_screen.dart`

**Purpose**: Student authentication with email/password.

**Class**: `class StudentLoginScreen extends StatefulWidget`

**State**: `_StudentLoginScreenState`

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
- Calls `_checkExistingSession()`

### `Future<void> _checkExistingSession()`
- **Purpose**: Auto-login if student session exists
- **Logic**:
  1. Check `SessionManager.instance.isStudentLoggedIn()`
  2. If true:
     - Get `getLoggedInStudentId()`
     - Fetch student from database
     - Navigate to StudentDashboardScreen
- **User Experience**: Remembers logged-in student

**Main Method**:

### `Future<void> _login()`
- **Purpose**: Handle login button
- **Validation**: Form validation
- **Logic**:
  1. Call `DatabaseHelper.instance.loginStudent(email, password)`
  2. If student returned:
     - Call `SessionManager.instance.saveStudentSession(id, name, email)`
     - Navigate to StudentDashboardScreen with student data
  3. If null (invalid credentials):
     - Show error snackbar
     - Stay on screen
- **Error Handling**: Show snackbar

**UI Components** (similar to admin login):

1. **Form Fields**:
   - Email (emailAddress keyboard)
   - Password (toggle visibility)

2. **Buttons**:
   - Login button (full width)
   - Register link (bottom):
     - Text: "Don't have an account?"
     - Button: "Register"
     - Navigation: → StudentRegistrationScreen

3. **Navigation Buttons**:
   - Back arrow
   - Home icon button

**Theme**: Blue/Deep Purple colors

---

## `lib/screens/student_registration_screen.dart`

**Purpose**: Create new student account with validation.

**Class**: `class StudentRegistrationScreen extends StatefulWidget`

**State**: `_StudentRegistrationScreenState`

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
- **Purpose**: Create new student account
- **Validation**:
  1. Form validation (all required)
  2. Email format check (contains @ and .)
  3. Password ≥ 6 characters
  4. Passwords match
- **Logic**:
  1. Hash password:
     ```dart
     passwordHash: PasswordUtils.hashPassword(_passwordController.text)
     ```
  2. Create Student object
  3. Call `DatabaseHelper.instance.registerStudent(student)`
  4. If email already exists: Show error
  5. Otherwise:
     - Show success snackbar
     - Navigate to StudentLoginScreen (user must log in)
- **Error Handling**: Display error message from exception

**UI Components**:

1. **Form Fields** (8 fields):
   - Full Name (text input)
   - Email (email keyboard)
   - Address (multi-line: 2 lines)
   - Phone Number (phone keyboard)
   - Password (obscured, toggle visibility)
   - Confirm Password (obscured, toggle visibility)

2. **Validation Messages**:
   - Name: "Please enter your name"
   - Email: "Valid email required"
   - Address: "Please enter address"
   - Phone: "Please enter phone"
   - Password: "Min 6 characters"
   - Confirm: "Passwords must match"

3. **Buttons**:
   - Register button (full width, deep purple)
   - Login link (bottom):
     - Text: "Already have an account?"
     - Button: "Login"

4. **AppBar**:
   - Title: "Student Registration"
   - Home button

**Theme**: Deep Purple gradient background

---

## `lib/screens/student_dashboard_screen.dart`

**Purpose**: Main student interface showing profile and quiz history.

**Class**: `class StudentDashboardScreen extends StatefulWidget`

**Constructor Parameter**:
```dart
final Student student;  // Logged-in student
```

**State**: `_StudentDashboardScreenState`

**State Variables**:
```dart
List<ScoreHistory> _scoreHistory = [];
bool _isLoading = true;
```

**Lifecycle**:

### `void initState()`
- Calls `_loadScoreHistory()`

### `Future<void> _loadScoreHistory()`
- **Purpose**: Fetch all quiz attempts for student
- **Logic**:
  1. Call `DatabaseHelper.instance.getStudentScores(student.id)`
  2. Update state with scores
  3. Scores are automatically sorted newest first

**Methods**:

### `void _logout()`
- **Purpose**: Clear session and return home
- **Logic**:
  1. Call `SessionManager.instance.logoutStudent()`
  2. Navigate to HomeScreen

**Helper Method**:

### `String _formatDate(DateTime date)`
- **Purpose**: Format timestamp for display
- **Format**: "Jan 23, 2023 at 16:45"
- **Used in**: Score history list items

**UI Components**:

1. **AppBar**:
   - Title: "My Dashboard"
   - Logout button (top-right)

2. **Profile Card**:
   - Avatar circle with first letter of name
   - "Welcome, [Name]!"
   - Email address below

3. **Start Quiz Button**:
   - Full width, green
   - Icon: play_arrow
   - On tap: Navigate to StudentCategorySelectionScreen
   - On return: Reload score history

4. **Score History Section**:
   - Title: "Score History"
   - If no scores:
     - Empty state icon and message
   - Or list of quiz attempts:
     - Percentage badge (green if ≥50%, orange if <50%)
     - Category name
     - "Score: X/Y"
     - Date and time
     - Pass/Fail icon (checkmark or warning)

**List Item Logic**:
```dart
isPassed = percentage >= 50;
// Green background if passed, orange if failed
```

---

## `lib/screens/student_category_selection_screen.dart`

**Purpose**: Let student choose quiz category to start.

**Class**: `class StudentCategorySelectionScreen extends StatefulWidget`

**Constructor Parameter**:
```dart
final Student student;  // To pass to quiz screen
```

**State**: `_StudentCategorySelectionScreenState`

**State Variables**:
```dart
List<String> _categories = [];
bool _isLoading = true;
```

**Lifecycle**:

### `void initState()`
- Calls `_loadCategories()`

### `Future<void> _loadCategories()`
- Load all category names (sorted alphabetically)

**Methods**:

### `Future<void> _startQuiz(String category)`
- **Purpose**: Begin quiz in selected category
- **Logic**:
  1. Get all questions in category:
     ```dart
     final questions = await DatabaseHelper.instance
         .getQuestionsByCategory(category);
     ```
  2. If no questions:
     - Show toast: "No questions found in [category]"
     - Return
  3. Otherwise:
     - Navigate to StudentQuizScreen with:
       - questions list
       - student object
       - category name

### `Color _getCategoryColor(String category)`
- **Purpose**: Return color for category
- **Logic**: Switch on lowercase category name
- **Colors**:
  - Math → Indigo
  - Science → Teal
  - History → Brown
  - Geography → Cyan
  - General Knowledge → Blue
  - Default → Deep Purple

### `IconData _getCategoryIcon(String category)`
- **Purpose**: Return icon for category
- **Icons**:
  - Math → calculate
  - Science → science
  - History → history_edu
  - Geography → public
  - General Knowledge → lightbulb
  - Default → category

**UI Components**:

1. **AppBar**:
   - Title: "Select Category"
   - Home button

2. **Empty State**:
   - Large icon
   - "No categories available"
   - "Please ask admin to add questions"

3. **Category List**:
   - ListView with gradient cards
   - Each card:
     - Left: Icon in white circle with category color
     - Center: Category name (bold, white text)
     - Right: Arrow icon
     - Gradient background (category color)
     - Tap to start quiz

**Design**: Colorful, intuitive category selection

---

## `lib/screens/student_quiz_screen.dart`

**Purpose**: Quiz interface where student answers questions.

**Class**: `class StudentQuizScreen extends StatefulWidget`

**Constructor Parameters**:
```dart
final List<Question> questions;
final Student student;
final String category;
```

**State**: `_StudentQuizScreenState`

**State Variables**:
```dart
int _currentQuestionIndex = 0;
int _score = 0;                      // Running score
String? _selectedAnswer;             // Which option selected (A, B, C, D)
bool _answered = false;              // Has user answered this question?
```

**Methods**:

### `void _answerQuestion(String answer)`
- **Purpose**: Handle user selecting an answer
- **Logic**:
  1. If already answered, return (prevent re-answering)
  2. Mark as answered
  3. Check if answer is correct
  4. If correct: increment score
  5. Update UI to show correct/incorrect feedback
- **Visual Feedback**:
  - Correct: Green background, checkmark
  - Incorrect: Red background for wrong answer, green for correct

### `void _nextQuestion()`
- **Purpose**: Move to next question or show results
- **Logic**:
  1. If more questions: 
     - Increment index
     - Reset selectedAnswer and answered flags
  2. If last question:
     - Navigate to StudentResultScreen with:
       - score
       - totalQuestions
       - student
       - category
  3. This navigates to result screen with replacement (no back)

**UI Components**:

1. **AppBar**:
   - Title: "Question X/Total"
   - Home button with confirmation dialog:
     - "Leave Quiz?"
     - Warns: "Progress will be lost"

2. **Progress Bar**:
   - LinearProgressIndicator showing progress (X/Total)
   - Deep purple color

3. **Question Card**:
   - Display question text (bold, centered)
   - Background: Light purple

4. **Answer Options**:
   - 4 buttons (A, B, C, D)
   - Each option shows:
     - Letter circle (left)
     - Option text (center)
     - Icon if answered (right)
   - Colors based on state:
     - Not answered: White background
     - Selected (before answering): Deep purple
     - Correct (after answering): Green with checkmark
     - Incorrect (after answering): Red with X
   - Tap to select answer (disabled after answering)

5. **Next Button**:
   - Only appears after answering
   - Text: "Next Question" or "See Results" (on last)
   - Deep purple
   - Full width

**Helper Widget**:

### `Widget _buildAnswerButton(String letter, String text, Question question)`
- **Purpose**: Build clickable answer option with styling
- **Parameters**:
  - `letter`: A, B, C, or D
  - `text`: Option text
  - `question`: Current question (to get correct answer)
- **Logic**:
  1. Calculate colors based on:
     - Is this option selected? (isSelected)
     - Is this option correct? (isCorrect)
     - Has user answered? (_answered)
  2. Apply appropriate styling
  3. Show checkmark/X icon if answered
  4. Disable tap if already answered
- **States**:
  - Normal: White, gray border
  - Selected (not answered): Deep purple tint
  - Correct: Green with checkmark
  - Wrong: Red with X

**Key Logic Flow**:
```
User taps option A
  ↓
_answerQuestion('A') called
  ↓
Compare with question.correctAnswer
  ↓
If match: _score++ (increment score)
  ↓
Update UI: Show green/red feedback
  ↓
User taps "Next Question"
  ↓
Move to next question or show results
```

---

## `lib/screens/student_result_screen.dart`

**Purpose**: Display quiz results and save score to database.

**Class**: `class StudentResultScreen extends StatefulWidget`

**Constructor Parameters**:
```dart
final int score;
final int totalQuestions;
final Student student;
final String category;
```

**State**: `_StudentResultScreenState`

**Lifecycle**:

### `void initState()`
- Calls `_saveScore()`

### `Future<void> _saveScore()`
- **Purpose**: Record quiz attempt in database
- **Logic**:
  1. Create ScoreHistory object:
     ```dart
     final scoreHistory = ScoreHistory(
       studentId: widget.student.id,
       category: widget.category,
       score: widget.score,
       totalQuestions: widget.totalQuestions,
     );
     ```
  2. Call `DatabaseHelper.instance.saveScore(scoreHistory)`
  3. Timestamp is auto-added
- **Error Handling**: Log error (don't show to user)
- **Timing**: Runs on screen load, before build

**UI Components**:

1. **AppBar**:
   - Title: "Quiz Results"
   - Home button

2. **Background**:
   - Gradient: Green if passed (≥50%), Orange if failed
   - Conditional colors based on performance

3. **Result Message Section**:
   - Large icon:
     - Passed: Trophy (emoji_events)
     - Failed: Refresh (refresh)
   - Message:
     - Passed: "Congratulations!"
     - Failed: "Keep Practicing!"
   - Subtext:
     - Passed: "You did great on this quiz!"
     - Failed: "Don't give up, try again!"
   - Category name displayed

4. **Score Display Card**:
   - Large score: "8" in bold (green or orange)
   - Fraction: " / 10" in gray
   - Percentage badge: "80%" in percentage color
   - Centered in card with shadow

5. **Action Buttons**:
   - "Try Again" button
     - Color: Green if passed, Orange if failed
     - Navigation: → StudentCategorySelectionScreen (restart)
   - "Go to Dashboard" button
     - Color: Deep Purple
     - Navigation: → StudentDashboardScreen

**Calculation**:
```dart
percentage = (score / totalQuestions * 100).round()
isPassed = percentage >= 50
```

**User Flow After Quiz**:
1. Finishes last question
2. Taps "See Results"
3. Navigates to StudentResultScreen
4. Score automatically saves to database
5. User sees results with options to retry or go back

---

## `lib/screens/result_screen.dart`

**Purpose**: Generic quiz result screen (alternative result display).

**Note**: Similar to StudentResultScreen but without automatic database save (used in different flow).

**Class**: `class ResultScreen extends StatelessWidget`

**Constructor Parameters**:
```dart
final int score;
final int totalQuestions;
final String? studentId;   // Optional
final String? category;    // Optional
```

**Key Difference from StudentResultScreen**:
- This screen does NOT save score (no initState, no database call)
- Used for quiz attempts without student login
- Generic result display

**UI Components**:
- Similar to StudentResultScreen
- Same calculation and color logic
- Buttons:
  - "Try Again" → CategorySelectionScreen
  - "Back to Home" → HomeScreen

---

# SCREENS - NAVIGATION

## `lib/screens/category_selection_screen.dart`

**Purpose**: Generic category selection (used in some quiz flows).

**Note**: Similar to StudentCategorySelectionScreen but standalone (not tied to specific student).

---

## Navigation Summary

```
HomeScreen
├─ Admin Path
│  ├─ AdminLoginScreen
│  │  └─ AdminDashboardScreen
│  │     ├─ CategoryManagementScreen
│  │     │  └─ AddCategoryScreen
│  │     └─ QuestionManagementScreen
│  │        └─ AddEditQuestionScreen
│  └─ Forgot Password → Reset Dialog
│
└─ Student Path
   ├─ StudentLoginScreen
   │  └─ StudentDashboardScreen
   │     ├─ StudentCategorySelectionScreen
   │     │  └─ StudentQuizScreen
   │     │     └─ StudentResultScreen
   │     └─ Score History
   └─ StudentRegistrationScreen
      └─ StudentLoginScreen
```

---

# Summary

**Total Files Documented**: 22 Dart files + 1 YAML config

**Core Functionality**:
- Authentication (Admin, Student)
- Database Operations (CRUD for all entities)
- Session Management
- Quiz Flow (Category → Questions → Results → Score Save)
- Category/Question Management

**Design Patterns Used**:
- Singleton (DatabaseHelper, SessionManager)
- Factory Pattern (Model.fromMap constructors)
- State Management (StatefulWidget)
- Widget Composition (reusable components)

**Data Security**:
- SHA-256 password hashing
- Session persistence
- Master recovery code for admin

**Key Features**:
- Complete CRUD for questions and categories
- Student registration and login
- Quiz taking with real-time scoring
- Score history tracking
- Admin management panel
- Password reset mechanism
