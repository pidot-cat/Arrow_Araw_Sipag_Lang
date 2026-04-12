// lib/screens/contact_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// [FIX 5A] Email validation — sender email must match logged-in Supabase user.
// [FIX 5B] Message forwarded to arrowarawsipaglang@gmail.com via EmailJS.
// [FIX 5C] template_params keys EXACTLY match EmailJS dashboard placeholders:
//          {{from_name}}  {{reply_to}}  {{message}}
// [FIX 5D] Verbose status/text/exception logging — surfaces 403/400 causes.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/background_wrapper.dart';
import '../widgets/gradient_button.dart';
import '../widgets/gradient_input_field.dart';
import '../utils/constants.dart';

// ── EmailJS credentials ───────────────────────────────────────────────────────
// These MUST match your EmailJS dashboard exactly.
//   service_id  → EmailJS > Email Services > your service ID
//   template_id → EmailJS > Email Templates > your template ID
//   user_id     → EmailJS > Account > Public Key
//
// Your template MUST contain these EXACT placeholders (case-sensitive):
//   {{from_name}}   {{reply_to}}   {{message}}
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
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool  _isSending   = false;

  String get _loggedInEmail =>
      Supabase.instance.client.auth.currentUser?.email?.trim() ?? '';

  @override
  void initState() {
    super.initState();
    _emailCtrl.text = _loggedInEmail; // [FIX 5A] pre-fill locked email
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name    = _nameCtrl.text.trim();
    final email   = _emailCtrl.text.trim();
    final message = _messageCtrl.text.trim();

    if (email.isEmpty || message.isEmpty) {
      _snack('Please fill in all fields.', Colors.red);
      return;
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      _snack('Please enter a valid email address.', Colors.red);
      return;
    }

    // [FIX 5A] Block send if email doesn't match logged-in account
    final accountEmail = _loggedInEmail.toLowerCase();
    if (accountEmail.isNotEmpty && email.toLowerCase() != accountEmail) {
      _snack('Email must match your account ($accountEmail).', Colors.orange);
      return;
    }

    setState(() => _isSending = true);
    try {
      // [FIX 5C] Keys must EXACTLY match the {{placeholders}} in EmailJS template
      final payload = {
        'service_id':  _kServiceId,
        'template_id': _kTemplateId,
        'user_id':     _kPublicKey,
        'template_params': {
          'from_name': name.isNotEmpty ? name : email, // → {{from_name}}
          'reply_to':  email,                           // → {{reply_to}}
          'message':   message,                         // → {{message}}
          'to_email':  'arrowarawsipaglang@gmail.com',  // → {{to_email}} (if used)
        },
      };

      // [FIX 5D] Log outgoing payload
      debugPrint('[EmailJS] POST → $_kEndpoint');
      debugPrint('[EmailJS] Payload → ${jsonEncode(payload)}');

      final res = await http.post(
        Uri.parse(_kEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Origin': 'https://www.emailjs.com', // Required by some plans
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 15));

      // [FIX 5D] Log full response — exposes 403/400 root causes
      debugPrint('[EmailJS] Status → ${res.statusCode}');
      debugPrint('[EmailJS] Body   → ${res.body}');

      if (!mounted) return;
      if (res.statusCode == 200) {
        _nameCtrl.clear();
        _emailCtrl.clear();
        _messageCtrl.clear();
        _snack('Message sent to arrowarawsipaglang@gmail.com ✓', Colors.green);
      } else {
        final errorDetail = res.body.isNotEmpty ? res.body : 'HTTP ${res.statusCode}';
        _snack('Failed: $errorDetail', Colors.red);
      }
    } catch (e, st) {
      // [FIX 5D] Full exception + stack trace
      debugPrint('[EmailJS] Exception → $e');
      debugPrint('[EmailJS] Stack     → $st');
      if (!mounted) return;
      _snack('Network error. Check your connection.', Colors.red);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final size     = MediaQuery.of(context).size;
    final isLocked = _loggedInEmail.isNotEmpty;

    return Scaffold(
      body: BackgroundWrapper(
        showBackButton: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(children: [
            SizedBox(height: size.height * 0.055),
            Image.asset(AppConstants.logoWithBg, width: 160, height: 160),
            const SizedBox(height: 16),
            const Text('Contact Us',
                style: TextStyle(color: Colors.white, fontSize: 26,
                    fontWeight: FontWeight.bold, letterSpacing: 1.2),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text("We're here to help!",
                style: TextStyle(color: Colors.white.withAlpha(179), fontSize: 15)),
            SizedBox(height: size.height * 0.035),

            // Name → {{from_name}}
            GradientInputField(
              hintText: 'Your Name (optional)',
              controller: _nameCtrl,
              prefixIcon: Icons.person,
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 14),

            // Email → {{reply_to}} — locked to account email when signed in
            GradientInputField(
              hintText: isLocked ? _loggedInEmail : 'Your Email',
              controller: _emailCtrl,
              prefixIcon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              readOnly: isLocked,
            ),
            if (isLocked)
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 4),
                child: Row(children: [
                  const Icon(Icons.lock_outline, size: 13, color: Colors.cyanAccent),
                  const SizedBox(width: 4),
                  Text('Sending from your account email',
                      style: TextStyle(
                          color: Colors.cyanAccent.withAlpha(180), fontSize: 12)),
                ]),
              ),

            const SizedBox(height: 14),
            // Message → {{message}}
            GradientInputField(
              hintText: 'Describe your problem...',
              controller: _messageCtrl,
              prefixIcon: Icons.message,
              maxLines: 5,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 30),

            _isSending
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan))
                : GradientButton(text: 'SEND MESSAGE', onPressed: _submit),

            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(13),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withAlpha(26)),
              ),
              child: Column(children: [
                const Text('Feedback Email:',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.email_rounded, color: Colors.cyan, size: 20),
                  const SizedBox(width: 8),
                  Text('arrowarawsipaglang@gmail.com',
                      style: TextStyle(
                          color: Colors.white.withAlpha(204), fontSize: 14)),
                ]),
              ]),
            ),
            SizedBox(height: size.height * 0.04),
          ]),
        ),
      ),
    );
  }
}
