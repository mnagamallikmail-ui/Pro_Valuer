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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          _Sidebar(currentRoute: currentRoute),
          Expanded(
            child: Column(
              children: [
                _TopBar(title: title ?? _getTitle(currentRoute)),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTitle(String route) {
    if (route == '/admin/users') return 'User Management';
    if (route.startsWith('/reports/new')) return 'Create New Report';
    if (route.startsWith('/reports/') && route.contains('/edit')) return 'Edit Report';
    if (route.startsWith('/reports/')) return 'Report Detail';
    if (route.startsWith('/reports')) return 'Reports';
    if (route.startsWith('/templates/upload')) return 'Upload Template';
    if (route.startsWith('/templates/') && route.contains('/confirm')) return 'Confirm Placeholders';
    if (route.startsWith('/templates')) return 'Templates';
    return 'Dashboard';
  }
}

class _Sidebar extends StatelessWidget {
  final String currentRoute;

  const _Sidebar({required this.currentRoute});

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
      width: 250,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(32),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.article_rounded, color: AppColors.textPrimary, size: 22),
                ),
                const SizedBox(width: 14),
                Text('BwVr', style: AppTypography.heading3),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: navItems.map((item) => _SidebarItem(
                item: item,
                isActive: currentRoute == item.route || (item.route != '/' && currentRoute.startsWith(item.route)),
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

  const _SidebarItem({required this.item, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () => context.go(item.route),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(item.icon, size: 20, color: isActive ? AppColors.textPrimary : AppColors.textSecondary),
              const SizedBox(width: 16),
              Text(
                item.label,
                style: AppTypography.subheading.copyWith(
                  color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  const _TopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          Text(title, style: AppTypography.heading2),
          const Spacer(),
          // Breadcrumbs can go here if needed
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
