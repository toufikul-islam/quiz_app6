# Quiz App Documentation

## Overview

The Quiz App is a Flutter web application that allows students to take quizzes across different categories while tracking their scores. Administrators can manage quiz questions through a dedicated admin panel.

**Key Features:**
- Student registration and login with secure password hashing
- Categorized quizzes (Math, Science, History, Geography, General Knowledge)
- Score tracking and quiz history for each student
- Admin panel for adding, editing, and deleting questions
- Home navigation from every screen

---

## App Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         main.dart                                │
│                    (App Entry Point)                             │
│         - Initializes Hive database                              │
│         - Seeds admin credentials                                │
│         - Launches HomeScreen                                    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                       HomeScreen                                 │
│                    (Main Landing Page)                           │
│         - Administrator section → Admin Login                    │
│         - Start Quiz section → Student Login                     │
└─────────────────────────────────────────────────────────────────┘
                    │                    │
        ┌───────────┘                    └───────────┐
        ▼                                            ▼
┌───────────────────┐                    ┌───────────────────────┐
│   Admin Flow      │                    │    Student Flow       │
└───────────────────┘                    └───────────────────────┘
```

---

## Screens Guide

### 1. Home Screen
**File:** `lib/screens/home_screen.dart`

**Purpose:** Main landing page of the app

**Features:**
- Welcome message with app branding
- Administrator section with "Manage Questions" button
- Start Quiz section for students to login/register

**Navigation:**
- "Manage Questions" → Admin Login Screen
- "Start Quiz" → Student Login Screen

---

### 2. Student Login Screen
**File:** `lib/screens/student_login_screen.dart`

**Purpose:** Authenticate existing students

**Features:**
- Email and password input fields
- Login button with validation
- Link to registration for new students
- Home button to return to main page

**Database Connection:**
- Reads from `students` box to verify credentials
- Uses SHA-256 password hashing for security

**Navigation:**
- Successful login → Student Dashboard
- "Register" link → Student Registration Screen
- Home button → Home Screen

---

### 3. Student Registration Screen
**File:** `lib/screens/student_registration_screen.dart`

**Purpose:** Create new student accounts

**Features:**
- Name, email, and password input fields
- Password confirmation
- Form validation
- Home button

**Database Connection:**
- Writes new student to `students` box
- Passwords are hashed before storage

**Navigation:**
- Successful registration → Student Login Screen
- Home button → Home Screen

---

### 4. Student Dashboard Screen
**File:** `lib/screens/student_dashboard_screen.dart`

**Purpose:** Student's personal hub after logging in

**Features:**
- Welcome message with student's name
- "Start Quiz" button to begin a new quiz
- Quiz history showing past attempts with scores
- Logout functionality
- Home button

**Database Connection:**
- Reads from `scores` box to display quiz history
- Filters scores by current student's email

**Navigation:**
- "Start Quiz" → Category Selection Screen
- Logout → Home Screen
- Home button → Home Screen

---

### 5. Category Selection Screen
**File:** `lib/screens/category_selection_screen.dart`

**Purpose:** Choose a quiz category

**Features:**
- Grid of category cards with icons:
  - Math (calculator icon)
  - Science (science icon)
  - History (history icon)
  - Geography (globe icon)
  - General Knowledge (lightbulb icon)
- Home button

**Database Connection:**
- Reads from `questions` box to check available questions per category

**Navigation:**
- Category card → Quiz Screen (for that category)
- Home button → Home Screen

---

### 6. Quiz Screen
**File:** `lib/screens/quiz_screen.dart`

**Purpose:** Display quiz questions and collect answers

**Features:**
- Shows one question at a time
- Multiple choice answers (4 options)
- Question counter (e.g., "Question 3 of 10")
- Progress indicator
- Next/Submit button
- Home button (with confirmation dialog)

**Database Connection:**
- Reads questions from `questions` box filtered by category
- Shuffles and limits to 10 questions per quiz

**Navigation:**
- After last question → Result Screen
- Home button (with confirmation) → Home Screen

---

### 7. Result Screen
**File:** `lib/screens/result_screen.dart`

**Purpose:** Show quiz results after completion

**Features:**
- Score display (e.g., "8/10")
- Percentage score
- Performance message (Excellent/Good/Keep Practicing)
- Visual score indicator
- "Back to Dashboard" button
- Home button

**Database Connection:**
- Writes score to `scores` box (if student is logged in)
- Stores: student email, category, score, total questions, date

**Navigation:**
- "Back to Dashboard" → Student Dashboard
- Home button → Home Screen

---

### 8. Admin Login Screen
**File:** `lib/screens/admin_login_screen.dart`

**Purpose:** Authenticate administrator access

**Features:**
- Username and password fields
- Login button
- Home button

**Default Credentials:**
- Username: `admin`
- Password: `admin123`

**Database Connection:**
- Reads from `admin` box to verify credentials

**Navigation:**
- Successful login → Question Management Screen
- Home button → Home Screen

---

### 9. Question Management Screen
**File:** `lib/screens/question_management_screen.dart`

**Purpose:** Admin panel to view and manage all questions

**Features:**
- List of all questions grouped by category
- Filter by category dropdown
- Add new question button (FAB)
- Edit button for each question
- Delete button with confirmation
- Home button

**Database Connection:**
- Reads all questions from `questions` box
- Deletes questions from `questions` box

**Navigation:**
- Add button (FAB) → Add Question Screen
- Edit button → Add Question Screen (edit mode)
- Home button → Home Screen

---

### 10. Add/Edit Question Screen
**File:** `lib/screens/add_question_screen.dart`

**Purpose:** Create new questions or edit existing ones

**Features:**
- Question text input
- Category dropdown selector
- Four answer option fields
- Correct answer selector
- Save button
- Home button

**Database Connection:**
- Writes new questions to `questions` box
- Updates existing questions in `questions` box

**Navigation:**
- Save → Question Management Screen
- Home button → Home Screen

---

## Database Structure

The app uses **Hive** database with **IndexedDB** adapter for web storage. Data persists in the browser's IndexedDB.

### Database Boxes (Tables)

#### 1. `students` Box
Stores registered student accounts.

| Field | Type | Description |
|-------|------|-------------|
| name | String | Student's full name |
| email | String | Unique email (used as key) |
| password | String | SHA-256 hashed password |

#### 2. `questions` Box
Stores quiz questions.

| Field | Type | Description |
|-------|------|-------------|
| id | String | Unique question ID (UUID) |
| question | String | Question text |
| options | List<String> | Four answer options |
| correctAnswer | int | Index of correct option (0-3) |
| category | String | Question category |

#### 3. `scores` Box
Stores quiz attempt history.

| Field | Type | Description |
|-------|------|-------------|
| id | String | Unique score ID |
| studentEmail | String | Email of student who took quiz |
| category | String | Quiz category |
| score | int | Number of correct answers |
| totalQuestions | int | Total questions in quiz |
| date | DateTime | When quiz was taken |

#### 4. `admin` Box
Stores admin credentials.

| Field | Type | Description |
|-------|------|-------------|
| username | String | Admin username |
| password | String | Admin password (plain text) |

---

## Database Helper

**File:** `lib/database/database_helper.dart`

The `DatabaseHelper` class is the central data access layer. All screens interact with the database through this class.

### Key Methods:

```dart
// Student Operations
Future<void> registerStudent(Student student)
Future<Student?> loginStudent(String email, String password)
Future<bool> isEmailRegistered(String email)

