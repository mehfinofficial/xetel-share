import 'package:flutter/material.dart';
import 'package:localsend_app/widget/local_send_logo.dart';
import 'package:localsend_app/widget/responsive_list_view.dart';

/// In-app Privacy Policy, styled to match [AboutPage] rather than sending
/// the user out to a browser.
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage();

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(height: 24),
          const _PolicySection(
            title: 'Introduction',
            body:
                'This Privacy Policy is designed to help you understand our practices regarding any information we might '
                'collect from you or that you provide to us, the ways in which we use this information, and how we handle it.\n\n'
                'Given that we do not collect any personal data or non-personal data, our practices are straightforward and '
                'committed to safeguarding your privacy.',
          ),
          const _PolicySection(
            title: 'Personal Data Collection and Use',
            body:
                'Xetel Share is built to work entirely over your local network, with privacy as a core part of its design. '
                'In line with this, we confirm that we do not collect, store, process, or use any personal data or '
                'non-personal data from you while you use our application.\n\n'
                'Personal data refers to any information that could potentially identify you as an individual. Non-personal '
                'data refers to any information that does not directly identify you and is aggregated or anonymized. Since we '
                'do not collect any such information, there\'s no possibility of us using, sharing, or selling this data.',
          ),
          const _PolicySection(
            title: 'Security',
            body:
                'As Xetel Share does not collect any data, there are no concerns regarding the transmission or storage of '
                'data. However, we still prioritize the security of our application and the trust you place in us by using it.',
          ),
          const _PolicySection(
            title: 'Third-Party Data Collection',
            body:
                'While Xetel Share itself does not collect any personal or non-personal data, it is important to note that '
                'users may still be subject to data collection by third parties such as operating systems (e.g. Android, '
                'iOS), device manufacturers, and other apps that have permissions to access device data. We have no control '
                'over and assume no responsibility for the data practices of these third parties. We encourage users to '
                'review the privacy policies of their operating system and device manufacturer to better understand their '
                'data practices.',
          ),
          const _PolicySection(
            title: 'Changes to This Privacy Policy',
            body:
                'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new '
                'Privacy Policy on this page. These changes are effective immediately after they are posted on this page.',
          ),
          const _PolicySection(
            title: 'Contact Us',
            body: 'If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us at support@xetel.in.',
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String body;

  const _PolicySection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          Text(body),
        ],
      ),
    );
  }
}