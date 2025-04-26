import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Initialize flutter_local_notifications for foreground notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications
  const androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initializationSettings = InitializationSettings(android: androidInitSettings);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const NewsApp());
}

class NewsApp extends StatefulWidget {
  const NewsApp({super.key});

  @override
  State<NewsApp> createState() => _NewsAppState();
}

class _NewsAppState extends State<NewsApp> {
  bool isDarkTheme = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News Buzz',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        brightness: Brightness.light,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          selectedIconTheme: IconThemeData(size: 30),
          unselectedIconTheme: IconThemeData(size: 24),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[900],
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          selectedIconTheme: IconThemeData(size: 30),
          unselectedIconTheme: IconThemeData(size: 24),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ),
      themeMode: isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NewsHomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Image.asset(
        'assets/images/news.png',
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover, // Ensures the image covers the entire screen
      ),
    );
  }
}

class NotificationModel {
  String id;
  String title;
  String body;
  bool isRead;
  String? url;
  String sourceId;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.isRead = false,
    this.url,
    required this.sourceId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'isRead': isRead,
    'url': url,
    'sourceId': sourceId,
  };

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
    id: json['id'],
    title: json['title'],
    body: json['body'],
    isRead: json['isRead'],
    url: json['url'],
    sourceId: json['sourceId'],
  );
}

class NewsHomePage extends StatefulWidget {
  const NewsHomePage({super.key});

  @override
  State<NewsHomePage> createState() => _NewsHomePageState();
}

class _NewsHomePageState extends State<NewsHomePage> {
  List articles = [];
  String selectedCategory = 'general'; // Default to "general" for "For you"
  final String apiKey = '67d273fc00284d0b8dbc317075db450c';
  int _selectedIndex = 0;
  List<NotificationModel> notifications = [];
  List<String> likedArticles = [];
  List<String> followedSources = [];
  String? selectedNewsstandCategory;
  List articlesForNewsstand = [];
  late SharedPreferences prefs;
  Map<String, String> lastNotifiedArticleUrl = {};
  bool notificationsEnabled = true;
  List<String> notifiedArticleUrls = [];

