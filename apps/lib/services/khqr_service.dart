// Static KHQR generation/parse placeholder.
class KhqrService {
  String generateStatic({required String merchant, required int amountRiel}) {
    return 'KHQR:$merchant:$amountRiel';
  }

  Map<String, dynamic> parse(String data) {
    return {'raw': data};
  }
}
