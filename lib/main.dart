import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BucketGame(),
    );
  }
}

class Ball {
  double x;
  double y;
  Color color;
  bool isCollected = false;
  Ball(this.x, this.y, this.color);
}

class BucketGame extends StatefulWidget {
  const BucketGame({super.key});

  @override
  State<BucketGame> createState() => _BucketGameState();
}

class _BucketGameState extends State<BucketGame> {
  double bucketX = 0;
  int score = 0;
  int level = 1;
  bool isGameOver = false;
  bool isPaused = false;
  Timer? gameTimer;
  List<Ball> balls = [];
  final Random random = Random();
  final List<Color> ballColors = [
    Colors.amber,
    Colors.green,
    Colors.red,
    Colors.blue,
    Colors.purple
  ];
  int frameCount = 0;
  double ballSpeed = 0.003;
  double savedBallSpeed = 0.003;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    isGameOver = false;
    isPaused = false;
    score = 0;
    level = 1;
    ballSpeed = 0.003;
    balls.clear();
    frameCount = 0;
    
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (isGameOver || isPaused) return;
      
      frameCount++;
      
      // Update ball positions
      for (final ball in balls) {
        if (!ball.isCollected) {
          ball.y += ballSpeed;
        }
      }

      // Add new balls at controlled rate
      if (frameCount % max(50 - level, 20) == 0) {
        balls.add(Ball(
          random.nextDouble() * 2 - 1,
          -0.1,
          ballColors[random.nextInt(ballColors.length)],
        ));
      }

      // Check for ball collection
      final collectedBalls = <Ball>[];
      for (final ball in balls) {
        if (!ball.isCollected && 
            (ball.x - bucketX).abs() < 0.2 && 
            ball.y >= 0.8 - 0.03 && 
            ball.y <= 0.8 + 0.03) {
          
          ball.isCollected = true;
          collectedBalls.add(ball);
          score++;
          
          if (score >= level * 20) {
            level++;
            ballSpeed += 0.0005;
          }
        }
      }

      // Remove collected balls
      if (collectedBalls.isNotEmpty) {
        Future.microtask(() {
          if (mounted) {
            setState(() {
              balls.removeWhere((ball) => collectedBalls.contains(ball));
            });
          }
        });
      }

      // Check for game over
      for (final ball in balls) {
        if (!ball.isCollected && ball.y > 1.0) {
          isGameOver = true;
          timer.cancel();
          if (mounted) setState(() {});
          break;
        }
      }

      if (mounted) setState(() {});
    });
  }

  void _togglePause() {
    setState(() {
      isPaused = !isPaused;
      if (isPaused) {
        savedBallSpeed = ballSpeed;
        ballSpeed = 0;
      } else {
        ballSpeed = savedBallSpeed;
      }
    });
  }

  void _restartGame() {
    gameTimer?.cancel();
    _startGame();
  }

  void _moveBucket(DragUpdateDetails details) {
    if (isPaused || isGameOver) return;
    setState(() {
      bucketX += details.delta.dx / MediaQuery.of(context).size.width * 2;
      bucketX = bucketX.clamp(-1.0, 1.0);
    });
  }

  void _updateBallSpeed(double newSpeed) {
    setState(() {
      ballSpeed = newSpeed;
      // If game is paused, update the saved speed too
      if (isPaused) {
        savedBallSpeed = newSpeed;
      }
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bucketWidth = screenWidth * 0.2;
    final bucketHeight = screenHeight * 0.15;

    return Scaffold(
      backgroundColor: Colors.lightBlue.shade100,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              const Icon(Icons.monetization_on, color: Colors.yellow),
              const SizedBox(width: 5),
              Text('$score', style: const TextStyle(fontSize: 20)),
            ]),
            Text('LEVEL $level', style: const TextStyle(fontSize: 20)),
            Row(
              children: [
                IconButton(
                  icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
                  onPressed: _togglePause,
                  color: Colors.white,
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () => _showSettingsDialog(context),
                  color: Colors.white,
                ),
              ],
            ),
          ],
        ),
      ),
      body: GestureDetector(
        onHorizontalDragUpdate: _moveBucket,
        child: Stack(
          children: [
            // Balls
            for (final ball in balls)
              Positioned(
                left: (ball.x + 1) / 2 * screenWidth - 15,
                top: ball.y * screenHeight,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 100),
                  opacity: ball.isCollected ? 0 : 1,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ball.color,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Bucket
            Positioned(
              left: (bucketX + 1) / 2 * screenWidth - bucketWidth / 2,
              top: 0.8 * screenHeight,
              child: Container(
                width: bucketWidth,
                height: bucketHeight,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                    topLeft: Radius.circular(5),
                    topRight: Radius.circular(5),
                  ),
                  color: Colors.pink.shade400,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shopping_basket,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),

            // Game over overlay
            if (isGameOver)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Game Over',
                        style: TextStyle(fontSize: 30, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Score: $score',
                        style: const TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      Text(
                        'Reached Level: $level',
                        style: const TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _restartGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink.shade400,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                        ),
                        child: const Text(
                          'Restart',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Pause overlay
            if (isPaused && !isGameOver)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Game Paused',
                        style: TextStyle(fontSize: 30, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _togglePause,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink.shade400,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                        ),
                        child: const Text(
                          'Resume',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    double newBallSpeed = isPaused ? savedBallSpeed : ballSpeed;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Game Settings'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text('Ball Speed'),
                    subtitle: Slider(
                      value: newBallSpeed,
                      min: 0.002,
                      max: 0.006,
                      divisions: 4,
                      label: '${(newBallSpeed * 1000).round()}',
                      onChanged: (value) {
                        setState(() => newBallSpeed = value);
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _updateBallSpeed(newBallSpeed);
                    },
                    child: const Text('Apply'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}