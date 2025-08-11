import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/group.dart';
import '../models/event.dart';
import '../models/user.dart';
import 'auth_service.dart';
import 'data_service.dart';
import 'widgets.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<Group> _groups = [];
  List<Event> _events = [];
  List<User> _users = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final user = ref.read(authProvider).user;
      if (user == null) return;
      
      final dataRepo = ref.read(dataRepositoryProvider);
      
      final users = await dataRepo.getUsers();
      final groups = await dataRepo.getGroupsForUser(user.id);
      final events = await dataRepo.getEventsForUser(user.id);
      
      setState(() {
        _users = users;
        _groups = groups;
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: ${e.toString()}')),
        );
      }
    }
  }

  String _getUserName(String userId) {
    final user = _users.firstWhere(
      (user) => user.id == userId,
      orElse: () => User(id: userId, name: 'Unknown', email: '', avatarUrl: ''),
    );
    return user.name;
  }

  void _navigateToGroupDetail(String groupId) {
    context.go('/group/$groupId');
  }

  void _navigateToEventDetail(String eventId) {
    context.go('/event/$eventId');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ShopSocial'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Profile screen would go here
              ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('Please log in'))
          : Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Groups'),
                    Tab(text: 'Events'),
                  ],
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Theme.of(context).primaryColor,
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            // Groups Tab
                            _groups.isEmpty
                                ? const Center(child: Text('No groups found'))
                                : ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: _groups.length,
                                    itemBuilder: (context, index) {
                                      final group = _groups[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 16.0),
                                        child: GroupCard(
                                          id: group.id,
                                          name: group.name,
                                          imageUrl: group.imageUrl,
                                          members: group.memberIds,
                                          onTap: () => _navigateToGroupDetail(group.id),
                                        ),
                                      );
                                    },
                                  ),
                            
                            // Events Tab
                            _events.isEmpty
                                ? const Center(child: Text('No events found'))
                                : ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: _events.length,
                                    itemBuilder: (context, index) {
                                      final event = _events[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 16.0),
                                        child: EventCard(
                                          id: event.id,
                                          title: event.title,
                                          imageUrl: event.imageUrl,
                                          date: event.startsAt ?? DateTime.now(),
                                          location: event.options.isNotEmpty ? event.options[0].optionText : "No location",
                                          attendees: [event.createdBy],
                                          onTap: () => _navigateToEventDetail(event.id),
                                        ),
                                      );
                                    },
                                  ),
                          ],
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/create');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
