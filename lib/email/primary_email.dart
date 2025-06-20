import 'dart:math';
import 'package:autobotv2email/phone_mockup/clickable_outline.dart';
import 'package:autobotv2email/phone_mockup/phone_mockup_container.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PrimaryEmailScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onCompose;
  final GlobalKey composeButtonKey;

  const PrimaryEmailScreen({
    super.key,
    required this.onBack,
    required this.onCompose,
    required this.composeButtonKey,
  });

  @override
  State<PrimaryEmailScreen> createState() => _PrimaryEmailScreenState();
}

class _PrimaryEmailScreenState extends State<PrimaryEmailScreen> {
  // Master list of all possible emails.
  final List<Map<String, dynamic>> _allEmails = [
    // Social
    {'sender': 'Facebook', 'initial': 'F', 'color': Colors.blue[800], 'subject': 'You have new friend suggestions', 'body': 'People you may know...', 'category': 'Social'},
    {'sender': 'LinkedIn', 'initial': 'L', 'color': Colors.blue[700], 'subject': 'You appeared in 9 searches this week', 'body': 'See who\'s searching for you...', 'category': 'Social'},
    {'sender': 'Twitter', 'initial': 'T', 'color': Colors.lightBlue, 'subject': 'Your week on Twitter', 'body': 'Here\'s what you missed...', 'category': 'Social'},
    {'sender': 'Instagram', 'initial': 'I', 'color': Colors.pink, 'subject': 'lorem_ipsum started a live video.', 'body': 'Watch it before it ends!', 'category': 'Social'},
    {'sender': 'Pinterest', 'initial': 'P', 'color': Colors.red[900], 'subject': 'Ideas for your next project', 'body': 'We found Pins you might love...', 'category': 'Social'},
    {'sender': 'Reddit', 'initial': 'R', 'color': Colors.orange[900], 'subject': 'r/flutterdev trending post: "Riverpod 2.0 is here!"', 'body': 'See what the community is talking about.', 'category': 'Social'},

    // Promotions
    {'sender': 'Swiggy', 'initial': 'S', 'color': Colors.orange[600], 'subject': '50% off on your next order', 'body': 'Don\'t miss out on this tasty deal...', 'category': 'Promotions'},
    {'sender': 'Amazon.in', 'initial': 'A', 'color': Colors.orange[800], 'subject': 'Deals you can\'t miss!', 'body': 'Your recommendations are here...', 'category': 'Promotions'},
    {'sender': 'Myntra', 'initial': 'M', 'color': Colors.redAccent, 'subject': 'Biggest fashion sale is LIVE!', 'body': 'Up to 80% off on top brands.', 'category': 'Promotions'},
    {'sender': 'Zomato', 'initial': 'Z', 'color': Colors.red[700], 'subject': 'Feeling hungry?', 'body': 'Order now and get 30% off.', 'category': 'Promotions'},
    {'sender': 'Flipkart', 'initial': 'F', 'color': Colors.yellow[700], 'subject': 'Big Billion Days are back!', 'body': 'Get ready for the biggest sale of the year.', 'category': 'Promotions'},
    {'sender': 'Goibibo', 'initial': 'G', 'color': Colors.deepOrange, 'subject': 'Flight tickets at lowest prices', 'body': 'Book now and save big on your travel.', 'category': 'Promotions'},

    // Updates
    {'sender': 'Google', 'initial': 'G', 'color': Colors.blue, 'subject': 'Security alert for your linked account', 'body': 'A new sign-in was detected on a device...', 'category': 'Updates'},
    {'sender': 'GitHub', 'initial': 'G', 'color': Colors.black, 'subject': '[GitHub] A third-party application has been approved', 'body': 'Hey abuzershaikh! A third-party...', 'category': 'Updates'},
    {'sender': 'Your Bank', 'initial': 'Y', 'color': Colors.indigo, 'subject': 'Monthly Statement for May', 'body': 'Your e-statement is now available...', 'category': 'Updates'},
    {'sender': 'Netflix', 'initial': 'N', 'color': Colors.red[800], 'subject': 'New Release: The Next Big Thing', 'body': 'A new movie has been added to your list...', 'category': 'Updates'},
    {'sender': 'IRCTC', 'initial': 'I', 'color': Colors.brown, 'subject': 'Your ticket has been booked successfully', 'body': 'PNR: 1234567890, from NDLS to BCT.', 'category': 'Updates'},
    {'sender': 'Jira', 'initial': 'J', 'color': Colors.blue[900], 'subject': '[JIRA] (PROJ-123) Task assigned to you', 'body': 'Please review the new task in the project.', 'category': 'Updates'},

    // Primary
    {'sender': 'YouTube Creators', 'initial': 'Y', 'color': Colors.red, 'subject': 'Hey Zest T Talk, taking a break?', 'body': 'We\'re here to support you when you...'},
    {'sender': 'LG Account', 'initial': 'L', 'color': Colors.grey[600], 'subject': '[LGE Ac...] Account Created', 'body': '[LGE Account] Account Created De...'},
    {'sender': 'Medium Daily Digest', 'initial': 'M', 'color': Colors.black, 'subject': 'Stories for you', 'body': 'Handpicked stories based on your interests...'},
    {'sender': 'Stack Overflow', 'initial': 'S', 'color': Colors.orange, 'subject': 'Your weekly newsletter is here', 'body': 'Top questions, news, and updates...'},
    {'sender': 'Quora', 'initial': 'Q', 'color': Colors.red[600], 'subject': 'A new answer to "What is the meaning of life?"', 'body': 'Check out the latest response...'},
    {'sender': 'Spotify', 'initial': 'S', 'color': Colors.green, 'subject': 'Your Discover Weekly is ready', 'body': '30 new songs just for you...'},
    {'sender': 'Discord', 'initial': 'D', 'color': Colors.purple[600], 'subject': 'You have a new message in #general', 'body': 'Someone mentioned you in the server...'},
    {'sender': 'Canva', 'initial': 'C', 'color': Colors.teal, 'subject': 'Your design is ready to be shared', 'body': 'Download or share your new design now...'},
    {'sender': 'Figma', 'initial': 'F', 'color': Colors.pink, 'subject': 'John Doe commented on your file', 'body': 'Review the feedback on your design...'},
    {'sender': 'Slack', 'initial': 'S', 'color': Colors.deepPurple, 'subject': '2 new messages in #project-alpha', 'body': 'Catch up on the latest team discussion...'},
    {'sender': 'Upwork', 'initial': 'U', 'color': Colors.green[800], 'subject': 'New job posting matching your skills', 'body': 'A new opportunity awaits you.'},
    {'sender': 'Asana', 'initial': 'A', 'color': Colors.pinkAccent, 'subject': 'Task "Finalize report" is due tomorrow', 'body': 'Don\'t forget to complete your task.'},
    {'sender': 'Jane Doe', 'initial': 'J', 'color': Colors.teal[300], 'subject': 'Meeting notes from today', 'body': 'Hi team, here are the notes from our meeting...'},
    {'sender': 'Project Manager', 'initial': 'P', 'color': Colors.brown[400], 'subject': 'Weekly project update', 'body': 'Please find the attached report for this week\'s progress.'},
    {'sender': 'HR Department', 'initial': 'H', 'color': Colors.blueGrey, 'subject': 'Important: Policy Update', 'body': 'Please review the updated company policies.'},
  ];

