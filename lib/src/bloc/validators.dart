import 'dart:async';

import 'package:app_repatidor_v2/src/utils/utils.dart';

class Validators {

  final emailValidator = StreamTransformer<String, String>.fromHandlers(
    handleData: (email, sink) {
      Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regExp = new RegExp(pattern);
      if (regExp.hasMatch(email)) {
        sink.add(email);
      } else {
        sink.addError('Debe ingresar un Email válido');
      }
    }
  );

  final passwordValidator = StreamTransformer<String, String>.fromHandlers(
    handleData: (password, sink) {
      if (password.length >= 6) {
        sink.add(password);
      } else {
        sink.addError('La contraseña debe contener más de 6 caracteres');
      }
    }
  );

  final requiredValidator = StreamTransformer<String, String>.fromHandlers(
    handleData: (value, sink) {
      if (value.length > 0) {
        sink.add(value);
      } else {
        sink.addError('El campo es requerido');
      }
    }
  );

  final nameValidator = StreamTransformer<String, String>.fromHandlers(
    handleData: (name, sink) {
      if (name.length >= 2) {
        sink.add(name);
      } else {
        sink.addError('El nombre debe contener más de 2 caracteres');
      }
    }
  );

  final phoneValidator = StreamTransformer<String, String>.fromHandlers(
    handleData: (phone, sink) {
      if (phone.length == 8 && isNumber(phone)) {
        sink.add(phone);
      } else {
        sink.addError('Ingrese solo números, no concidere el prefijo');
      }
    }
  );

}