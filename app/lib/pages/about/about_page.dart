import 'package:flutter/material.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/pages/debug/debug_page.dart';
import 'package:localsend_app/widget/local_send_logo.dart';
import 'package:localsend_app/widget/responsive_list_view.dart';
import 'package:routerino/routerino.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.aboutPage.title),
      ),
      body: ResponsiveListView(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        children: [
          const SizedBox(height: 20),
          const LocalSendLogo(withText: true),
          Text(
            '© ${DateTime.now().year} Xetel Inc',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: () async {
                await launchUrl(Uri.parse('https://www.xetel.in'));
              },
              child: const Text('www.xetel.in'),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Xetel Share lets you send files and messages directly between nearby devices over your own local network — '
            'no internet connection, no cloud upload, no account required.\n\n'
            'It runs on Android, iOS, macOS, Windows, and Linux, so your devices can find and talk to each other no matter '
            'what you\'re using.',
          ),
          const SizedBox(height: 24),
          const Text('Supported languages', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('Xetel Share is available in ${AppLocale.values.length}+ languages, with more added over time.'),
          const SizedBox(height: 30),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                onPressed: () async {
                  await launchUrl(Uri.parse('https://www.xetel.in'));
                },
                child: const Text('Homepage'),
              ),
              TextButton(
                onPressed: () async {
                  await context.push(() => const LicensePage());
                },
                child: const Text('License Notices'),
              ),
              TextButton(
                onPressed: () async {
                  await context.push(() => const DebugPage());
                },
                child: const Text('Debugging'),
              ),
            ],
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}