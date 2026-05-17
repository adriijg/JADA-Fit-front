import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/user_summary.dart';
import '../../data/models/challenge.dart';
import '../../data/services/social_service.dart';
import '../../data/services/challenge_service.dart';
import 'user_profile_screen.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SocialService _socialService = SocialService();
  final ChallengeService _challengeService = ChallengeService();

  // Search state
  final TextEditingController _searchController = TextEditingController();
  List<UserSummary> _searchResults = [];
  bool _isSearching = false;

  // Connections state
  List<UserSummary> _followers = [];
  List<UserSummary> _following = [];
  bool _isLoadingConnections = false;

  // Challenges state
  List<Challenge> _myChallenges = [];
  bool _isLoadingChallenges = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1 && !_tabController.indexIsChanging) {
        _loadConnections();
      } else if (_tabController.index == 2 && !_tabController.indexIsChanging) {
        _loadChallenges();
      }
    });
  }

  Future<void> _loadChallenges() async {
    setState(() {
      _isLoadingChallenges = true;
    });

    try {
      final challenges = await _challengeService.getMyChallenges();
      if (mounted) {
        setState(() {
          _myChallenges = challenges;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar piques: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingChallenges = false;
        });
      }
    }
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
            Tab(text: 'Piques'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSearchTab(),
          _buildConnectionsTab(),
          _buildChallengesTab(),
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
                    backgroundColor: AppColors.primary.withOpacity(0.2),
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

  Widget _buildChallengesTab() {
    if (_isLoadingChallenges) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_myChallenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events_outlined, size: 64, color: AppColors.secondary),
            const SizedBox(height: 16),
            const Text(
              'No tienes piques activos.',
              style: TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '¡Desafía a tus amigos para ver quién levanta más!',
              style: TextStyle(color: AppColors.secondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _showUpdateRecordDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Actualizar mis marcas'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadChallenges,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _myChallenges.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tus Piques',
                    style: TextStyle(color: AppColors.textMain, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: _showUpdateRecordDialog,
                    icon: const Icon(Icons.add, color: AppColors.primary),
                    label: const Text('Mis Marcas', style: TextStyle(color: AppColors.primary)),
                  ),
                ],
              ),
            );
          }

          final challenge = _myChallenges[index - 1];
          return _buildChallengeCard(challenge);
        },
      ),
    );
  }

  Widget _buildChallengeCard(Challenge challenge) {
    final bool isIncoming = challenge.status == ChallengeStatus.PENDING; // Simplificado para demo
    
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    challenge.challenger.username[0].toUpperCase(),
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                const Text('vs', style: TextStyle(color: AppColors.secondary, fontStyle: FontStyle.italic)),
                const SizedBox(width: 12),
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    challenge.challenged.username[0].toUpperCase(),
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                _buildStatusBadge(challenge.status),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              challenge.exerciseName,
              style: const TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeightInfo(challenge.challenger.username, challenge.challengerWeight),
                const Icon(Icons.bolt, color: Colors.orange),
                _buildWeightInfo(challenge.challenged.username, challenge.challengedWeight),
              ],
            ),
            if (challenge.status == ChallengeStatus.PENDING) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _rejectChallenge(challenge.id),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Rechazar', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _acceptChallenge(challenge.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Aceptar'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeightInfo(String username, double weight) {
    return Column(
      children: [
        Text(
          username,
          style: const TextStyle(color: AppColors.secondary, fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${weight.toStringAsFixed(1)} kg',
          style: const TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(ChallengeStatus status) {
    Color color;
    String text;
    switch (status) {
      case ChallengeStatus.PENDING:
        color = Colors.orange;
        text = 'PENDIENTE';
        break;
      case ChallengeStatus.ACCEPTED:
        color = Colors.green;
        text = 'ACTIVO';
        break;
      case ChallengeStatus.REJECTED:
        color = Colors.red;
        text = 'RECHAZADO';
        break;
      case ChallengeStatus.FINISHED:
        color = AppColors.primary;
        text = 'FINALIZADO';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _acceptChallenge(String id) async {
    try {
      await _challengeService.acceptChallenge(id);
      _loadChallenges();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _rejectChallenge(String id) async {
    try {
      await _challengeService.rejectChallenge(id);
      _loadChallenges();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showUpdateRecordDialog() {
    final TextEditingController exerciseController = TextEditingController();
    final TextEditingController weightController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Actualizar Marca Personal', style: TextStyle(color: AppColors.textMain)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: exerciseController,
              decoration: const InputDecoration(
                labelText: 'Ejercicio (ej: Press Banca)',
                labelStyle: TextStyle(color: AppColors.secondary),
              ),
              style: const TextStyle(color: AppColors.textMain),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: weightController,
              decoration: const InputDecoration(
                labelText: 'Peso (kg)',
                labelStyle: TextStyle(color: AppColors.secondary),
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textMain),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.secondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final exercise = exerciseController.text;
              final weight = double.tryParse(weightController.text);
              if (exercise.isNotEmpty && weight != null) {
                try {
                  await _challengeService.updateRecord(exercise, weight);
                  if (mounted) {
                    Navigator.pop(context);
                    _loadChallenges();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marca actualizada')));
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
