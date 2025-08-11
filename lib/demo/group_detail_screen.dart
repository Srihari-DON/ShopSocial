import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/group.dart';
import '../models/user.dart';
import '../models/event.dart';
import '../models/expense.dart';
import 'data_service.dart';
import 'widgets.dart';

class GroupDetailScreen extends ConsumerStatefulWidget {
  final String groupId;

  const GroupDetailScreen({
    Key? key,
    required this.groupId,
  }) : super(key: key);

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  Group? _group;
  List<User> _members = [];
  List<Event> _events = [];
  List<Expense> _expenses = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      final dataRepo = ref.read(dataRepositoryProvider);
      
      final group = await dataRepo.getGroupById(widget.groupId);
      final allUsers = await dataRepo.getUsers();
      final members = allUsers.where((user) => group.memberIds.contains(user.id)).toList();
      final events = await dataRepo.getEventsForGroup(widget.groupId);
      final expenses = await dataRepo.getExpensesForGroup(widget.groupId);
      
      setState(() {
        _group = group;
        _members = members;
        _events = events;
        _expenses = expenses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading group: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_group?.name ?? 'Group Details'),
      ),
      body: _isLoading || _group == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Group header
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Row(
                    children: [
                      Avatar(
                        imageUrl: _group!.imageUrl,
                        name: _group!.name,
                        size: 70,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _group!.name,
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_members.length} members',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _group!.description,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Events'),
                    Tab(text: 'Expenses'),
                    Tab(text: 'Members'),
                  ],
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Theme.of(context).primaryColor,
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Events Tab
                      _events.isEmpty
                          ? const Center(child: Text('No events'))
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
                                    date: event.startsAt ?? DateTime.now(),
                                    location: event.options.isNotEmpty ? event.options[0].optionText : "No location",
                                    attendees: [event.createdBy],
                                    onTap: () {
                                      context.go('/event/${event.id}');
                                    },
                                  ),
                                );
                              },
                            ),
                      
                      // Expenses Tab
                      _expenses.isEmpty
                          ? const Center(child: Text('No expenses'))
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _expenses.length,
                              itemBuilder: (context, index) {
                                final expense = _expenses[index];
                                final payer = _members.firstWhere(
                                  (member) => member.id == expense.createdBy,
                                  orElse: () => User(
                                    id: 'unknown',
                                    name: 'Unknown',
                                    email: '',
                                    avatarUrl: '',
                                  ),
                                );
                                
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    leading: Avatar(
                                      imageUrl: payer.avatarUrl,
                                      name: payer.name,
                                      size: 40,
                                    ),
                                    title: Text(expense.description),
                                    subtitle: Text('Paid by: ${payer.name}'),
                                    trailing: Text(
                                      '\$${expense.amount.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                      
                      // Members Tab
                      ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _members.length,
                        itemBuilder: (context, index) {
                          final member = _members[index];
                          return ListTile(
                            leading: Avatar(
                              imageUrl: member.avatarUrl,
                              name: member.name,
                              size: 40,
                            ),
                            title: Text(member.name),
                            subtitle: Text(member.email),
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
          // Using GoRouter instead of Navigator
          _tabController.index == 0
              ? context.go('/create')  // Simplified for demo
              : _tabController.index == 1
                  ? context.go('/create') // Simplified for demo
                  : null;
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
