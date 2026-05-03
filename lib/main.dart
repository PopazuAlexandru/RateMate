import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

part 'main.g.dart';

// ============================================================================
// RATE MATE DESIGN TOKENS
// ============================================================================

class AppDesignTokens {
  // Typography
  static const double fontSize = 16.0;
  static const String fontFamily = 'Quicksand';
  static const FontWeight fontWeightMedium = FontWeight.w600;
  static const FontWeight fontWeightNormal = FontWeight.w400;
  static const String handwritingFont = 'Pacifico';

  // Primary Brand
  static const Color primary = Color(0xFF6366f1);
  static const Color primaryForeground = Color(0xFFffffff);

  // Backgrounds
  static const Color background = Color(0xFFffffff);
  static const Color card = Color(0xFFffffff);
  static const Color popover = Color(0xFFffffff);

  // Text
  static const Color foreground = Color(0xFF1a1a1a);
  static const Color cardForeground = Color(0xFF1a1a1a);
  static const Color mutedForeground = Color(0xFF6b7280);

  // Secondary & Muted
  static const Color secondary = Color(0xFFf3f4f6);
  static const Color secondaryForeground = Color(0xFF1a1a1a);
  static const Color muted = Color(0xFFf9fafb);
  static const Color accent = Color(0xFFe0e7ff);
  static const Color accentForeground = Color(0xFF1a1a1a);

  // Interactive Elements
  static const Color border = Color(0xFFe5e7eb);
  static const Color input = Colors.transparent;
  static const Color inputBackground = Color(0xFFf9fafb);
  static const Color switchBackground = Color(0xFFd1d5db);
  static const Color ring = Color(0xFF6366f1);

  // Ratings (Custom)
  static const Color starFilled = Color(0xFFfbbf24);
  static const Color starEmpty = Color(0xFFe5e7eb);

  // Destructive/Error
  static const Color destructive = Color(0xFFef4444);
  static const Color destructiveForeground = Color(0xFFffffff);

  // Success
  static const Color success = Color(0xFF22c55e);

  // Border Radius
  static const double radius = 1.0;
  static const double radiusSm = 0.75;
  static const double radiusMd = 0.875;
  static const double radiusLg = 1.0;
  static const double radiusXl = 1.25;

  // User Avatar Gradients
  static const List<List<Color>> avatarGradients = [
    [Color(0xFF3b82f6), Color(0xFF06b6d4)], // Blue-Cyan
    [Color(0xFFa855f7), Color(0xFFec4899)], // Purple-Pink
    [Color(0xFF22c55e), Color(0xFF14b8a6)], // Green-Teal
    [Color(0xFFf97316), Color(0xFFef4444)], // Orange-Red
    [Color(0xFF6366f1), Color(0xFFa855f7)], // Indigo-Purple
    [Color(0xFF6366f1), Color(0xFFa855f7)], // Primary (Alexandra)
  ];

  static LinearGradient getAvatarGradient(int index) {
    final colors = avatarGradients[index % avatarGradients.length];
    return LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(ReviewAdapter());
  Hive.registerAdapter(ReviewStatusAdapter());
  runApp(const RateMateApp());
}

final _uuid = Uuid();

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String email;
  @HiveField(3)
  final String password;
  @HiveField(4)
  final String? profilePicturePath;
  @HiveField(5)
  final List<String> tags;
  @HiveField(6)
  final List<String> followers;
  @HiveField(7)
  final List<String> following;
  @HiveField(8)
  final bool isAdmin;
  @HiveField(9)
  final bool isBlocked;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.profilePicturePath,
    List<String>? tags,
    List<String>? followers,
    List<String>? following,
    this.isAdmin = false,
    this.isBlocked = false,
  }) : tags = tags ?? [],
       followers = followers ?? [],
       following = following ?? [];
}

@HiveType(typeId: 1)
class Review {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String targetUserId;
  @HiveField(2)
  final String? submitterUserId;
  @HiveField(3)
  final int rating;
  @HiveField(4)
  final String comment;
  @HiveField(5)
  final DateTime timestamp;
  @HiveField(6)
  final ReviewStatus status;
  @HiveField(7)
  final String? moderatorNote;
  @HiveField(8)
  final String? tag;

  Review({
    required this.id,
    required this.targetUserId,
    this.submitterUserId,
    required this.rating,
    required this.comment,
    required this.timestamp,
    this.status = ReviewStatus.pending,
    this.moderatorNote,
    this.tag,
  });
}

