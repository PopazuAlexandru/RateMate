# RateMate
# Alexandra Negut 1231EC
# George Alexandru Popazu 1231EC
RateMate is a mobile application built with Flutter and Hive, designed as a social review platform where users can rate and review other people in a structured and moderated environment. The app focuses on simplicity, offline functionality, and user interaction through ratings, comments, and social connections.

Key Screens & Features:
Authentication (Login / Sign-Up):
A simple authentication system that allows users to create accounts and log in using email and password. User sessions are persisted locally, enabling automatic login on app restart.
Home Dashboard:
The main screen of the application where users can view their profile summary, including average rating and descriptive tags. It also provides access to search functionality, user lists, and navigation to other core features.
User Search & Filtering:
Users can search for other profiles by name and apply filters such as rating range or following status. This allows efficient discovery of users within the app.
Review System:
Users can leave ratings (1–5 stars) and written reviews for other users. Reviews are stored locally and linked to target users, contributing to their overall rating.
My Reviews Screen:
Displays all reviews received by the current user, allowing them to see feedback from others in a centralized view.
Social Features (Following System):
Users can follow or unfollow others, creating a simple social network structure. This relationship is reflected in both follower and following lists.
Admin & Moderation System:
The application includes role-based functionality where admin users can manage the platform by approving or deleting reviews or blocking users. 
Local Data Storage (Hive):
All data, including users, reviews, and session state, is stored locally using Hive, a lightweight NoSQL database. This enables the app to function fully offline without requiring a backend server.
