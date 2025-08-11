import 'package:flutter/material.dart';
import 'constants/colors.dart';
import 'constants/typography.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ShopSocial Home'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Welcome to ShopSocial',
            style: AppTypography.h3,
          ),
          const SizedBox(height: 24),
          _buildFeatureCard(
            context,
            'Upcoming Events',
            'Check out what\'s happening next',
            Icons.event,
            AppColors.primary,
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            'Group Chats',
            'Stay connected with your friends',
            Icons.chat,
            AppColors.secondary,
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            'Shared Expenses',
            'Track and split expenses easily',
            Icons.receipt_long,
            AppColors.accent,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, String subtitle, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: AppTypography.subtitle1),
        subtitle: Text(subtitle, style: AppTypography.body2),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Coming soon: $title')),
          );
        },
      ),
    );
  }
}
