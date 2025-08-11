import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../constants/colors.dart';
import '../../constants/spacing.dart';

class CreateMenu extends ConsumerWidget {
  const CreateMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            _buildCreateOption(
              context,
              title: 'Create Group',
              description: 'Create a new shopping group with friends',
              icon: Icons.group_add,
              color: AppColors.primary,
              onTap: () {
                // In a real app, this would navigate to create group screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Create group not implemented in demo'),
                  ),
                );
                context.pop();
              },
            ),
            
            _buildCreateOption(
              context,
              title: 'Create Event',
              description: 'Schedule a new shopping event',
              icon: Icons.event_available,
              color: AppColors.secondary,
              onTap: () {
                // Navigate to create event wizard
                context.push('/calendar/create');
              },
            ),
            
            _buildCreateOption(
              context,
              title: 'Add Expense',
              description: 'Add and split expenses with your group',
              icon: Icons.account_balance_wallet,
              color: AppColors.tertiary,
              onTap: () {
                // In a real app, this would navigate to add expense screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Add expense not implemented in demo'),
                  ),
                );
                context.pop();
              },
            ),
            
            _buildCreateOption(
              context,
              title: 'New Chat',
              description: 'Start a conversation with friends',
              icon: Icons.chat_bubble_outline,
              color: AppColors.accent1,
              onTap: () {
                // In a real app, this would navigate to new chat screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('New chat not implemented in demo'),
                  ),
                );
                context.pop();
              },
            ),
            
            _buildCreateOption(
              context,
              title: 'Shopping List',
              description: 'Create a new shopping list',
              icon: Icons.list_alt,
              color: AppColors.accent2,
              onTap: () {
                // In a real app, this would navigate to create shopping list screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Shopping list not implemented in demo'),
                  ),
                );
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCreateOption(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        side: BorderSide(color: AppColors.outline),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              
              const SizedBox(width: AppSpacing.md),
              
              // Title and description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs / 2),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Arrow icon
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textHint,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
