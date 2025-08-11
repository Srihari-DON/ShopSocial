import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../constants/colors.dart';
import '../constants/spacing.dart';
import '../constants/strings.dart';
import '../constants/typography.dart';
import '../viewmodels/auth_vm.dart';
import '../widgets/app_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      image: 'assets/images/onboarding1.png',
      title: 'Connect with Friends',
      description: 'Join groups with friends and family for shopping activities.',
    ),
    OnboardingPage(
      image: 'assets/images/onboarding2.png',
      title: 'Plan Shopping Events',
      description: 'Create and manage shopping events with your groups.',
    ),
    OnboardingPage(
      image: 'assets/images/onboarding3.png',
      title: 'Split Expenses Easily',
      description: 'Keep track of who paid for what and settle expenses easily.',
    ),
    OnboardingPage(
      image: 'assets/images/onboarding4.png',
      title: 'Chat in Real-time',
      description: 'Stay connected with your shopping companions in real-time.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: Text(
                    'Skip',
                    style: AppTypography.button.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
            
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            
            // Dots indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => _buildDotIndicator(index),
                ),
              ),
            ),
            
            // Next or Get Started button
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: AppButton(
                onPressed: _isLastPage ? _finishOnboarding : _goToNextPage,
                label: _isLastPage ? 'Get Started' : 'Next',
                icon: _isLastPage ? Icons.check_circle_outline : Icons.arrow_forward,
                variant: AppButtonVariant.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Placeholder for image - in a real app, you'd use Image.asset
          // Since we don't have the actual images, we'll use a container with a color
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: AppColors.surfaceLighter,
              borderRadius: BorderRadius.circular(AppSpacing.md),
            ),
            child: Center(
              child: Icon(
                _getIconForIndex(_currentPage),
                size: 80,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            page.title,
            style: AppTypography.headline5,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            page.description,
            style: AppTypography.body1.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildDotIndicator(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: index == _currentPage 
            ? AppColors.primary 
            : AppColors.surfaceDark,
      ),
    );
  }
  
  bool get _isLastPage => _currentPage == _pages.length - 1;
  
  void _goToNextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
  
  void _finishOnboarding() {
    // Mark onboarding as completed
    ref.read(authVMProvider.notifier).completeOnboarding();
    
    // Navigate to login screen
    context.go('/auth/login');
  }
  
  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.people_alt_outlined;
      case 1:
        return Icons.event_outlined;
      case 2:
        return Icons.account_balance_wallet_outlined;
      case 3:
        return Icons.chat_outlined;
      default:
        return Icons.help_outline;
    }
  }
}

class OnboardingPage {
  final String image;
  final String title;
  final String description;
  
  OnboardingPage({
    required this.image,
    required this.title,
    required this.description,
  });
}
