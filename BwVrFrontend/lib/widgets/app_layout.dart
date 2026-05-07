import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AppLayout extends StatelessWidget {
  final String currentRoute;
  final Widget child;
  final String? title;

  const AppLayout({
    super.key,
    required this.currentRoute,
    required this.child,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 900;

      return Scaffold(
        backgroundColor: AppColors.background,
        drawer: isMobile ? Drawer(child: _Sidebar(currentRoute: currentRoute, isMobile: true)) : null,
        body: Row(
          children: [
            if (!isMobile)
              SizedBox(
                width: 280,
                child: _Sidebar(currentRoute: currentRoute, isMobile: false),
              ),
            Expanded(
              child: Column(
                children: [
                  _TopBar(
                    title: title ?? _getTitle(currentRoute),
                    showMenu: isMobile,
                  ),
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  String _getTitle(String route) {
    if (route == '/admin/users') return 'Directory';
    if (route.startsWith('/reports/new')) return 'New Registry';
    if (route.startsWith('/reports/') && route.contains('/edit')) return 'Data Capture';
    if (route.startsWith('/reports/')) return 'File Inspection';
    if (route.startsWith('/reports')) return 'Records';
    if (route.startsWith('/templates/upload')) return 'New Layout';
    if (route.startsWith('/templates/') && route.contains('/confirm')) return 'Mapping Verification';
    if (route.startsWith('/templates')) return 'Layouts';
    return 'Overview';
  }
}

class _Sidebar extends StatelessWidget {
  final String currentRoute;
  final bool isMobile;

  const _Sidebar({required this.currentRoute, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final isAdmin = auth.session?.isAdmin ?? false;

    final navItems = <_NavItem>[
      const _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard', route: '/'),
      const _NavItem(icon: Icons.folder_copy_rounded, label: 'Templates', route: '/templates'),
      if (isAdmin)
        const _NavItem(icon: Icons.upload_file_rounded, label: 'Upload Template', route: '/templates/upload'),
      const _NavItem(icon: Icons.description_rounded, label: 'Reports', route: '/reports'),
      if (isAdmin)
        const _NavItem(icon: Icons.people_rounded, label: 'User Management', route: '/admin/users'),
    ];

    return Container(
      color: AppColors.structural,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            alignment: Alignment.centerLeft,
            child: Image.asset(
              'assets/images/logo.png',
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: navItems.map((item) => _SidebarItem(
                item: item,
                isActive: currentRoute == item.route || (item.route != '/' && currentRoute.startsWith(item.route)),
                onTap: isMobile ? () => Navigator.pop(context) : null,
              )).toList(),
            ),
          ),

          const Divider(),

          // User info + logout
          Padding(
            padding: const EdgeInsets.all(20),
            child: Builder(builder: (context) {
              final session = AuthService().session;
              final displayName = session?.displayName ?? 'User';
              final isAdm = session?.isAdmin ?? false;
              
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: isAdm ? AppColors.primary : AppColors.accent,
                      child: const Icon(Icons.person_rounded, size: 18, color: AppColors.textPrimary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(displayName, style: AppTypography.label.copyWith(color: AppColors.textPrimary), overflow: TextOverflow.ellipsis),
                          if (isAdm)
                            Text('Admin', style: AppTypography.label.copyWith(fontSize: 10, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.textSecondary),
                      onPressed: () {
                        AuthService().logout();
                        context.go('/login');
                      },
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback? onTap;

  const _SidebarItem({required this.item, required this.isActive, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (onTap != null) onTap!();
        context.go(item.route);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: isActive ? AppColors.primary : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            Icon(
              item.icon,
              size: 20,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 16),
            Text(
              item.label,
              style: AppTypography.subheading.copyWith(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final bool showMenu;
  const _TopBar({required this.title, this.showMenu = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      padding: EdgeInsets.symmetric(horizontal: showMenu ? 16 : 32),
      child: Row(
        children: [
          if (showMenu) ...[
            IconButton(
              icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
            const SizedBox(width: 8),
          ],
          if (!showMenu) ...[
            // Logo removed from here to eliminate redundancy
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              title,
              style: AppTypography.heading3.copyWith(color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  const _NavItem({required this.icon, required this.label, required this.route});
}