@HiveType(typeId: 2)
enum ReviewStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  approved,
  @HiveField(2)
  rejected,
}

class AppData extends ChangeNotifier {
  late Box<User> _userBox;
  late Box<Review> _reviewBox;
  late Box<String> _currentUserBox;

  final List<User> _users = [];
  final List<Review> _reviews = [];

  User? currentUser;

  Future<void> init() async {
    _userBox = await Hive.openBox<User>('users');
    _reviewBox = await Hive.openBox<Review>('reviews');
    _currentUserBox = await Hive.openBox<String>('currentUser');
    _loadData();
  }

  @override
  void dispose() {
    _userBox.close();
    _reviewBox.close();
    _currentUserBox.close();
    super.dispose();
  }

  void _loadData() {
    _users.clear();
    _users.addAll(_userBox.values);
    _reviews.clear();
    _reviews.addAll(_reviewBox.values);

    final persistedUserId = _currentUserBox.get('id');
    if (persistedUserId != null) {
      final restoredUser = _users.firstWhere(
        (u) => u.id == persistedUserId,
        orElse: () => User(id: '', name: '', email: '', password: ''),
      );
      currentUser = restoredUser.id.isNotEmpty ? restoredUser : null;
    } else {
      currentUser = null;
    }

    notifyListeners();
  }

  Future<void> _saveUsers() async {
    await _userBox.clear();
    for (var user in _users) {
      await _userBox.put(user.id, user);
    }
  }

  Future<void> _saveReviews() async {
    try {
      await _reviewBox.clear();
      for (var review in _reviews) {
        await _reviewBox.put(review.id, review);
      }
    } catch (e) {
      // Data persistence error
    }
  }

  List<User> get users => List.unmodifiable(_users);
  List<Review> get reviews => List.unmodifiable(_reviews);

  // Logic Update: Helper for received reviews (used by MyReviewsScreen)
  List<Review> getReceivedReviews(String userId) {
    return _reviews.where((r) => r.targetUserId == userId).toList();
  }

  Future<bool> register(String name, String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (_users.any((u) => u.email.toLowerCase() == normalizedEmail)) {
      return false;
    }
    final newUser = User(
      id: _uuid.v4(),
      name: name.trim(),
      email: normalizedEmail,
      password: password,
    );
    _users.add(newUser);
    await _saveUsers();
    notifyListeners();
    return true;
  }

  bool login(String email, String password) {
    final user = _users.firstWhere(
      (u) =>
          u.email.toLowerCase() == email.trim().toLowerCase() &&
          u.password == password,
      orElse: () => User(id: '', name: '', email: '', password: ''),
    );
    if (user.id.isEmpty) return false;
    currentUser = user;
    _currentUserBox.put('id', user.id);
    notifyListeners();
    return true;
  }

  void logout() {
    currentUser = null;
    _currentUserBox.delete('id');
    notifyListeners();
  }

  Future<void> addReview(
    String reviewerId,
    String targetUserId,
    int rating,
    String comment,
    String? tag,
  ) async {
    _reviews.add(
      Review(
        id: _uuid.v4(),
        targetUserId: targetUserId,
        submitterUserId: reviewerId,
        rating: rating,
        comment: comment.trim(),
        timestamp: DateTime.now(),
        status: currentUser?.isAdmin == true
            ? ReviewStatus.approved
            : ReviewStatus.pending,
        tag: tag,
      ),
    );
    await _saveReviews();
    notifyListeners();
  }

  // User Management (Admin & Moderation)
  Future<void> deleteReview(String reviewId) async {
    _reviews.removeWhere((r) => r.id == reviewId);
    await _saveReviews();
    notifyListeners();
  }

  Future<void> blockUser(String userId, bool blocked) async {
    final userIndex = _users.indexWhere((u) => u.id == userId);
    if (userIndex != -1) {
      final user = _users[userIndex];
      final updatedUser = User(
        id: user.id,
        name: user.name,
        email: user.email,
        password: user.password,
        profilePicturePath: user.profilePicturePath,
        tags: user.tags,
        followers: user.followers,
        following: user.following,
        isAdmin: user.isAdmin,
        isBlocked: blocked,
      );
      _users[userIndex] = updatedUser;
      await _saveUsers();
      notifyListeners();
    }
  }

