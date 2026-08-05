import 'package:flutter/material.dart';
import 'package:localsend_app/widget/local_send_logo.dart';
import 'package:localsend_app/widget/responsive_list_view.dart';

/// In-app Privacy Policy, styled to match [AboutPage] rather than sending
/// the user out to a browser.
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage();

  @override
  Widget build(BuildContext context) {
    final headingStyle = const TextStyle(fontWeight: FontWeight.bold, fontSize: 19);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
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
          const SizedBox(height: 6),
          Text(
            'Last updated: Aug 1, 2026',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 28),

          Text('Introduction', style: headingStyle),
          const SizedBox(height: 10),
          const Text(
            'This Privacy Policy is designed to help you understand our practices regarding any information we might '
            'collect from you or that you provide to us, the ways in which we use this information, and how we handle it.\n\n'
            'Given that we do not collect any personal data or non-personal data, our practices are straightforward and '
            'committed to safeguarding your privacy. By using Xetel Share, you agree to the terms described in this policy.',
          ),
          const SizedBox(height: 28),

          Text('Personal Data Collection and Use', style: headingStyle),
          const SizedBox(height: 10),
          const Text(
            'Xetel Share is built to work entirely over your local network, with privacy as a core part of its design. '
            'In line with this, we confirm that we do not collect, store, process, or use any personal data or '
            'non-personal data from you while you use our application.\n\n'
            'Personal data refers to any information that could potentially identify you as an individual. Non-personal '
            'data refers to any information that does not directly identify you and is aggregated or anonymized. Since we '
            'do not collect any such information, there\'s no possibility of us using, sharing, or selling this data.',
          ),
          const SizedBox(height: 28),

          Text('How Transfers Work', style: headingStyle),
          const SizedBox(height: 10),
          const Text(
            'Files, folders, and messages sent through Xetel Share travel directly between your devices over your local '
            'network. They are never routed through, stored on, or accessible to any server operated by Xetel Inc. Once a '
            'transfer completes, we have no copy of it and no record that it happened.',
          ),
          const SizedBox(height: 28),

          Text('Permissions We Request', style: headingStyle),
          const SizedBox(height: 10),
          const Text(
            'Xetel Share may request device permissions such as local network access, storage/file access, and '
            'notifications. These permissions are used strictly to discover nearby devices and to send or receive the '
            'files you choose — never to collect data for any other purpose.',
          ),
          const SizedBox(height: 28),

          Text('Cookies and Tracking Technologies', style: headingStyle),
          const SizedBox(height: 10),
          const Text(
            'Xetel Share does not use cookies, analytics SDKs, advertising identifiers, or any other tracking '
            'technology. We do not build usage profiles, and we do not monitor how you use the app.',
          ),
          const SizedBox(height: 28),

          Text('Children\'s Privacy', style: headingStyle),
          const SizedBox(height: 10),
          const Text(
            'Xetel Share does not knowingly collect any information from anyone, including children under the age of '
            '13. Because the app collects no personal data from any user, this applies equally regardless of age.',
          ),
          const SizedBox(height: 28),

          Text('Your Rights', style: headingStyle),
          const SizedBox(height: 10),
          const Text(
            'Since we do not collect, store, or process any personal data, there is no user data held by us to access, '
            'correct, export, or delete. Regardless of your location or applicable data protection law, this means '
            'Xetel Share is, by design, compliant with data-minimization principles such as those under GDPR and CCPA.',
          ),
          const SizedBox(height: 28),

          Text('Security', style: headingStyle),
          const SizedBox(height: 10),
          const Text(
            'As Xetel Share does not collect any data, there are no concerns regarding the transmission or storage of '
            'data on our end. Transfers between your devices are encrypted in transit over your local network. We still '
            'prioritize the overall security of our application and the trust you place in us by using it.',
          ),
          const SizedBox(height: 28),

          Text('Third-Party Data Collection', style: headingStyle),
          const SizedBox(height: 10),
          const Text(
            'While Xetel Share itself does not collect any personal or non-personal data, it is important to note that '
            'users may still be subject to data collection by third parties such as operating systems (e.g. Android, '
            'iOS), device manufacturers, and other apps that have permissions to access device data. We have no control '
            'over and assume no responsibility for the data practices of these third parties. We encourage users to '
            'review the privacy policies of their operating system and device manufacturer to better understand their '
            'data practices.',
          ),
          const SizedBox(height: 28),

          Text('Data Retention', style: headingStyle),
          const SizedBox(height: 10),
          const Text(
            'Because we do not collect any personal or non-personal data, we have no data retention period to disclose '
            '— there is simply nothing of yours stored on our end to retain or delete.',
          ),
          const SizedBox(height: 28),

          Text('International Users', style: headingStyle),
          const SizedBox(height: 10),
          const Text(
            'Xetel Share can be used anywhere in the world. Since all transfers happen locally on your own network and '
            'no data is sent to us, no personal data ever crosses international borders through use of this app.',
          ),
          const SizedBox(height: 28),

          Text('Changes to This Privacy Policy', style: headingStyle),
          const SizedBox(height: 10),
          const Text(
            'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new '
            'Privacy Policy on this page, along with an updated "Last updated" date. These changes are effective '
            'immediately after they are posted on this page. We encourage you to review this policy periodically.',
          ),
          const SizedBox(height: 28),

          Text('Contact Us', style: headingStyle),
          const SizedBox(height: 10),
          const Text(
            'If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us at '
            'support@xetel.in.',
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}