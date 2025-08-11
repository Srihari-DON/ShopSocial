import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'constants/strings.dart';
import 'routes.dart';
import 'theme/theme.dart';
import 'viewmodels/auth_vm.dart';

class ShopSocialApp extends ConsumerWidget {
  const ShopSocialApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final isDarkMode = ref.watch(themeModeProvider);
    
    return MaterialApp.router(
      title: AppStrings.appName,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

final themeModeProvider = StateProvider<bool>((ref) => false);
