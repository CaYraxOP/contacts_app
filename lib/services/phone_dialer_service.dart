import 'package:url_launcher/url_launcher.dart';

import '../core/utils/phone_utils.dart';

class PhoneDialerService {
  const PhoneDialerService();

  Future<bool> dial(String phoneNumber) async {
    final sanitized = PhoneUtils.sanitize(phoneNumber);
    if (!PhoneUtils.isProbablyValid(sanitized)) return false;

    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: sanitized,
    );

    // Some Android devices return null component for ACTION_VIEW tel: if there is
    // no dialer app, the dialer is disabled, or package-visibility queries are missing.
    final canLaunch = await canLaunchUrl(phoneUri);
    if (!canLaunch) return false;

    final launched = await launchUrl(
      phoneUri,
      mode: LaunchMode.externalApplication,
    );
    if (launched) return true;

    // Fallback: try platform default mode in case the OEM dialer doesn't like
    // the chosen launch mode.
    return launchUrl(phoneUri, mode: LaunchMode.platformDefault);
  }
}
