import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AppLayout extends StatelessWidget {
  final String currentRoute;
  final Widget child;
  final String? title;
  final Widget? trailing;

  const AppLayout({
    super.key,
    required this.currentRoute,
    required this.child,
    this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isMobile ? AppBar(
        title: Text(title ?? _getTitle(currentRoute), style: AppTypography.heading3.copyWith(color: AppColors.primaryText)),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.primaryText),
      ) : null,
      drawer: isMobile ? Drawer(
        backgroundColor: AppColors.background,
        child: _Sidebar(currentRoute: currentRoute)
      ) : null,
      body: Row(
        children: [
          if (!isMobile) _Sidebar(currentRoute: currentRoute),
          Expanded(
            child: Column(
              children: [
                if (!isMobile) _TopBar(
                  title: title ?? _getTitle(currentRoute),
                  trailing: trailing,
                ),
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
        color: AppColors.primary, 
        border: Border(right: BorderSide(color: Colors.white10, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Branding
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accent, 
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.analytics_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Pro Valuer', 
                  style: AppTypography.heading2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  )
                ),
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

          // User info Card at bottom
          Padding(
            padding: const EdgeInsets.all(16),
            child: Builder(builder: (context) {
              final session = AuthService().session;
              final displayName = session?.displayName ?? 'User';
              final isAdm = session?.isAdmin ?? false;
              
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10, width: 1),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.accent,
                          child: Icon(
                            isAdm ? Icons.admin_panel_settings_rounded : Icons.person_rounded, 
                            size: 16, 
                            color: Colors.white
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(displayName, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: Colors.white), overflow: TextOverflow.ellipsis),
                              Text(isAdm ? 'Administrator' : 'Valuer', 
                                style: AppTypography.label.copyWith(fontSize: 10, color: Colors.white70)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        AuthService().logout();
                        context.go('/login');
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white70,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(double.infinity, 36),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout_rounded, size: 14),
                          const SizedBox(width: 8),
                          Text('Sign Out', style: AppTypography.bodyMedium.copyWith(color: Colors.white70, fontWeight: FontWeight.w600)),
                        ],
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
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () => context.go(item.route),
        borderRadius: BorderRadius.circular(12),
        hoverColor: Colors.white.withOpacity(0.05),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.accent.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                item.icon, 
                size: 20, 
                color: isActive ? AppColors.accent : Colors.white60
              ),
              const SizedBox(width: 12),
              Text(
                item.label,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? AppColors.accent : Colors.white60,
                ),
              ),
              if (isActive) ...[
                const Spacer(),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
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
  final Widget? trailing;
  const _TopBar({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          Text(title, style: AppTypography.heading3.copyWith(color: AppColors.primaryText)),
          const Spacer(),
          if (trailing != null) ...[
            trailing!,
            const SizedBox(width: 24),
          ],
          // Streaming status indicator
          StreamBuilder<String>(
            stream: NotificationService().changeStream,
            builder: (context, snapshot) {
              final active = snapshot.connectionState == ConnectionState.active;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (active ? AppColors.success : AppColors.textSecondary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: active ? AppColors.success : AppColors.textSecondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      active ? 'Live Sync' : 'Sync Offline', 
                      style: AppTypography.label.copyWith(
                        color: active ? AppColors.success : AppColors.textSecondary, 
                        fontSize: 10
                      )
                    ),
                  ],
                ),
              );
            }
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

