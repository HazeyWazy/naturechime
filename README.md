# NatureChime - Mobile Application

NatureChime is a Flutter-based mobile application that empowers users to capture, organise, and share natural sounds and soundscapes from their environment.

## Overview

### Purpose

NatureChime aims to create a community of sound enthusiasts who can:

- Record and preserve natural soundscapes
- Share their audio discoveries with others
- Explore sounds from different locations and environments
- Build personal collections of environmental audio

### Target Audience

- Nature enthusiasts and field recordists
- Environmental researchers and scientists
- Sound designers and audio professionals
- General users interested in natural sounds

### Key Differentiators

- High-quality audio recording with custom parameters
- Manual location tagging for each recording
- Comprehensive sound organization system
- Cross-platform compatibility (iOS and Android)

## Project Architecture

### Directory Structure

```
lib/
├── firebase_options.dart     # Firebase configuration and setup
├── main.dart                # Application entry point and initialization
├── models/                  # Data models and state management
│   ├── recording_model.dart # Sound recording data structure
│   └── user_model.dart      # User profile and settings
screens/
│   └──  welcome_screen.dart      # Landing page with auth options
│   └── create_account_screen.dart # New user registration
│   └──  login_screen.dart       # User authentication
│   └── main_screen.dart        # Main navigation container
│   └── home_screen.dart        # Dashboard view
│   └── library_screen.dart     # Recordings collection
│   └── explore_screen.dart     # Discover other recordings
│   └── record_screen.dart      # Audio recording interface
│   └── profile_screen.dart     # User profile management
│   └── playback_screen.dart    # Audio playback interface
├── services/               # Business logic and external services
│   ├── auth_service.dart   # Authentication handling
├── utils/                  # Utility functions and helpers
│   ├── theme.dart          # Application theming
│   ├── validators.dart     # Input validation
└── widgets/               # Reusable UI components
```

### Architecture Pattern

The application follows a layered architecture pattern:

1. **Presentation Layer** (screens/, widgets/)

   - Handles UI rendering and user interaction
   - Manages screen state and navigation
   - Implements responsive design

2. **Business Logic Layer** (services/)

   - Processes application logic
   - Manages data operations
   - Handles external service integration

3. **Data Layer** (models/)
   - Defines data structures
   - Implements data validation
   - Manages state persistence

## Core Components

### Main Application (`main.dart`)

- Initialises Firebase and environment variables
- Sets up the application theme and providers
- Handles authentication state management
- Routes to either WelcomeScreen or MainScreen based on auth state

### Screens

#### Authentication Screens

- **WelcomeScreen**: Initial landing page with app features and authentication options
- **LoginScreen**: Email/password and Google sign-in functionality
- **CreateAccountScreen**: New user registration with profile picture upload
  - **Difference from Design:** Added a note under the username field stating _"You cannot change it later."_

#### Main Application Screens

- **MainScreen**: Container for the main navigation tabs

  - **Difference from Design:** The AppBar originally designed to include a profile picture icon on the right side has been omitted in the final implementation.

- **HomeScreen**: Dashboard with quick access to recent recordings
- **LibraryScreen**: Personal collection of recorded sounds
- **ExploreScreen**: Discover and browse other users' recordings
- **RecordScreen**: Audio recording interface
- **ProfileScreen**: User profile management and settings
  - **Difference from Design:**
    - The _Edit Profile_ button was replaced with an **Edit Profile Picture** button.
    - The _Favourites_ functionality was removed from this screen.
    - Account management buttons (such as _Log out_, _Delete account_, etc.) are centered on the screen rather than left-aligned as originally planned.

### Services

- **AuthService**: Handles user authentication, including:
  - Email/Password authentication
  - Google Sign-in
  - Password reset
  - Account management
  - Profile updates

### Features

1. **Authentication**

   - Email/Password login
   - Google Sign-in integration
   - Password reset functionality
   - Account creation with profile picture