  List<Map<String, dynamic>> _displayEmails = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _generateRandomEmails();
  }

  void _generateRandomEmails() {
    _allEmails.shuffle(_random);
    final int emailCount = 15 + _random.nextInt(_allEmails.length - 15 + 1);
    final List<Map<String, dynamic>> tempEmails = _allEmails.take(emailCount).toList();
    final List<Map<String, dynamic>> processedEmails = tempEmails.map((email) {
      return {
        ...email,
        'isUnread': _random.nextBool(),
        'date': _generateRandomDate(),
      };
    }).toList();
    final socialEmails = processedEmails.where((e) => e['category'] == 'Social').toList();
    final promotionsEmails = processedEmails.where((e) => e['category'] == 'Promotions').toList();
    final updatesEmails = processedEmails.where((e) => e['category'] == 'Updates').toList();
    final primaryEmails = processedEmails.where((e) => e['category'] == null).toList();
    final List<Map<String, dynamic>> categoryItems = [];
    if (socialEmails.isNotEmpty) {
      categoryItems.add({
        'sender': socialEmails.map((e) => e['sender']).take(2).join(', '),
        'subject': socialEmails.first['subject'],
        'body': 'You have new social notifications...',
        'date': '${_random.nextInt(50) + 1} new',
        'isCategory': true,
        'categoryIcon': Icons.people_outline,
        'categoryTitle': 'Social'
      });
    }
    if (promotionsEmails.isNotEmpty) {
      categoryItems.add({
        'sender': promotionsEmails.map((e) => e['sender']).take(2).join(', '),
        'subject': promotionsEmails.first['subject'],
        'body': 'Latest offers and deals for you...',
        'date': '${_random.nextInt(99) + 1} new',
        'isCategory': true,
        'categoryIcon': Icons.local_offer_outlined,
        'categoryTitle': 'Promotions'
      });
    }
    if (updatesEmails.isNotEmpty) {
      categoryItems.add({
        'sender': updatesEmails.map((e) => e['sender']).take(2).join(', '),
        'subject': updatesEmails.first['subject'],
        'body': 'Important updates and alerts...',
        'date': '${_random.nextInt(20) + 1} new',
        'isCategory': true,
        'categoryIcon': Icons.info_outline,
        'categoryTitle': 'Updates'
      });
    }
    setState(() {
      _displayEmails = [...categoryItems, ...primaryEmails];
    });
  }

  // Generates a random date within the last 10 days.
  String _generateRandomDate() {
    final now = DateTime.now();
    // Generate date within the last 10 days. (0 to 9 days ago)
    final randomDay = _random.nextInt(10); // <<<<<<<<<<<< YEH LINE CHANGE KI GAYI HAI
    final emailDate = now.subtract(Duration(days: randomDay, hours: _random.nextInt(24)));
    
    // If it's today, show time. Otherwise, show date.
    if (now.difference(emailDate).inDays == 0) {
      return DateFormat('h:mm a').format(emailDate); // e.g., 2:30 PM
    } else {
      return DateFormat('d MMM').format(emailDate); // e.g., 18 Jun
    }
  }

  @override
  Widget build(BuildContext context) {
    final PhoneMockupContainerState? phoneMockupState = context.findAncestorStateOfType<PhoneMockupContainerState>();
    final ValueNotifier<String>? captionNotifier = phoneMockupState?.widget.currentCaption;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.grey[100],
            elevation: 1,
            floating: true,
            title: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.black54),
                    onPressed: widget.onBack,
                  ),
                  const Expanded(
                    child: Text(
                      'Search in emails',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.deepPurple,
                      child: Text(
                        'Z',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
              child: Text(
                'Primary',
                style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // Use the randomized and dynamic list.
                return EmailListItem(email: _displayEmails[index]);
              },
              childCount: _displayEmails.length,
            ),
          ),
        ],
      ),
      floatingActionButton: ClickableOutline(
        key: widget.composeButtonKey as GlobalKey<ClickableOutlineState>,
        action: () async => widget.onCompose(),
        captionNotifier: captionNotifier,
        caption: "Click here to compose a new email.",
        child: FloatingActionButton.extended(
          onPressed: widget.onCompose,
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Compose'),
          backgroundColor: Colors.blue[100],
          foregroundColor: Colors.blue[800],
          elevation: 2,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('99+'),
              child: Icon(Icons.mail),
            ),
            label: 'Mail',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.videocam_outlined),
            label: 'Meet',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: Colors.grey[600],
        showUnselectedLabels: true,
      ),
    );
  }
}

class EmailListItem extends StatelessWidget {
  final Map<String, dynamic> email;

  const EmailListItem({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    if (email['isCategory'] == true) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Icon(email['categoryIcon'], color: Colors.black54),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(email['categoryTitle'],
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(email['sender'],
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14)),
                  Text(email['subject'],
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getCategoryColor(email['categoryTitle']),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                email['date'],
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            )
          ],
        ),
      );
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: email['color'] ?? Colors.grey,
        child: Text(
          email['initial'] ?? '?',
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              email['sender'],
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: email['isUnread'] == true ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            email['date'],
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: email['isUnread'] == true ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email['subject'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: email['isUnread'] == true ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                Text(
                  email['body'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.star_border,
            color: Color.fromARGB(255, 225, 232, 221),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Social':
        return Colors.blue[600]!;
      case 'Promotions':
        return Colors.green[600]!;
      case 'Updates':
        return Colors.orange[600]!;
      default:
        return Colors.grey;
    }
  }
}