import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_city/eventdetails_page.dart';
import 'package:smart_city/profile_page.dart';
import 'event.dart'; // Import the Event class from event.dart

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color.fromRGBO(141, 134, 201, 1),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: HomeScreen(title: "Home"),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onMenuPressed;
  final VoidCallback onSearchPressed;
  final bool isSearchBarOpen;
  final PageController pageController;
  final ValueChanged<String> onSearchQueryChanged;

  CustomAppBar({
    required this.onMenuPressed,
    required this.onSearchPressed,
    required this.isSearchBarOpen,
    required this.pageController,
    required this.onSearchQueryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: isSearchBarOpen
          ? TextField(
              onChanged: onSearchQueryChanged,
              decoration: InputDecoration(
                hintText: 'Search...',
                border: InputBorder.none,
              ),
            )
          : Text('AbhiVriddhi'),
      leading: IconButton(
        icon: Icon(Icons.menu),
        onPressed: onMenuPressed,
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search),
          onPressed: onSearchPressed,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + kTextTabBarHeight);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required String title}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSearchBarOpen = false;
  late TabController _tabController;
  late PageController _pageController;
  int currentPage = 0;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pageController = PageController(initialPage: 0, viewportFraction: 1);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _pageController.animateToPage(_tabController.index,
            duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        onMenuPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
        onSearchPressed: () {
          setState(() {
            isSearchBarOpen = !isSearchBarOpen;
            if (!isSearchBarOpen) {
              searchQuery = '';
            }
          });
        },
        isSearchBarOpen: isSearchBarOpen,
        pageController: _pageController,
        onSearchQueryChanged: (query) {
          setState(() {
            searchQuery = query;
          });
        },
      ),
      drawer: buildDrawer(context),
      body: buildEventBoxes(''),
    );
  }

  Drawer buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration:
                BoxDecoration(color: const Color.fromRGBO(141, 134, 201, 1)),
            child: Text(
              'AbhiVriddhi',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            tileColor: Color.fromRGBO(103, 0, 238, 1),
            title: Text('My Profile'),
            onTap: () {
               Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(),
                    ),
                  );
            },
          ),
        ],
      ),
    );
  }

  Future<List<Event>> fetchEvents(String category) async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection("Announcements").get();

      List<Event> events = querySnapshot.docs.map((doc) {
        DateTime startDate = (doc['Start Date'] as Timestamp).toDate();
        DateTime endDate = (doc['End Date'] as Timestamp).toDate();

        return Event(
          title: doc['Title'],
          description: doc['Description'],
          details: List<String>.from(doc['Details']),
          startDate: startDate,
          endDate: endDate,
        );
      }).toList();

      print("Fetched ${events.length} events");
      return events;
    } catch (e) {
      print("Failed to fetch events: $e");
      return [];
    }
  }

  Widget buildEventBoxes(String category) {
    return FutureBuilder<List<Event>>(
      future: fetchEvents(category),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<Event> filteredEvents = snapshot.data!.where((event) {
            String searchTerm = searchQuery.toLowerCase();
            return event.title.toLowerCase().contains(searchTerm) ||
                event.description.toLowerCase().contains(searchTerm);
          }).toList();

          return ListView.builder(
            itemCount: filteredEvents.length,
            itemBuilder: (context, index) {
              Event event = filteredEvents[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetailsPage(event: event),
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Color.fromARGB(255, 113, 117, 231).withOpacity(0.2),
                        offset: Offset(0, 3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(event.description),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
