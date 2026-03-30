import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/arrow_model.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';
import '../services/audio_service.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/victory_overlay.dart';
import '../widgets/life_indicator.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  final AudioService _audioService = AudioService();
  late AnimationController _pulseController;

  // Settings overlay state
  bool _showSettingsOverlay = false;
  late AnimationController _settingsController;
  late Animation<Offset> _settingsSlide;
  late Animation<double> _settingsFade;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _settingsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    _settingsSlide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _settingsController, curve: Curves.easeInOut),
    );

    _settingsFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _settingsController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _audioService.playGameMusic();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _settingsController.dispose();
    super.dispose();
  }

  void _toggleSettingsOverlay() {
    setState(() => _showSettingsOverlay = !_showSettingsOverlay);
    if (_showSettingsOverlay) {
      _settingsController.forward();
    } else {
      _settingsController.reverse();
    }
  }

  String _getDifficultyText(int level) {
    if (level <= 2) return 'Easy';
    if (level <= 4) return 'Normal';
    if (level <= 6) return 'Hard';
    if (level <= 8) return 'Expert';
    return 'Master';
  }

  Color _getDifficultyColor(int level) {
    if (level <= 2) return Colors.greenAccent;
    if (level <= 4) return Colors.yellowAccent;
    if (level <= 6) return Colors.orangeAccent;
    if (level <= 8) return Colors.redAccent;
    return AppColors.purple;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _audioService.stopGameMusic();
        }
      },
      child: Consumer<GameProvider>(
        builder: (context, game, child) {
          return Scaffold(
            backgroundColor: AppColors.backgroundDark,
            body: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AppConstants.background),
                  fit: BoxFit.cover,
                  opacity: 0.15,
                ),
              ),
              child: SafeArea(
                child: Stack(
                  children: [
                    // Main game column
                    Column(
                      children: [
                        _buildTopBar(context, game, size),
                        _buildTimerBar(game, size),
                        Expanded(
                          child: Center(
                            child: _buildGameGrid(game, size),
                          ),
                        ),
                        _buildBottomHint(size),
                      ],
                    ),

                    // In-game Settings Overlay (slides from top)
                    if (_showSettingsOverlay) ...[
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: _toggleSettingsOverlay,
                          child: FadeTransition(
                            opacity: _settingsFade,
                            child: Container(
                              color: Colors.black.withAlpha(120),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: SlideTransition(
                          position: _settingsSlide,
                          child: _buildSettingsPanel(size),
                        ),
                      ),
                    ],

                    // Game Over overlay — Loss sound plays here only
                    if (game.isGameOver)
                      GameOverOverlay(
                        onRetry: () {
                          _audioService.playGameMusic();
                          game.initLevel(game.currentLevel);
                        },
                        onBack: () {
                          _audioService.stopGameMusic();
                          Navigator.pop(context);
                        },
                      ),

                    // Victory overlay — Win sound plays here only
                    if (game.isLevelWon)
                      VictoryOverlay(
                        onNext: () {
                          _audioService.playGameMusic();
                          game.nextLevel();
                        },
                        onBack: () {
                          _audioService.stopGameMusic();
                          Navigator.pop(context);
                        },
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Top Bar: Back (LEFT) | Center info | Settings (RIGHT) — swapped per spec
  Widget _buildTopBar(BuildContext context, GameProvider game, Size size) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: size.width * 0.03, vertical: 8),
      child: Row(
        children: [
          // ← Back button is now on the LEFT
          _buildIconBtn(
            icon: Icons.arrow_back_ios_new,
            onTap: () {
              _audioService.stopGameMusic();
              Navigator.pop(context);
            },
            size: size,
          ),

          // Center: level name + difficulty badge + lives
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'LEVEL ${game.currentLevel}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size.width * 0.04,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(game.currentLevel)
                            .withAlpha(50),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getDifficultyColor(game.currentLevel),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getDifficultyText(game.currentLevel),
                        style: TextStyle(
                          color: _getDifficultyColor(game.currentLevel),
                          fontSize: size.width * 0.03,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LifeIndicator(currentLives: game.lives),
              ],
            ),
          ),

          // ⚙ Settings button is now on the RIGHT
          _buildIconBtn(
            icon: Icons.settings,
            onTap: _toggleSettingsOverlay,
            size: size,
            highlighted: _showSettingsOverlay,
          ),
        ],
      ),
    );
  }

  // Animated settings panel — slides down from top when Settings tapped
  Widget _buildSettingsPanel(Size size) {
    return Container(
      margin: EdgeInsets.fromLTRB(
          size.width * 0.06, 8, size.width * 0.06, 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(30), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(140),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SETTINGS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 1.8,
                ),
              ),
              GestureDetector(
                onTap: _toggleSettingsOverlay,
                child: Icon(Icons.close,
                    color: Colors.white.withAlpha(160), size: 18),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Music toggle
          _buildAnimatedToggle(
            label: 'Music',
            icon: Icons.music_note_rounded,
            value: _audioService.isMusicOn,
            onChanged: (_) => setState(() => _audioService.toggleMusic()),
          ),
          const SizedBox(height: 10),
          // Sound FX toggle
          _buildAnimatedToggle(
            label: 'Sound FX',
            icon: Icons.volume_up_rounded,
            value: _audioService.isSfxOn,
            onChanged: (_) => setState(() => _audioService.toggleSfx()),
          ),
        ],
      ),
    );
  }

  // Smooth animated toggle: 260ms easeInOut track + thumb slide
  Widget _buildAnimatedToggle({
    required String label,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    const dur = Duration(milliseconds: 260);
    const curve = Curves.easeInOut;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.cyan, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => onChanged(!value),
          child: AnimatedContainer(
            duration: dur,
            curve: curve,
            width: 52,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: value
                  ? AppColors.cyan.withAlpha(180)
                  : Colors.white.withAlpha(40),
              border: Border.all(
                color: value
                    ? AppColors.cyan
                    : Colors.white.withAlpha(60),
                width: 1.5,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedAlign(
                  duration: dur,
                  curve: curve,
                  alignment:
                      value ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: value
                          ? AppColors.cyan
                          : Colors.white.withAlpha(200),
                      boxShadow: [
                        BoxShadow(
                          color: value
                              ? AppColors.cyan.withAlpha(130)
                              : Colors.black.withAlpha(60),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: dur,
                        child: Text(
                          value ? 'ON' : 'OFF',
                          key: ValueKey(value),
                          style: TextStyle(
                            fontSize: 7,
                            fontWeight: FontWeight.bold,
                            color: value
                                ? Colors.black.withAlpha(180)
                                : Colors.white.withAlpha(180),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconBtn({
    required IconData icon,
    required VoidCallback onTap,
    required Size size,
    bool highlighted = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size.width * 0.1,
        height: size.width * 0.1,
        decoration: BoxDecoration(
          color: highlighted
              ? AppColors.cyan.withAlpha(40)
              : Colors.white.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: highlighted
                ? AppColors.cyan.withAlpha(180)
                : Colors.white.withAlpha(40),
          ),
        ),
        child: Icon(
          icon,
          color: highlighted ? AppColors.cyan : Colors.white,
          size: size.width * 0.055,
        ),
      ),
    );
  }

  Widget _buildTimerBar(GameProvider game, Size size) {
    final double progress = game.timeLeft / 60.0;
    final Color timerColor = game.timeLeft > 20
        ? AppColors.cyan
        : game.timeLeft > 10
            ? Colors.orange
            : Colors.red;

    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: size.width * 0.04, vertical: 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer, color: timerColor, size: size.width * 0.04),
              const SizedBox(width: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  color: timerColor,
                  fontSize: game.timeLeft <= 10
                      ? size.width * 0.06
                      : size.width * 0.045,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
                child: Text('${game.timeLeft}s'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: 6,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withAlpha(30),
                valueColor: AlwaysStoppedAnimation<Color>(timerColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameGrid(GameProvider game, Size size) {
    final double padding = size.width * 0.04;
    final double gridPixels = size.width - (padding * 2);
    final double cellSize = gridPixels / game.gridSize;

    return Container(
      width: gridPixels,
      height: gridPixels,
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(80),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(20), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: game.arrows
              .where((a) => !a.isRemoved)
              .map((arrow) => _buildArrowWidget(arrow, cellSize, size))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildArrowWidget(ArrowModel arrow, double cellSize, Size size) {
    IconData icon;
    Offset escapeTarget;

    switch (arrow.direction) {
      case ArrowDirection.up:
        icon = Icons.arrow_upward_rounded;
        escapeTarget = Offset(0, -(size.height));
        break;
      case ArrowDirection.down:
        icon = Icons.arrow_downward_rounded;
        escapeTarget = Offset(0, size.height);
        break;
      case ArrowDirection.left:
        icon = Icons.arrow_back_rounded;
        escapeTarget = Offset(-size.width, 0);
        break;
      case ArrowDirection.right:
        icon = Icons.arrow_forward_rounded;
        escapeTarget = Offset(size.width, 0);
        break;
      case ArrowDirection.white:
        icon = Icons.circle;
        escapeTarget = Offset.zero;
        break;
    }

    final double margin = cellSize * 0.08;
    final double iconSize = cellSize * 0.65;

    return _AnimatedArrow(
      key: ValueKey('${arrow.x}_${arrow.y}_${arrow.direction}'),
      arrow: arrow,
      cellSize: cellSize,
      margin: margin,
      icon: icon,
      iconSize: iconSize,
      escapeTarget: escapeTarget,
      onTap: () => context.read<GameProvider>().tapArrow(arrow),
    );
  }

  Widget _buildBottomHint(Size size) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        'TAP ARROWS TO CLEAR THE PATH',
        style: TextStyle(
          fontSize: size.width * 0.032,
          color: Colors.white.withAlpha(80),
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

// ─── Animated Arrow Widget ────────────────────────────────────────────────────

class _AnimatedArrow extends StatefulWidget {
  final ArrowModel arrow;
  final double cellSize;
  final double margin;
  final IconData icon;
  final double iconSize;
  final Offset escapeTarget;
  final VoidCallback onTap;

  const _AnimatedArrow({
    super.key,
    required this.arrow,
    required this.cellSize,
    required this.margin,
    required this.icon,
    required this.iconSize,
    required this.escapeTarget,
    required this.onTap,
  });

  @override
  State<_AnimatedArrow> createState() => _AnimatedArrowState();
}

class _AnimatedArrowState extends State<_AnimatedArrow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arrow = widget.arrow;
    final left = arrow.x * widget.cellSize;
    final top = arrow.y * widget.cellSize;

    if (arrow.isEscaping) {
      return TweenAnimationBuilder<Offset>(
        tween: Tween<Offset>(
          begin: Offset.zero,
          end: widget.escapeTarget,
        ),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeIn,
        builder: (context, offset, child) {
          return Positioned(
            left: left + offset.dx,
            top: top + offset.dy,
            width: widget.cellSize,
            height: widget.cellSize,
            child: Opacity(
              opacity: (1.0 -
                      (offset.distance /
                          (widget.escapeTarget.distance + 1)))
                  .clamp(0.0, 1.0),
              child: _arrowBody(arrow),
            ),
          );
        },
      );
    }

    return Positioned(
      left: left,
      top: top,
      width: widget.cellSize,
      height: widget.cellSize,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _scaleAnim,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnim.value,
            child: child,
          ),
          child: _arrowBody(arrow),
        ),
      ),
    );
  }

  Widget _arrowBody(ArrowModel arrow) {
    return Container(
      margin: EdgeInsets.all(widget.margin),
      decoration: BoxDecoration(
        color: arrow.color.withAlpha(60),
        borderRadius: BorderRadius.circular(widget.cellSize * 0.2),
        border: Border.all(
          color: arrow.color,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: arrow.color.withAlpha(80),
            blurRadius: 6,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          widget.icon,
          color: arrow.color,
          size: widget.iconSize,
        ),
      ),
    );
  }
}
