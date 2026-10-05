import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class PhoneUtils {
  /// Strips extra whitespace, brackets, hyphens while retaining leading '+'
  static String cleanPhoneNumber(String raw) {
    String cleaned = raw.trim().replaceAll(RegExp(r'[^\d+]'), '');
    return cleaned;
  }

  /// Initiates a phone call via the device's dialer
  static Future<void> makeCall(BuildContext context, String rawPhone) async {
    final phone = cleanPhoneNumber(rawPhone);
    if (phone.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phone number is not available'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        // Fallback direct launch attempt
        final launched = await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
        if (!launched && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open dialer for $rawPhone'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error launching phone dialer: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Copies the phone number to clipboard with feedback
  static Future<void> copyToClipboard(
    BuildContext context,
    String rawPhone, {
    String label = 'Phone number',
  }) async {
    final text = rawPhone.trim();
    if (text.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No phone number to copy'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Copied $text to clipboard'),
              ),
            ],
          ),
          backgroundColor: Colors.blueGrey.shade900,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }
}

/// A compact interactive phone widget for complaint cards
class InteractivePhoneChip extends StatelessWidget {
  final String phone;
  final TextStyle? style;

  const InteractivePhoneChip({
    super.key,
    required this.phone,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = style ??
        TextStyle(
          fontSize: 13,
          color: Colors.blue.shade900,
          fontWeight: FontWeight.w600,
        );

    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () => PhoneUtils.makeCall(context, phone),
      onLongPress: () => PhoneUtils.copyToClipboard(context, phone),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.blue.shade200, width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.phone, size: 13, color: Colors.blue.shade800),
            const SizedBox(width: 4),
            Text(phone, style: textStyle),
            const SizedBox(width: 6),
            // Quick copy icon button
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => PhoneUtils.copyToClipboard(context, phone),
              child: Tooltip(
                message: 'Copy phone number',
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Icon(
                    Icons.copy,
                    size: 13,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
