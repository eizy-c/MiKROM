import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../dashboard/views/dashboard_view.dart';
import '../../wifi_config/views/wifi_config_view.dart';
import '../../access_control/views/access_control_view.dart';
import '../../network_settings/views/network_settings_view.dart';

/// Main Navigation Shell with NavigationBar.
class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardView(),
    WifiConfigView(),
    AccessControlView(),
    NetworkSettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.cardBorder, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view_rounded, color: AppColors.primary),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.wifi_outlined),
              selectedIcon: Icon(Icons.wifi, color: AppColors.primary),
              label: 'Wi-Fi',
            ),
            NavigationDestination(
              icon: Icon(Icons.security_outlined),
              selectedIcon: Icon(Icons.security, color: AppColors.primary),
              label: 'Seguridad',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_ethernet_outlined),
              selectedIcon: Icon(Icons.settings_ethernet, color: AppColors.primary),
              label: 'Red LAN',
            ),
          ],
        ),
      ),
    );
  }
}
