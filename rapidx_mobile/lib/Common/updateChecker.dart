import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateChecker {
  static Future<void> checkForUpdates(BuildContext context, {bool showNoUpdateMessage = true}) async {
    // Show a loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(
            color: const Color(0xff234C6A),
          ),
        );
      },
    );

    try {
      // Simulate API call delay to "check" for updates
      await Future.delayed(const Duration(seconds: 2));
      
      // Get the current app version from pubspec.yaml
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;
      
      // Close the loading indicator
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Mock remote version (simulate an update available occasionally or hardcode to show specific behavior)
      // For demonstration, we'll pretend the remote version is the same, so no update by default unless we want to trigger it.
      // E.g. final String remoteVersion = "1.0.1";
      final String remoteVersion = currentVersion; // No update currently available

      if (remoteVersion != currentVersion) {
        _showUpdateDialog(context, currentVersion, remoteVersion);
      } else {
        if (showNoUpdateMessage) {
          _showNoUpdateDialog(context, currentVersion);
        }
      }
    } catch (e) {
      // Close the loading indicator
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to check for updates. Please try again later."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  static void _showUpdateDialog(BuildContext context, String currentVersion, String newVersion) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Update Available", 
            style: GoogleFonts.baloo2(
              fontWeight: FontWeight.bold,
              color: const Color(0xff234C6A)
            )
          ),
          content: Text(
            "A new version ($newVersion) of RapidX is available. You are currently on version $currentVersion.\n\nWould you like to update now?",
            style: GoogleFonts.baloo2(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Later", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                // Simulate redirect to Play Store/App Store
                final Uri url = Uri.parse('https://play.google.com/store/apps/details?id=com.newrapidx.app'); // Replace with real URL
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Could not launch app store.")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff234C6A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Update Now",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  static void _showNoUpdateDialog(BuildContext context, String currentVersion) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Up to Date", 
            style: GoogleFonts.baloo2(
              fontWeight: FontWeight.bold,
              color: Colors.green
            )
          ),
          content: Text(
            "You are already using the latest version of RapidX ($currentVersion).",
            style: GoogleFonts.baloo2(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Okay",
                style: TextStyle(color: const Color(0xff234C6A)),
              ),
            ),
          ],
        );
      },
    );
  }
}
