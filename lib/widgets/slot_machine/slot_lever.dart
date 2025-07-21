import 'package:flutter/material.dart';

class SlotLever extends StatelessWidget {
  final Animation<double> animation;
  final VoidCallback onTap;
  final bool isEnabled;

  const SlotLever({
    Key? key,
    required this.animation,
    required this.onTap,
    required this.isEnabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return GestureDetector(
          onTap: isEnabled ? onTap : null,
          child: Transform.rotate(
            angle: animation.value * 0.5,
            child: Container(
              width: 60,
              height: 100,
              decoration: BoxDecoration(
                color: isEnabled ? Colors.red : Colors.grey,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.sports_esports,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        );
      },
    );
  }
}
