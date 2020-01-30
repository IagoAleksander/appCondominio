import 'dart:async';

import 'package:email_validator/email_validator.dart';

class LoginValidators {
  static String validateEmail(String email, String errorLabel) {
    if (!EmailValidator.validate(email)) {
      return errorLabel;
    }
    return null;
  }

  static String validatePassword(String value, String errorLabel) {
    if (value.length < 6) {
      return errorLabel;
    }
    return null;
  }

  static String confirmPassword(String password, String confirmPassword, String errorLabel) {
    if (password != confirmPassword) {
      return errorLabel;
    }
    return null;
  }

  static String validateNotEmpty(String value, String errorLabel) {
    if (value.isEmpty) {
      return errorLabel;
    }
    return null;
  }

//  validateNotEmpty(String error) =>
//      StreamTransformer<String, String>.fromHandlers(
//          handleData: (String value, EventSink<String> sink) {
//        if (value.trim().isNotEmpty) {
//          sink.add(value);
//        } else {
//          sink.addError(error);
//        }
//      });
}