// Question Operations
Future<void> addQuestion(Question question)
Future<void> updateQuestion(Question question)
Future<void> deleteQuestion(String id)
Future<List<Question>> getAllQuestions()
Future<List<Question>> getQuestionsByCategory(String category)

// Score Operations
Future<void> saveScore(ScoreHistory score)
Future<List<ScoreHistory>> getStudentScores(String email)

// Admin Operations
Future<bool> adminLogin(String username, String password)
```

---

## Data Models

### Student Model
**File:** `lib/models/student.dart`

```dart
class Student {
  final String name;
  final String email;
  final String password; // Hashed
}
```

### Question Model
**File:** `lib/models/question.dart`

```dart
class Question {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String category;
}
```

### Score Model
**File:** `lib/models/score.dart`

```dart
class ScoreHistory {
  final String id;
  final String studentEmail;
  final String category;
  final int score;
  final int totalQuestions;
  final DateTime date;
}
```

---

## Navigation Flow Diagram

```
                              ┌──────────────┐
                              │  HomeScreen  │
                              └──────┬───────┘
                                     │
              ┌──────────────────────┴──────────────────────┐
              │                                              │
              ▼                                              ▼
    ┌─────────────────┐                           ┌─────────────────┐
    │  Admin Login    │                           │ Student Login   │
    └────────┬────────┘                           └────────┬────────┘
             │                                             │
             │                                    ┌────────┴────────┐
             │                                    │                 │
             ▼                                    ▼                 ▼
    ┌─────────────────┐                 ┌─────────────────┐  ┌──────────────┐
    │   Question      │                 │    Student      │  │  Student     │
    │   Management    │                 │   Dashboard     │  │ Registration │
    └────────┬────────┘                 └────────┬────────┘  └──────────────┘
             │                                   │
             ▼                                   ▼
    ┌─────────────────┐                 ┌─────────────────┐
    │  Add/Edit       │                 │    Category     │
    │  Question       │                 │   Selection     │
    └─────────────────┘                 └────────┬────────┘
                                                 │
                                                 ▼
                                        ┌─────────────────┐
                                        │   Quiz Screen   │
                                        └────────┬────────┘
                                                 │
                                                 ▼
                                        ┌─────────────────┐
                                        │  Result Screen  │
                                        └─────────────────┘
