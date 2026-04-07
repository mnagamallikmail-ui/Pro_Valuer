import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

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
      backgroundColor: AppTheme.surface,
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
    if (route.startsWith('/reports/') && route.contains('/edit'))
      return 'Edit Report';
    if (route.startsWith('/reports/')) return 'Report Detail';
    if (route.startsWith('/reports')) return 'Reports';
    if (route.startsWith('/templates/upload')) return 'Upload Template';
    if (route.startsWith('/templates/') && route.contains('/confirm'))
      return 'Confirm Placeholders';
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

    // Build role-based nav items
    final navItems = <_NavItem>[
      const _NavItem(
          icon: Icons.dashboard_rounded,
          label: 'Dashboard',
          route: '/'),
      const _NavItem(
          icon: Icons.folder_copy_rounded,
          label: 'Templates',
          route: '/templates'),
      if (isAdmin)
        const _NavItem(
            icon: Icons.upload_file_rounded,
            label: 'Upload Template',
            route: '/templates/upload'),
      const _NavItem(
          icon: Icons.description_rounded,
          label: 'Reports',
          route: '/reports'),
      if (isAdmin)
        const _NavItem(
            icon: Icons.people_rounded,
            label: 'User Management',
            route: '/admin/users'),
    ];

    return Container(
      width: 220,
      height: double.infinity,
      color: AppTheme.sidebarBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo / Brand
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.article_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('BwVr',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                    Text('Reports',
                        style: TextStyle(color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 12),

          // Navigation items
          ...navItems.map((item) => _SidebarItem(
                item: item,
                isActive: currentRoute == item.route ||
                    (item.route != '/' && currentRoute.startsWith(item.route)),
              )),

          const Spacer(),
          const Divider(color: Colors.white12, height: 1),

          // Quick actions for users / admins
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/reports/new'),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('New Report'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      textStyle: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // User info + logout
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Builder(builder: (context) {
              final session = AuthService().session;
              final displayName = session?.displayName ?? 'User';
              final adminBadge = session?.isAdmin ?? false;
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor:
                          adminBadge ? const Color(0xFF8B5CF6) : AppTheme.accent,
                      child: const Icon(Icons.person_rounded,
                          size: 14, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(displayName,
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis),
                          if (adminBadge)
                            const Text('Admin',
                                style: TextStyle(
                                    color: Color(0xFF8B5CF6),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        AuthService().logout();
                        context.go('/login');
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.logout_rounded,
                            size: 16, color: Colors.white38),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: InkWell(
        onTap: () => context.go(item.route),
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.sidebarActive : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isActive
                ? Border.all(color: AppTheme.accent.withOpacity(0.3))
                : null,
          ),
          child: Row(
            children: [
              Icon(item.icon,
                  size: 18, color: isActive ? AppTheme.accent : Colors.white54),
              const SizedBox(width: 12),
              Text(item.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive ? Colors.white : Colors.white70,
                  )),
              if (isActive) ...[
                const Spacer(),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                      color: AppTheme.accent, shape: BoxShape.circle),
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
      height: 60,
      color: AppTheme.cardBg,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary)),
          const Spacer(),
          Builder(builder: (context) {
            final username = AuthService().session?.username ?? '';
            final isAdmin = AuthService().session?.isAdmin ?? false;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                      radius: 10,
                      backgroundColor: isAdmin ? const Color(0xFF8B5CF6) : AppTheme.accent,
                      child: const Icon(Icons.person_rounded, size: 12, color: Colors.white)),
                  const SizedBox(width: 8),
                  Text(username.isEmpty ? 'User' : username,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary)),
                  if (isAdmin) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('ADMIN',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                              color: Color(0xFF8B5CF6))),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  const _NavItem(
      {required this.icon, required this.label, required this.route});
}
