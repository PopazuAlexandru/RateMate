# App Requirements - RateMate

RateMate is a social networking Android application focused on peer-to-peer feedback. It allows users to search for friends and leave anonymous textual reviews accompanied by a numerical rating.

- **Feature 1: User Authentication System**
    - Secure user registration and login.
    - User profile management (UserID, Name, Email).
- **Feature 2: Anonymous Peer Review Engine**
    - Searchable user directory to find "friends" by name.
    - Review submission system: Text-based feedback + 1-5 star rating.
    - Identity masking: Submissions must be linked to a TargetUserID but remain anonymous to the recipient.
- **UI/UX details:**
    - Social-media-inspired layout (Facebook-like feed or profile pages).
    - Review list view with aggregate star rating display.
    - Minimalist search bar for finding peer profiles.
- **Data model:**
    - **Users:** UUID, name, email, auth_credentials.
    - **Reviews:** ReviewID, target_user_id, rating (int 1-5), comment (string), timestamp.
- **Navigation:**
    - Auth Stack (Login/Sign-up) -> Home Screen (Search/Feed) -> User Profile (Submit/View Reviews).
- **Platforms:** Android

(This app's name is RateMate. It is a peer-rating social platform designed for academic project purposes.)