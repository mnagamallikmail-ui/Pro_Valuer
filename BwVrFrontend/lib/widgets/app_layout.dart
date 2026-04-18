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
    if (route == '/admin/users') return 'Management';
    if (route.startsWith('/reports/new')) return 'New Report';
    if (route.startsWith('/reports/') && route.contains('/edit')) return 'Edit Report';
    if (route.startsWith('/reports/')) return 'Valuation Review';
    if (route.startsWith('/reports')) return 'Reports';
    if (route.startsWith('/templates/upload')) return 'New Template';
    if (route.startsWith('/templates/') && route.contains('/confirm')) return 'Configuration';
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
      const _NavItem(icon: Icons.grid_view_rounded, label: 'Dashboard', route: '/'),
      const _NavItem(icon: Icons.layers_rounded, label: 'Templates', route: '/templates'),
      const _NavItem(icon: Icons.assignment_rounded, label: 'Reports', route: '/reports'),
      if (isAdmin)
        const _NavItem(icon: Icons.manage_accounts_rounded, label: 'User Admin', route: '/admin/users'),
    ];

    return Container(
      width: 280,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface, // Ghost White
        border: Border(right: BorderSide(color: AppColors.border, width: 1.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Branding
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryText, // Turquoise
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.analytics_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Text('BwVr', style: AppTypography.heading2.copyWith(color: AppColors.primaryText)),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: navItems.map((item) => _SidebarItem(
                item: item,
                isActive: currentRoute == item.route || (item.route != '/' && currentRoute.startsWith(item.route)),
              )).toList(),
            ),
          ),

          // User info Card at bottom
          Padding(
            padding: const EdgeInsets.all(24),
            child: Builder(builder: (context) {
              final session = AuthService().session;
              final displayName = session?.displayName ?? 'User';
              final isAdm = session?.isAdmin ?? false;
              
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: isAdm ? AppColors.primary : AppColors.secondary,
                          child: Icon(Icons.person_outline_rounded, size: 20, color: isAdm ? Colors.white : AppColors.primaryText),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(displayName, style: AppTypography.heading3.copyWith(fontSize: 14), overflow: TextOverflow.ellipsis),
                              Text(isAdm ? 'Admin Access' : 'Staff Member', 
                                style: AppTypography.label.copyWith(fontSize: 10, color: AppColors.accent)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: AppColors.border.withOpacity(0.5)),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        AuthService().logout();
                        context.go('/login');
                      },
                      icon: const Icon(Icons.logout_rounded, size: 16, color: AppColors.primary),
                      label: Text('Logout', style: AppTypography.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => context.go(item.route),
        borderRadius: BorderRadius.circular(12),
        hoverColor: AppColors.primary.withOpacity(0.05),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isActive ? Border.all(color: AppColors.primaryText, width: 1.5) : null,
          ),
          child: Row(
            children: [
              Icon(item.icon, size: 22, color: isActive ? AppColors.primaryText : AppColors.accent),
              const SizedBox(width: 16),
              Text(
                item.label,
                style: AppTypography.heading3.copyWith(
                  fontSize: 15,
                  color: isActive ? AppColors.primaryText : AppColors.accent,
                ),
              ),
              if (isActive) ...[
                const Spacer(),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                ),
              ],
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
      height: 90,
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: [
          Text(title, style: AppTypography.heading2.copyWith(color: AppColors.primaryText)),
          const Spacer(),
          // Placeholder for streaming status / notifications
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.secondary.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.sync_rounded, color: AppColors.secondary, size: 16),
                const SizedBox(width: 8),
                Text('Real-time Data Active', style: AppTypography.label.copyWith(color: AppColors.primaryText)),
              ],
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
