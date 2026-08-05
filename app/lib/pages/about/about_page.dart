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
    final headingStyle = const TextStyle(fontWeight: FontWeight.bold, fontSize: 19);

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
          const SizedBox(height: 32),

          // Features
          Text('Features', style: headingStyle),
          const SizedBox(height: 10),
          const Text('•  Direct device-to-device transfer over your local network — nothing ever passes through an external server.'),
          const SizedBox(height: 6),
          const Text('•  No internet connection required, so it works even on networks with no outbound access.'),
          const SizedBox(height: 6),
          const Text('•  No account, sign-up, or login needed — open the app and start sending.'),
          const SizedBox(height: 6),
          const Text('•  No cloud upload — your files stay on your network and never touch the internet.'),
          const SizedBox(height: 6),
          const Text('•  HTTPS-encrypted transfers between devices on your network.'),
          const SizedBox(height: 6),
          const Text('•  Optional PIN protection so incoming transfers require your approval.'),
          const SizedBox(height: 6),
          const Text('•  Cross-platform support for Android, iOS, macOS, Windows, and Linux.'),
          const SizedBox(height: 6),
          const Text('•  Send files, folders, and text messages in a single transfer.'),
          const SizedBox(height: 6),
          const Text('•  Choose exactly where received files are saved on your device.'),
          const SizedBox(height: 6),
          const Text('•  Transfer speeds limited only by your local network, not by upload bandwidth.'),
          const SizedBox(height: 6),
          Text('•  Available in ${AppLocale.values.length}+ languages, with more added over time.'),
          const SizedBox(height: 6),
          const Text('•  Light and dark themes, with a modern glass-styled interface.'),
          const SizedBox(height: 32),

          // How It Works
          Text('How It Works', style: headingStyle),
          const SizedBox(height: 10),
          const Text(
            'Xetel Share uses your local Wi-Fi network to discover nearby devices automatically, the same way you\'d '
            'find a printer or a smart TV on your network. Each device broadcasts its presence, so no manual pairing or '
            'network setup is required.\n\n'
            'When you send something, your device talks directly to the receiving device over that local connection using '
            'an encrypted connection — there\'s no middle server relaying your files, and nothing leaves your network at '
            'any point. This keeps transfers fast and private by design.\n\n'
            'Because everything happens over the local network, transfer speed depends entirely on your Wi-Fi, not on '
            'internet bandwidth — which usually means much faster transfers than uploading to and downloading from a '
            'cloud service.',
          ),
          const SizedBox(height: 32),

          // How To Use
          Text('How To Use', style: headingStyle),
          const SizedBox(height: 10),
          const Text('1.  Connect both devices to the same Wi-Fi network.'),
          const SizedBox(height: 6),
          const Text('2.  Open Xetel Share on both devices — each one will appear automatically in the other\'s device list.'),
          const SizedBox(height: 6),
          const Text('3.  On the sending device, pick the files, folders, or message you want to share.'),
          const SizedBox(height: 6),
          const Text('4.  Select the receiving device from the list and confirm.'),
          const SizedBox(height: 6),
          const Text('5.  On the receiving device, accept the incoming transfer to complete it.'),
          const SizedBox(height: 6),
          const Text('6.  Optionally, turn on Quick Save or a PIN in Settings to control how incoming transfers are handled.'),
          const SizedBox(height: 32),

          // Security & Privacy
          Text('Security & Privacy', style: headingStyle),
          const SizedBox(height: 10),
          const Text(
            'Every transfer stays inside your local network and is encrypted in transit, so nobody outside your network '
            'can intercept it. Xetel Share does not run any background server outside your device, does not track usage, '
            'and does not require any permissions beyond what\'s needed to discover devices and send or receive files.',
          ),
          const SizedBox(height: 32),

          // Supported Platforms
          Text('Supported Platforms', style: headingStyle),
          const SizedBox(height: 10),
          const Text('•  Android'),
          const SizedBox(height: 6),
          const Text('•  iOS'),
          const SizedBox(height: 6),
          const Text('•  Windows'),
          const SizedBox(height: 6),
          const Text('•  macOS'),
          const SizedBox(height: 6),
          const Text('•  Linux'),
          const SizedBox(height: 32),

          // About Xetel
          Text('About Xetel Inc', style: headingStyle),
          const SizedBox(height: 10),
          const Text(
            'Xetel Inc builds software solutions for businesses across Pharma, Transport, Schools, Accounting, Hotels, and '
            'Restaurants. Xetel Share is built and maintained by Xetel Inc as a fast, private way to move files between '
            'devices without depending on the cloud.',
          ),
          const SizedBox(height: 20),

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