import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class HeartsWidget extends StatelessWidget {
  const HeartsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final hearts = userProvider.userProgress?.hearts ?? 5;
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              ...List.generate(5, (index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: Icon(
                    index < hearts ? Icons.favorite : Icons.favorite_border,
                    color: index < hearts ? Colors.red : Colors.grey,
                    size: 20,
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
