// Madhu Sudhan Reddy Konda-002847774
// Sri Haneesha Davuluri-002804845

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() => runApp(HalloweenApp());

class HalloweenApp extends StatefulWidget {
  @override
  _HalloweenAppState createState() => _HalloweenAppState();
}

class _HalloweenAppState extends State<HalloweenApp> {
  late AudioPlayer _spookyPlayer;
  late AudioPlayer _bgMusicPlayer;
  late AudioPlayer _successPlayer;
  final Random _random = Random();
  bool _foundItem = false;
  bool _showPumpkin = true;
  bool _isMusicOn = true; // To track if music is on or off
  String _message = "Find the Pumpkin!";
  late Offset _pumpkinPosition;
  List<Offset> _positions = [];

  @override
  void initState() {
    super.initState();
    _initializeAudioPlayers();
    if (_isMusicOn) {
      _playSpookySoundContinuously(); // Start spooky sound immediately if music is on
    }
    _resetGame();
    _startPumpkinAnimation(); // Start the pumpkin show-hide cycle
  }

  // Initialize audio players
  void _initializeAudioPlayers() {
    _spookyPlayer = AudioPlayer();
    _bgMusicPlayer = AudioPlayer();
    _successPlayer = AudioPlayer();
  }

  // Play spooky sound in a loop as soon as the app starts
  void _playSpookySoundContinuously() async {
    await _spookyPlayer.setSource(
        AssetSource('sounds/spooky_effect.mp3')); // Set spooky sound source
    _spookyPlayer.setReleaseMode(ReleaseMode.loop); // Loop the spooky sound
    await _spookyPlayer.resume(); // Start playing
  }

  // Play background Halloween music when a ghost is tapped
  void _playBackgroundMusic() async {
    _stopSpookyMusic(); // Stop spooky music only
    await _bgMusicPlayer.setSource(AssetSource('sounds/halloween_bg.mp3'));
    _bgMusicPlayer.setReleaseMode(ReleaseMode.loop);
    _bgMusicPlayer.resume(); // Play Halloween background music in loop
  }

  // Play success sound when the pumpkin is tapped
  void _playSuccessSound() async {
    _stopAllSounds(); // Stop all sounds before playing success sound
    await _successPlayer.play(AssetSource('sounds/success_sound.mp3'));
  }

  // Stop only spooky music
  void _stopSpookyMusic() {
    _spookyPlayer.stop();
  }

  // Stop all sounds (when resetting the game or when the pumpkin is clicked)
  void _stopAllSounds() {
    _spookyPlayer.stop();
    _bgMusicPlayer.stop();
    _successPlayer.stop();
  }

  // Toggle music on or off
  void _toggleMusic() {
    setState(() {
      _isMusicOn = !_isMusicOn;
      if (_isMusicOn) {
        _playSpookySoundContinuously(); // Start playing music if turned on
      } else {
        _stopAllSounds(); // Stop all sounds if turned off
      }
    });
  }

  // Randomize positions for the ghosts and pumpkin
  void _resetGame() {
    setState(() {
      _foundItem = false;
      _showPumpkin = true; // Show the pumpkin initially
      _message = "Find the Pumpkin!";
      _positions = List.generate(6, (_) => _randomPosition());
      _pumpkinPosition = _randomPosition(); // Initialize pumpkin position
      if (_isMusicOn) {
        _playSpookySoundContinuously(); // Restart spooky sound when resetting
      }
      _startPumpkinAnimation(); // Restart pumpkin show-hide cycle
    });
  }

  // Get a random position on the screen
  Offset _randomPosition() {
    double x = _random.nextDouble() * 300 + 50; // Random x position
    double y = _random.nextDouble() * 500 + 100; // Random y position
    return Offset(x, y);
  }

  // Handle ghost tap
  void _onTapGhost() {
    if (_isMusicOn) {
      _playBackgroundMusic(); // Play Halloween background music
    }
    setState(() {
      _message = "Boo! Wrong Item!";
    });
  }

  // Handle pumpkin tap
  void _onTapPumpkin() {
    if (_isMusicOn) {
      _playSuccessSound(); // Play success sound when pumpkin is tapped
    }
    setState(() {
      _foundItem = true;
      _message = "You Found the Pumpkin!";
      _showPumpkin = false; // Stop showing the pumpkin
    });
  }

  // Continuously animate pumpkin to appear for 7 seconds, disappear for 4 seconds
  void _startPumpkinAnimation() async {
    while (!_foundItem) {
      setState(() {
        _showPumpkin = true;
        _pumpkinPosition = _randomPosition(); // Update pumpkin position
      });

      await Future.delayed(
          Duration(seconds: 7)); // Pumpkin visible for 7 seconds

      setState(() {
        _showPumpkin = false; // Hide pumpkin
      });

      await Future.delayed(
          Duration(seconds: 4)); // Pumpkin hidden for 4 seconds
    }
  }

  @override
  void dispose() {
    _spookyPlayer.dispose();
    _bgMusicPlayer.dispose();
    _successPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                'assets/images/happy_halloween_bg.png',
                fit: BoxFit.cover,
              ),
            ),
            // Display ghosts and pumpkin
            ..._buildGhostsAndPumpkin(),
            // Message
            Positioned(
              top: 50,
              left: 50,
              child: Text(
                _message,
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Music Toggle Button at the top right corner
            Positioned(
              top: 50,
              right: 20,
              child: IconButton(
                icon: Icon(
                  _isMusicOn ? Icons.music_note : Icons.music_off,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: _toggleMusic, // Toggle music on or off
              ),
            ),
            // Play again button
            if (_foundItem)
              Center(
                child: ElevatedButton(
                  onPressed: _resetGame,
                  child: Text("Play Again"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    textStyle: TextStyle(fontSize: 20),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Create widgets for ghosts and pumpkin
  List<Widget> _buildGhostsAndPumpkin() {
    List<Widget> ghostsAndPumpkin = [];

    // Add ghosts
    for (int i = 0; i < 6; i++) {
      ghostsAndPumpkin.add(
        Positioned(
          left: _positions[i].dx,
          top: _positions[i].dy,
          child: GestureDetector(
            onTap: _onTapGhost,
            child: Image.asset(
              'assets/images/spooky_ghost.png',
              width: 100,
            )
                .animate(onComplete: (controller) {
                  controller.repeat(); // Repeat the animation
                })
                .shakeX(duration: 1000.ms)
                .then() // Add shake animation
                .moveX(
                    duration: 1000.ms, begin: -10, end: 10), // Floating effect
          ),
        ),
      );
    }

    // Add pumpkin with show-hide cycle
    if (_showPumpkin) {
      ghostsAndPumpkin.add(
        Positioned(
          left: _pumpkinPosition.dx,
          top: _pumpkinPosition.dy,
          child: GestureDetector(
            onTap: _onTapPumpkin,
            child: Image.asset(
              'assets/images/scary_pumpkin.png',
              width: 120,
            ),
          ),
        ),
      );
    }

    return ghostsAndPumpkin;
  }
}
