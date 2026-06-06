import 'package:flutter/material.dart';

class TeamPicker extends StatelessWidget {
  const TeamPicker({
    super.key,
    required this.teams,
    required this.selectedTeam,
    required this.onChanged,
    this.label = 'Takım Seç',
  });

  final List<String> teams;
  final String? selectedTeam;
  final ValueChanged<String?> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey(selectedTeam),
      initialValue: selectedTeam != null && teams.contains(selectedTeam)
          ? selectedTeam
          : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.flag),
      ),
      items: teams
          .map(
            (team) => DropdownMenuItem(
              value: team,
              child: Text(team),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? 'Bir takım seçmelisin' : null,
    );
  }
}
