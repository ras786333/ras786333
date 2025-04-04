class AppConstants {
  // TODO: Update this link after publishing on GitHub

  // GitHub Release Link (Update after publishing)
  static const String appStoreLink =
      'https://github.com/ras786333/mobile_shop/releases/latest';

  // Base URL for product sharing (Update with your domain)
  static const String baseShareUrl = 'https://mobileshop.com/product/';

  // App sharing message
  static const String appShareMessage = '''
Check out this amazing Mobile Shop App!

Download from:
GitHub: $appStoreLink
''';

  // Product sharing message template
  static String getProductShareMessage(
      String productName, String productId, double price) {
    return '''
*$productName*
------------------
*വില:* ₹${price.toStringAsFixed(2)}

ഉൽപ്പന്നം കാണാൻ: $baseShareUrl$productId

ആപ്പ് ഡൗൺലോഡ് ചെയ്യാൻ:
$appStoreLink
''';
  }
}
