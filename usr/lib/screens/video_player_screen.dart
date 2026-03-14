import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> with TickerProviderStateMixin {
  late VideoPlayerController _controller;
  late TabController _tabController;
  late AnimationController _avatarController;
  bool _isInitialized = false;
  String _currentCaption = "Welcome to this lesson!";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Animation for the floating teacher avatar to make it look alive/talking
    _avatarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    // Using a rich animated video placeholder to simulate the generated background
    _controller = VideoPlayerController.networkUrl(
      Uri.parse('https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'),
    )..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        _controller.play();
        _controller.setLooping(true);
      });

    // Listen to video progress to update the simulated captions
    _controller.addListener(_updateCaptions);
  }

  void _updateCaptions() {
    if (!_controller.value.isInitialized) return;
    
    final position = _controller.value.position.inSeconds;
    String newCaption = _currentCaption;
    
    // Simulated script syncing with the video
    if (position < 4) {
      newCaption = "Welcome to this lesson on photosynthesis.";
    } else if (position < 9) {
      newCaption = "Have you ever wondered how plants get their food?";
    } else if (position < 15) {
      newCaption = "Instead, they make their own food using a process called photosynthesis.";
    } else if (position < 22) {
      newCaption = "The word comes from 'photo' meaning light, and 'synthesis' meaning putting together.";
    } else {
      newCaption = "Plants take in carbon dioxide from the air and water from the soil.";
    }
    
    if (newCaption != _currentCaption) {
      setState(() {
        _currentCaption = newCaption;
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_updateCaptions);
    _controller.dispose();
    _tabController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Lesson: Photosynthesis'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Video Player Area with AI Teacher Overlay
          Container(
            width: double.infinity,
            color: Colors.black,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: _isInitialized
                  ? Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        // 1. Main Background Video
                        VideoPlayer(_controller),
                        
                        // 2. Play/Pause Controls
                        _ControlsOverlay(controller: _controller),
                        
                        // 3. Dynamic Captions Overlay
                        Positioned(
                          bottom: 30,
                          left: 20,
                          right: 120, // Leave space for the avatar
                          child: AnimatedOpacity(
                            opacity: _controller.value.isPlaying ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _currentCaption,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        
                        // 4. Animated Teacher Avatar (Picture-in-Picture)
                        Positioned(
                          bottom: 20,
                          right: 20,
                          child: AnimatedBuilder(
                            animation: _avatarController,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, -8 * _avatarController.value),
                                child: child,
                              );
                            },
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade50,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.primary, 
                                  width: 3
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  )
                                ],
                                image: const DecorationImage(
                                  // Using DiceBear to generate a cartoon teacher avatar
                                  image: NetworkImage('https://api.dicebear.com/7.x/avataaars/png?seed=Teacher&backgroundColor=e0e7ff'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        // 5. Progress Bar
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: VideoProgressIndicator(_controller, allowScrubbing: true),
                        ),
                      ],
                    )
                  : const Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
          ),
          
          // Tabs for Study Material
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(text: 'Summary'),
              Tab(text: 'Transcript'),
            ],
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSummaryTab(),
                _buildTranscriptTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Key Takeaways',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildBulletPoint('Photosynthesis is the process used by plants to convert light energy into chemical energy.'),
        _buildBulletPoint('It requires sunlight, carbon dioxide, and water.'),
        _buildBulletPoint('The primary output is glucose (sugar) and oxygen.'),
        _buildBulletPoint('Chlorophyll is the green pigment responsible for capturing light energy.'),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Study Tip',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Remember the formula: 6CO2 + 6H2O + Light → C6H12O6 + 6O2',
                style: TextStyle(color: Colors.blue.shade900),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 12),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildTranscriptLine('0:00', 'Welcome to this lesson on photosynthesis.'),
        _buildTranscriptLine('0:05', 'Have you ever wondered how plants get their food? Unlike animals, they don\'t eat.'),
        _buildTranscriptLine('0:12', 'Instead, they make their own food using a process called photosynthesis.'),
        _buildTranscriptLine('0:18', 'The word comes from "photo" meaning light, and "synthesis" meaning putting together.'),
        _buildTranscriptLine('0:25', 'Plants take in carbon dioxide from the air and water from the soil.'),
        _buildTranscriptLine('0:32', 'Using the energy from sunlight, captured by chlorophyll in their leaves...'),
      ],
    );
  }

  Widget _buildTranscriptLine(String time, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            time,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({required this.controller});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 60.0,
                      semanticLabel: 'Play',
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}
