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
    return pressedButton
        ? ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonConfig.border),
              ),
              elevation: buttonConfig.elevation,
              padding: EdgeInsets.all(buttonConfig.padding),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(int.parse(
                        buttonConfig.buttonColor.replaceAll('#', '0x'))),
                    Color(int.parse(
                        buttonConfig.buttonColor.replaceAll('#', '0x'))),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(buttonConfig.border),
                boxShadow: [
                  BoxShadow(
                    color: Color(int.parse(
                            buttonConfig.buttonColor.replaceAll('#', '0x')))
                        .withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star,
                    color: pressedButton ? Colors.white : Colors.black,
                    size: 24,
                  ),
                ],
              ),
            ),
          )
        : ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
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
