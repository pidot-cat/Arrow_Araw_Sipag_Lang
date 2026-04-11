// contact_screen.dart
// Sends player feedback to arrowarawsipaglang@gmail.com via EmailJS REST API.
// User fills in their email + problem description, taps Send Message.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/background_wrapper.dart';
import '../widgets/gradient_button.dart';
import '../widgets/gradient_input_field.dart';
import '../utils/constants.dart';

// ── EmailJS credentials ───────────────────────────────────────────────────
// Template variables expected: {{from_email}}, {{message}}, {{to_email}}
const String _kServiceId  = 'service_vtus5km';
const String _kTemplateId = 'template_eb907ud';
const String _kPublicKey  = 'Pc1EQujpT72L2Po8V';
const String _kEndpoint   = 'https://api.emailjs.com/api/v1.0/email/send';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final TextEditingController _emailController   = TextEditingController();
  final TextEditingController _problemController = TextEditingController();

  // Controls button disabled state while API call is in flight
  bool _isSending = false;

  @override
  void dispose() {
    _emailController.dispose();
    _problemController.dispose();
    super.dispose();
  }

  /// Validates inputs, posts to EmailJS, shows result snackbar.
  Future<void> _submitContact() async {
    final senderEmail = _emailController.text.trim();
    final message     = _problemController.text.trim();

    // Empty field guard
    if (senderEmail.isEmpty || message.isEmpty) {
      _showSnackBar('Please fill in all fields.', Colors.red);
      return;
    }

    // Basic email format check
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(senderEmail)) {
      _showSnackBar('Please enter a valid email address.', Colors.red);
      return;
    }

    setState(() => _isSending = true);

    try {
      // POST to EmailJS REST endpoint
      final response = await http.post(
        Uri.parse(_kEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'service_id':  _kServiceId,
          'template_id': _kTemplateId,
          'user_id':     _kPublicKey,
          'template_params': {
            'from_email': senderEmail,
            'message':    message,
            'to_email':   'arrowarawsipaglang@gmail.com',
          },
        }),
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        _emailController.clear();
        _problemController.clear();
        _showSnackBar("Message sent! We'll get back to you soon.", Colors.green);
      } else {
        _showSnackBar('Failed to send. Please try again later.', Colors.red);
      }
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('Network error. Check your connection and try again.', Colors.red);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  /// Floating SnackBar helper.
  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color,
          behavior: SnackBarBehavior.floating),
    );
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
              SizedBox(height: size.height * 0.055),
              Image.asset(AppConstants.logoWithBg, width: 160, height: 160),
              const SizedBox(height: 16),

              // Screen title
              const Text('Contact Us',
                style: TextStyle(color: Colors.white, fontSize: 26,
                    fontWeight: FontWeight.bold, letterSpacing: 1.2),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text("We're here to help!",
                  style: TextStyle(color: Colors.white.withAlpha(179), fontSize: 15)),
              SizedBox(height: size.height * 0.035),

              // Sender email input
              GradientInputField(
                hintText: 'Your Email', controller: _emailController,
                prefixIcon: Icons.email, keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Problem description input
              GradientInputField(
                hintText: 'Describe your problem...', controller: _problemController,
                prefixIcon: Icons.message, maxLines: 5,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 30),

              // Send button or loading spinner
              _isSending
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan))
                  : GradientButton(text: 'SEND MESSAGE', onPressed: _submitContact),

              const SizedBox(height: 24),

              // Alternative contact info card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(13),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withAlpha(26)),
                ),
                child: Column(
                  children: [
                    const Text('Other ways to reach us:',
                        style: TextStyle(color: Colors.white, fontSize: 15,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.email_rounded, color: Colors.cyan, size: 20),
                        const SizedBox(width: 8),
                        Text('arrowarawsipaglang@gmail.com',
                            style: TextStyle(color: Colors.white.withAlpha(204),
                                fontSize: 14)),
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
