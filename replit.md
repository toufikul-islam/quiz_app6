# Quiz App

## Overview
A Flutter web application for creating and taking quizzes. The app allows users to:
- Add, edit, and delete quiz questions (admin only)
- Take quizzes with multiple-choice questions
- View quiz results with scoring
- Student registration and login with score history tracking

## Project Information
- **Framework**: Flutter 3.32.0 / Dart 3.8.0
- **Database**: Hive (local storage with IndexedDB for web)
- **Security**: SHA-256 password hashing using crypto package
- **Type**: Single-page web application
- **Import Date**: November 9, 2025

## Project Structure
- `lib/` - Flutter application code
  - `main.dart` - App entry point with admin initialization
  - `models/` - Data models (Question, Student, ScoreHistory)
  - `screens/` - UI screens (Home, Quiz, Results, Question Management, Student Dashboard)
  - `database/` - Hive database helper with student and score management
  - `utils/` - Utility functions (password hashing)
- `web/` - Web-specific assets and configuration
- `build/web/` - Compiled web application (production build)

## Development
The app runs on port 5000 using Python's HTTP server to serve the built Flutter web app.

### Running the App
The workflow automatically:
1. Serves the production build from `build/web/` directory
2. Runs on http://0.0.0.0:5000

### Rebuilding
To rebuild the Flutter web app after making changes:
```bash
flutter build web --release
```
The workflow will automatically serve the updated build.

## Features
- **Admin Authentication**: Secure login system for question management with hashed passwords
- **Student System**: Complete student registration and login with profile management
- **Password Security**: All passwords stored as SHA-256 hashes using crypto package
- **Category Management**: Questions organized by categories (Music, Food, General Knowledge, Sports, Science, History)
- **Question Management**: Add, edit, and delete quiz questions with 4 multiple-choice options
  - Questions displayed grouped by category
  - Each category shows question count
  - Easy update and delete options for each question
- **Student Dashboard**: Personal dashboard showing score history
- **Score Tracking**: All quiz attempts recorded with date, category, and score
- **Category Selection**: Users select a category before starting the quiz
- **Quiz Taking**: Interactive quiz interface with option selection filtered by chosen category
- **Result Display**: Score calculation and results screen with "Try Again" button
- **Login Required**: Users must be registered and logged in to take quizzes
- **Home Navigation**: Every page has a home button for easy navigation back to the main screen
- **Local Storage**: All data persists using Hive database (IndexedDB in web browsers)

## Database
Uses Hive for local storage, which works seamlessly in web browsers using IndexedDB. Database boxes:
- `questions` - Quiz questions with categories
- `students` - Student profiles with hashed passwords
- `scores` - Quiz score history for each student
- `admin` - Admin credentials with hashed password

## User Roles

### Students
- Register with name, email, address, phone, and password
- Login to personal dashboard
- View score history across all categories
- Take category-based quizzes with score tracking
- All quiz results saved to history

### Administrators
- Login with admin credentials
- Add, edit, and delete quiz questions
- Organize questions by category

## Deployment
Configured for Replit autoscale deployment:
- Build step: `flutter build web --release`
- Run step: `python -m http.server 5000 --directory build/web`

## User Flow

### Student Flow
1. **Home Screen**: Choose "Student Login" or "Register"
2. **Registration**: Enter name, email, address, phone, and password
3. **Login**: Enter email and password
4. **Dashboard**: View score history, start new quiz
5. **Category Selection**: Choose a category to quiz on
6. **Quiz**: Answer questions from the selected category
7. **Results**: View score (saved automatically), try again or return to dashboard

### Admin Flow
1. **Home Screen**: Click "Manage Questions"
2. **Admin Login**: Enter admin credentials
3. **Question Management**: View all questions grouped by category
4. **Add/Edit Question**: Select category, enter question text, options, and correct answer

### Start Quiz (Login Required)
1. **Home Screen**: Click "Start Quiz"
2. **Login**: If already registered, enter email and password
3. **Register**: If new user, register first then login
4. **Dashboard**: View score history and click "Start Quiz"
5. **Category Selection**: Choose a category
6. **Quiz**: Answer questions
7. **Results**: View score (saved automatically), try again or return to dashboard

## Authentication
- **Admin Credentials**:
  - Username: `admin`
  - Password: `admin123`
- **Password Storage**: All passwords stored as SHA-256 hashes
- Note: These are demo credentials. For production use, implement proper authentication.

## Categories
The app supports the following categories:
- General Knowledge
- Music
- Food
- Sports
- Science
- History

## Documentation
See `DOCUMENTATION.md` for comprehensive app documentation including:
- Detailed screen descriptions
- Database structure and connections
- Navigation flow diagrams
- Authentication flows
- Data models

### Student Profile Features (Added Feb 2026)
- **Profile Icon**: Added to student dashboard beside logout icon.
- **Profile Photo Upload**: Students can now upload a profile photo from their gallery.
- **Base64 Storage**: Profile photos are base64-encoded and stored in Firestore/Hive.
- **Default Icon**: Shows a user icon if no photo is uploaded.
- **Change Password**: Added option for students to change their password from the profile menu.

## Recent Changes
- **Feb 25, 2026**: Added profile management to student dashboard.
  - Updated `Student` model with `profileImageUrl`.
  - Added `updateStudentProfile` and `updateStudentPassword` to `DatabaseHelper`.
  - Implemented profile settings menu with photo upload and password change in `StudentDashboardScreen`.
  - Added `image_picker` dependency.

- **Dec 13, 2025**: Dynamic category management
  - Added Category model and database box for storing categories
  - Created Admin Dashboard with two options: Manage Categories and Manage Questions
  - Created Category Management screen (add, edit, delete categories)
  - Home screen now shows only Admin Panel and Start Quiz
  - Admin Login now leads to Admin Dashboard
  - Question creation uses dynamic categories from database
  - Category renaming cascades to all associated questions
  - Default categories: Math, Science, History, Geography, General Knowledge

- **Dec 11, 2025**: Home page cleanup
  - Removed Students section from home page (redundant with Start Quiz)
  - Home page now shows only Administrator and Start Quiz sections

- **Dec 3, 2025**: Quiz login requirement and navigation improvements
  - Removed quick quiz feature - all quizzes now require login
  - Added home button to every page for easy navigation
  - "Start Quiz" now redirects to login page
  - Quiz screens show confirmation dialog before leaving

- **Dec 3, 2025**: Student system and security enhancements
  - Added SHA-256 password hashing using crypto package
  - Implemented student registration with profile fields (name, email, address, phone)
  - Added student login and authentication
  - Created student dashboard with score history
  - Added score tracking for all student quiz attempts
  - Implemented student-specific quiz flow
  - Added "Try Again" button to result screens
  - Updated home screen with Students, Administrator, and Quick Quiz sections
  - Admin credentials now stored with hashed password

- **Nov 9, 2025**: Enhanced features added
  - Added admin authentication for question management
  - Implemented category-based quiz system
  - Updated Question model to include category field
  - Enhanced question management UI with category grouping
  - Added category selection screen for quiz
  - Updated database helper with category filtering
  - All existing questions default to "General Knowledge" category
  
- **Nov 9, 2025**: Initial setup in Replit environment
  - Installed Flutter and dependencies
  - Built production web version
  - Configured workflow to serve on port 5000
  - Set up deployment configuration
