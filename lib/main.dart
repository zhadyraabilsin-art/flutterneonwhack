import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const NeonReflexApp());
}

class NeonReflexApp extends StatelessWidget {
  const NeonReflexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Neon Reflex Arcade',
      theme: ThemeData.dark(useMaterial3: true),
      home: const ReflexGameScreen(),
    );
  }
}

class ReflexGameScreen extends StatefulWidget {
  const ReflexGameScreen({super.key});

  @override
  State<ReflexGameScreen> createState() => _ReflexGameScreenState();
}

class _ReflexGameScreenState extends State<ReflexGameScreen> {
  static const int _gridSize = 9;
  int _activeCell = -1;
  bool _isBonusTarget = false;
  int _score = 0;
  int _highScore = 0;
  int _timeLeft = 30;
  bool _isPlaying = false;

  Timer? _countdownTimer;
  Timer? _spawnTimer;
  final Random _random = Random();

  void _startGame() {
    _countdownTimer?.cancel();
    _spawnTimer?.cancel();

    setState(() {
      _score = 0;
      _timeLeft = 30;
      _isPlaying = true;
      _spawnNextTarget();
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft <= 1) {
        _endGame();
      } else {
        setState(() => _timeLeft--);
      }
    });

    _spawnTimer = Timer.periodic(const Duration(milliseconds: 750), (timer) {
      if (_isPlaying) {
        setState(() => _spawnNextTarget());
      }
    });
  }

  void _spawnNextTarget() {
    int next = _random.nextInt(_gridSize);
    while (next == _activeCell) {
      next = _random.nextInt(_gridSize);
    }
    _activeCell = next;
    _isBonusTarget = _random.nextInt(5) == 0; // 20% бонус нысана
  }

  void _onCellTap(int index) {
    if (!_isPlaying) return;

    if (index == _activeCell) {
      setState(() {
        _score += _isBonusTarget ? 25 : 10;
        if (_score > _highScore) _highScore = _score;
        _spawnNextTarget();
      });
    } else {
      setState(() {
        _score = max(0, _score - 5);
      });
    }
  }

  void _endGame() {
    _countdownTimer?.cancel();
    _spawnTimer?.cancel();
    setState(() {
      _isPlaying = false;
      _activeCell = -1;
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _spawnTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0D16),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'NEON REFLEX',
          style: TextStyle(letterSpacing: 1.8, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _infoChip(
                  'TIME',
                  '${_timeLeft}s',
                  _timeLeft <= 5 ? Colors.redAccent : Colors.cyanAccent,
                ),
                _infoChip('SCORE', '$_score', Colors.greenAccent),
                _infoChip('BEST', '$_highScore', Colors.amberAccent),
              ],
            ),
            const Spacer(),
            AspectRatio(
              aspectRatio: 1,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _gridSize,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemBuilder: (ctx, index) {
                  final isTarget = index == _activeCell;
                  final targetColor = _isBonusTarget
                      ? Colors.amberAccent
                      : Colors.pinkAccent;

                  return GestureDetector(
                    onTap: () => _onCellTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      decoration: BoxDecoration(
                        color: isTarget
                            ? targetColor.withValues(alpha: 0.22)
                            : const Color(0xFF151A2A),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isTarget ? targetColor : Colors.white12,
                          width: isTarget ? 3 : 1.5,
                        ),
                        boxShadow: isTarget
                            ? [
                                BoxShadow(
                                  color: targetColor.withValues(alpha: 0.45),
                                  blurRadius: 14,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: isTarget
                            ? Icon(
                                _isBonusTarget ? Icons.bolt : Icons.smart_toy,
                                size: 48,
                                color: targetColor,
                              )
                            : const Icon(
                                Icons.circle_outlined,
                                color: Colors.white10,
                                size: 28,
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: _startGame,
              icon: Icon(_isPlaying ? Icons.refresh : Icons.play_arrow),
              label: Text(_isPlaying ? 'Restart Round' : 'Start 30s Challenge'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.pinkAccent.shade700,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141929),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
