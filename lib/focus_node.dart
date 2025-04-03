import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomFocusManager {
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  CustomFocusManager() {
    // Request focus for the email field when the widget is first displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      emailFocusNode.requestFocus();
    });
  }

  void dispose() {
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
  }

  void requestPasswordFocus() {
    passwordFocusNode.requestFocus();
  }
}
