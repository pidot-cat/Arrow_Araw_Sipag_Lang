import 'package:flutter/material.dart';
import '../widgets/background_wrapper.dart';
import '../widgets/gradient_button.dart';
import '../widgets/gradient_input_field.dart';
import '../utils/constants.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _problemController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _problemController.dispose();
    super.dispose();
  }

  void _submitContact() {
    if (_emailController.text.isEmpty || _problemController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Message sent! We'll get back to you soon."),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
    _emailController.clear();
    _problemController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: BackgroundWrapper(
        showBackButton: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Standard top gap with logo
              SizedBox(height: size.height * 0.055),
              Image.asset(AppConstants.logoWithBg, width: 160, height: 160),
              const SizedBox(height: 16),
              const Text(
                'Contact us',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "We're here to help!",
                style:
                    TextStyle(color: Colors.white.withAlpha(179), fontSize: 15),
              ),
              SizedBox(height: size.height * 0.035),
              GradientInputField(
                hintText: 'Your Email',
                controller: _emailController,
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              GradientInputField(
                hintText: 'Describe your problem...',
                controller: _problemController,
                prefixIcon: Icons.message,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 30),
              GradientButton(text: 'SEND MESSAGE', onPressed: _submitContact),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(13),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withAlpha(26)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Other ways to reach us:',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.email_rounded,
                            color: Colors.cyan, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'support@arrowaraw.com',
                          style: TextStyle(
                              color: Colors.white.withAlpha(204), fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.04),
            ],
          ),
        ),
      ),
    );
  }
}
