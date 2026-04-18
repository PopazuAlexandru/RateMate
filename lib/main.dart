import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

void main() {
  runApp(const RateMateApp());
}

final _uuid = Uuid();

class User {
  final String id;
  final String name;
  final String email;
  final String password;
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
  });
}

class Review {
  final String id;
  final String targetUserId;
  final String? submitterUserId;
  final int rating;
  final String comment;
  final DateTime timestamp;
  Review({
    required this.id,
    required this.targetUserId,
    this.submitterUserId,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });
}

class AppData extends ChangeNotifier {
  final List<User> _users = [];
  final List<Review> _reviews = [];

  User? currentUser;

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
    notifyListeners();
    return true;
  }

  void logout() {
    currentUser = null;
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
      ),
    );
    notifyListeners();
  }

  List<Review> getReviewsFor(String userId) =>
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

  List<User> searchUsers(String query) {
    final q = query.trim().toLowerCase();
    final filtered = _users.where((u) => u.id != currentUser?.id);
    if (q.isEmpty) return filtered.toList();
    return filtered.where((u) => u.name.toLowerCase().contains(q)).toList();
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

class _RateMateAppState extends State<RateMateApp> {
  final AppData data = AppData();

  @override
  void initState() {
    super.initState();
    data.register('Ana Maria', 'ana.maria@gmail.com', 'password1234');
    data.register(
      'Rares Opritescu',
      'rares.opritescu@gmail.com',
      'password1234',
    );
    data.register('Dragan Mihai', 'mihai.dragan@gmail.com', 'password1234');
  }

  @override
  Widget build(BuildContext context) {
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

class _HomeScreenState extends State<HomeScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final current = widget.appData.currentUser!;
    final candidates = widget.appData.searchUsers(query);
    return Scaffold(
      appBar: AppBar(
        title: const Text('RateMate Home'),
        actions: [
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
                        return Card(
                          child: ListTile(
                            title: Text(user.name),
                            subtitle: Text(
                              'Rating: ${avgRating.toStringAsFixed(1)} / 5 from ${widget.appData.getReviewsFor(user.id).length} reviews\nTag: $tag',
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
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
    setState(() => exportPath = path);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Exported to: $path')));
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
