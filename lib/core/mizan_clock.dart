class MizanClock {
  MizanClock._();

  static DateTime Function() _provider = DateTime.now;

  static DateTime now() => _provider();

  static void setNowForTesting(DateTime value) {
    _provider = () => value;
  }

  static void resetForTesting() {
    _provider = DateTime.now;
  }
}
