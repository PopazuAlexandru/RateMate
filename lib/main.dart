import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';

part 'main.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter('hive_db');
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(ReviewAdapter());
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

  Review({
    required this.id,
    required this.targetUserId,
    this.submitterUserId,
    required this.rating,
    required this.comment,
    required this.timestamp,
    this.status = ReviewStatus.pending,
    this.moderatorNote,
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
  Future<void> dispose() async {
    await _userBox.close();
    await _reviewBox.close();
    await _currentUserBox.close();
    super.dispose();
  }

  void _loadData() {
    _users.clear();
    _users.addAll(_userBox.values);
    _reviews.clear();
    _reviews.addAll(_reviewBox.values);
    // Always start with no logged-in user to require login on app startup
    currentUser = null;
    notifyListeners();
  }

  void _saveUsers() {
    _userBox.clear();
    for (var user in _users) {
      _userBox.put(user.id, user);
    }
  }

  void _saveReviews() {
    try {
      _reviewBox.clear();
      for (var review in _reviews) {
        _reviewBox.put(review.id, review);
      }
    } catch (e) {
      // Error saving reviews - data may not persist
    }
  }

  List<User> get users => List.unmodifiable(_users);
  List<Review> get reviews => List.unmodifiable(_reviews);

  bool register(String name, String email, String password) {
    final normalizedEmail = email.trim().toLowerCase();
    if (_users.any((u) => u.email.toLowerCase() == normalizedEmail)) {
      return false;
    }
    _users.add(
      User(
        id: _uuid.v4(),
        name: name.trim(),
        email: normalizedEmail,
        password: password,
      ),
    );
    _saveUsers();
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

  void addReview(String targetUserId, int rating, String comment) {
    _reviews.add(
      Review(
        id: _uuid.v4(),
        targetUserId: targetUserId,
        submitterUserId: currentUser?.id,
        rating: rating,
        comment: comment.trim(),
        timestamp: DateTime.now(),
        status: currentUser?.isAdmin == true
            ? ReviewStatus.approved
            : ReviewStatus.pending,
      ),
    );
    _saveReviews();
    notifyListeners();
  }

  // Profile Picture Management
  void updateProfilePicture(String userId, String? imagePath) {
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
      _saveUsers();
      if (currentUser?.id == userId) {
        currentUser = updatedUser;
      }
      notifyListeners();
    }
  }

  // User Tags Management
  void updateUserTags(String userId, List<String> tags) {
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
      _saveUsers();
      if (currentUser?.id == userId) {
        currentUser = updatedUser;
      }
      notifyListeners();
    }
  }

  // Following System
  void followUser(String followerId, String targetUserId) {
    if (followerId == targetUserId) return;

    final followerIndex = _users.indexWhere((u) => u.id == followerId);
    final targetIndex = _users.indexWhere((u) => u.id == targetUserId);

    if (followerIndex != -1 && targetIndex != -1) {
      final follower = _users[followerIndex];
      final target = _users[targetIndex];

      if (!follower.following.contains(targetUserId)) {
        final updatedFollower = User(
          id: follower.id,
          name: follower.name,
          email: follower.email,
          password: follower.password,
          profilePicturePath: follower.profilePicturePath,
          tags: follower.tags,
          followers: follower.followers,
          following: [...follower.following, targetUserId],
          isAdmin: follower.isAdmin,
          isBlocked: follower.isBlocked,
        );

        final updatedTarget = User(
          id: target.id,
          name: target.name,
          email: target.email,
          password: target.password,
          profilePicturePath: target.profilePicturePath,
          tags: target.tags,
          followers: [...target.followers, followerId],
          following: target.following,
          isAdmin: target.isAdmin,
          isBlocked: target.isBlocked,
        );

        _users[followerIndex] = updatedFollower;
        _users[targetIndex] = updatedTarget;
        _saveUsers();

        if (currentUser?.id == followerId) {
          currentUser = updatedFollower;
        }
        notifyListeners();
      }
    }
  }

  void unfollowUser(String followerId, String targetUserId) {
    final followerIndex = _users.indexWhere((u) => u.id == followerId);
    final targetIndex = _users.indexWhere((u) => u.id == targetUserId);

    if (followerIndex != -1 && targetIndex != -1) {
      final follower = _users[followerIndex];
      final target = _users[targetIndex];

      final updatedFollower = User(
        id: follower.id,
        name: follower.name,
        email: follower.email,
        password: follower.password,
        profilePicturePath: follower.profilePicturePath,
        tags: follower.tags,
        followers: follower.followers,
        following: follower.following
            .where((id) => id != targetUserId)
            .toList(),
        isAdmin: follower.isAdmin,
        isBlocked: follower.isBlocked,
      );

      final updatedTarget = User(
        id: target.id,
        name: target.name,
        email: target.email,
        password: target.password,
        profilePicturePath: target.profilePicturePath,
        tags: target.tags,
        followers: target.followers.where((id) => id != followerId).toList(),
        following: target.following,
        isAdmin: target.isAdmin,
        isBlocked: target.isBlocked,
      );

      _users[followerIndex] = updatedFollower;
      _users[targetIndex] = updatedTarget;
      _saveUsers();

      if (currentUser?.id == followerId) {
        currentUser = updatedFollower;
      }
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

  // Review Moderation
  void moderateReview(
    String reviewId,
    ReviewStatus status, {
    String? moderatorNote,
  }) {
    final reviewIndex = _reviews.indexWhere((r) => r.id == reviewId);
    if (reviewIndex != -1) {
      final review = _reviews[reviewIndex];
      final updatedReview = Review(
        id: review.id,
        targetUserId: review.targetUserId,
        submitterUserId: review.submitterUserId,
        rating: review.rating,
        comment: review.comment,
        timestamp: review.timestamp,
        status: status,
        moderatorNote: moderatorNote,
      );
      _reviews[reviewIndex] = updatedReview;
      _saveReviews();
      notifyListeners();
    }
  }

  // User Management (Admin)
  void blockUser(String userId, bool blocked) {
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
      _saveUsers();
      notifyListeners();
    }
  }

  void makeAdmin(String userId, bool isAdmin) {
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
      _saveUsers();
      notifyListeners();
    }
  }

  List<Review> getReviewsFor(String userId) => _reviews
      .where(
        (r) => r.targetUserId == userId && r.status == ReviewStatus.approved,
      )
      .toList();

  List<Review> getPendingReviews() =>
      _reviews.where((r) => r.status == ReviewStatus.pending).toList();

  List<Review> getAllReviewsFor(String userId) =>
      _reviews.where((r) => r.targetUserId == userId).toList();

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

    // Text search
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      filtered = filtered.where((u) => u.name.toLowerCase().contains(q));
    }

    // Rating filter
    if (minRating != null) {
      filtered = filtered.where((u) => averageRating(u.id) >= minRating);
    }
    if (maxRating != null) {
      filtered = filtered.where((u) => averageRating(u.id) <= maxRating);
    }

    // Tag filter
    if (tags != null && tags.isNotEmpty) {
      filtered = filtered.where((u) => tags.any((tag) => u.tags.contains(tag)));
    }

    // Following filter
    if (followingOnly == true && currentUser != null) {
      filtered = filtered.where((u) => currentUser!.following.contains(u.id));
    }

    return filtered.toList();
  }

  Future<String> exportAccountsTxt() async {
    final directory = Directory(r'C:\Users\Popazu\Desktop\MEC\RateMate');
    await directory.create(recursive: true);
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      data.dispose();
    }
  }

  Future<void> _initializeData() async {
    await data.init();
    // If no users, add initial ones
    if (data.users.isEmpty) {
      data.register(
        'Alexandru Popazu',
        'alexandru.popazu@gmail.com',
        'Alexandru1111',
      );
      // Make Alexandru Popazu an admin
      data.makeAdmin(data.users.first.id, true);
      data.register('Ana Maria', 'ana.maria@gmail.com', 'password1234');
      data.register(
        'Rares Opritescu',
        'rares.opritescu@gmail.com',
        'password1234',
      );
      data.register('Dragan Mihai', 'mihai.dragan@gmail.com', 'password1234');
    }
    setState(() {
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return MaterialApp(
      title: 'RateMate',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: AnimatedBuilder(
        animation: data,
        builder: (context, child) {
          if (data.currentUser == null) {
            return AuthScreen(appData: data);
          }
          return HomeScreen(appData: data);
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthScreen extends StatefulWidget {
  final AppData appData;
  const AuthScreen({required this.appData, super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  String error = '';

  void toggleMode() {
    setState(() {
      isLogin = !isLogin;
      error = '';
    });
  }

  void submit() {
    final email = emailController.text;
    final password = passwordController.text;
    if (email.isEmpty ||
        password.isEmpty ||
        (!isLogin && nameController.text.trim().isEmpty)) {
      setState(() => error = 'Please fill all required fields');
      return;
    }
    final success = isLogin
        ? widget.appData.login(email, password)
        : widget.appData.register(nameController.text, email, password);
    if (!success) {
      setState(
        () => error = isLogin
            ? 'Login failed: check credentials'
            : 'Registration failed: email already used',
      );
      return;
    }
    setState(() => error = '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLogin ? 'RateMate Login' : 'RateMate Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (!isLogin)
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: submit,
              child: Text(isLogin ? 'Login' : 'Register'),
            ),
            TextButton(
              onPressed: toggleMode,
              child: Text(
                isLogin
                    ? "Don't have an account? Sign up"
                    : 'Already have an account? Login',
              ),
            ),
            if (error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(error, style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final AppData appData;
  const HomeScreen({required this.appData, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String query = '';
  double? minRating;
  double? maxRating;
  List<String> selectedTags = [];
  bool followingOnly = false;
  bool showFilters = false;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _toggleFilters() {
    setState(() {
      showFilters = !showFilters;
    });
  }

  List<String> _getAllTags() {
    final allTags = <String>{};
    for (final user in widget.appData.users) {
      allTags.addAll(user.tags);
    }
    return allTags.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.appData.currentUser!;
    final candidates = widget.appData.searchUsers(
      query,
      minRating: minRating,
      maxRating: maxRating,
      tags: selectedTags.isNotEmpty ? selectedTags : null,
      followingOnly: followingOnly,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('RateMate Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Advanced Filters',
            onPressed: _toggleFilters,
          ),
          if (current.isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Admin Panel',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AdminPanelScreen(appData: widget.appData),
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.reviews),
            tooltip: 'My Reviews',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MyReviewsScreen(appData: widget.appData),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              widget.appData.logout();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${current.name}!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) => setState(() => query = value),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search users',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: showFilters
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: Container(),
              secondChild: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Advanced Filters',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text('Rating: '),
                          Expanded(
                            child: RangeSlider(
                              values: RangeValues(
                                minRating ?? 0,
                                maxRating ?? 5,
                              ),
                              min: 0,
                              max: 5,
                              divisions: 10,
                              labels: RangeLabels(
                                (minRating ?? 0).toStringAsFixed(1),
                                (maxRating ?? 5).toStringAsFixed(1),
                              ),
                              onChanged: (values) {
                                setState(() {
                                  minRating = values.start == 0
                                      ? null
                                      : values.start;
                                  maxRating = values.end == 5
                                      ? null
                                      : values.end;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: _getAllTags().map((tag) {
                          final isSelected = selectedTags.contains(tag);
                          return FilterChip(
                            label: Text(tag),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedTags.add(tag);
                                } else {
                                  selectedTags.remove(tag);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text('Following only: '),
                          Switch(
                            value: followingOnly,
                            onChanged: (value) =>
                                setState(() => followingOnly = value),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Find friends to review',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: candidates.isEmpty
                  ? const Center(child: Text('No users found.'))
                  : ListView.builder(
                      itemCount: candidates.length,
                      itemBuilder: (context, index) {
                        final user = candidates[index];
                        final avgRating = widget.appData.averageRating(user.id);
                        final tag = widget.appData.getUserTag(user.id);
                        final isFollowing = widget.appData.isFollowing(
                          current.id,
                          user.id,
                        );

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Dismissible(
                            key: Key(user.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              color: Colors.blue,
                              child: const Icon(
                                Icons.rate_review,
                                color: Colors.white,
                              ),
                            ),

                            child: Card(
                              elevation: 2,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                      user.profilePicturePath != null
                                      ? FileImage(
                                          File(user.profilePicturePath!),
                                        )
                                      : null,
                                  child: user.profilePicturePath == null
                                      ? Text(user.name[0].toUpperCase())
                                      : null,
                                ),
                                title: Text(user.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Rating: ${avgRating.toStringAsFixed(1)} / 5 from ${widget.appData.getReviewsFor(user.id).length} reviews',
                                    ),
                                    Text('Tag: $tag'),
                                    if (user.tags.isNotEmpty)
                                      Text(
                                        'Tags: ${user.tags.join(", ")}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        isFollowing
                                            ? Icons.person_remove
                                            : Icons.person_add,
                                        color: isFollowing
                                            ? Colors.red
                                            : Colors.green,
                                      ),
                                      onPressed: () {
                                        if (isFollowing) {
                                          widget.appData.unfollowUser(
                                            current.id,
                                            user.id,
                                          );
                                        } else {
                                          widget.appData.followUser(
                                            current.id,
                                            user.id,
                                          );
                                        }
                                      },
                                    ),
                                    const Icon(Icons.arrow_forward_ios),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ProfileScreen(
                                        appData: widget.appData,
                                        targetUser: user,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    ProfileScreen(appData: widget.appData, targetUser: current),
              ),
            );
          },
          tooltip: 'My Profile',
          child: const Icon(Icons.person),
        ),
      ),
    );
  }
}

class MyReviewsScreen extends StatefulWidget {
  final AppData appData;
  const MyReviewsScreen({required this.appData, super.key});

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  String exportPath = '';

  void _exportToTxt() async {
    final path = await widget.appData.exportAccountsTxt();
    if (mounted) {
      setState(() => exportPath = path);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Exported to: $path')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.appData.currentUser!;
    final reviews = widget.appData.reviews
        .where((r) => r.targetUserId == current.id)
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reviews'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export users/reviews',
            onPressed: _exportToTxt,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You received ${reviews.length} reviews',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: reviews.isEmpty
                  ? const Center(child: Text('No reviews yet.'))
                  : ListView.builder(
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        final review = reviews[index];
                        return Card(
                          child: ListTile(
                            title: const Text('Secret Admirer'),
                            subtitle: Text(review.comment),
                            trailing: Text('${review.rating}/5'),
                          ),
                        );
                      },
                    ),
            ),
            if (exportPath.isNotEmpty)
              Text(
                'Last export: $exportPath',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  final AppData appData;
  final User targetUser;
  const ProfileScreen({
    required this.appData,
    required this.targetUser,
    super.key,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int rating = 5;
  final commentController = TextEditingController();
  String message = '';

  void submitReview() {
    final comment = commentController.text.trim();
    final current = widget.appData.currentUser!;
    if (current.id == widget.targetUser.id) {
      setState(() => message = 'Cannot review yourself.');
      return;
    }
    if (comment.isEmpty) {
      setState(() => message = 'Please add a comment.');
      return;
    }
    widget.appData.addReview(widget.targetUser.id, rating, comment);
    commentController.clear();
    setState(() => message = 'Review submitted anonymously!');
  }

  @override
  Widget build(BuildContext context) {
    final reviews = widget.appData.getReviewsFor(widget.targetUser.id);
    final avgRating = widget.appData.averageRating(widget.targetUser.id);
    final tag = widget.appData.getUserTag(widget.targetUser.id);
    return Scaffold(
      appBar: AppBar(title: Text(widget.targetUser.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.targetUser.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              'Email: ${widget.targetUser.email}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Text(
              'Average rating: ${avgRating.toStringAsFixed(2)} / 5 (${reviews.length} reviews)',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Tag: $tag',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            const Divider(height: 24),
            const Text(
              'Submit anonymous review',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Rating:'),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: rating,
                  items: List.generate(5, (i) => i + 1)
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text('$value'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() {
                    rating = value ?? 5;
                  }),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                labelText: 'Comment',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: submitReview,
              child: const Text('Submit Review'),
            ),
            if (message.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(message, style: const TextStyle(color: Colors.green)),
            ],
            const Divider(height: 24),
            const Text(
              'User Reviews',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: reviews.isEmpty
                  ? const Text('No reviews yet.')
                  : ListView.builder(
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        final r = reviews[index];
                        return Card(
                          child: ListTile(
                            title: Row(
                              children: [
                                for (var i = 0; i < r.rating; i++)
                                  const Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.orange,
                                  ),
                              ],
                            ),
                            subtitle: Text(r.comment),
                            trailing: Text(
                              '${r.timestamp.month}/${r.timestamp.day}/${r.timestamp.year}',
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminPanelScreen extends StatefulWidget {
  final AppData appData;
  const AdminPanelScreen({required this.appData, super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final currentUser = widget.appData.currentUser;

    // Only Alexandru Popazu can access admin settings
    if (currentUser?.email != 'alexandru.popazu@gmail.com') {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: const Center(
          child: Text('Only Alexandru Popazu can access admin settings'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Moderator Settings')),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.selected,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('Users'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.reviews),
                label: Text('Reviews'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.analytics),
                label: Text('Analytics'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildUserManagement();
      case 1:
        return _buildReviewModeration();
      case 2:
        return _buildAnalytics();
      default:
        return Container();
    }
  }

  Widget _buildUserManagement() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'User Management',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: widget.appData.users.length,
              itemBuilder: (context, index) {
                final user = widget.appData.users[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user.profilePicturePath != null
                          ? FileImage(File(user.profilePicturePath!))
                          : null,
                      child: user.profilePicturePath == null
                          ? Text(user.name[0].toUpperCase())
                          : null,
                    ),
                    title: Text(user.name),
                    subtitle: Text(
                      '${user.email} • ${user.followers.length} followers • ${user.following.length} following',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            user.isAdmin
                                ? Icons.admin_panel_settings
                                : Icons.admin_panel_settings_outlined,
                          ),
                          onPressed: () {
                            widget.appData.makeAdmin(user.id, !user.isAdmin);
                          },
                          tooltip: user.isAdmin ? 'Remove Admin' : 'Make Admin',
                        ),
                        IconButton(
                          icon: Icon(
                            user.isBlocked ? Icons.block : Icons.check_circle,
                          ),
                          color: user.isBlocked ? Colors.red : Colors.green,
                          onPressed: () {
                            widget.appData.blockUser(user.id, !user.isBlocked);
                          },
                          tooltip: user.isBlocked
                              ? 'Unblock User'
                              : 'Block User',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewModeration() {
    final pendingReviews = widget.appData.getPendingReviews();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Moderation (${pendingReviews.length} pending)',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: pendingReviews.isEmpty
                ? const Center(child: Text('No reviews pending moderation'))
                : ListView.builder(
                    itemCount: pendingReviews.length,
                    itemBuilder: (context, index) {
                      final review = pendingReviews[index];
                      final targetUser = widget.appData.users.firstWhere(
                        (u) => u.id == review.targetUserId,
                        orElse: () => User(
                          id: '',
                          name: 'Unknown',
                          email: '',
                          password: '',
                        ),
                      );

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Review for: ${targetUser.name}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('Rating: ${review.rating}/5'),
                              Text('Comment: ${review.comment}'),
                              Text('Submitted: ${review.timestamp.toString()}'),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      widget.appData.moderateReview(
                                        review.id,
                                        ReviewStatus.approved,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                    child: const Text('Approve'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      widget.appData.moderateReview(
                                        review.id,
                                        ReviewStatus.rejected,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text('Reject'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalytics() {
    final totalUsers = widget.appData.users.length;
    final totalReviews = widget.appData.reviews.length;
    final approvedReviews = widget.appData.reviews
        .where((r) => r.status == ReviewStatus.approved)
        .length;
    final averageRating = widget.appData.users.isEmpty
        ? 0.0
        : widget.appData.users
                  .map((u) => widget.appData.averageRating(u.id))
                  .reduce((a, b) => a + b) /
              widget.appData.users.length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analytics',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            childAspectRatio: 2,
            children: [
              _buildStatCard(
                'Total Users',
                totalUsers.toString(),
                Icons.people,
              ),
              _buildStatCard(
                'Total Reviews',
                totalReviews.toString(),
                Icons.reviews,
              ),
              _buildStatCard(
                'Approved Reviews',
                approvedReviews.toString(),
                Icons.check_circle,
              ),
              _buildStatCard(
                'Average Rating',
                averageRating.toStringAsFixed(1),
                Icons.star,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
