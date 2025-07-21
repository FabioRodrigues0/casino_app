import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class SlotReel extends StatelessWidget {
  final int index;
  final Animation<double> animation;
  final String currentSymbol;
  final int reelPosition;
  final bool isSpinning;

  const SlotReel({
    Key? key,
    required this.index,
    required this.animation,
    required this.currentSymbol,
    required this.reelPosition,
    required this.isSpinning,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: isSpinning ? _buildSpinningReel() : _buildStaticReel(),
      ),
    );
  }

  Widget _buildSpinningReel() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 40,
          child: Center(
            child: Text(
              GameConstants.symbols[
                  (reelPosition - 1 + GameConstants.symbols.length) % GameConstants.symbols.length],
              style: TextStyle(fontSize: 25, color: Colors.grey.shade400),
            ),
          ),
        ),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            border: Border.symmetric(
              horizontal: BorderSide(color: Colors.blue.shade300, width: 1),
            ),
          ),
          child: Center(
            child: Text(
              GameConstants.symbols[reelPosition],
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Container(
          height: 40,
          child: Center(
            child: Text(
              GameConstants.symbols[(reelPosition + 1) % GameConstants.symbols.length],
              style: TextStyle(fontSize: 25, color: Colors.grey.shade400),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStaticReel() {
    return Center(
      child: Text(
        currentSymbol,
        style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
      ),
    );
  }
}
