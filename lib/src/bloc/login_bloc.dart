import 'dart:async';
import 'package:app_repatidor_v2/src/bloc/validators.dart';
import 'package:app_repatidor_v2/src/services/auth_service.dart';
import 'package:rxdart/rxdart.dart';

class LoginBloc with Validators {
  final _emailController = BehaviorSubject<String>();
  final _passwordController = BehaviorSubject<String>();
  final _passwordConfirmController = BehaviorSubject<String>();
  final _nameController = BehaviorSubject<String>();
  final _phoneController = BehaviorSubject<String>();

  AuthService service = new AuthService();

  // recuperar los datos del stream
  Stream<String> get emailStream => _emailController.stream.transform(emailValidator);
  Stream<String> get passwordStream => _passwordController.stream.transform(passwordValidator);
  Stream<String> get nameStream => _nameController.stream.transform(nameValidator);
  Stream<String> get passwordConfirmStream => _passwordConfirmController.stream.transform(passwordValidator)
    .doOnData((String c){
      if (0 != _passwordController.value.compareTo(c)){
        _passwordConfirmController.addError("Las contraseñas no coinciden");
      }
    });
  Stream<String> get phoneStream => _phoneController.stream.transform(phoneValidator);


  Stream<bool> get registerFormValidStream => Rx.combineLatest5(emailStream, passwordStream, nameStream, passwordConfirmStream, phoneStream, (a, b, c, d, e) => true);

  Stream<bool> get formValidStream => Rx.combineLatest2(emailStream, passwordStream, (a, b) => true);



  // insertar valores a los stream
  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changePassword => _passwordController.sink.add;
  Function(String) get changePasswordConfirm => _passwordConfirmController.sink.add;
  Function(String) get changePhone => _phoneController.sink.add;
  Function(String) get changeName => _nameController.sink.add;

  // obtener el ultimo valor de los streams

  String get email    => _emailController.value.toLowerCase();
  String get password => _passwordController.value;
  String get passwordConfirm    => _passwordConfirmController.value;
  String get name => _nameController.value;
  String get phone    => _phoneController.value;


  Future<Map> signIn() async {
    return await service.login(email, password);
  }


  dispose() {
    _emailController?.close();
    _passwordController?.close();
    _passwordConfirmController?.close();
    _nameController?.close();
    _phoneController?.close();
  }


}