  @override
  void initState() {
    super.initState();
    _initPrefs();
    fetchNews(selectedCategory);
  }

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getString('notifications');
    if (notificationsJson != null) {
      final List<dynamic> decoded = jsonDecode(notificationsJson);
      notifications = decoded.map((item) => NotificationModel.fromJson(item)).toList();
    }
    likedArticles = prefs.getStringList('likedArticles') ?? [];
    followedSources = prefs.getStringList('followedSources') ?? [];
    notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    notifiedArticleUrls = prefs.getStringList('notifiedArticleUrls') ?? [];
    setState(() {});
  }

  Future<void> _saveNotifications() async {
    final notificationsJson = jsonEncode(notifications.map((n) => n.toJson()).toList());
    await prefs.setString('notifications', notificationsJson);
  }

  Future<void> _saveLikedArticles() async {
    await prefs.setStringList('likedArticles', likedArticles);
  }

  Future<void> _saveFollowedSources() async {
    await prefs.setStringList('followedSources', followedSources);
  }

  Future<void> _saveNotificationsEnabled() async {
    await prefs.setBool('notificationsEnabled', notificationsEnabled);
  }

  Future<void> _saveNotifiedArticleUrls() async {
    await prefs.setStringList('notifiedArticleUrls', notifiedArticleUrls);
  }

  bool _isValidArticle(Map article) {
    final sourceId = article['source']['id'];
    final url = article['url'];
    return sourceId != null &&
        sourceId != 'unknown' &&
        sourceId.isNotEmpty &&
        url != null &&
        Uri.tryParse(url)?.hasAbsolutePath == true;
  }

  Future<void> fetchNews(String category) async {
    String url;
    if (_selectedIndex == 0) {
      url = 'https://newsapi.org/v2/top-headlines?category=general&apiKey=$apiKey';
    } else if (_selectedIndex == 1) {
      url = 'https://newsapi.org/v2/top-headlines?sources=bbc-news&apiKey=$apiKey';
    } else if (_selectedIndex == 2) {
      if (followedSources.isEmpty) {
        setState(() {
          articles = [];
        });
        return;
      }
      final sources = followedSources.join(',');
      url = 'https://newsapi.org/v2/top-headlines?sources=$sources&apiKey=$apiKey';
    } else {
      return;
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          articles = (data['articles'] as List<dynamic>)
              .where((article) => _isValidArticle(article))
              .toList();
          // Generate notifications only in the "Following" tab and if enabled
          if (articles.isNotEmpty && _selectedIndex == 2 && notificationsEnabled) {
            final newArticle = articles.first;
            final sourceId = newArticle['source']['id'];
            final articleUrl = newArticle['url'];
            if (lastNotifiedArticleUrl[sourceId] != articleUrl) {
              // Add to in-app notifications
              final newNotification = NotificationModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: 'New Article from ${newArticle['source']['name']}',
                body: 'Check out: ${newArticle['title']}',
                isRead: false,
                url: articleUrl,
                sourceId: sourceId,
              );
              notifications.add(newNotification);
              lastNotifiedArticleUrl[sourceId] = articleUrl;
              _saveNotifications();

              // Show foreground notification
              if (!notifiedArticleUrls.contains(articleUrl)) {
                const androidDetails = AndroidNotificationDetails(
                  'news_channel',
                  'News Updates',
                  channelDescription: 'Notifications for new articles from followed sources',
                  importance: Importance.max,
                  priority: Priority.high,
                );
                const notificationDetails = NotificationDetails(android: androidDetails);

                flutterLocalNotificationsPlugin.show(
                  DateTime.now().millisecondsSinceEpoch ~/ 1000,
                  'New Article from ${newArticle['source']['name']}',
                  'Check out: ${newArticle['title']}',
                  notificationDetails,
                );

                notifiedArticleUrls.add(articleUrl);
                _saveNotifiedArticleUrls();
              }
            }
          }
        });
      } else {
        setState(() {
          articles = [];
        });
      }
    } catch (e) {
      setState(() {
        articles = [];
      });
    }
  }

  Future<void> fetchNewsForNewsstand(String category) async {
    final url = 'https://newsapi.org/v2/top-headlines?category=$category&apiKey=$apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          articlesForNewsstand = (data['articles'] as List<dynamic>)
              .where((article) => _isValidArticle(article))
              .toList();
        });
      } else {
        setState(() {
          articlesForNewsstand = [];
        });
      }
    } catch (e) {
      setState(() {
        articlesForNewsstand = [];
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0) {
        fetchNews('general');
      } else if (_selectedIndex == 1) {
        fetchNews('headlines');
      } else if (_selectedIndex == 2) {
        fetchNews('following');
      } else if (_selectedIndex == 3) {
        selectedNewsstandCategory = null;
        articlesForNewsstand = [];
      }
    });
  }

  void _toggleTheme() {
    final newsAppState = context.findAncestorStateOfType<_NewsAppState>();
    newsAppState?.setState(() {
      newsAppState.isDarkTheme = !newsAppState.isDarkTheme;
    });
  }

  void _toggleNotifications() {
    setState(() {
      notificationsEnabled = !notificationsEnabled;
      _saveNotificationsEnabled();
      if (!notificationsEnabled) {
        notifications.clear();
        _saveNotifications();
      }
    });
  }

  void _showNotificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: SizedBox(
          width: double.maxFinite,
          height: 350, // Increased height to accommodate toggle
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Enable Notifications'),
                  Switch(
                    value: notificationsEnabled,
                    onChanged: (value) {
                      _toggleNotifications();
                    },
                    activeColor: Colors.blue,
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: notifications.isEmpty
                    ? const Center(child: Text('No notifications available.'))
                    : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return ListTile(
                      title: Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(notification.body),
                      trailing: IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () {
                          setState(() {
                            notification.isRead = true;
                            _saveNotifications();
                          });
                        },
                      ),
                      onTap: () async {
                        setState(() {
                          notification.isRead = true;
                          _saveNotifications();
                        });
                        if (notification.url != null) {
                          final uri = Uri.parse(notification.url!);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Could not launch notification URL')),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                notifications.clear();
                _saveNotifications();
              });
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  int getUnreadNotificationCount() {
    return notifications.where((notification) => !notification.isRead).length;
  }

  void _likeArticle(String articleId) {
    setState(() {
      if (likedArticles.contains(articleId)) {
        likedArticles.remove(articleId);
      } else {
        likedArticles.add(articleId);
      }
      _saveLikedArticles();
    });
  }

  void _followSource(String sourceId, String sourceName, BuildContext context) {
    setState(() {
      if (followedSources.contains(sourceId)) {
        followedSources.remove(sourceId);
        notifications.removeWhere((notification) => notification.sourceId == sourceId);
        _saveNotifications();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unfollowed $sourceName')),
        );
      } else {
        followedSources.add(sourceId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Followed $sourceName')),
        );
      }
      _saveFollowedSources();
      if (_selectedIndex == 2) {
        fetchNews('following');
      }
    });
  }

  bool _hasVideoContent(Map article) {
    return article.containsKey('videoUrl') && article['videoUrl'] != null;
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      // "For you" tab
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Stories for you',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: articles.isEmpty
                ? const Center(child: Text('No articles available'))
                : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                final articleId = article['url'];
                final sourceId = article['source']['id'];
                final sourceName = article['source']['name'] ?? 'Unknown Source';
                return NewsCard(
                  article: article,
                  isLiked: likedArticles.contains(articleId),
                  isFollowed: followedSources.contains(sourceId),
                  onPlay: () {
                    if (_hasVideoContent(article)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('This article has video content (placeholder)')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No video available for this article')),
                      );
                    }
                  },
                  onShare: () {
                    final title = article['title'] ?? 'Untitled';
                    final url = article['url'];
                    Share.share(
                      '$title\n$url',
                      subject: 'Check out this article!',
                    );
                  },
                  onLike: () => _likeArticle(articleId),
                  onFollow: () => _followSource(sourceId, sourceName, context),
                );
              },
            ),
          ),
        ],
      ),
      // "Headlines" tab
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Headlines',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: articles.isEmpty
                ? const Center(child: Text('No articles available'))
                : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                final articleId = article['url'];
                final sourceId = article['source']['id'];
                final sourceName = article['source']['name'] ?? 'Unknown Source';
                return NewsCard(
                  article: article,
                  isLiked: likedArticles.contains(articleId),
                  isFollowed: followedSources.contains(sourceId),
                  onPlay: () {
                    if (_hasVideoContent(article)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('This article has video content (placeholder)')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No video available for this article')),
                      );
                    }
                  },
                  onShare: () {
                    final title = article['title'] ?? 'Untitled';
                    final url = article['url'];
                    Share.share(
                      '$title\n$url',
                      subject: 'Check out this article!',
                    );
                  },
                  onLike: () => _likeArticle(articleId),
                  onFollow: () => _followSource(sourceId, sourceName, context),
                );
              },
            ),
          ),
        ],
      ),
      // "Following" tab
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Following',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: articles.isEmpty
                ? const Center(child: Text('Follow some sources to see articles'))
                : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                final articleId = article['url'];
                final sourceId = article['source']['id'];
                final sourceName = article['source']['name'] ?? 'Unknown Source';
                return NewsCard(
                  article: article,
                  isLiked: likedArticles.contains(articleId),
                  isFollowed: followedSources.contains(sourceId),
                  onPlay: () {
                    if (_hasVideoContent(article)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('This article has video content (placeholder)')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No video available for this article')),
                      );
                    }
                  },
                  onShare: () {
                    final title = article['title'] ?? 'Untitled';
                    final url = article['url'];
                    Share.share(
                      '$title\n$url',
                      subject: 'Check out this article!',
                    );
                  },
                  onLike: () => _likeArticle(articleId),
                  onFollow: () => _followSource(sourceId, sourceName, context),
                );
              },
            ),
          ),
        ],
      ),
      // "Newsstand" tab
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Newsstand',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: selectedNewsstandCategory == null
                ? GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(15),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                CategoryTile(
                  category: 'Technology',
                  icon: Icons.computer,
                  onTap: () {
                    setState(() {
                      selectedNewsstandCategory = 'technology';
                    });
                    fetchNewsForNewsstand('technology');
                  },
                ),
                CategoryTile(
                  category: 'Sports',
                  icon: Icons.sports,
                  onTap: () {
                    setState(() {
                      selectedNewsstandCategory = 'sports';
                    });
                    fetchNewsForNewsstand('sports');
                  },
                ),
                CategoryTile(
                  category: 'Business',
                  icon: Icons.business,
                  onTap: () {
                    setState(() {
                      selectedNewsstandCategory = 'business';
                    });
                    fetchNewsForNewsstand('business');
                  },
                ),
                CategoryTile(
                  category: 'Entertainment',
                  icon: Icons.movie,
                  onTap: () {
                    setState(() {
                      selectedNewsstandCategory = 'entertainment';
                    });
                    fetchNewsForNewsstand('entertainment');
                  },
                ),
              ],
            )
                : articlesForNewsstand.isEmpty
                ? const Center(child: Text('No articles available'))
                : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: articlesForNewsstand.length,
              itemBuilder: (context, index) {
                final article = articlesForNewsstand[index];
                final articleId = article['url'];
                final sourceId = article['source']['id'];
                final sourceName = article['source']['name'] ?? 'Unknown Source';
                return NewsCard(
                  article: article,
                  isLiked: likedArticles.contains(articleId),
                  isFollowed: followedSources.contains(sourceId),
                  onPlay: () {
                    if (_hasVideoContent(article)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('This article has video content (placeholder)')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No video available for this article')),
                      );
                    }
                  },
                  onShare: () {
                    final title = article['title'] ?? 'Untitled';
                    final url = article['url'];
                    Share.share(
                      '$title\n$url',
                      subject: 'Check out this article!',
                    );
                  },
                  onLike: () => _likeArticle(articleId),
                  onFollow: () => _followSource(sourceId, sourceName, context),
                );
              },
            ),
          ),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('News Buzz'),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.brightness_7
                  : Icons.brightness_6,
            ),
            onPressed: _toggleTheme,
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: _showNotificationDialog,
              ),
              if (getUnreadNotificationCount() > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.red,
                    child: Text(
                      getUnreadNotificationCount().toString(),
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'For you',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: 'Headlines',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Following',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Newsstand',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class CategoryTile extends StatelessWidget {
  final String category;
  final IconData icon;
  final VoidCallback onTap;

  const CategoryTile({
    super.key,
    required this.category,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: Colors.blue,
            ),
            const SizedBox(height: 10),
            Text(
              category,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class NewsCard extends StatelessWidget {
  final Map article;
  final bool isLiked;
  final bool isFollowed;
  final VoidCallback onPlay;
  final VoidCallback onShare;
  final VoidCallback onLike;
  final VoidCallback onFollow;

  const NewsCard({
    super.key,
    required this.article,
    required this.isLiked,
    required this.isFollowed,
    required this.onPlay,
    required this.onShare,
    required this.onLike,
    required this.onFollow,
  });

  @override
  Widget build(BuildContext context) {
    final url = article['url'];
    final isValidUrl = url != null && Uri.tryParse(url)?.hasAbsolutePath == true;

    return GestureDetector(
      onTap: () async {
        if (isValidUrl) {
          try {
            await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to open article: $e')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Article URL is invalid or missing')),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            article['urlToImage'] != null
                ? ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: Image.network(
                article['urlToImage'],
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.error)),
                  );
                },
              ),
            )
                : Container(
              height: 200,
              color: Colors.grey[300],
              child: const Center(child: Icon(Icons.image_not_supported)),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                article['title'] ?? 'No Title',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.play_circle_outline),
                    onPressed: onPlay,
                  ),
                  IconButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : null,
                    ),
                    onPressed: onLike,
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: onShare,
                  ),
                  IconButton(
                    icon: Icon(
                      isFollowed ? Icons.person_remove : Icons.person_add,
                      color: isFollowed ? Colors.blue : null,
                    ),
                    onPressed: onFollow,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}