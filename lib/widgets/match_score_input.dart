import 'package:flutter/material.dart';

class MatchScoreInput extends StatelessWidget {
  const MatchScoreInput({
    super.key,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeScore,
    required this.awayScore,
    required this.onHomeChanged,
    required this.onAwayChanged,
  });

  final String homeTeam;
  final String awayTeam;
  final int homeScore;
  final int awayScore;
  final ValueChanged<int> onHomeChanged;
  final ValueChanged<int> onAwayChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: _TeamScoreColumn(
          team: homeTeam,
          score: homeScore,
          onChanged: onHomeChanged,
        )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '-',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Expanded(child: _TeamScoreColumn(
          team: awayTeam,
          score: awayScore,
          onChanged: onAwayChanged,
        )),
      ],
    );
  }
}

class _TeamScoreColumn extends StatelessWidget {
  const _TeamScoreColumn({
    required this.team,
    required this.score,
    required this.onChanged,
  });

  final String team;
  final int score;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          team,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ScoreButton(
              icon: Icons.remove,
              onPressed: score > 0 ? () => onChanged(score - 1) : null,
            ),
            Container(
              width: 56,
              alignment: Alignment.center,
              child: Text(
                '$score',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            _ScoreButton(
              icon: Icons.add,
              onPressed: score < 20 ? () => onChanged(score + 1) : null,
            ),
          ],
        ),
      ],
    );
  }
}

class _ScoreButton extends StatelessWidget {
  const _ScoreButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: onPressed,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        minimumSize: const Size(48, 48),
      ),
    );
  }
}