```

---

## Authentication Flow

### Student Authentication

```
1. Student enters email/password on Login Screen
                    │
                    ▼
2. Password is hashed using SHA-256 (password_utils.dart)
                    │
                    ▼
3. DatabaseHelper.loginStudent() queries 'students' box
                    │
                    ▼
4. Compares hashed password with stored hash
                    │
          ┌─────────┴─────────┐
          │                   │
     Match Found         No Match
          │                   │
          ▼                   ▼
   Navigate to          Show error
   Dashboard            message
```

### Admin Authentication

```
1. Admin enters username/password on Admin Login Screen
                    │
                    ▼
2. DatabaseHelper.adminLogin() queries 'admin' box
                    │
                    ▼
3. Compares credentials directly (no hashing)
                    │
          ┌─────────┴─────────┐
          │                   │
     Match Found         No Match
          │                   │
          ▼                   ▼
   Navigate to          Show error
   Question Mgmt        message
```

---

## Key Files Summary

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry point, Hive initialization, admin seeding |
| `lib/database/database_helper.dart` | All database operations |
| `lib/models/student.dart` | Student data model |
| `lib/models/question.dart` | Question data model |
| `lib/models/score.dart` | Score history data model |
| `lib/utils/password_utils.dart` | SHA-256 password hashing |
| `lib/screens/home_screen.dart` | Main landing page |
| `lib/screens/student_login_screen.dart` | Student authentication |
| `lib/screens/student_registration_screen.dart` | New student signup |
| `lib/screens/student_dashboard_screen.dart` | Student's personal area |
| `lib/screens/category_selection_screen.dart` | Quiz category picker |
| `lib/screens/quiz_screen.dart` | Quiz questions display |
| `lib/screens/result_screen.dart` | Quiz results display |
| `lib/screens/admin_login_screen.dart` | Admin authentication |
| `lib/screens/question_management_screen.dart` | Question list/management |
| `lib/screens/add_question_screen.dart` | Add/edit questions |
| `pubspec.yaml` | Dependencies configuration |

---

## Dependencies

| Package | Purpose |
|---------|---------|
| `hive` | NoSQL database |
| `hive_flutter` | Hive Flutter integration |
| `crypto` | SHA-256 password hashing |
| `uuid` | Unique ID generation |

---

## Categories

The app supports these quiz categories:
1. **Math** - Mathematical problems and calculations
2. **Science** - Scientific concepts and facts
3. **History** - Historical events and figures
4. **Geography** - Countries, capitals, landmarks
5. **General Knowledge** - Miscellaneous trivia

---

## Security Features

1. **Password Hashing:** Student passwords are hashed using SHA-256 before storage
2. **No Plain Text Passwords:** Passwords are never stored in readable form for students
3. **Session-based Access:** Students must login to access dashboard and take quizzes
4. **Admin Separation:** Admin has separate login and cannot access student features

---

## Browser Storage

Data is stored in the browser's **IndexedDB** under Hive database boxes. This means:
- Data persists between sessions
- Data is specific to each browser
- Clearing browser data will reset all app data
- Different browsers/devices have separate data
