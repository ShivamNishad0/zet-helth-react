import 'package:flutter/material.dart';
import 'package:zet_health/Helper/ColorHelper.dart';

class FAQSection extends StatefulWidget {
  const FAQSection({super.key});

  @override
  State<FAQSection> createState() => _FAQSectionState();
}

class _FAQSectionState extends State<FAQSection> {
  int? _expandedIndex;

  final List<Map<String, String>> _faqs = [
    {
      "question": "What does my Health Score mean?",
      "answer": "Your Health Score is a composite measure based on the parameters tested in your report. Green means most values are within range, Orange signals early signs to watch, and Red highlights high-risk areas needing medical attention.",
    },
    {
      "question": "Why are some categories marked as \"Not Tested\"?",
      "answer": "Not all diagnostic packages cover every health category. \"Not Tested\" simply means those parameters were not part of your chosen package.",
    },
    {
      "question": "Does \"All is Well\" mean I am 100% healthy?",
      "answer": "Not necessarily. \"All is Well\" only applies to the parameters tested. For a complete picture, you may need additional tests based on your age, lifestyle, or family history.",
    },
    {
      "question": "What should I do if something is in the \"High Risk\" section?",
      "answer": "We strongly recommend consulting a doctor with your report. Our recommendations are informative, but only a medical professional can provide a proper diagnosis and treatment plan.",
    },
    {
      "question": "Why do my reference ranges differ from others?",
      "answer": "Reference ranges depend on age, gender, and lab methodology. That's why your ranges may look different from a friend's report.",
    },
    {
      "question": "Can I track my health over time?",
      "answer": "Yes. Each new report will be stored and compared, allowing you to track trends in your Health Score, categories, and parameters.",
    },
    {
      "question": "Can I rely only on AI insights for medical decisions?",
      "answer": "No. Our AI insights are educational and meant to guide you. Always consult your doctor before making health-related decisions.",
    },
    {
      "question": "How can I improve my Health Score?",
      "answer": "Follow the personalized recommendations provided, maintain a healthy lifestyle, and consider taking the suggested diagnostic packages for a more complete view of your health.",
    },
  ];

  void _toggleExpansion(int index) {
    setState(() {
      if (_expandedIndex == index) {
        _expandedIndex = null; // Close if already open
      } else {
        _expandedIndex = index; // Open new one
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 14.0),
          child: Row(
            children: [
              SizedBox(width: 8),
              Text(
                "Frequently Asked Questions",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        ..._faqs.asMap().entries.map((entry) {
          final index = entry.key;
          final faq = entry.value;
          final isExpanded = _expandedIndex == index;

          return FAQItem(
            question: faq["question"]!,
            answer: faq["answer"]!,
            isExpanded: isExpanded,
            onTap: () => _toggleExpansion(index),
          );
        }),
      ],
    );
  }
}

class FAQItem extends StatelessWidget {
  final String question;
  final String answer;
  final bool isExpanded;
  final VoidCallback onTap;

  const FAQItem({
    super.key,
    required this.question,
    required this.answer,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        question,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isExpanded ? primaryColor : Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      isExpanded ? Icons.remove_circle_outline : Icons.add_circle_outline,
                      color: isExpanded ? primaryColor : Colors.grey,
                      size: 22,
                    ),
                  ],
                ),
                if (isExpanded) ...[
                  const SizedBox(height: 12),
                  Divider(
                    height: 1,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    answer,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}