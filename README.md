# RateMate
## Alexandra Negut 1231EC
## George Alexandru Popazu 1231EC

## Project Description
**RateMate** is a mobile application built with Flutter and Hive, designed as a social review platform where users can rate and review other people in a structured and moderated environment. The app focuses on simplicity, offline functionality, and user interaction through ratings, comments, and social connections.

## Technical Stack

RateMate is built on a modern, high-performance architecture designed for speed and offline reliability.

*   **Flutter (UI Framework)**: Leveraged for high-performance, cross-platform mobile development with a consistent look and feel.
*   **Dart (Logic Layer)**: The primary programming language used to drive the application's core business logic.
*   **Hive (Local NoSQL Database)**: A lightweight, lightning-fast key-value database that handles local data storage and offline persistence.
*   **path_provider**: Manages secure access to the mobile device's file system for reliable data management.
*   **UUID**: Ensures every user, review, and entry has a distinct, unique identifier to maintain data integrity.
*   **Provider / ChangeNotifier**: Implements a reactive state management pattern to ensure the UI updates instantly as data changes.

### Key Screens & Features:
* **Authentication (Login / Sign-Up):** A simple authentication system that allows users to create accounts and log in using email and password. User sessions are persisted locally, enabling automatic login on app restart.
* **Home Dashboard:** The main screen of the application where users can view their profile summary, including average rating and descriptive tags. It also provides access to search functionality, user lists, and navigation to other core features.
* **User Search & Filtering:** Users can search for other profiles by name and apply filters such as rating range or following status. This allows efficient discovery of users within the app.
* **Review System:** Users can leave ratings (1–5 stars) and written reviews for other users. Reviews are stored locally and linked to target users, contributing to their overall rating.
* **My Reviews Screen:** Displays all reviews received by the current user, allowing them to see feedback from others in a centralized view.
* **Social Features (Following System):** Users can follow or unfollow others, creating a simple social network structure. This relationship is reflected in both follower and following lists.
* **Admin & Moderation System:** The application includes role-based functionality where admin users can manage the platform by approving or deleting reviews or blocking users. 
* **Local Data Storage (Hive):** All data, including users, reviews, and session state, is stored locally using Hive, a lightweight NoSQL database. This enables the app to function fully offline without requiring a backend server.

### Project Structure
```
lib/
├── screens/                  # Application UI pages
│   ├── admin_screen.dart     # Admin & moderation hub
│   ├── auth_screen.dart      # Login & Sign-up logic
│   ├── home_screen.dart      # Main dashboard & user discovery
│   ├── my_reviews_screen.dart # Personal feedback view
│   └── profile_screen.dart   # User profile details
├── main.dart                 # App entry point & Hive setup
└── main.g.dart               # Generated Hive adapters
```

## Visuals

### Authentication Flow
| Log In | Sign Up |
| :---: | :---: |
| <img src="https://github.com/user-attachments/assets/376424f9-9553-4d1c-975f-0526fd017025" width="250"> | <img src="https://github.com/user-attachments/assets/6f9b8aa0-ca93-4f3a-a1d7-7fb7a64bc527" width="250"> |

### Core Experience
| Main Dashboard | Admin Panel | Review Page |
| :---: | :---: | :---: |
| <img src="https://github.com/user-attachments/assets/5c11da2b-05d6-46cf-a1c0-7df598ec426d" width="250"> | <img src="https://github.com/user-attachments/assets/8757a9ee-787b-49e9-aae6-ee89a36cb92d" width="250"> | <img src="https://github.com/user-attachments/assets/ec296885-7ac1-4b16-8468-e03b41e53328" width="250" />

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.







