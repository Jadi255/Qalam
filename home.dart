import 'dart:async';
import 'dart:ffi';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qalam/Pages/cache.dart';
import 'package:qalam/Pages/chats.dart';
import 'package:qalam/Pages/fetchers.dart';
import 'package:qalam/Pages/homepage_posts.dart';
import 'package:qalam/Pages/my_profile.dart';
import 'package:qalam/Pages/notifications.dart';
import 'package:qalam/Pages/search.dart';
import 'package:qalam/Pages/topics.dart';
import 'package:qalam/styles.dart';
import 'package:qalam/user_data.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  int _currentIndex = 0;
  final _pageController = PageController();
  var initConnectivityState;
  int buildNo = 1515;
  bool get wantKeepAlive => true;

  final List<Widget> _children = [
    const ViewPosts(),
    const AllConversations(),
    const Topics(),
    MyProfile(
      isLeading: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    connectivityStream().listen((event) {
      if (event == ConnectivityResult.none) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.wifi_off,
                  color: Colors.white,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text('أنت غير متصل بالإنترنت'),
                ),
              ],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.wifi,
                  color: Colors.white,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text('عاد الإتصال'),
                ),
              ],
            ),
          ),
        );
      }
    });
    Future.delayed(Duration.zero, () async {
      if (kIsWeb) {
        final user = Provider.of<User>(context, listen: false);
        if (user.fullName == "") {
          context.go('/');
        }
      } else {
        await checkUpdates();
      }
      await getAlerts();
    });
    try {
      getInitConnectivity();
      messagesSubscriber();
      getMessages();
    } catch (e) {
      print(e);
    }
  }

  Future getAlerts() async {
    final user = Provider.of<User>(context, listen: false);
    var fetcher = Fetcher(pb: user.pb);
    var request = await fetcher.getAlerts(user.id);
    for (var i = 0; i < request.length; i++) {
      var alert = await request[i]!.toJson();
      String id = alert['id'];
      String alertText = alert['alert'];
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.black,
                  iconColor: Colors.black,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        alert['title'],
                        textScaler: TextScaler.linear(0.75),
                      ),
                    ],
                  ),
                  content: Padding(
                    padding: EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [Text(alertText)],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          user.pb
                              .collection('alerts')
                              .update(id, body: {"seen": true});
                          Navigator.of(context).pop();
                        },
                        child: Text('تم'),
                        style: TextButtonStyle)
                  ]),
            );
          });
    }
  }

  void getMessages() async {
    CacheManager().clearMessages();
    final user = Provider.of<User>(context, listen: false);
    final fetcher = Fetcher(pb: user.pb);
    final messages = await fetcher.fetchMessages(user.id);
    final cacheManager = CacheManager();
    if (messages.length == 0) {
      setState(() {});
    }
    for (int i = 0; i < messages.length; i++) {
      var item = messages[i].toJson();
      final message = Message(
        item['id'],
        item['to'],
        item['from'],
        item['text'],
        DateTime.parse(item['created']),
        DateTime.parse(item['updated']),
      );
      await cacheManager.cacheMessage(message);
    }
  }

  void showBuildVer() {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.black,
            iconColor: Colors.black,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'معلومات الإصدار',
                  textScaler: TextScaler.linear(0.75),
                ),
              ],
            ),
            content: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                  textDirection: TextDirection.rtl,
                  'إصدار رقم $buildNo\n\nتصميم جهاد ناصرالدين (C) ${DateTime.now().year}'),
            ),
          );
        });
  }

  void messagesSubscriber() async {
    final user = Provider.of<User>(context, listen: false);
    if (!kIsWeb) {
      await user.pb.collection('notifications').subscribe(
        '*',
        (e) async {
          getMessages();
        },
      );
    } else if (kIsWeb) {
      Timer.periodic(
        Duration(seconds: 30),
        (timer) async {
          try {
            getMessages();
          } catch (e) {
            print(e);
          }
        },
      );
    }
  }

  Future<void> getInitConnectivity() async {
    initConnectivityState = await Connectivity().checkConnectivity();
  }

  void authRefresh() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.authRefresh();
  }

  Stream<ConnectivityResult> connectivityStream() async* {
    final Connectivity connectivity = Connectivity();
    await for (ConnectivityResult result
        in connectivity.onConnectivityChanged) {
      if (result != initConnectivityState) {
        initConnectivityState = result;
        yield result;
      }
    }
  }

  void onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future checkUpdates() async {
    final user = Provider.of<User>(context, listen: false);
    var request = await user.pb
        .collection('version_control')
        .getFullList(filter: 'latest = true');

    if (request.isNotEmpty) {
      var response = request[0].toJson();
      response['build'].runtimeType != double;
      if (response['build'] <= buildNo) {
        return;
      }
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return AlertDialog(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.black,
                iconColor: Colors.black,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'يوجد تحديث جديد',
                      style: defaultText,
                      textScaler: TextScaler.linear(0.75),
                    ),
                  ],
                ),
                content: Padding(
                  padding: EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                          'تم إطلاق نسخة محدثة من تطبيق قلم. هل ترغب بتحمليها الآن؟',
                          textDirection: TextDirection.rtl,
                        )
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('لا'),
                      style: TextButtonStyle),
                  TextButton(
                      onPressed: () async {
                        await launchUrl(Uri.parse(response['repo']));
                      },
                      child: Text('نعم'),
                      style: TextButtonStyle),
                ]);
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var user = Provider.of<User>(context);
    authRefresh();
    user.realTime();
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: GestureDetector(
            onTap: () {
              showBuildVer();
            },
            child: coloredLogo,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: CircleAvatar(
                  backgroundColor: Colors.grey.shade100,
                  foregroundImage: user.avatar,
                  backgroundImage: Image.asset('assets/placeholder.jpg').image,
                  radius: 15),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        SearchMenu(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      var begin = Offset(1.0, 0.0);
                      var end = Offset.zero;
                      var curve = Curves.ease;

                      var tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));

                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                  ),
                );
              },
              icon: const Icon(Icons.search),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: NotificationBell(),
            ),
          ],
        ),
        body: PageView(
          controller: _pageController,
          children: _children,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          onTap: onTabTapped,
          currentIndex: _currentIndex,
          selectedItemColor: greenColor,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "الرئيسية",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message_rounded),
              label: "محادثات",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tag),
              label: "مواضيع",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "صفحتي",
            )
          ],
        ),
      ),
    );
  }
}
