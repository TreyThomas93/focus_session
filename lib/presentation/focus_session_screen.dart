import 'package:audioplayers/audioplayers.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';

// scaffold messnger key
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class FocusSessionScreen extends StatefulWidget {
  const FocusSessionScreen({super.key});

  @override
  State<FocusSessionScreen> createState() => _FocusSessionScreenState();
}

class _FocusSessionScreenState extends State<FocusSessionScreen> {
  final player = AudioPlayer();

  final int _minutes = 45;

  bool _isFinished = false;

  bool _isPaused = false;

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  // reset
  void resetTimer() {
    _controller.restart(duration: _minutes * 60);
    setState(() {
      _isPaused = false;
      _isFinished = false;
    });
  }

  // resume time
  void resumeTimer() {
    _controller.resume();
    setState(() {
      _isPaused = false;
    });
  }

  // pause time
  void pauseTimer() {
    _controller.pause();
    setState(() {
      _isPaused = true;
    });
  }

  // show snackbar
  void showSnackbar(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message,
            style: const TextStyle(fontSize: 14, color: Colors.white)),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.blueGrey,
      ),
    );
  }

  final CountDownController _controller = CountDownController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularCountDownTimer(
                duration: _minutes * 60,
                initialDuration: 0,
                controller: _controller,
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.height / 2,
                ringColor: Colors.grey[300]!,
                ringGradient: null,
                fillColor: const Color.fromARGB(255, 39, 92, 135),
                fillGradient: null,
                backgroundColor: Colors.transparent,
                backgroundGradient: null,
                strokeWidth: 10.0,
                strokeCap: StrokeCap.square,
                textStyle: const TextStyle(
                    fontSize: 33.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                textFormat: CountdownTextFormat.S,
                isReverse: true,
                isReverseAnimation: false,
                isTimerTextShown: true,
                autoStart: true,
                onStart: () {
                  debugPrint('Countdown Started');
                },
                onComplete: () async {
                  setState(() {
                    _isFinished = true;
                  });
                  await player
                      .play(AssetSource('audio/countdown_complete.mp3'));
                  showSnackbar('$_minutes minute focus session completed');
                },
                onChange: (String timeStamp) {
                  debugPrint('Countdown Changed $timeStamp');
                },
                timeFormatterFunction: (defaultFormatterFunction, duration) {
                  final days = duration.inDays;
                  final hours = duration.inHours;
                  final minutes = duration.inMinutes;
                  final seconds = duration.inSeconds;

                  if (seconds == 0) {
                    return Function.apply(defaultFormatterFunction, [duration]);
                  }

                  if (days != 0) {
                    return '$days:${(hours % 24).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
                  } else if (hours != 0) {
                    return '${(hours % 24).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
                  } else if (minutes != 0) {
                    return '${(minutes % 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
                  } else {
                    return (seconds % 60).toString().padLeft(2, '0');
                  }
                },
              ),
              if (_isFinished)
                ElevatedButton(
                  onPressed: () => resetTimer(),
                  child: const Text('Restart'),
                )
              else if (_isPaused)
                // resume button
                ...[
                ElevatedButton(
                  onPressed: () => resumeTimer(),
                  child: const Text('Resume'),
                ),
                const SizedBox(height: 24),
                // reset
                ElevatedButton(
                  onPressed: () => resetTimer(),
                  child: const Text('Reset'),
                ),
              ] else
                // pause button
                ElevatedButton(
                  onPressed: () => pauseTimer(),
                  child: const Text('Pause'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
