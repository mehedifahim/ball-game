A Flutter implementation of a bucket ball collection game where players control a bucket to catch falling balls.

Features
-  Touch or keyboard controls (arrow keys)
-  Pause/Resume functionality
-  Adjustable ball speed settings
-  Progressive difficulty (speed increases with levels)
-  Score tracking and level system

Installation
1. Ensure Flutter is installed 
   Run `flutter doctor` to verify

2. Clone the repository
   https://github.com/mehedifahim/ball-game.git

3. Install dependencies 
   flutter pub get

4. Run the game
   flutter run

Files
lib/main.dart – Core game logic and UI
pubspec.yaml – Manages dependencies and assets
android/ & ios/ – Platform-specific configurations

Configuration
Adjust game settings via:
1. Click the settings gear icon in app bar
2. Modify ball speed using the slider
3. Click "Apply" to save changes

How to Play
1. Balls/coins will fall from the top
2. Move the bucket to catch them
3. Each catch increases the score
4. Every 20 points increases the level and speed
5. Game ends if you miss a ball

Github: https://github.com/mehedifahim/ball-game.git 
