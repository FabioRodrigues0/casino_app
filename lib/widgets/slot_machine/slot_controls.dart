import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class SlotControls extends StatelessWidget {
  final int bet;
  final bool isSpinning;
  final int credits;
  final VoidCallback onSpin;
  final VoidCallback onDecreaseBet;
  final VoidCallback onIncreaseBet;

  const SlotControls({
    Key? key,
    required this.bet,
    required this.isSpinning,
    required this.credits,
    required this.onSpin,
    required this.onDecreaseBet,
    required this.onIncreaseBet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: bet > GameConstants.minBet ? onDecreaseBet : null,
            child: Text('-${GameConstants.betIncrement}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton(
            onPressed: isSpinning || credits < bet ? null : onSpin,
            child: Text(isSpinning ? 'A Girar...' : 'SPIN'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: bet < GameConstants.maxBet ? onIncreaseBet : null,
            child: Text('+${GameConstants.betIncrement}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