  Future<void> makeAdmin(String userId, bool isAdmin) async {
    final userIndex = _users.indexWhere((u) => u.id == userId);
    if (userIndex != -1) {
      final user = _users[userIndex];
      final updatedUser = User(
        id: user.id,
        name: user.name,
        email: user.email,
        password: user.password,
        profilePicturePath: user.profilePicturePath,
        tags: user.tags,
        followers: user.followers,
        following: user.following,
        isAdmin: isAdmin,
        isBlocked: user.isBlocked,
      );
      _users[userIndex] = updatedUser;
      await _saveUsers();
      notifyListeners();
    }
  }

  void toggleAdmin(String userId) {
    final userIndex = _users.indexWhere((u) => u.id == userId);
    if (userIndex != -1) {
      final user = _users[userIndex];
      makeAdmin(userId, !user.isAdmin);
    }
  }

  Future<void> deleteUser(String userId) async {
    _users.removeWhere((u) => u.id == userId);
    _reviews.removeWhere(
      (r) => r.targetUserId == userId || r.submitterUserId == userId,
    );
    await _saveUsers();
    await _saveReviews();
    notifyListeners();
  }

  // Profile Picture Management
  Future<void> updateProfilePicture(String userId, String? imagePath) async {
    final userIndex = _users.indexWhere((u) => u.id == userId);
    if (userIndex != -1) {
      final updatedUser = User(
        id: _users[userIndex].id,
        name: _users[userIndex].name,
        email: _users[userIndex].email,
        password: _users[userIndex].password,
        profilePicturePath: imagePath,
        tags: _users[userIndex].tags,
        followers: _users[userIndex].followers,
        following: _users[userIndex].following,
        isAdmin: _users[userIndex].isAdmin,
        isBlocked: _users[userIndex].isBlocked,
      );
      _users[userIndex] = updatedUser;
      await _saveUsers();
      if (currentUser?.id == userId) {
        currentUser = updatedUser;
      }
      notifyListeners();
    }
  }

  // User Tags Management
  Future<void> updateUserTags(String userId, List<String> tags) async {
    final userIndex = _users.indexWhere((u) => u.id == userId);
    if (userIndex != -1) {
      final updatedUser = User(
        id: _users[userIndex].id,
        name: _users[userIndex].name,
        email: _users[userIndex].email,
        password: _users[userIndex].password,
        profilePicturePath: _users[userIndex].profilePicturePath,
        tags: tags,
        followers: _users[userIndex].followers,
        following: _users[userIndex].following,
        isAdmin: _users[userIndex].isAdmin,
        isBlocked: _users[userIndex].isBlocked,
      );
      _users[userIndex] = updatedUser;
      await _saveUsers();
      if (currentUser?.id == userId) {
        currentUser = updatedUser;
      }
      notifyListeners();
    }
  }

  // Following System
  Future<void> followUser(String followerId, String targetUserId) async {
    if (followerId == targetUserId) return;

    final fIdx = _users.indexWhere((u) => u.id == followerId);
    final tIdx = _users.indexWhere((u) => u.id == targetUserId);

    if (fIdx != -1 && tIdx != -1) {
      final f = _users[fIdx];
      final t = _users[tIdx];

      if (!f.following.contains(targetUserId)) {
        _users[fIdx] = User(
          id: f.id,
          name: f.name,
          email: f.email,
          password: f.password,
          profilePicturePath: f.profilePicturePath,
          tags: f.tags,
          followers: f.followers,
          following: [...f.following, targetUserId],
          isAdmin: f.isAdmin,
          isBlocked: f.isBlocked,
        );
        _users[tIdx] = User(
          id: t.id,
          name: t.name,
          email: t.email,
          password: t.password,
          profilePicturePath: t.profilePicturePath,
          tags: t.tags,
          followers: [...t.followers, followerId],
          following: t.following,
          isAdmin: t.isAdmin,
          isBlocked: t.isBlocked,
        );
        await _saveUsers();
        if (currentUser?.id == followerId) currentUser = _users[fIdx];
        notifyListeners();
      }
    }
  }