2. **Sound Recording**

   - Record audio from device
   - Location tagging
   - Custom naming and organization

3. **Library Management**

   - Organize recordings
   - Playback functionality
   - Delete/Edit capabilities

4. **User Profile**
   - Profile picture management
   - Account settings
   - Privacy controls

## Technical Implementation

### State Management

- Uses Provider for state management
- ChangeNotifier for authentication state

### Firebase Integration

#### Authentication (Firebase Auth)

- Email/password authentication with validation
- Google Sign-In OAuth integration
- Secure token management and refresh
- User session persistence

#### Data Storage (Cloud Firestore)

- User profiles and preferences
- Recording metadata and information
- Social interactions and relationships
- Location data for recordings
- Optimized queries with indexing

#### Media Storage (Cloudinary)

- Audio file storage with compression
- Profile image storage and optimisation
- Secure access control

### Theme System

#### Design Language

- Material Design 3 implementation
- Consistent component styling
- Typography system with scale
- Responsive layout adaptations

#### Color Schemes

- Dynamic color generation from seed
- Light and dark theme variants
- Accessibility-compliant contrast
- Brand color integration

#### Custom Components

- Styled audio player interface
- Recording visualisation elements
- Custom navigation components
- Branded input elements
- Responsive containers

### Navigation

- Bottom navigation bar for main sections
- CupertinoPageRoute for smooth transitions
- Proper state maintenance during navigation

## Development Guidelines

### Code Standards

- Follows Flutter's official style guide
- Consistent naming conventions

### Testing Strategy

1. **Unit Tests**

   - Business logic validation
   - Model behavior verification
   - Service method testing
   - Utility function coverage

2. **Widget Tests**

   - Component rendering verification
   - User interaction simulation
   - State management testing
   - Navigation flow validation

### Error Handling

- Comprehensive error catching
- User-friendly error messages
- Graceful degradation
- Crash reporting integration
- Network error management

### Performance Considerations

- Lazy loading implementation
- Image and audio optimisation
- Memory management
- Battery usage optimisation
- Caching strategies

### Security Measures

- Secure data transmission
- Input sanitisation
- Authentication token management
- File access control
- API key protection

### Environment Setup & Configuration

To run this project, you will need to perform a one-time setup for API credentials.

**1. Prerequisites:**

- Ensure you have Flutter installed. For guidance, see the [official Flutter installation guide](https://flutter.dev/docs/get-started/install).
- An IDE like VS Code or Android Studio with the Flutter plugin.

**2. Clone the Repository:**

```bash
git clone https://github.com/MQ-COMP3130/mobile-application-development-HazeyWazy.git
cd naturechime
```

**3. Configure Cloudinary API Credentials (.env file):**

The application uses Cloudinary for storing recorded audio files. You need to provide API credentials for this service via an environment file.

- In the root directory of the project (alongside `pubspec.yaml`), create a new file named exactly `.env`.
- You will need to populate the `.env` file with the following Cloudinary credentials:

  - `CLOUDINARY_CLOUD_NAME=`
  - `CLOUDINARY_UPLOAD_PRESET=`

**Please use the following values provided for marking purposes:**

```
CLOUDINARY_CLOUD_NAME=dogct8rpj
CLOUDINARY_UPLOAD_PRESET=NCRecordings
CLOUDINARY_PROFILE_UPLOAD_PRESET=NCProfilePics
```

**4. Install Dependencies:**
Open your terminal in the project root and run:

```bash
flutter pub get
```

**5. Run the App:**

```bash
flutter run
```

**Firebase Usage:**
This application uses Firebase for user authentication and storing recording metadata. The necessary Firebase project configuration files (`lib/firebase_options.dart`, `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`) are included in the repository, so no additional Firebase setup (like `flutterfire configure`) is required by you to run the app. Ensure you have an active internet connection in emulator for Firebase services to work.
