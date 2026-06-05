import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/catalog_exercise_model.dart';
import '../../data/models/exercise_catalog.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final CatalogExerciseModel exercise;

  ExerciseDetailScreen({super.key, required this.exercise});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isVideoError = false;
  double _videoHeight = 300;

  @override
  void initState() {
    super.initState();
    if (widget.exercise.videoUrl != null && widget.exercise.videoUrl!.isNotEmpty) {
      _initializeVideo(widget.exercise.videoUrl!);
    }
  }

  Future<void> _initializeVideo(String source) async {
    try {
      if (source.startsWith('assets/')) {
        _videoController = VideoPlayerController.asset(source);
      } else {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(source));
      }
      await _videoController!.initialize();
      _videoController!.setLooping(true);
      _videoController!.setVolume(0);
      _videoController!.play();
      if (mounted) {
        final screenWidth = MediaQuery.of(context).size.width;
        final aspectRatio = _videoController!.value.aspectRatio;
        final calculatedHeight = screenWidth / aspectRatio;
        setState(() {
          _isVideoInitialized = true;
          _videoHeight = calculatedHeight.clamp(250.0, 500.0);
        });
      }
    } catch (e) {
      debugPrint("Error al inicializar video: $e");
      if (mounted) {
        setState(() {
          _isVideoError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: context.colors.surface,
            expandedHeight: _videoHeight,
            pinned: true,
            iconTheme: IconThemeData(color: context.colors.textMain),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildVideoPlayer(),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: context.colors.background,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              padding: EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.exercise.name,
                    style: TextStyle(
                      color: context.colors.textMain,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 24),
                  
                  _buildSectionTitle('¿Para qué sirve?', Icons.info_outline_rounded),
                  SizedBox(height: 12),
                  Text(
                    widget.exercise.description,
                    style: TextStyle(
                      color: context.colors.textMain.withOpacity(0.7),
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                  
                  SizedBox(height: 32),
                  
                  _buildSectionTitle('Beneficios Principales', Icons.star_border_rounded),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: context.colors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: context.colors.primary.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: context.colors.primary,
                          size: 24,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            widget.exercise.benefits,
                            style: TextStyle(
                              color: context.colors.textMain,
                              fontSize: 15,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _isVideoInitialized ? FloatingActionButton(
        backgroundColor: context.colors.primary,
        onPressed: () {
          setState(() {
            _videoController!.value.isPlaying
                ? _videoController!.pause()
                : _videoController!.play();
          });
        },
        child: Icon(
          _videoController!.value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: Colors.black,
        ),
      ) : null,
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: context.colors.secondary, size: 24),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: context.colors.textMain,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPlayer() {
    if (_isVideoError) {
      return Container(
        color: context.colors.surface,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
            SizedBox(height: 16),
            Text(
              'No se pudo cargar el video.',
              style: TextStyle(color: context.colors.textMain.withOpacity(0.5)),
            )
          ],
        ),
      );
    }

    if (_isVideoInitialized && _videoController != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: _videoController!.value.size.width,
              height: _videoController!.value.size.height,
              child: VideoPlayer(_videoController!),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.transparent,
                  context.colors.background.withOpacity(0.8),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      color: context.colors.surface,
      child: Center(
        child: CircularProgressIndicator(color: context.colors.primary),
      ),
    );
  }
}

CatalogExerciseModel toCatalogModel(CatalogExercise ex) {
  return CatalogExerciseModel(
    id: 0,
    name: ex.name,
    description: ex.description,
    benefits: 'Fortalece y desarrolla los ${ex.muscleGroup.toLowerCase()}. Ideal para mejorar el rendimiento y la estética muscular.',
    videoUrl: ex.videoAsset,
  );
}