  Future<void> unfollowUser(String followerId, String targetUserId) async {
    final fIdx = _users.indexWhere((u) => u.id == followerId);
    final tIdx = _users.indexWhere((u) => u.id == targetUserId);

    if (fIdx != -1 && tIdx != -1) {
      final f = _users[fIdx];
      final t = _users[tIdx];

      _users[fIdx] = User(
        id: f.id,
        name: f.name,
        email: f.email,
        password: f.password,
        profilePicturePath: f.profilePicturePath,
        tags: f.tags,
        followers: f.followers,
        following: f.following.where((id) => id != targetUserId).toList(),
        isAdmin: f.isAdmin,
        isBlocked: f.isBlocked,
      );
      _users[tIdx] = User(
        id: t.id,
        name: t.name,
        email: t.email,
        password: t.password,
        profilePicturePath: t.profilePicturePath,
        tags: t.tags,
        followers: t.followers.where((id) => id != followerId).toList(),
        following: t.following,
        isAdmin: t.isAdmin,
        isBlocked: t.isBlocked,
      );
      await _saveUsers();
      if (currentUser?.id == followerId) currentUser = _users[fIdx];
      notifyListeners();
    }
  }

  bool isFollowing(String followerId, String targetUserId) {
    final follower = _users.firstWhere(
      (u) => u.id == followerId,
      orElse: () => User(id: '', name: '', email: '', password: ''),
    );
    return follower.following.contains(targetUserId);
  }

  List<Review> getReviewsFor(String userId, {bool includePending = true}) {
    return _reviews.where((r) {
      if (r.targetUserId != userId) return false;
      if (r.status == ReviewStatus.approved) return true;
      return includePending && r.status == ReviewStatus.pending;
    }).toList();
  }

  double averageRating(String userId) {
    final userReviews = getReviewsFor(userId);
    if (userReviews.isEmpty) return 0;
    return userReviews.map((r) => r.rating).reduce((a, b) => a + b) /
        userReviews.length;
  }

  String getUserTag(String userId) {
    final avg = averageRating(userId);
    if (avg < 3) return 'bad person';
    if (avg == 3) return 'ok person';
    return 'awesome person';
  }

  List<User> searchUsers(
    String query, {
    double? minRating,
    double? maxRating,
    List<String>? tags,
    bool? followingOnly,
  }) {
    var filtered = _users.where((u) => u.id != currentUser?.id && !u.isBlocked);
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty)
      filtered = filtered.where((u) => u.name.toLowerCase().contains(q));
    if (minRating != null)
      filtered = filtered.where((u) => averageRating(u.id) >= minRating);
    if (maxRating != null)
      filtered = filtered.where((u) => averageRating(u.id) <= maxRating);
    if (tags != null && tags.isNotEmpty)
      filtered = filtered.where((u) => tags.any((tag) => u.tags.contains(tag)));
    if (followingOnly == true && currentUser != null)
      filtered = filtered.where((u) => currentUser!.following.contains(u.id));
    return filtered.toList();
  }

  Future<String> exportAccountsTxt() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/user_accounts.txt');
    final userText = _users
        .map(
          (u) =>
              'Name: ${u.name}, Email: ${u.email}, Password: ${u.password}, Tag: ${getUserTag(u.id)}',
        )
        .join('\n');
    final reviewText = _reviews
        .map((r) {
          final target = _users.firstWhere(
            (u) => u.id == r.targetUserId,
            orElse: () =>
                User(id: '', name: 'Unknown', email: 'unknown', password: ''),
          );
          return 'Target:${target.name}, Rating:${r.rating}, Comment:${r.comment}, On:${r.timestamp.toIso8601String()}';
        })
        .join('\n');
    await file.writeAsString('USERS:\n$userText\n\nREVIEWS:\n$reviewText');
    return file.path;
  }
}

class RateMateApp extends StatefulWidget {
  const RateMateApp({super.key});

  @override
  State<RateMateApp> createState() => _RateMateAppState();
}

class _RateMateAppState extends State<RateMateApp> with WidgetsBindingObserver {
  final AppData data = AppData();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    data.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await data.init();
    if (data.users.isEmpty) {
      await data.register(
        'Popazu Alexandru',
        'alexandru.popazu@gmail.com',
        'Alexandru1111',
      );
      final alexUser = data.users.firstWhere(
        (u) => u.email == 'alexandru.popazu@gmail.com',
      );
      await data.makeAdmin(alexUser.id, true);
      await data.register('Ana Maria', 'ana.maria@gmail.com', 'password1234');
      await data.register(
        'Rares Opritescu',
        'rares.opritescu@gmail.com',
        'password1234',
      );
    }
    setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized)
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    return MaterialApp(
      title: 'RateMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(primary: AppDesignTokens.primary),
        fontFamily: AppDesignTokens.fontFamily,
      ),
      home: AnimatedBuilder(
        animation: data,
        builder: (context, child) => data.currentUser == null
            ? AuthScreen(appData: data)
            : HomeScreen(appData: data),
      ),
    );
  }
}
