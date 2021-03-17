class BaseService{
  final url = 'https://dimabe-odoo-sociedadjp-test-2165343.dev.odoo.com';

  bool isSuccessCode(int code) => code >= 200 && code < 300;
}