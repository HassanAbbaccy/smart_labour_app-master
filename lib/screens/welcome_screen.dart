import 'package:flutter/material.dart';
import '../screens/signin_screen.dart';
import '../screens/signup_screen.dart';
import '../theme/theme.dart';
import '../widgets/custom_scaffold.dart';
import '../widgets/welcome_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Flexible(
              flex: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 40.0,
                ),
                child: Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        const TextSpan(
                            text: 'Smart\n',
                            style: TextStyle(
                              fontSize: 45.0,
                              fontWeight: FontWeight.w600,
                            )),
                        TextSpan(
                          children: [
                            WidgetSpan(
                              child: ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [
                                    Colors.deepPurple,
                                    Colors.purple,
                                    Colors.pinkAccent,
                                    Colors.greenAccent,
                                    Colors.cyan,
                                    Colors.lightGreen,
                                    Colors.red,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds),
                                child: const Text(
                                  'Labour App\n',
                                  style: TextStyle(
                                    fontSize: 45,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white, // required so gradient shows
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),


                        TextSpan(
                            text:
                            '\nEnter personal details to your employee account',
                            style: TextStyle(
                              fontSize: 20,
                              // height: 0,
                            ))
                      ],
                    ),
                  ),
                ),
              )),
          Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Row(
                children: [
                  const Expanded(
                    child: WelcomeButton(
                      buttonText: 'Sign in',
                      onTap: SignInScreen(),
                      color: Colors.transparent,
                      textColor: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'Sign up',
                      onTap: const SignUpScreen(),
                      color: Colors.white,
                      textColor: lightColorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}