import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import 'home_tab.dart';
import 'products_tab.dart';
import 'orders_tab.dart';
import 'customers_tab.dart';
import 'profile_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      HomeTab(onTabChange: _changeTab),
      ProductsTab(),
      OrdersTab(),
      CustomersTab(),
      ProfileTab(),
    ]);
  }

  void _changeTab(int index) {
    setState(() => _currentIndex = index);
  }

  final List<BottomNavItem> _navItems = [
    BottomNavItem(
      icon: Icons.home_rounded,
      label: 'Home',
      activeColor: AppColors.secondary,
    ),
    BottomNavItem(
      icon: Icons.inventory_2_rounded,
      label: 'Products',
      activeColor: AppColors.secondary,
    ),
    BottomNavItem(
      icon: Icons.shopping_bag_rounded,
      label: 'Orders',
      activeColor: AppColors.secondary,
    ),
    BottomNavItem(
      icon: Icons.people_rounded,
      label: 'Customers',
      activeColor: AppColors.secondary,
    ),
    BottomNavItem(
      icon: Icons.person_rounded,
      label: 'Profile',
      activeColor: AppColors.secondary,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                _navItems.length,
                (index) => _buildNavItem(index),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = _navItems[index];
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? item.activeColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: isActive ? item.activeColor : AppColors.textTertiary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? item.activeColor : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final String label;
  final Color activeColor;

  BottomNavItem({
    required this.icon,
    required this.label,
    required this.activeColor,
  });
}
