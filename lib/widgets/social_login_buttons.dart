import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class SocialLoginButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final Widget icon;
  final VoidCallback onPressed;
  final bool isLoading;

  const SocialLoginButton({
    Key? key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  const SizedBox(width: 12),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class GoogleLoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final String text;

  const GoogleLoginButton({
    Key? key,
    required this.onPressed,
    this.isLoading = false,
    this.text = 'Continuar com Google',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SocialLoginButton(
      text: text,
      backgroundColor: Colors.white,
      textColor: Colors.black87,
      icon: Image.asset(
        'assets/icons/google_icon.png',
        height: 24,
        width: 24,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.g_mobiledata,
          size: 28,
          color: Colors.blue,
        ),
      ),
      onPressed: onPressed,
      isLoading: isLoading,
    );
  }
}

class AppleLoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final String text;

  const AppleLoginButton({
    Key? key,
    required this.onPressed,
    this.isLoading = false,
    this.text = 'Continuar com Apple',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SocialLoginButton(
      text: text,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      icon: Icon(Icons.apple, size: 24),
      onPressed: onPressed,
      isLoading: isLoading,
    );
  }
}

class FacebookLoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final String text;

  const FacebookLoginButton({
    Key? key,
    required this.onPressed,
    this.isLoading = false,
    this.text = 'Continuar com Facebook',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SocialLoginButton(
      text: text,
      backgroundColor: Color(0xFF1877F2),
      textColor: Colors.white,
      icon: Icon(Icons.facebook, size: 24),
      onPressed: onPressed,
      isLoading: isLoading,
    );
  }
}

class TwitterLoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final String text;

  const TwitterLoginButton({
    Key? key,
    required this.onPressed,
    this.isLoading = false,
    this.text = 'Continuar com X',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SocialLoginButton(
      text: text,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      icon: Text(
        '𝕏',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      onPressed: onPressed,
      isLoading: isLoading,
    );
  }
}

class BiometricLoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final String text;

  const BiometricLoginButton({
    Key? key,
    required this.onPressed,
    this.isLoading = false,
    this.text = 'Entrar com Biometria',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SocialLoginButton(
      text: text,
      backgroundColor: Theme.of(context).primaryColor,
      textColor: Colors.white,
      icon: Icon(
        defaultTargetPlatform == TargetPlatform.iOS
            ? Icons.face
            : Icons.fingerprint,
        size: 24,
      ),
      onPressed: onPressed,
      isLoading: isLoading,
    );
  }
}

class SocialLoginDivider extends StatelessWidget {
  final String text;

  const SocialLoginDivider({
    Key? key,
    this.text = 'ou',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey[400])),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey[400])),
        ],
      ),
    );
  }
}
