import 'package:flutter/material.dart';
import 'package:zet_health/Helper/ColorHelper.dart';

class ReportsInsightsSwitch extends StatelessWidget {
  final bool isReportsSelected;
  final ValueChanged<bool> onToggle;

  const ReportsInsightsSwitch({
    super.key,
    required this.isReportsSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton("Insights", !isReportsSelected, () => onToggle(false)),
          _buildButton("Reports", isReportsSelected, () => onToggle(true)),
        ],
      ),
    );
  }

  Widget _buildButton(String text, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

