# Flutter Quiz App - Complete Architecture Documentation

## Table of Contents
1. [App Overview](#app-overview)
2. [Project Structure](#project-structure)
3. [Architecture & Design Patterns](#architecture--design-patterns)
4. [Core Modules](#core-modules)
5. [Data Models](#data-models)
6. [Database System](#database-system)
7. [Session Management](#session-management)
8. [User Flows](#user-flows)
9. [Screen/Panel Details](#screenpanel-details)
10. [Data Flow Diagrams](#data-flow-diagrams)

---

## App Overview

**Quiz App** is a Flutter web application that allows two types of users to interact with a quiz system:
- **Administrators**: Manage quiz categories and questions
- **Students**: Register, login, and take quizzes

The app uses Hive database (local storage compatible with web, mobile, and desktop platforms) and stores all data persistently on the device.

**Key Features:**
- Admin authentication with password reset functionality
- Student registration and login
- Category management
- Question management with multiple choice answers
- Quiz taking with real-time scoring
- Score history tracking
- Session management for both admin and student users

---

## Project Structure

```
quiz_app/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── database/
│   │   └── database_helper.dart           # Database operations
│   ├── models/
│   │   ├── student.dart                   # Student & ScoreHistory models
│   │   ├── category.dart                  # Category model
│   │   └── question.dart                  # Question model
│   ├── screens/
│   │   ├── home_screen.dart              # Home/Landing screen
│   │   ├── admin_login_screen.dart       # Admin login
│   │   ├── admin_dashboard_screen.dart   # Admin main panel
│   │   ├── category_management_screen.dart
│   │   ├── question_management_screen.dart
│   │   ├── student_login_screen.dart
│   │   ├── student_registration_screen.dart
│   │   ├── student_dashboard_screen.dart
│   │   ├── category_selection_screen.dart
│   │   ├── quiz_screen.dart              # Quiz taking screen
│   │   ├── result_screen.dart            # Quiz results
│   │   ├── student_quiz_screen.dart
│   │   ├── student_result_screen.dart
│   │   ├── student_category_selection_screen.dart
│   │   └── add_edit_question_screen.dart
│   │   └── add_category_screen.dart
│   └── utils/
│       ├── session_manager.dart          # Session handling
│       └── password_utils.dart           # Password hashing
├── pubspec.yaml                          # Dependencies
└── web/                                  # Web assets
    ├── index.html
    ├── manifest.json
    └── icons/
```

---

## Architecture & Design Patterns

### Pattern Used: **Singleton + State Management**

1. **DatabaseHelper (Singleton)**: 
   - Single instance accessed globally via `DatabaseHelper.instance`
   - Manages all database operations
   - Lazy initialization of Hive boxes

2. **SessionManager (Singleton)**:
   - Tracks admin and student login sessions
   - Persists session data in Hive

3. **StatefulWidget Pattern**:
   - Used for screens with user input and form validation
   - Local state management for form fields and loading states

### Technology Stack

| Component | Technology |
|-----------|-----------|
| UI Framework | Flutter + Material Design 3 |
| Database | Hive (NoSQL) |
| Password Security | SHA-256 hashing (crypto package) |
| ID Generation | UUID |
| State Management | Local StatefulWidget state |

---

## Core Modules

### 1. **Database Module** (`lib/database/database_helper.dart`)

The DatabaseHelper is the central point for all database operations using Hive.

**Hive Boxes (Storage Collections):**
- `questions`: Stores all quiz questions
- `students`: Stores student user accounts
- `scores`: Stores score history
- `admin`: Stores admin credentials
- `categories`: Stores quiz categories

**Key Methods:**

| Method | Purpose | Returns |
|--------|---------|---------|
| `verifyAdminCredentials(username, password)` | Verify admin login | bool |
| `createQuestion(question)` | Add new question | Future<void> |
| `updateQuestion(question)` | Edit existing question | Future<void> |
| `deleteQuestion(id)` | Remove question | Future<void> |
| `getQuestionsByCategory(category)` | Get questions by category | Future<List<Question>> |
| `getAllCategories()` | Retrieve all categories | Future<List<Category>> |
| `createCategory(category)` | Add new category | Future<void> |
| `updateCategory(category, oldName)` | Edit category (updates associated questions) | Future<void> |
| `deleteCategory(id)` | Remove category | Future<void> |
| `registerStudent(student)` | Create new student account | Future<void> |
| `loginStudent(email, password)` | Authenticate student | Future<Student?> |
| `getStudentById(id)` | Retrieve student by ID | Future<Student?> |
| `saveScore(scoreHistory)` | Record quiz score | Future<void> |
| `getStudentScores(studentId)` | Get all scores for a student | Future<List<ScoreHistory>> |
| `resetAdminPassword(newPassword)` | Change admin password | Future<void> |

**Initialization Flow:**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();  // Initialize Hive
  await DatabaseHelper.instance.initializeAdmin();  // Create default admin
  await DatabaseHelper.instance.initializeDefaultCategories();  // Create default categories
  runApp(const QuizApp());
}
```

### 2. **Session Management Module** (`lib/utils/session_manager.dart`)

Manages user login sessions using Hive for persistence.

**Session Storage Keys:**

| Key | Purpose | Type |
|-----|---------|------|
| `isAdminLoggedIn` | Admin login status | bool |
| `adminLoginTime` | When admin logged in | String (ISO8601) |
| `isStudentLoggedIn` | Student login status | bool |
| `studentId` | Current student ID | String |
| `studentName` | Current student name | String |
| `studentEmail` | Current student email | String |
| `studentLoginTime` | When student logged in | String (ISO8601) |

**Key Methods:**

| Method | Purpose |
|--------|---------|
| `saveAdminSession()` | Create admin session |
| `isAdminLoggedIn()` | Check if admin is logged in |
| `logoutAdmin()` | Clear admin session |
| `saveStudentSession(id, name, email)` | Create student session |
| `isStudentLoggedIn()` | Check if student is logged in |
| `getLoggedInStudentId()` | Get current student ID |
| `logoutStudent()` | Clear student session |

### 3. **Password Security Module** (`lib/utils/password_utils.dart`)

Provides secure password hashing using SHA-256.

```dart
// Hash password before storing
String hashed = PasswordUtils.hashPassword('myPassword');

// Verify password during login
bool isValid = PasswordUtils.verifyPassword('myPassword', hashedPassword);
```

---

## Data Models

### 1. **Student Model** (`lib/models/student.dart`)

```dart
class Student {
  final String id;              // Unique identifier (timestamp-based)
  final String name;            // Student full name
  final String email;           // Student email (unique)
  final String address;         // Student address
  final String phone;           // Student phone number
  final String passwordHash;    // SHA-256 hashed password
  final DateTime createdAt;     // Account creation time
}
```

**Database Representation:**
```json
{
  "id": "1703352000000",
  "name": "John Doe",
  "email": "john@example.com",
  "address": "123 Main St",
  "phone": "555-1234",
  "passwordHash": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
  "createdAt": "2023-12-23T16:00:00.000Z"
}
```

### 2. **ScoreHistory Model** (in `lib/models/student.dart`)

```dart
class ScoreHistory {
  final String id;              // Unique identifier
  final String studentId;       // Reference to student
  final String category;        // Quiz category
  final int score;              // Points scored
  final int totalQuestions;     // Total questions answered
  final DateTime timestamp;     // When quiz was taken
  
  int get percentage => (score / totalQuestions * 100).round();
}
```

**Database Representation:**
```json
{
  "id": "1703352000001",
  "studentId": "1703352000000",
  "category": "Math",
  "score": 8,
  "totalQuestions": 10,
  "timestamp": "2023-12-23T16:05:00.000Z"
}
```

### 3. **Category Model** (`lib/models/category.dart`)

```dart
class Category {
  final String id;              // Unique identifier
  final String name;            // Category name (e.g., "Math", "Science")
}
```

**Database Representation:**
```json
{
  "id": "cat_1",
  "name": "Math"
}
```

**Default Categories on Initialization:**
- Math
- Science
- History
- Geography
- General Knowledge

### 4. **Question Model** (`lib/models/question.dart`)

```dart
class Question {
  final String id;              // Unique identifier (timestamp-based)
  final String questionText;    // The question
  final String optionA;         // Answer option A
  final String optionB;         // Answer option B
  final String optionC;         // Answer option C
  final String optionD;         // Answer option D
  final String correctAnswer;   // Correct option (A, B, C, or D)
  final String category;        // Category this question belongs to
}
```

**Database Representation:**
```json
{
  "id": "1703352000002",
  "questionText": "What is 2 + 2?",
  "optionA": "3",
  "optionB": "4",
  "optionC": "5",
  "optionD": "6",
  "correctAnswer": "B",
  "category": "Math"
}
```

---

## Database System

### Hive Database Overview

Hive is a lightweight local database that works across platforms (Flutter web, mobile, desktop).

### Database Schema

```
┌─────────────────────────────────────────────────────────────┐
│                        Hive Boxes                            │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Box: "questions"                                           │
│  ├── Key: Question.id                                       │
│  └── Value: {questionText, optionA-D, correctAnswer, ...}  │
│                                                              │
│  Box: "categories"                                          │
│  ├── Key: Category.id                                       │
│  └── Value: {name}                                          │
│                                                              │
│  Box: "students"                                            │
│  ├── Key: Student.id                                        │
│  └── Value: {name, email, address, phone, passwordHash, ...}
│                                                              │
│  Box: "scores"                                              │
│  ├── Key: ScoreHistory.id                                   │
│  └── Value: {studentId, category, score, totalQuestions, ...}
│                                                              │
│  Box: "admin"                                               │
│  ├── Key: "admin"                                           │
│  └── Value: {username, passwordHash}                        │
│                                                              │
│  Box: "session"                                             │
│  ├── Key: isAdminLoggedIn, adminLoginTime                  │
│  ├── Key: isStudentLoggedIn, studentId, studentName, ...   │
│  └── Value: (stored values)                                 │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Relationships

```
Student (1) ──────── (many) ScoreHistory
           |
           └─────────────────┐
                         Each score tracks
                     which quiz was taken

Category (1) ──────── (many) Question
           |
           └─────────────────┐
                    Questions belong to
                       categories
```

---

## Session Management

### How Sessions Work

1. **Admin Session Flow:**
   ```
   Admin Login Screen
        ↓
   Verify credentials (DatabaseHelper)
        ↓
   If valid: Save session (SessionManager.saveAdminSession())
        ↓
   Navigate to Admin Dashboard
   ```

2. **Student Session Flow:**
   ```
   Student Login/Registration Screen
        ↓
   Create or verify account (DatabaseHelper)
        ↓
   If successful: Save session (SessionManager.saveStudentSession())
        ↓
   Navigate to Student Dashboard
   ```

3. **Session Persistence:**
   - Sessions are stored in the "session" Hive box
   - Sessions persist across app restarts
   - Check existing session on login screen initialization
   - If session exists, auto-navigate to dashboard

### Default Credentials

**Admin:**
- Username: `admin`
- Password: `admin123`
- Master Recovery Code: `ADMIN@RESET` (for password reset)

---

## User Flows

### Flow 1: Admin Workflow

```
┌──────────────────────────────────────────────────────────┐
│                      HOME SCREEN                         │
│  ┌────────────────────┐  ┌──────────────────────────┐  │
│  │  Administrator     │  │   Start Quiz             │  │
│  │  Manage categories │  │  Login/Register          │  │
│  └────────┬───────────┘  └──────────────────────────┘  │
│           │                                             │
└───────────┼─────────────────────────────────────────────┘
            ↓
┌──────────────────────────────────────────────────────────┐
│            ADMIN LOGIN SCREEN                            │
│  - Enter username & password                             │
│  - Optional: Forgot password (master code reset)        │
└────────────────┬─────────────────────────────────────────┘
                 ↓
         ┌──────────────┐
         │ Credentials  │
         │ Valid?       │
         └──┬───────┬───┘
            │       │
          YES      NO
            │       │
            ↓       └→ Show error, retry
            │
┌───────────────────────────────────────────────────────────┐
│          ADMIN DASHBOARD SCREEN                           │
│  ┌──────────────────┐  ┌──────────────────────┐          │
│  │ Manage Categories│  │  Manage Questions    │          │
│  └────────┬─────────┘  └────────┬─────────────┘          │
│           │                     │                        │
└───────────┼─────────────────────┼────────────────────────┘
            ↓                     ↓
  ┌─────────────────┐  ┌──────────────────┐
  │ CATEGORY SCREEN │  │ QUESTION SCREEN  │
  │ - Add category  │  │ - Add question   │
  │ - Edit category │  │ - Edit question  │
  │ - Delete        │  │ - Delete         │
  └────────┬────────┘  └────────┬─────────┘
           │                    │
           └────────┬───────────┘
                    ↓
        ┌──────────────────────┐
        │ Database Updated     │
        │ (Hive boxes)         │
        └──────────────────────┘
```

### Flow 2: Student Workflow

```
┌──────────────────────────────────────────────────────────┐
│                    HOME SCREEN                           │
│                 Start Quiz Button                        │
└────────────────────┬─────────────────────────────────────┘
                     ↓
          ┌────────────────────┐
          │ New Student?       │
          └──┬────────┬────────┘
             │        │
           YES        NO
             │        │
    ┌────────↓─┐  ┌───↓──────┐
    │REGISTER  │  │   LOGIN  │
    └────┬─────┘  └────┬─────┘
         │             │
         └──────┬──────┘
                ↓
    ┌──────────────────────┐
    │ CATEGORY SELECTION   │
    │ - Browse categories  │
    │ - View question count│
    └────────┬─────────────┘
             ↓
    ┌──────────────────────┐
    │    QUIZ SCREEN       │
    │ - Show question      │
    │ - 4 options (A-D)    │
    │ - Progress indicator │
    └────────┬─────────────┘
             │
        ┌────┴────┐
        │ All Qs  │
        │answered?│
        └────┬────┘
             │
           NO
             │
             ↓
    ┌──────────────────────┐
    │    RESULT SCREEN     │
    │ - Score: X/Y         │
    │ - Percentage         │
    │ - Return to home     │
    └──────────────────────┘
```

---

## Screen/Panel Details

### Screen Hierarchy & Navigation

#### 1. **HomeScreen** (`home_screen.dart`)
- **Purpose**: Landing/main entry point
- **Navigation Options**:
  - Administrator → AdminLoginScreen
  - Start Quiz → StudentLoginScreen
- **Components**:
  - Quiz icon (header)
  - Two cards with action buttons
  - Gradient background

#### 2. **AdminLoginScreen** (`admin_login_screen.dart`)
- **Purpose**: Admin authentication
- **Features**:
  - Username/password form validation
  - "Forgot Password" with master code recovery
  - Session check on initialization
  - Loading state during verification
- **Navigation**:
  - Success → AdminDashboardScreen
  - Forgot Password → Password Reset Dialog
  - Back → HomeScreen

#### 3. **AdminDashboardScreen** (`admin_dashboard_screen.dart`)
- **Purpose**: Main admin control panel
- **Options**:
  - Manage Categories
  - Manage Questions
  - Logout button (top-right)
- **Navigation**:
  - Manage Categories → CategoryManagementScreen
  - Manage Questions → QuestionManagementScreen
  - Logout → HomeScreen (clear session)

#### 4. **CategoryManagementScreen** (`category_management_screen.dart`)
- **Purpose**: CRUD operations for categories
- **Features**:
  - List all categories
  - Add new category
  - Edit existing category
  - Delete category with confirmation
  - Display question count per category

#### 5. **QuestionManagementScreen** (`question_management_screen.dart`)
- **Purpose**: CRUD operations for questions
- **Features**:
  - List all questions
  - Filter by category
  - Add/Edit/Delete questions
  - Form validation for all fields
  - Display correct answer for each question

#### 6. **AddEditQuestionScreen** (`add_edit_question_screen.dart`)
- **Purpose**: Form for adding or editing questions
- **Fields**:
  - Question text (text area)
  - Option A, B, C, D (text inputs)
  - Correct answer (dropdown: A/B/C/D)
  - Category (dropdown)
- **Validation**: All fields required

#### 7. **AddCategoryScreen** (`add_category_screen.dart`)
- **Purpose**: Form for creating new category
- **Fields**:
  - Category name (text input)
- **Validation**: Name required, no duplicates

#### 8. **StudentLoginScreen** (`student_login_screen.dart`)
- **Purpose**: Student authentication
- **Features**:
  - Email/password form
  - Session check on initialization
  - Link to registration
  - Loading state
- **Navigation**:
  - Success → StudentDashboardScreen
  - New user → StudentRegistrationScreen
  - Back → HomeScreen

#### 9. **StudentRegistrationScreen** (`student_registration_screen.dart`)
- **Purpose**: Student account creation
- **Fields**:
  - Full name
  - Email (unique validation)
  - Address
  - Phone number
  - Password (min 6 chars)
  - Confirm password
- **Validation**: All fields required, email format, password match
- **Navigation**:
  - Success → StudentLoginScreen
  - Link to login → StudentLoginScreen

#### 10. **StudentDashboardScreen** (`student_dashboard_screen.dart`)
- **Purpose**: Student main menu
- **Options**:
  - Start New Quiz
  - View Quiz History
  - View Profile
  - Logout
- **Navigation**:
  - Start Quiz → CategorySelectionScreen
  - History → ScoreHistoryScreen
  - Profile → ProfileScreen
  - Logout → HomeScreen

#### 11. **CategorySelectionScreen** (`student_category_selection_screen.dart`)
- **Purpose**: Choose quiz category
- **Features**:
  - List all categories
  - Show question count
  - Display difficulty (if applicable)
- **Navigation**:
  - Select category → QuizScreen

#### 12. **QuizScreen** (`quiz_screen.dart`)
- **Purpose**: Main quiz interface
- **Features**:
  - Display current question (1/10 format)
  - Progress bar
  - 4 answer buttons (A, B, C, D)
  - Color feedback (green = correct, red = wrong)
  - Show correct answer after selection
  - Next/See Results button
- **Scoring**: Real-time score tracking
- **Navigation**:
  - Last question → ResultScreen
  - Leave quiz → HomeScreen (with confirmation dialog)

#### 13. **ResultScreen** (`result_screen.dart`)
- **Purpose**: Show quiz results
- **Display**:
  - Score: X/Y
  - Percentage (%)
  - Performance feedback
  - Option to retake quiz or go home
- **Database**: Saves score to database
- **Navigation**:
  - Retake Quiz → CategorySelectionScreen
  - Home → StudentDashboardScreen

---

## Data Flow Diagrams

### Data Flow 1: Question Management

```
Admin adds a Question
        ↓
AddEditQuestionScreen (form input)
        ↓
Validate all fields
        ↓
Question object created
        ↓
DatabaseHelper.createQuestion(question)
        ↓
Hive "questions" box updated
        ↓
Success message shown
        ↓
QuestionManagementScreen updated with new question
```

### Data Flow 2: Category Update

```
Admin edits a Category name
        ↓
CategoryManagementScreen (edit dialog)
        ↓
DatabaseHelper.updateCategory(category, oldName)
        ↓
Split into 2 operations:
├─ Update "categories" box
└─ Update all questions with old category name
        ↓
DatabaseHelper.updateQuestionsCategoryName(oldName, newName)
        ├─ Get all questions with oldName
        ├─ Create new Question objects with newName
        └─ Update each in "questions" box
        ↓
Complete → Show success
```

### Data Flow 3: Student Quiz Flow

```
Student selects category
        ↓
DatabaseHelper.getQuestionsByCategory(categoryName)
        ↓
Query "questions" box (filter by category)
        ↓
Return List<Question>
        ↓
QuizScreen receives questions list
        ↓
Display 1st question with options
        ↓
Student selects answer
        ↓
QuizScreen compares with correctAnswer
        ↓
Update score if correct
        ↓
Move to next question (repeat)
        ↓
All questions done
        ↓
ResultScreen shows final score
        ↓
ScoreHistory created & saved
        ↓
DatabaseHelper.saveScore(scoreHistory)
        ↓
"scores" box updated
        ↓
Database now contains student's performance record
```

### Data Flow 4: Student Login & Session

```
StudentLoginScreen
        ↓
User enters email & password
        ↓
DatabaseHelper.loginStudent(email, password)
        ├─ Query "students" box for email
        ├─ Compare password with stored hash
        └─ Return Student object if match
        ↓
Check credentials valid?
        ↓
YES ↓
SessionManager.saveStudentSession(id, name, email)
        ├─ Store in "session" Hive box
        ├─ isStudentLoggedIn = true
        ├─ studentId, studentName, studentEmail stored
        └─ studentLoginTime = now
        ↓
Navigate to StudentDashboardScreen
        ↓
Future logins can check:
SessionManager.isStudentLoggedIn() → true
        ↓
Auto-navigate to dashboard without login
```

### Data Flow 5: Admin Password Reset

```
AdminLoginScreen (Forgot Password?)
        ↓
Show password reset dialog
        ↓
User enters:
├─ Master recovery code: "ADMIN@RESET"
├─ New password
└─ Confirm password
        ↓
Validate:
├─ Recovery code matches
├─ Password ≥ 6 characters
└─ Both passwords match
        ↓
ALL VALID ↓
DatabaseHelper.resetAdminPassword(newPassword)
        ├─ Hash new password with PasswordUtils.hashPassword()
        ├─ Update "admin" box entry
        └─ passwordHash = newHash
        ↓
Success message shown
        ↓
Dialog closes
        ↓
Admin can login with new password
```

---

## File Responsibility Matrix

| File | Responsibility |
|------|-----------------|
| `main.dart` | App initialization, Hive setup, default data creation |
| `database/database_helper.dart` | All database operations, CRUD for all models |
| `utils/session_manager.dart` | Login session persistence and retrieval |
| `utils/password_utils.dart` | Password hashing and verification |
| `models/student.dart` | Student and ScoreHistory data structures |
| `models/category.dart` | Category data structure |
| `models/question.dart` | Question data structure |
| `screens/home_screen.dart` | App landing page, navigation entry |
| `screens/admin_login_screen.dart` | Admin authentication |
| `screens/admin_dashboard_screen.dart` | Admin main menu |
| `screens/category_management_screen.dart` | Category CRUD UI |
| `screens/question_management_screen.dart` | Question CRUD UI |
| `screens/add_edit_question_screen.dart` | Question form |
| `screens/add_category_screen.dart` | Category form |
| `screens/student_login_screen.dart` | Student authentication |
| `screens/student_registration_screen.dart` | Student account creation |
| `screens/student_dashboard_screen.dart` | Student main menu |
| `screens/category_selection_screen.dart` | Quiz category picker |
| `screens/quiz_screen.dart` | Quiz interface with questions and answers |
| `screens/result_screen.dart` | Quiz results display and score storage |

---

## Key Implementation Details

### 1. Password Security
- Uses SHA-256 hashing algorithm
- Passwords NEVER stored in plain text
- Verification compares hashes, not passwords

### 2. Session Persistence
- Uses Hive for persistent storage
- Sessions survive app restarts
- Checked on app start (login screens)
- Can be manually cleared via logout

### 3. Unique Identifiers
- Student/Question IDs: Generated from `DateTime.now().millisecondsSinceEpoch`
- Category IDs: Static format `cat_1`, `cat_2`, etc.
- ScoreHistory IDs: Timestamp-based

### 4. Data Validation
- Form validation in every input screen
- Duplicate email check for student registration
- Duplicate category name check
- All required fields validated

### 5. Error Handling
- Try-catch blocks in database operations
- User-friendly error messages
- SnackBar notifications for feedback

---

## API Reference for Developers

### To add a new question programmatically:
```dart
final question = Question(
  questionText: 'What is Flutter?',
  optionA: 'A programming language',
  optionB: 'A framework',
  optionC: 'A database',
  optionD: 'An IDE',
  correctAnswer: 'B',
  category: 'General Knowledge',
);
await DatabaseHelper.instance.createQuestion(question);
```

### To check student login:
```dart
final isLoggedIn = await SessionManager.instance.isStudentLoggedIn();
if (isLoggedIn) {
  final studentId = await SessionManager.instance.getLoggedInStudentId();
}
```

### To get quiz scores for a student:
```dart
final scores = await DatabaseHelper.instance.getStudentScores(studentId);
for (var score in scores) {
  print('${score.category}: ${score.percentage}%');
}
```

---

## Summary

This Quiz App is a complete educational platform with:
- **Admin Controls**: Manage quiz content (categories and questions)
- **Student Features**: Register, login, take quizzes, view history
- **Secure Storage**: Hive database with encrypted passwords
- **Session Management**: Persistent login sessions
- **Real-time Feedback**: Immediate quiz result evaluation
- **Score Tracking**: Complete quiz history for each student

The architecture is modular, scalable, and maintains clear separation of concerns between database, business logic, and UI layers.
