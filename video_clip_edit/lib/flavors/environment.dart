// ignore_for_file: constant_identifier_names
enum Environment {
  TEST('https://chatest.beiyinapp.com/api/'),
  PRODUCTION('https://inchat.beiyinapp.com/api/');

  final String domain;
  const Environment(this.domain);

  bool get isProduction => this == Environment.PRODUCTION;
}
