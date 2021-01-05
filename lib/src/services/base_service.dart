class BaseService{
  final url = 'https://testerp.somosjp.cl';

  bool isSuccessCode(int code) => code >= 200 && code < 300;
}