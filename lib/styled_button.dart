import 'package:excel_example/button_config.dart';
import 'package:excel_example/gamepage.dart';
import 'package:flutter/material.dart';

class StyledButton extends StatelessWidget {
  final ButtonConfig buttonConfig;
  final VoidCallback onPressed;

  const StyledButton({
    super.key,
    required this.buttonConfig,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: pressedButton
            ? Color(
                int.parse(
                  buttonConfig.buttonColor.replaceAll('#', '0x'),
                ),
              )
            : Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            buttonConfig.border,
          ),
        ),
        elevation: buttonConfig.elevation,
        padding: EdgeInsets.all(buttonConfig.padding),
      ),
      child: const Text(""),
    );
  }
}
