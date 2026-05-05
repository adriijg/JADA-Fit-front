import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/user_summary.dart';
import '../../data/services/social_service.dart';
import 'user_profile_screen.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SocialService _socialService = SocialService();

  // Search state
  final TextEditingController _searchController = TextEditingController();
  List<UserSummary> _searchResults = [];
  bool _isSearching = false;

  // Connections state
  List<UserSummary> _followers = [];
  List<UserSummary> _following = [];
  bool _isLoadingConnections = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1 && !_tabController.indexIsChanging) {
        _loadConnections();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await _socialService.searchUsers(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al buscar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  Future<void> _loadConnections() async {
    setState(() {
      _isLoadingConnections = true;
    });

    try {
      // Usar un endpoint como "me" si se adapta, pero en backend
      // getFollowers y getFollowing requieren un userId.
      // Si en backend no hay "me" para social, el front debería obtener 
      // el ID del usuario logueado. 
      // Por simplicidad en este demo asumiremos que obtenemos nuestro ID de Auth,
      // o ajustamos el servicio/backend.
      // Omitido: Carga real aquí si no tenemos nuestro ID a mano.
      // Lo ideal es tener un "me/followers" en el backend.
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingConnections = false;
        });
      }
    }
  }

  void _navigateToProfile(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(userId: userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Social', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.secondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Buscar'),
            Tab(text: 'Conexiones'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSearchTab(),
          _buildConnectionsTab(),
        ],
      ),
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar usuarios...',
              hintStyle: const TextStyle(color: AppColors.secondary),
              prefixIcon: const Icon(Icons.search, color: AppColors.secondary),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(color: AppColors.textMain),
            onSubmitted: _searchUsers,
          ),
        ),
        if (_isSearching)
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          )
        else if (_searchResults.isEmpty)
          const Expanded(
            child: Center(
              child: Text(
                'Busca a otros usuarios de JADA-Fit',
                style: TextStyle(color: AppColors.secondary),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final user = _searchResults[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    child: Text(
                      user.username[0].toUpperCase(),
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(user.username, style: const TextStyle(color: AppColors.textMain)),
                  onTap: () => _navigateToProfile(user.id),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildConnectionsTab() {
    if (_isLoadingConnections) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    // Aquí iría la vista de followers/following
    return const Center(
      child: Text(
        'Tus seguidores y personas a las que sigues aparecerán aquí.',
        style: TextStyle(color: AppColors.secondary),
        textAlign: TextAlign.center,
      ),
    );
  }
}
